import 'package:boomarang/main.dart';
import 'package:boomarang/misc/alert_dialog.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddRequestScreen extends StatefulWidget {
  const AddRequestScreen({super.key, this.request});

  final BoomarangRequest? request;

  @override
  State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  final _requestFormKey = GlobalKey<FormBuilderState>();

  List<Widget> children = [];

  bool? hasConsent;
  String? knowsHolder;
  bool? isRequester;

  String? consentFormName;
  String? requestFormName;

  int currentStep = 0;

  BoomarangRequest? get request => widget.request;

  bool isUploadingRequestForm = false;
  bool isUploadingConsentForm = false;

  late String id;

  @override
  void initState() {
    id = request?.id ?? const Uuid().v4();
    hasConsent = request?.hasConsent;
    storage.ref('requests/$id/request_form').list().then((value) {
      if (value.items.isEmpty) {
        return;
      }
      setState(() {
        requestFormName = value.items.map((e) => e.name).first;
      });
    });
    storage.ref('requests/$id/consent_form').list().then((value) {
      if (value.items.isEmpty) {
        return;
      }
      setState(() {
        consentFormName = value.items.map((e) => e.name).first;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Step> steps = [
      Step(
        title: const Text('Request'),
        content: Column(
          children: [
            //are you the requester or is it on behalf of someone else. if its on behalf of someone else, you will need to provide their email
            FormBuilderRadioGroup(
              name: 'is_requester',
              initialValue: request?.isRequester,
              orientation: OptionsOrientation.vertical,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  isRequester = value as bool;
                });
              },
              options: const [
                FormBuilderFieldOption(
                  value: true,
                  child: Text('I am the requester'),
                ),
                FormBuilderFieldOption(
                  value: false,
                  child: Text(
                      'I am submitting a request on behalf of someone else'),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            if (isRequester == false) ...[
              FormBuilderTextField(
                name: 'requester_email',
                decoration: const InputDecoration(
                  labelText: 'Email',
                  helperText:
                      'A link to the finished report will be sent to this email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],

            FormBuilderDropdown(
              name: 'type',
              autofocus: false,
              onChanged: (value) {
                FocusScope.of(context).nextFocus();
              },
              decoration: const InputDecoration(
                labelText: 'Type',
                // helperText: 'Please select the type of request',
                border: OutlineInputBorder(),
              ),
              initialValue: request?.requestType,
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
              maxLines: 5,
              initialValue: request?.requestDetails,
              decoration: const InputDecoration(
                labelText: 'Request Details',
                hintText: 'Please provide as much detail as possible',
                helperText:
                    'If you are uploading a request form, you can leave this blank.',
                border: OutlineInputBorder(),
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
                            ? const Expanded(child: LinearProgressIndicator())
                            : TextButton.icon(
                                onPressed: () async {
                                  setState(() {
                                    isUploadingRequestForm = true;
                                  });

                                  FilePickerResult? requestFormFile =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf'],
                                  );

                                  if (requestFormFile == null) {
                                    setState(() {
                                      isUploadingRequestForm = false;
                                    });
                                    return;
                                  }

                                  String? requestFormUrl;
                                  String requestFormFileName =
                                      requestFormFile.files.single.name;

                                  try {
                                    //upload file
                                    await storage
                                        .ref(
                                            'requests/$id/request_form/$requestFormFileName')
                                        .putData(
                                            requestFormFile.files.single.bytes!,
                                            SettableMetadata(
                                                contentType:
                                                    'application/pdf'));

                                    requestFormUrl = await storage
                                        .ref(
                                            'requests/$id/request_form/$requestFormFileName')
                                        .getDownloadURL();

                                    _requestFormKey.currentState!
                                        .fields['request_form_ref']!
                                        .didChange(requestFormUrl);

                                    requestFormName = await storage
                                        .ref(
                                            'requests/$id/request_form/$requestFormFileName')
                                        .getMetadata()
                                        .then((value) => value.name);

                                    setState(() {});
                                  } on Exception catch (e) {
                                    buildErrorAlertDialog(e);
                                  } finally {
                                    setState(() {
                                      isUploadingRequestForm = false;
                                    });
                                  }

                                  setState(() {
                                    isUploadingRequestForm = false;
                                  });
                                },
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Select Request Form')),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        //success icon
                        const Icon(Icons.check, color: Colors.green),
                        const SizedBox(width: 16),

                        Text(requestFormName!),
                        const SizedBox(width: 16),
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
      Step(
        title: const Text('Authoriser'),
        content: Column(
          children: [
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'authoriser_first_name',
              initialValue: request?.authoriserFirstName,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'authoriser_last_name',
              initialValue: request?.authoriserLastName,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            //authoriser dob
            const SizedBox(height: 16),
            FormBuilderTextField(
                name: 'authoriser_dob',
                initialValue: request?.authoriserDOB != null
                    ? DateFormat('dd/MM/yyyy').format(request!.authoriserDOB!)
                    : null,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                  DateFormatInputFormatter(DateFormat('dd/MM/yyyy')),
                ],
                valueTransformer: (value) {
                  if (value == null) {
                    return null;
                  }
                  return DateFormat('dd/MM/yyyy').parse(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: 'dd/mm/yyyy',
                  border: OutlineInputBorder(),
                )),
            //authoriser email
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'authoriser_email',
              initialValue: request?.authoriserEmail,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Consent'),
        content: Column(
          children: [
            FormBuilderRadioGroup(
              name: 'has_consent',
              initialValue: request?.hasConsent,
              orientation: OptionsOrientation.vertical,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  hasConsent = value as bool;
                });
              },
              options: const [
                FormBuilderFieldOption(
                    value: true, child: Text('I already have consent')),
                FormBuilderFieldOption(
                  value: false,
                  child: Text('I need to consent the authoriser'),
                ),
              ],
            ),
            if (hasConsent == true)
              FormBuilderField(
                name: 'consent_form_ref',
                builder: (context) => Column(
                  children: [
                    const SizedBox(height: 16),
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

                                    FilePickerResult? consentFormFile =
                                        await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['pdf'],
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
                                      //upload file
                                      await storage
                                          .ref(
                                              'requests/$id/consent_form/$consentFormFileName')
                                          .putData(
                                              consentFormFile
                                                  .files.single.bytes!,
                                              SettableMetadata(
                                                  contentType:
                                                      'application/pdf'));

                                      String consentFormUrl = await storage
                                          .ref(
                                              'requests/$id/consent_form/$consentFormFileName')
                                          .getDownloadURL();

                                      _requestFormKey.currentState!
                                          .fields['consent_form_ref']!
                                          .didChange(consentFormUrl);

                                      consentFormName = await storage
                                          .ref(
                                              'requests/$id/consent_form/$consentFormFileName')
                                          .getMetadata()
                                          .then((value) => value.name);

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
                                  },
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Select Consent Form'),
                                ),
                              ],
                            ),
                    if (consentFormName != null)
                      Row(
                        children: [
                          Text(consentFormName!),
                          const SizedBox(width: 16),
                          IconButton(
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
            if (hasConsent == false)
              Column(
                children: [
                  const SizedBox(height: 16),
                  FormBuilderDropdown(
                      name: 'consent_template',
                      decoration: const InputDecoration(
                        labelText: 'Consent Template',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: request?.consentTemplateId ?? '1',
                      items: const [
                        DropdownMenuItem(
                          value: '1',
                          child: Text('Consent Template 1 (recommended)'),
                        ),
                        DropdownMenuItem(
                          value: '2',
                          child: Text('Consent Template 2'),
                        ),
                        DropdownMenuItem(
                          value: '3',
                          child: Text('Consent Template 3'),
                        ),
                      ])
                ],
              ),
          ],
        ),
      ),
      Step(
        title: const Text('Holder'),
        content: Column(
          children: [
            FormBuilderRadioGroup(
              name: 'knows_holder',
              orientation: OptionsOrientation.vertical,
              initialValue: request?.knowsHolder,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  knowsHolder = value;
                });
              },
              options: const [
                FormBuilderFieldOption(
                  value: 'yes',
                  child: Text('I know the holder email'),
                ),
                FormBuilderFieldOption(
                  value: 'no',
                  child: Text(
                      'I do not know the holder (authoriser will be asked to complete)'),
                ),
                FormBuilderFieldOption(
                  value: 'self',
                  child: Text('I am the holder'),
                ),
                //i am the holder
              ],
            ),
            if (knowsHolder == 'yes')
              Column(
                children: [
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'holder_email',
                    decoration: const InputDecoration(
                      labelText: 'Holder Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Request'),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              if (_requestFormKey.currentState!.saveAndValidate()) {
                saveRequest(submit: false);
                navigatorKey.currentState!.pop();
              }
            },
            label: const Text("Save Draft"),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: FormBuilder(
        key: _requestFormKey,
        child: Stepper(
          currentStep: currentStep,
          type: StepperType.horizontal,
          controlsBuilder: (context, controlsDetails) {
            return Column(
              children: [
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        if (currentStep > 0) {
                          setState(() {
                            currentStep--;
                          });
                        }
                      },
                      child: const Text('Back'),
                    ),
                    if (currentStep != steps.length - 1)
                      Row(
                        children: [
                          const SizedBox(
                            width: 16,
                          ),
                          TextButton(
                            onPressed: () {
                              if (_requestFormKey.currentState!
                                  .saveAndValidate()) {
                                if (currentStep < steps.length - 1) {
                                  setState(() {
                                    currentStep++;
                                  });
                                }
                              }
                            },
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    if (currentStep == steps.length - 1)
                      Row(
                        children: [
                          const SizedBox(
                            width: 16,
                          ),
                          TextButton(
                            onPressed: () async {
                              if (_requestFormKey.currentState!
                                  .saveAndValidate()) {
                                await saveRequest(
                                  submit: true,
                                );
                                navigatorKey.currentState!.pop();
                              }
                            },
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            );
          },
          onStepTapped: (value) {
            setState(() {
              currentStep = value;
            });
          },
          onStepCancel: () {
            if (currentStep > 0) {
              setState(() {
                currentStep--;
              });
            }
          },
          onStepContinue: () {
            if (_requestFormKey.currentState!.saveAndValidate()) {
              if (currentStep < steps.length - 1) {
                setState(() {
                  currentStep++;
                });
              }
            }
          },
          steps: steps,
        ),
      ),
    );
  }

  Future<void> saveRequest({required bool submit}) async {
    BoomarangRequest newRequest = BoomarangRequest(
      id: id,
      creatorId: request?.creatorId ?? auth.currentUser!.uid,
      isRequester: request?.isRequester ??
          _requestFormKey.currentState!.fields['is_requester']?.value,
      creatorOrgId: request?.creatorOrgId,
      isSubmitted: submit,
      knowsHolder: _requestFormKey.currentState!.fields['knows_holder']?.value,
      hasConsent: _requestFormKey.currentState!.fields['has_consent']?.value,
      authoriserFirstName:
          _requestFormKey.currentState!.fields['authoriser_first_name']?.value,
      authoriserLastName:
          _requestFormKey.currentState!.fields['authoriser_last_name']?.value,
      authoriserEmail:
          _requestFormKey.currentState!.fields['authoriser_email']?.value,
      authoriserDOB: DateFormat('dd/MM/yyyy').tryParse(
          _requestFormKey.currentState!.fields['authoriser_dob']?.value ?? ""),
      authoriserEmailVerified: false,
      // authoriserPhoneNumber: _requestFormKey.currentState!.fields['authoriser_phone_number']!.value as String,
      requesterUserId: null,
      requesterOrgName: null,
      requestEmail:
          _requestFormKey.currentState!.fields['request_email']?.value,
      holderUserId: knowsHolder == 'self' ? auth.currentUser!.uid : null,
      holderOrgId: null,
      dateCreated: DateTime.now(),
      dateUpdated: DateTime.now(),
      dateSubmitted: DateTime.now(),
      consentStatus: hasConsent == true
          ? 'consent_received_from_requester'
          : 'consent_pending',
      consentVerified: false,
      paymentStatus: 'payment_pending',
      requestStatus: 'request_pending',
      requestType: _requestFormKey.currentState!.fields['type']?.value,
      requestDetails:
          _requestFormKey.currentState!.fields['request_details']?.value,
      requestFormRef: requestFormName == null
          ? null
          : _requestFormKey.currentState!.fields['request_form_ref']?.value,
      consentTemplateId: hasConsent == false
          ? _requestFormKey.currentState!.fields['consent_template']?.value
          : null,
      consentFormRef: consentFormName == null
          ? null
          : _requestFormKey.currentState!.fields['consent_form_ref']?.value,
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
