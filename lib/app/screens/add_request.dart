import 'package:boomarang/app/screens/dialogs/submit_request.dart';
import 'package:boomarang/main.dart';
import 'package:boomarang/misc/custom_stepper.dart';
import 'package:boomarang_shared/data/request_types.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Stepper, Step, StepperType;
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddRequestScreen extends StatefulWidget {
  const AddRequestScreen({
    super.key,
    this.request,
  });

  final BoomarangRequest? request;

  @override
  State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  final _subjectDetailsFormKey = GlobalKey<FormBuilderState>();
  final _recipientDetailsFormKey = GlobalKey<FormBuilderState>();
  final _requestDetailsFormKey = GlobalKey<FormBuilderState>();

  int currentStep = 0;

  late String id;

  bool isSubmitting = false;

  BoomarangRequest? request;

  @override
  void initState() {
    request = widget.request;
    id = request?.id ?? const Uuid().v4();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Step> steps = [
      Step(
        title: const Text('Subject'),
        isActive: currentStep == 0,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 600,
              child: FormBuilder(
                key: _subjectDetailsFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Subject",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    //who the request is about. this can be you or someone else
                    Text(
                      "Who is the request about? This can be you or someone else.",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 32),
                    FormBuilderTextField(
                      name: 'subject_first_name',
                      enabled: request?.subjectFirstName == null,
                      initialValue: request?.subjectFirstName ??
                          (kDebugMode ? "Dave" : null),
                      autofocus: true,
                      validator: FormBuilderValidators.required(),
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'subject_last_name',
                      enabled: request?.subjectLastName == null,
                      initialValue: request?.subjectLastName ??
                          (kDebugMode ? "Smith" : null),
                      validator: FormBuilderValidators.required(),
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    //subject dob
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'subject_dob',
                      initialValue: kDebugMode ? "01/01/2000" : null,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                        DateFormatInputFormatter(DateFormat('dd/MM/yyyy')),
                      ],
                      valueTransformer: (value) {
                        if (value == null) {
                          return null;
                        }
                        // Parse the date, set to start of the day, and convert to UTC
                        DateTime localDate =
                            DateFormat('dd/MM/yyyy').parse(value);
                        DateTime localMidnight = DateTime.utc(
                            localDate.year, localDate.month, localDate.day);

                        DateTime utcDate = localMidnight.toUtc();
                        return utcDate;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        hintText: 'dd/mm/yyyy',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    //subject email
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'subject_email',
                      initialValue:
                          kDebugMode ? "georgeleidig@icloud.com" : null,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      Step(
        title: const Text("Recipient"),
        isActive: currentStep == 1,
        content: Row(
          children: [
            SizedBox(
              width: 600,
              child: FormBuilder(
                key: _recipientDetailsFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recipient",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    //who are you sending the request to?
                    Text(
                      "Who are you sending the request to? e.g. a doctor, a hospital, etc.",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 32),
                    FormBuilderTextField(
                      name: 'recipient_email',
                      initialValue: request?.recipientEmail ??
                          (kDebugMode ? "ed@doctors.com" : null),
                      enabled: request?.recipientEmail == null,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        helperText:
                            'We will send the request to this email address',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Request'),
        isActive: currentStep == 2,
        content: FormBuilder(
          key: _requestDetailsFormKey,
          child: Row(
            children: [
              SizedBox(
                width: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Request",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    //what type of request are you making?
                    Text(
                      "What type of request are you making?",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Column(
                      children: [
                        FormBuilderDropdown(
                          name: 'type',
                          autofocus: false,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: FormBuilderValidators.required(
                            errorText: 'Please select a request type',
                          ),
                          onChanged: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            helperText: "Select the type of request",
                            border: OutlineInputBorder(),
                          ),
                          items: requestTypes
                              .map((e) => DropdownMenuItem(
                                    value: e.id,
                                    child: Text(e.name),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 32),
                        FormBuilderTextField(
                          name: 'additional_details',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Additional details',
                            hintText:
                                'Please provide any additional details that may be relevant to your request',
                            helperText: '',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      body: Stepper(
        physics: const NeverScrollableScrollPhysics(),
        currentStep: currentStep,
        type: StepperType.horizontal,
        onStepTapped: !kDebugMode
            ? null
            : (step) {
                setState(() {
                  currentStep = step;
                });
              },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() {
              currentStep--;
            });
          }
        },
        onStepContinue: () async {
          if (currentStep == 0) {
            if (_subjectDetailsFormKey.currentState!.saveAndValidate()) {
              setState(() {
                currentStep++;
              });
            }
          } else if (currentStep == 1) {
            if (_recipientDetailsFormKey.currentState!.saveAndValidate()) {
              setState(() {
                currentStep++;
              });
            }
          } else if (currentStep == 2) {
            if (_requestDetailsFormKey.currentState!.saveAndValidate()) {
              showDialog(
                context: context,
                builder: (context) => SubmitRequestDialog(
                  submitRequest: submitRequest,
                ),
              );
            }
          }
        },
        steps: steps,
      ),
    );
  }

  Future<void> submitRequest() async {
    BoomarangRequest newRequest = BoomarangRequest(
      id: id,
      recipientEmail: _recipientDetailsFormKey
          .currentState!.fields['recipient_email']?.value,
      subjectFirstName: _subjectDetailsFormKey
          .currentState!.fields['subject_first_name']?.value,
      subjectLastName: _subjectDetailsFormKey
          .currentState!.fields['subject_last_name']?.value,
      subjectEmail:
          _subjectDetailsFormKey.currentState!.fields['subject_email']?.value,
      subjectDOB: DateFormat('dd/MM/yyyy').tryParse(
          _subjectDetailsFormKey.currentState!.fields['subject_dob']?.value ??
              "",
          true),
      subjectEmailVerified: false,
      senderUserId: auth.currentUser!.uid,
      recipientUserID: null,
      dateCreated: DateTime.now(),
      consentVerified: false,
      requestStatus: 'awaiting_response',
      requestType: _requestDetailsFormKey.currentState!.fields['type']?.value,
      requestDetails:
          _requestDetailsFormKey.currentState!.fields['request_details']?.value,
    );

    return await firestore
        .collection('requests')
        .doc(id)
        .set(newRequest.toMap());
  }
}

class DateFormatInputFormatter extends TextInputFormatter {
  DateFormatInputFormatter(this.format);

  final DateFormat format;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();
    if (newTextLength >= 3) {
      newText.write('${newValue.text.substring(0, usedSubstringIndex = 2)}/');
      if (newValue.selection.end >= 2) selectionIndex++;
    }
    if (newTextLength >= 5) {
      newText.write('${newValue.text.substring(2, usedSubstringIndex = 4)}/');
      if (newValue.selection.end >= 4) selectionIndex++;
    }
    if (newTextLength >= 9) {
      newText.write(newValue.text.substring(4, usedSubstringIndex = 8));
      if (newValue.selection.end >= 8) selectionIndex++;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
