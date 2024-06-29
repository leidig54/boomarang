import 'package:boomarang/main.dart';
import 'package:boomarang/methods/generate_report.dart';
import 'package:boomarang/misc/alert_dialog.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:boomarang_shared/models/response.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewRequestScreen extends StatefulWidget {
  const ViewRequestScreen({
    super.key,
    required this.request,
  });

  final BoomarangRequest request;

  @override
  State<ViewRequestScreen> createState() => _ViewRequestScreenState();
}

class _ViewRequestScreenState extends State<ViewRequestScreen> {
  final _consultationsFormKey = GlobalKey<FormBuilderState>();

  BoomarangRequest get request => widget.request;
  BoomarangResponse? response;

  int _currentStep = 0;
  bool isGeneratingReport = false;
  QuillController reportQuillController = QuillController.basic();

  String? consultationFormName;
  String? consultationFormRef;

  late String id;

  bool isUploadingConsultations = false;

  @override
  void initState() {
    id = request.id;
    firestore.collection('responses').doc(id).get().then((value) {
      if (value.exists) {
        response = BoomarangResponse.fromMap(value.data()!);
        reportQuillController.document = Document.fromJson(response!.report);
      }
    });
    storage.ref('consultations/$id/consultation_form').list().then((value) {
      if (value.items.isNotEmpty) {
        setState(() {
          consultationFormName = value.items.first.name;
        });
        value.items.first.getDownloadURL().then((value) {
          setState(() {
            consultationFormRef = value;
          });
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Step> steps = [
      Step(
        title: const Text("Authoriser"),
        isActive: _currentStep == 0,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichText(
              text: TextSpan(
                text: 'Name: ',
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                      text:
                          '${request.authoriserFirstName} ${request.authoriserLastName}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black87))
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Date of Birth: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                          text: request.formattedAuthoriserDob,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87))
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                //separator
                Container(
                  height: 16,
                  width: 1,
                  color: Colors.black26,
                ),
                const SizedBox(width: 8),
                //dob verified
                RichText(
                  text: TextSpan(
                    text: 'DOB Verified: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                          text: request.authoriserDOBVerified == true
                              ? 'Yes'
                              : 'No',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87))
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  request.authoriserDOBVerified == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: request.authoriserDOBVerified == true
                      ? Colors.green
                      : Colors.red,
                  size: 16,
                )
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Email: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                          text: request.authoriserEmail,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87))
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                //separator
                Container(
                  height: 16,
                  width: 1,
                  color: Colors.black26,
                ),
                const SizedBox(width: 8),
                //email verified
                RichText(
                  text: TextSpan(
                    text: 'Email Verified: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                          text: request.authoriserEmailVerified == true
                              ? 'Yes'
                              : 'No',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87))
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  request.authoriserEmailVerified == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: request.authoriserEmailVerified == true
                      ? Colors.green
                      : Colors.red,
                  size: 16,
                )
              ],
            ),
          ],
        ),
      ),
      Step(
        title: const Text("Consent"),
        isActive: _currentStep == 1,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //consent status
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Status: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                          text: request.formattedConsentStatus,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87))
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                //separator
                Container(
                  height: 16,
                  width: 1,
                  color: Colors.black26,
                ),
                const SizedBox(width: 8),
                //consent verified
                RichText(
                  text: TextSpan(
                    text: 'Verified: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                          text: request.consentVerified == true ? 'Yes' : 'No',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87))
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  request.consentVerified == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: request.consentVerified == true
                      ? Colors.green
                      : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                //separator
                Container(
                  height: 16,
                  width: 1,
                  color: Colors.black26,
                ),
                const SizedBox(width: 8),
              ],
            ),
            //show file
            if (request.consentFormRef != null) ...[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: SfPdfViewer.network(request.consentFormRef!),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  launchUrl(Uri.parse(request.consentFormRef!));
                },
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
            ]
          ],
        ),
      ),
      Step(
        title: const Text("Request"),
        isActive: _currentStep == 2,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //type
            RichText(
              text: TextSpan(
                text: 'Type: ',
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                      text: request.requestType,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black87))
                ],
              ),
            ),
            const SizedBox(height: 4),
            //Request Details
            if (request.requestDetails != null)
              RichText(
                text: TextSpan(
                  text: 'Details: \n',
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(
                        text: request.requestDetails,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.black87))
                  ],
                ),
              ),
            if (request.requestFormRef != null) ...[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: SfPdfViewer.network(request.requestFormRef!),
              ),
            ],
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                launchUrl(Uri.parse(request.requestFormRef!));
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Request Form'),
            ),
          ],
        ),
      ),
      Step(
        title: const Text("Consultations"),
        isActive: _currentStep == 3,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //upload consultations
            if (consultationFormName != null && consultationFormRef != null)
              //show pdf
              ...[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: SfPdfViewer.network(consultationFormRef!),
              ),
              FormBuilderField(
                name: 'consultation_form_ref',
                builder: (context) => Row(
                  children: [
                    Text('Consultations: $consultationFormName'),
                    //delete button
                    IconButton(
                      onPressed: () {
                        storage
                            .ref(
                                'consultations/$id/consultation_form/$consultationFormName')
                            .delete()
                            .then((value) {
                          setState(() {
                            consultationFormName = null;
                            consultationFormRef = null;
                          });
                        }).catchError(
                          (error) {
                            buildErrorAlertDialog(error);
                            throw error;
                          },
                        );
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ] else
              isUploadingConsultations
                  ? const LinearProgressIndicator()
                  : Row(
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            setState(() {
                              isUploadingConsultations = true;
                            });
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                              withData: true,
                            );

                            if (result == null) {
                              setState(() {
                                isUploadingConsultations = false;
                              });
                              return;
                            }

                            String consultationFormFileName =
                                result.files.first.name;

                            try {
                              await storage
                                  .ref(
                                      'consultations/$id/consultation_form/$consultationFormFileName')
                                  .putData(
                                      result.files.first.bytes!,
                                      SettableMetadata(
                                          contentType: 'application/pdf'));

                              consultationFormRef = await storage
                                  .ref(
                                      'consultations/$id/consultation_form/$consultationFormFileName')
                                  .getDownloadURL();

                              _consultationsFormKey
                                  .currentState!.fields['consultation_form_ref']
                                  ?.didChange(consultationFormRef);

                              consultationFormName = await storage
                                  .ref(
                                      'consultations/$id/consultation_form/$consultationFormFileName')
                                  .getMetadata()
                                  .then((value) => value.name);

                              setState(() {});
                            } catch (error) {
                              buildErrorAlertDialog(error);
                            } finally {
                              setState(() {
                                isUploadingConsultations = false;
                              });
                            }

                            setState(() {
                              isUploadingConsultations = false;
                            });
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Consultations'),
                        ),
                      ],
                    ),
          ],
        ),
      ),
      Step(
        title: const Text("Report"),
        isActive: _currentStep == 4,
        content: Column(
          children: [
            if (reportQuillController.document.isEmpty())
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(
                  height: 20,
                ),
                FloatingActionButton.extended(
                  icon: isGeneratingReport
                      ? const CircularProgressIndicator.adaptive()
                      : const Icon(Icons.create),
                  onPressed: isGeneratingReport
                      ? null
                      : () async {
                          setState(() {
                            isGeneratingReport = true;
                          });
                          reportQuillController.document = await generateReport(
                            requestData: RequestData(
                              text: request.requestDetails,
                              file: request.requestFormRef,
                            ),
                            consultationData: ConsultationData(
                              text: null,
                              file: consultationFormRef,
                            ),
                          ).whenComplete(() {
                            setState(() {
                              isGeneratingReport = false;
                            });
                          });
                        },
                  label: isGeneratingReport
                      ? const Text('Generating')
                      : const Text('Generate Report'),
                ),
              ])
            else
              Column(
                children: [
                  QuillToolbar.simple(
                    configurations: QuillSimpleToolbarConfigurations(
                      controller: reportQuillController,
                      showInlineCode: false,
                      showColorButton: false,
                      showCodeBlock: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showLink: false,
                      showFontFamily: false,
                      showSearchButton: false,
                      showClipboardCopy: false,
                      showClipboardCut: false,
                      showClipboardPaste: false,
                      showQuote: false,
                      showBackgroundColorButton: false,
                      showStrikeThrough: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: QuillEditor.basic(
                        configurations: QuillEditorConfigurations(
                          controller: reportQuillController,
                          showCursor: true,
                        ),
                        // scrollController: requestScrollController,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      )
    ];

    return Scaffold(
        appBar: AppBar(
          title: const Text('Respond'),
          centerTitle: false,
          actions: [
            //save Draft
            TextButton.icon(
              onPressed: () async {
                if (_consultationsFormKey.currentState!.saveAndValidate()) {
                  await saveResponse(isSubmitted: false);
                  navigatorKey.currentState!.pop();
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Draft'),
            ),
          ],
        ),
        body: FormBuilder(
          key: _consultationsFormKey,
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Column(
              children: [
                Text(
                  '${request.authoriserFirstName} ${request.authoriserLastName}',
                  textAlign: TextAlign.end,
                ),
                //authoriserDOB
                Text(
                  request.formattedAuthoriserDob,
                  textAlign: TextAlign.end,
                ),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: Stepper(
                      currentStep: _currentStep,
                      physics: const NeverScrollableScrollPhysics(),
                      type: StepperType.horizontal,
                      controlsBuilder: (context, controlsDetails) {
                        final colorScheme = Theme.of(context).colorScheme;
                        const OutlinedBorder buttonShape =
                            RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2)));
                        const EdgeInsets buttonPadding =
                            EdgeInsets.symmetric(horizontal: 16.0);
                        ButtonStyle buttonStyle = ButtonStyle(
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                            return states.contains(WidgetState.disabled)
                                ? null
                                : colorScheme.onPrimary;
                          }),
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                            return colorScheme.primary;
                          }),
                          padding:
                              const WidgetStatePropertyAll<EdgeInsetsGeometry>(
                                  buttonPadding),
                          shape: const WidgetStatePropertyAll<OutlinedBorder>(
                              buttonShape),
                        );
                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (_currentStep != 0)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: TextButton(
                                      style: buttonStyle,
                                      onPressed: controlsDetails.onStepCancel,
                                      child: const Text('Back'),
                                    ),
                                  ),
                                if (_currentStep != steps.length - 1)
                                  TextButton(
                                    style: buttonStyle,
                                    onPressed: controlsDetails.onStepContinue,
                                    child: const Text('Next'),
                                  ),
                                if (_currentStep == steps.length - 1)
                                  TextButton(
                                    style: buttonStyle,
                                    onPressed: () async {
                                      if (_consultationsFormKey.currentState!
                                          .saveAndValidate()) {
                                        await saveResponse(isSubmitted: true);
                                        navigatorKey.currentState!.pop();
                                      }
                                    },
                                    child: const Text('Submit'),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                      onStepTapped: (step) {
                        setState(() {
                          _currentStep = step;
                        });
                      },
                      onStepContinue: () {
                        setState(() {
                          if (_currentStep < steps.length - 1) {
                            _currentStep++;
                          }
                        });
                      },
                      onStepCancel: () {
                        setState(() {
                          if (_currentStep > 0) {
                            _currentStep--;
                          }
                        });
                      },
                      steps: steps,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> saveResponse({required bool isSubmitted}) async {
    BoomarangResponse response = BoomarangResponse(
      id: id,
      holderUserId: auth.currentUser!.uid,
      requesterUserId: request.requesterUserId,
      consultationFormRef: consultationFormRef,
      consultationDetails: null,
      report: reportQuillController.document.toDelta().toJson(),
      isSubmitted: isSubmitted,
      status: isSubmitted ? 'Complete' : 'Draft',
    );

    return await firestore
        .collection('responses')
        .doc(id)
        .set(response.toMap());
  }
}
