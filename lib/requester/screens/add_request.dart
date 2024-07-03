import 'package:boomarang/main.dart';
import 'package:boomarang/misc/custom_stepper.dart';
import 'package:boomarang/misc/tab_index_provider.dart';
import 'package:boomarang/shared/alert_dialog.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Stepper, Step, StepperType;
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddRequestScreen extends StatefulWidget {
  const AddRequestScreen({super.key});

  @override
  State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  final _contactDetailsFormKey = GlobalKey<FormBuilderState>();
  final _requestDetailsFormKey = GlobalKey<FormBuilderState>();
  final _consentDetailsFormKey = GlobalKey<FormBuilderState>();

  List<Widget> children = [];

  String? knowsHolder;

  String? consentFormName;
  String? requestFormName;

  int currentStep = 0;

  bool isUploadingRequestForm = false;
  bool isUploadingConsentForm = false;

  late String id;

  bool isSubmitting = false;

  @override
  void initState() {
    id = const Uuid().v4();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Step> steps = [
      Step(
        title: const Text('Contact Details'),
        isActive: currentStep == 0,
        content: Row(
          children: [
            SizedBox(
              width: 600,
              child: FormBuilder(
                key: _contactDetailsFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Patient",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'subject_first_name',
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
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                        DateFormatInputFormatter(DateFormat('dd/MM/yyyy')),
                      ],
                      valueTransformer: (value) {
                        if (value == null) {
                          return null;
                        }
                        // Parse the date, set to start of the day, and convert to UTC
                        DateTime localDate =
                            DateFormat('dd/MM/yyyy').parse(value, true).toUtc();
                        return DateTime.utc(
                            localDate.year, localDate.month, localDate.day);
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
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 64),
                    Text(
                      "Healthcare Provider",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'holder_email',
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
        isActive: currentStep == 1,
        content: Row(
          children: [
            SizedBox(
              width: 600,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Request Details",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(
                    height: 20,
                  ),
                  FormBuilder(
                    key: _requestDetailsFormKey,
                    child: Column(
                      children: [
                        FormBuilderDropdown(
                          name: 'type',
                          autofocus: false,
                          validator: FormBuilderValidators.required(),
                          onChanged: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: UnderlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Subject Access Request',
                              child: Text('Subject Access Request'),
                            ),
                            DropdownMenuItem(
                              value: 'Occupational Health',
                              child: Text('Occupational Health'),
                            ),
                            DropdownMenuItem(
                              value: 'Private Medical Insurance',
                              child: Text('Private Medical Insurance'),
                            ),
                            DropdownMenuItem(
                              value: 'Police Report',
                              child: Text('Police Report'),
                            ),
                            DropdownMenuItem(
                              value: 'Clinical Trial',
                              child: Text('Clinical Trial'),
                            ),
                            DropdownMenuItem(
                              value: 'Health Assessment',
                              child: Text('Health Assessment'),
                            ),
                            DropdownMenuItem(
                              value: 'DWP UC113',
                              child: Text('DWP UC113'),
                            ),
                            DropdownMenuItem(
                              value: 'Advisory Service',
                              child: Text('Advisory Service'),
                            ),
                            DropdownMenuItem(
                              value: 'DWP PIP',
                              child: Text('DWP PIP'),
                            ),
                            DropdownMenuItem(
                              value: 'Legal Aid',
                              child: Text('Legal Aid'),
                            ),
                            DropdownMenuItem(
                              value: 'Disability Student Allowance',
                              child: Text('Disability Student Allowance'),
                            ),
                            DropdownMenuItem(
                              value: 'Disability Living Allowance',
                              child: Text('Disability Living Allowance'),
                            ),
                            DropdownMenuItem(
                              value: 'MoD - PHCR',
                              child: Text('MoD - PHCR'),
                            ),
                            DropdownMenuItem(
                              value: 'MoD - Veterans',
                              child: Text('MoD - Veterans'),
                            ),
                            DropdownMenuItem(
                              value: 'MoD - CDRM',
                              child: Text('MoD - CDRM'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'request_details',
                          validator: (value) {
                            final formState =
                                _requestDetailsFormKey.currentState;
                            if (value == null || value.isEmpty) {
                              final requestFormRefValue =
                                  formState?.fields['request_form_ref']?.value;
                              if (requestFormRefValue == null ||
                                  requestFormRefValue.isEmpty) {
                                return 'Please provide the request details or upload a request form.';
                              }
                            }
                            return null; // Return null if the validation passed
                          },
                          maxLines: 5,
                          enabled: requestFormName == null,
                          decoration: const InputDecoration(
                            labelText: 'Request Details',
                            hintText:
                                'Please describe the reason for the request, the data required, etc.',
                            helperText:
                                'If you are uploading a request form, leave this blank.',
                            border: UnderlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderField(
                            name: 'request_form_ref',
                            builder: (context) {
                              if (requestFormName == null) {
                                return Row(
                                  children: [
                                    isUploadingRequestForm
                                        ? const Expanded(
                                            child: LinearProgressIndicator())
                                        : TextButton.icon(
                                            onPressed: () async {
                                              setState(() {
                                                isUploadingRequestForm = true;
                                              });

                                              FilePickerResult?
                                                  requestFormFile =
                                                  await FilePicker.platform
                                                      .pickFiles(
                                                type: FileType.custom,
                                                allowedExtensions: ['pdf'],
                                                withData: true,
                                              );

                                              if (requestFormFile == null) {
                                                setState(() {
                                                  isUploadingRequestForm =
                                                      false;
                                                });
                                                return;
                                              }

                                              String? requestFormUrl;
                                              String requestFormFileName =
                                                  requestFormFile
                                                      .files.single.name;

                                              try {
                                                //upload file
                                                await storage
                                                    .ref(
                                                        'requests/$id/request_form/$requestFormFileName')
                                                    .putData(
                                                        requestFormFile.files
                                                            .single.bytes!,
                                                        SettableMetadata(
                                                            contentType:
                                                                'application/pdf'));

                                                requestFormUrl = await storage
                                                    .ref(
                                                        'requests/$id/request_form/$requestFormFileName')
                                                    .getDownloadURL();

                                                _requestDetailsFormKey
                                                    .currentState!
                                                    .fields['request_form_ref']!
                                                    .didChange(requestFormUrl);

                                                requestFormName = await storage
                                                    .ref(
                                                        'requests/$id/request_form/$requestFormFileName')
                                                    .getMetadata()
                                                    .then(
                                                        (value) => value.name);

                                                //clear the request details
                                                _requestDetailsFormKey
                                                    .currentState!
                                                    .fields['request_details']!
                                                    .didChange(null);

                                                setState(() {});
                                              } on Exception catch (e) {
                                                buildErrorAlertDialog(e);
                                              } finally {
                                                setState(() {
                                                  isUploadingRequestForm =
                                                      false;
                                                });
                                              }

                                              setState(() {
                                                isUploadingRequestForm = false;
                                              });
                                            },
                                            icon: const Icon(Icons.upload_file),
                                            label: const Text(
                                                'Select Request Form')),
                                  ],
                                );
                              } else {
                                return Row(
                                  children: [
                                    //success icon
                                    const Icon(Icons.check,
                                        color: Colors.green),
                                    const SizedBox(width: 16),

                                    Text(requestFormName!),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      label: const Text('Delete'),
                                      onPressed: () async {
                                        await storage
                                            .ref(
                                                'requests/$id/request_form/$requestFormName')
                                            .delete()
                                            .catchError((error) {
                                          buildErrorAlertDialog(error);
                                        });
                                        setState(() {
                                          requestFormName = null;
                                        });
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                                  ],
                                );
                              }
                            })
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Text("Consent",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(
                    height: 20,
                  ),
                  FormBuilder(
                    key: _consentDetailsFormKey,
                    child: Column(
                      children: [
                        FormBuilderField(
                          name: 'consent_form_ref',
                          //TODO: validator doesnt work
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                          builder: (context) => Column(
                            children: [
                              if (consentFormName == null)
                                isUploadingConsentForm
                                    ? const LinearProgressIndicator()
                                    : Row(
                                        children: [
                                          TextButton.icon(
                                            onPressed: () async {
                                              setState(() {
                                                isUploadingConsentForm = true;
                                              });

                                              FilePickerResult?
                                                  consentFormFile =
                                                  await FilePicker.platform
                                                      .pickFiles(
                                                type: FileType.custom,
                                                allowedExtensions: ['pdf'],
                                                withData: true,
                                              );

                                              if (consentFormFile == null) {
                                                setState(() {
                                                  isUploadingConsentForm =
                                                      false;
                                                });
                                                return;
                                              }

                                              String consentFormFileName =
                                                  consentFormFile
                                                      .files.single.name;

                                              try {
                                                //upload file
                                                await storage
                                                    .ref(
                                                        'requests/$id/consent_form/$consentFormFileName')
                                                    .putData(
                                                        consentFormFile.files
                                                            .single.bytes!,
                                                        SettableMetadata(
                                                            contentType:
                                                                'application/pdf'));

                                                String consentFormUrl =
                                                    await storage
                                                        .ref(
                                                            'requests/$id/consent_form/$consentFormFileName')
                                                        .getDownloadURL();

                                                _consentDetailsFormKey
                                                    .currentState!
                                                    .fields['consent_form_ref']!
                                                    .didChange(consentFormUrl);

                                                consentFormName = await storage
                                                    .ref(
                                                        'requests/$id/consent_form/$consentFormFileName')
                                                    .getMetadata()
                                                    .then(
                                                        (value) => value.name);

                                                setState(() {});
                                              } on Exception catch (e) {
                                                buildErrorAlertDialog(e);
                                              } finally {
                                                setState(() {
                                                  isUploadingConsentForm =
                                                      false;
                                                });
                                              }

                                              setState(() {
                                                isUploadingConsentForm = false;
                                              });
                                            },
                                            icon: const Icon(Icons.upload_file),
                                            label: const Text(
                                                'Select Consent Form'),
                                          ),
                                        ],
                                      ),
                              if (consentFormName != null)
                                Row(
                                  children: [
                                    const Icon(Icons.check,
                                        color: Colors.green),
                                    const SizedBox(width: 16),
                                    Text(consentFormName!),
                                    const SizedBox(width: 16),
                                    TextButton.icon(
                                      label: const Text('Delete'),
                                      onPressed: () async {
                                        await storage
                                            .ref(
                                                'requests/$id/consent_form/$consentFormName')
                                            .delete()
                                            .catchError((error) {
                                          buildErrorAlertDialog(error);
                                        });
                                        setState(() {
                                          consentFormName = null;
                                        });
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            if (_contactDetailsFormKey.currentState!.saveAndValidate()) {
              setState(() {
                currentStep++;
              });
            }
          } else if (currentStep == 1) {
            if (_consentDetailsFormKey.currentState!.saveAndValidate() &&
                _requestDetailsFormKey.currentState!.saveAndValidate()) {
              //TODO: Extract this widget
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Submit Request'),
                  content: const Text(
                      'Are you sure you want to submit this request?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await submitRequest();
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        context.read<TabIndexProvider>().setTabIndex(1);
                      },
                      child: const Text('Submit'),
                    ),
                  ],
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
      holderEmail:
          _contactDetailsFormKey.currentState!.fields['holder_email']?.value,
      subjectFirstName: _contactDetailsFormKey
          .currentState!.fields['subject_first_name']?.value,
      subjectLastName: _contactDetailsFormKey
          .currentState!.fields['subject_last_name']?.value,
      subjectEmail:
          _contactDetailsFormKey.currentState!.fields['subject_email']?.value,
      subjectDOB: DateFormat('dd/MM/yyyy').tryParse(
          _contactDetailsFormKey.currentState!.fields['subject_dob']?.value ??
              ""),
      subjectEmailVerified: false,
      requesterUserId: auth.currentUser!.uid,
      requesterOrgName: null,
      requestEmail: auth.currentUser!.email,
      holderUserId: null,
      holderOrgId: null,
      dateCreated: DateTime.now(),
      consentVerified: false,
      requestStatus: 'awaiting_response',
      requestType: _requestDetailsFormKey.currentState!.fields['type']?.value,
      requestDetails:
          _requestDetailsFormKey.currentState!.fields['request_details']?.value,
      requestFormRef: requestFormName == null
          ? null
          : _requestDetailsFormKey
              .currentState!.fields['request_form_ref']?.value,
      consentFormRef: consentFormName == null
          ? null
          : _consentDetailsFormKey
              .currentState!.fields['consent_form_ref']?.value,
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
