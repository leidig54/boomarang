import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Stepper, Step, StepperType;
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CreateBoomarangScreen extends StatefulWidget {
  const CreateBoomarangScreen({
    super.key,
    this.request,
  });

  final BoomarangRequest? request;

  @override
  State<CreateBoomarangScreen> createState() => _CreateBoomarangScreenState();
}

class _CreateBoomarangScreenState extends State<CreateBoomarangScreen> {
  final _requestDetailsFormKey = GlobalKey<FormBuilderState>();

  int currentStep = 0;
  final ScrollController _scrollController = ScrollController();
  late String id;

  bool isSubmitting = false;

  BoomarangRequest? request;

  @override
  void initState() {
    super.initState();
    request = widget.request;
    id = request?.id ?? const Uuid().v4();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 1000),
        child: Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: FormBuilder(
              key: _requestDetailsFormKey,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView(
                  controller: _scrollController,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 600,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
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
                              const SizedBox(height: 16),
                              FormBuilderTextField(
                                name: 'subject_first_name',
                                enabled: request?.subjectFirstName == null,
                                initialValue: request?.subjectFirstName ??
                                    (kDebugMode ? "Dave" : null),
                                autofocus: true,
                                validator: FormBuilderValidators.required(),
                                decoration: const InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(),
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
                                  border: OutlineInputBorder(),
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
                                  DateFormatInputFormatter(
                                      DateFormat('dd/MM/yyyy')),
                                ],
                                valueTransformer: (value) {
                                  if (value == null) {
                                    return null;
                                  }
                                  // Parse the date, set to start of the day, and convert to UTC
                                  DateTime localDate =
                                      DateFormat('dd/MM/yyyy').parse(value);
                                  DateTime localMidnight = DateTime.utc(
                                      localDate.year,
                                      localDate.month,
                                      localDate.day);

                                  DateTime utcDate = localMidnight.toUtc();
                                  return utcDate;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Date of Birth',
                                  hintText: 'dd/mm/yyyy',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              //subject email
                              const SizedBox(height: 16),
                              FormBuilderTextField(
                                name: 'subject_email',
                                initialValue: kDebugMode
                                    ? "georgeleidig@icloud.com"
                                    : null,
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.email(),
                                ]),
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                "Recipient",
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.end,
                              ),
                              const SizedBox(height: 4),
                              //who are you sending the request to?
                              Text(
                                "Who are you sending the request to?",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: 16),
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
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                "Request Details",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              //what type of request are you making?
                              Text(
                                "What are you asking for?",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              FormBuilderTextField(
                                name: 'request_details',
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Please provide any additional details that may be relevant to your request',
                                  helperText: '',
                                  border: OutlineInputBorder(),
                                  alignLabelWithHint: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: const Text("Submit"),
                          onPressed: () async {
                            if (_requestDetailsFormKey.currentState!
                                .saveAndValidate()) {
                              BoomarangRequest newRequest = BoomarangRequest(
                                id: id,
                                recipientEmail: _requestDetailsFormKey
                                    .currentState!
                                    .fields['recipient_email']
                                    ?.value,
                                subjectFirstName: _requestDetailsFormKey
                                    .currentState!
                                    .fields['subject_first_name']
                                    ?.value,
                                subjectLastName: _requestDetailsFormKey
                                    .currentState!
                                    .fields['subject_last_name']
                                    ?.value,
                                subjectEmail: _requestDetailsFormKey
                                    .currentState!
                                    .fields['subject_email']
                                    ?.value,
                                subjectDOB: DateFormat('dd/MM/yyyy').tryParse(
                                    _requestDetailsFormKey.currentState!
                                            .fields['subject_dob']?.value ??
                                        "",
                                    true),
                                subjectEmailVerified: false,
                                senderUserId: auth.currentUser!.uid,
                                recipientUserID: null,
                                dateCreated: DateTime.now(),
                                consentVerified: false,
                                requestStatus: 'awaiting_response',
                                requestDescription: _requestDetailsFormKey
                                    .currentState!
                                    .fields['requestDescription']
                                    ?.value,
                              );

                              await firestore
                                  .collection('requests')
                                  .doc(id)
                                  .set(newRequest.toMap());
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
