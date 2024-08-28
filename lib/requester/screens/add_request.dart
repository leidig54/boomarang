import 'package:boomarang/main.dart';
import 'package:boomarang/misc/custom_stepper.dart';
import 'package:boomarang/requester/screens/dialogs/submit_request.dart';
import 'package:boomarang/shared/alert_dialog.dart';
import 'package:boomarang_shared/data/request_types.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final _holderDetailsFormKey = GlobalKey<FormBuilderState>();
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
  bool noConsentForm = false;
  bool isUsingBoomarangConsent = false;

  BoomarangRequest? request;

  bool hasFoundHolder = false;

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
        title: const Text('Subject Details'),
        isActive: currentStep == 0,
        content: Row(
          children: [
            SizedBox(
              width: 600,
              child: FormBuilder(
                key: _subjectDetailsFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
        title: const Text("Holder Details"),
        isActive: currentStep == 1,
        content: Row(
          children: [
            SizedBox(
              width: 600,
              child: FormBuilder(
                key: _holderDetailsFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Holder",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    //who are you sending the request to?
                    Text(
                      "Who are you sending the request to? e.g. a doctor, a hospital, etc.",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'holder_email',
                      initialValue: request?.holderEmail ??
                          (kDebugMode ? "ed@doctors.com" : null),
                      enabled: request?.holderEmail == null,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                      onChanged: (value) async {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            hasFoundHolder = false;
                          });
                          return;
                        }

                        await firestore
                            .collection('users')
                            .where('email', isEqualTo: value.trim())
                            .where('userType', isEqualTo: 'holder')
                            .get()
                            .then((value) {
                          if (value.docs.isNotEmpty) {
                            setState(() {
                              hasFoundHolder = true;
                            });
                          } else {
                            setState(() {
                              hasFoundHolder = false;
                            });
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        helperText: hasFoundHolder
                            ? 'User found on Boomarang'
                            : 'We will send the request to this email address',
                        helperStyle: TextStyle(
                          color: hasFoundHolder
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        border: const UnderlineInputBorder(),
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
                    Text("Request Details",
                        style: Theme.of(context).textTheme.titleLarge),
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
                          name: 'request_details',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderField(
                            name: 'request_form_ref',
                            builder: (formBuilderState) {
                              if (requestFormName == null) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: const Text('Upload Request Form'),
                                      enabled:
                                          isUploadingRequestForm ? false : true,
                                      leading: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: isUploadingRequestForm
                                            ? const CircularProgressIndicator()
                                            : Icon(
                                                isUploadingRequestForm
                                                    ? Icons.upload_file
                                                    : Icons.upload_file,
                                                color: isUploadingRequestForm
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : null,
                                              ),
                                      ),
                                      onTap: isUploadingRequestForm
                                          ? null
                                          : () async {
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

                                              String requestFormFileName =
                                                  requestFormFile
                                                      .files.single.name;

                                              try {
                                                await storage
                                                    .ref(
                                                        'requests/$id/request_form/$requestFormFileName')
                                                    .putData(
                                                        requestFormFile.files
                                                            .single.bytes!,
                                                        SettableMetadata(
                                                            contentType:
                                                                'application/pdf'));

                                                String requestFormUrl =
                                                    await storage
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
                                    ),
                                    //error message
                                    Text(
                                      formBuilderState.errorText ?? '',
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error),
                                    ),
                                  ],
                                );
                              } else {
                                return ListTile(
                                  title: Text(requestFormName!),
                                  subtitle:
                                      const Text('Form successfully uploaded'),
                                  leading: Icon(Icons.check_box,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
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
                                  ),
                                );
                              }
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Consent'),
        isActive: currentStep == 3,
        content: FormBuilder(
          key: _consentDetailsFormKey,
          child: Row(
            children: [
              SizedBox(
                width: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Consent",
                        style: Theme.of(context).textTheme.titleLarge),
                    //if you require consent to process or use this data from the subject, please upload your consent form here
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      "If you require consent to process or use this data from the subject, please upload your consent form here.",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    FormBuilderField(
                      name: 'consent_form_ref',
                      autovalidateMode: AutovalidateMode.disabled,
                      validator: (value) {
                        print('consent form ref validator');
                        final formState = _consentDetailsFormKey.currentState;
                        print(noConsentForm);
                        if (noConsentForm) {
                          print('no consent form');
                          return null;
                        }
                        if (value == null) {
                          final consentFormRefValue =
                              formState?.fields['consent_form_ref']?.value;
                          if ((consentFormRefValue == null ||
                                  consentFormRefValue.isEmpty) &&
                              !noConsentForm) {
                            return 'Please upload a consent form or select "No consent required"';
                          }
                        }
                        return null; // Return null if the validation passed
                      },
                      builder: (formBuilderState) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (consentFormName == null)
                            ListTile(
                                title: const Text("Upload consent form"),
                                leading: isUploadingConsentForm
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator())
                                    : const Icon(Icons.upload_file),
                                subtitle: const Text(
                                    'The subject will be asked to complete this form'),
                                enabled: noConsentForm || isUploadingConsentForm
                                    ? false
                                    : true,
                                onTap: noConsentForm
                                    ? null
                                    : () async {
                                        setState(() {
                                          isUploadingConsentForm = true;
                                        });

                                        FilePickerResult? consentFormFile =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf'],
                                          withData: true,
                                        );

                                        if (consentFormFile == null) {
                                          setState(() {
                                            isUploadingConsentForm = false;
                                          });
                                          return;
                                        }

                                        String consentFormFileName =
                                            consentFormFile.files.single.name;

                                        try {
                                          await storage
                                              .ref(
                                                  'requests/$id/consent_form/$consentFormFileName')
                                              .putData(
                                                  consentFormFile
                                                      .files.single.bytes!,
                                                  SettableMetadata(
                                                      contentType:
                                                          'application/pdf'));

                                          await storage
                                              .ref(
                                                  'requests/$id/consent_form/$consentFormFileName')
                                              .getDownloadURL()
                                              .then((consentFormUrl) {
                                            _consentDetailsFormKey.currentState!
                                                .fields['consent_form_ref']!
                                                .didChange(consentFormUrl);
                                          });

                                          await storage
                                              .ref(
                                                  'requests/$id/consent_form/$consentFormFileName')
                                              .getMetadata()
                                              .then((value) {
                                            consentFormName = value.name;
                                          });

                                          setState(() {});
                                        } on Exception catch (e) {
                                          buildErrorAlertDialog(e);
                                        } finally {
                                          setState(() {
                                            isUploadingConsentForm = false;
                                          });
                                        }

                                        setState(() {
                                          isUploadingConsentForm = false;
                                        });
                                      }),
                          if (consentFormName != null)
                            ListTile(
                              subtitle:
                                  const Text("Form successfully uploaded"),
                              leading: Icon(Icons.check_box,
                                  color: Theme.of(context).colorScheme.primary),
                              title: Text(consentFormName!),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                ),
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
                                    _consentDetailsFormKey.currentState!
                                        .fields['consent_form_ref']!
                                        .didChange(null);
                                  });
                                },
                              ),
                            ),
                          if (formBuilderState.errorText != null)
                            Text(
                              formBuilderState.errorText!,
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error),
                            ),
                        ],
                      ),
                    ),
                    FormBuilderField(
                      name: 'has_consent_form',
                      builder: (formBuilderState) {
                        return ListTile(
                            leading: Icon(
                              noConsentForm
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: noConsentForm
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            enabled: !isUploadingConsentForm &&
                                consentFormName == null,
                            title: const Text(
                              'No consent required',
                            ),
                            subtitle: const Text(
                              'The holder may reject this request',
                            ),
                            onTap: () {
                              setState(() {
                                noConsentForm = !noConsentForm;
                              });
                              if (noConsentForm) {
                                _consentDetailsFormKey.currentState!.validate();
                              }
                            });
                      },
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
            if (_holderDetailsFormKey.currentState!.saveAndValidate()) {
              setState(() {
                currentStep++;
              });
            }
          } else if (currentStep == 2) {
            if (_requestDetailsFormKey.currentState!.saveAndValidate()) {
              setState(() {
                currentStep++;
              });
            }
          } else if (currentStep == 3) {
            if (_consentDetailsFormKey.currentState!.saveAndValidate()) {
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
      holderEmail:
          _subjectDetailsFormKey.currentState!.fields['holder_email']?.value,
      subjectFirstName: _subjectDetailsFormKey
          .currentState!.fields['subject_first_name']?.value,
      subjectLastName: _subjectDetailsFormKey
          .currentState!.fields['subject_last_name']?.value,
      subjectEmail:
          _subjectDetailsFormKey.currentState!.fields['subject_email']?.value,
      subjectDOB: DateFormat('dd/MM/yyyy').tryParse(
          _subjectDetailsFormKey.currentState!.fields['subject_dob']?.value ??
              ""),
      subjectEmailVerified: false,
      requesterUserId: auth.currentUser!.uid,
      holderUserId: null,
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
          : _requestDetailsFormKey
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
