import 'package:boomarang/holder/logic/generate_report.dart';
import 'package:boomarang/main.dart';
import 'package:boomarang/misc/custom_stepper.dart';
import 'package:boomarang/shared/alert_dialog.dart';
import 'package:boomarang_shared/data/request_types.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:boomarang_shared/models/request_type.dart';
import 'package:boomarang_shared/models/response.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Stepper, Step, StepperType;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

//TODO: add a warnings area for concerns (patient mididentification, insufficient information etc)
//TODO: accept or decline report with amendments

class RespondRequestScreen extends StatefulWidget {
  const RespondRequestScreen({
    super.key,
    required this.request,
  });

  final BoomarangRequest request;

  @override
  State<RespondRequestScreen> createState() => _RespondRequestScreenState();
}

class _RespondRequestScreenState extends State<RespondRequestScreen> {
  final _consultationsFormKey = GlobalKey<FormBuilderState>();

  BoomarangRequest get request => widget.request;

  int _currentStep = 0;
  bool isGeneratingReport = false;
  bool hasGeneratedReport = false;
  QuillController reportQuillController = QuillController.basic();

  String? consultationFormName;
  String? consultationFormRef;

  late String id;

  bool isUploadingConsultations = false;
  bool includeConsultationDetailsInReport = false;

  @override
  void initState() {
    id = request.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    RequestType requestType =
        requestTypes.firstWhere((element) => element.id == request.requestType);

    List<Step> steps = [
      Step(
        title: const Text("Request"),
        isActive: _currentStep == 0,
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Patient Details",
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Name: ',
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(
                                text:
                                    '${request.subjectFirstName} ${request.subjectLastName}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87))
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Date of Birth: ',
                              style: Theme.of(context).textTheme.bodyLarge,
                              children: [
                                TextSpan(
                                    text: request.formattedSubjectDob,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87))
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          //separator]
                          Container(
                            height: 16,
                            width: 1,
                            color: Colors.black26,
                          ),
                          const SizedBox(width: 8),
                          //dob verified
                          Text(
                              request.subjectDOBVerified == true
                                  ? 'Verified'
                                  : 'Not Verified',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                          const SizedBox(width: 8),
                          Icon(
                            request.subjectDOBVerified == true
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: request.subjectDOBVerified == true
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
                              style: Theme.of(context).textTheme.bodyLarge,
                              children: [
                                TextSpan(
                                    text: request.subjectEmail,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
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
                          Text(
                              request.subjectEmailVerified == true
                                  ? 'Verified'
                                  : 'Not Verified',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),

                          const SizedBox(width: 8),
                          Icon(
                            request.subjectEmailVerified == true
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: request.subjectEmailVerified == true
                                ? Colors.green
                                : Colors.red,
                            size: 16,
                          )
                        ],
                      ),
                      //consent
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Consent: ',
                              style: Theme.of(context).textTheme.bodyLarge,
                              children: [
                                //link to consent file wth recogniser
                                TextSpan(
                                  text: 'View',
                                  //theme color and bold
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).primaryColor),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(
                                          Uri.parse(request.consentFormRef!));
                                    },
                                ),
                              ],
                            ),
                          ),
                          //spacer
                          const SizedBox(width: 8),
                          //separator
                          Container(
                            height: 16,
                            width: 1,
                            color: Colors.black26,
                          ),
                          const SizedBox(width: 8),
                          //consent verified
                          Text(
                              request.consentVerified == true
                                  ? 'Verified'
                                  : 'Not Verified',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                          const SizedBox(width: 8),
                          Icon(
                            request.consentVerified == true
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: request.consentVerified == true
                                ? Colors.green
                                : Colors.red,
                            size: 16,
                          )
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Request Details",
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Type: ',
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(
                                text: requestType.name,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = requestType.holderDescription ==
                                          null
                                      ? null
                                      : () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return SimpleDialog(
                                                  title: Text(requestType.name),
                                                  contentPadding:
                                                      const EdgeInsets.all(20),
                                                  children: [
                                                    SizedBox(
                                                      width: 600,
                                                      height: 600,
                                                      child: Markdown(
                                                        data: requestType
                                                            .holderDescription!,
                                                        shrinkWrap: true,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Close'))
                                                  ],
                                                );
                                              });
                                        },
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor)),
                          ],
                        ),
                      ),
                      //requester
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          text: 'Requester: ',
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(
                                text: request.requesterOrgName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87))
                          ],
                        ),
                      ),

                      //submitted date

                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          text: 'Submitted: ',
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(
                                text: request.formattedCreatedFullDate,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      //fee amount and if paid
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Fee: ',
                              style: Theme.of(context).textTheme.bodyLarge,
                              children: [
                                TextSpan(
                                    text: request.fee == 0
                                        ? "N/A"
                                        : request.formattedFee,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87))
                              ],
                            ),
                          ),
                          if (request.feePaid != null) ...[
                            const SizedBox(width: 8),
                            //separator
                            Container(
                              height: 16,
                              width: 1,
                              color: Colors.black26,
                            ),
                            const SizedBox(width: 8),
                            //fee paid
                            Text(request.feePaid == true ? 'Paid' : 'Not Paid',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    )),
                            const SizedBox(width: 8),
                            Icon(
                              request.feePaid == true
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: request.feePaid == true
                                  ? Colors.green
                                  : Colors.red,
                              size: 16,
                            )
                          ]
                        ],
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              if (request.requestFormRef != null)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SfPdfViewer.network(
                      request.requestFormRef!,
                    ),
                  ),
                ),
              if (request.requestDetails != null) ...[
                const SizedBox(
                  height: 20,
                ),
                //request details
                Text("Description",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: MediaQuery.of(context).size.height * 0.40,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      request.requestDetails!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
              const SizedBox(
                height: 20,
              ),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return RejectRequestDialog(id: id);
                      });
                },
                label: const Text("Reject Request"),
                icon: const Icon(Icons.cancel),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text("Report"),
        isActive: _currentStep == 1,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Writing Assistant",
                style: Theme.of(context).textTheme.titleLarge),
            const Text("Upload consultations to create a tailored report"),
            //learn more
            const SizedBox(
              height: 4,
            ),
            RichText(
              text: TextSpan(
                text: 'Learn more',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 600),
                                child: SimpleDialog(
                                  title: const Text('AI Assistant'),
                                  contentPadding: const EdgeInsets.all(20),
                                  children: [
                                    Text("How does it work?",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                decoration:
                                                    TextDecoration.underline)),
                                    const Text(
                                        'Boomarang AI uses the details of the request, along with the consultation data you upload, to generate a tailored report for the insurer.'),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Is it secure?",
                                      //underline
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              decoration:
                                                  TextDecoration.underline),
                                    ),
                                    const Text(
                                        'Yes, all data is encrypted and stored securely. The patients are fully consented before their data is shared, and the consultation data is only used for generating the report.\n\nThe consultation data is never made available to the insurer and is deleted immediately after the report is submitted.'),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Is is accurate?",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              decoration:
                                                  TextDecoration.underline),
                                    ),
                                    const Text(
                                        "Boomarang AI uses the most advanced AI models available. It is capable of reliably extracting relevant information and producing accurate and detailed reports.\n\nHowever, the final report should always be reviewed by a medical professional before being submitted to the insurer."),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Close'))
                                  ],
                                ),
                              ),
                            ],
                          );
                        });
                  },
              ),
            ),
            const SizedBox(height: 20),
            //upload consultations
            SizedBox(
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.create),
                        onPressed: consultationFormName == null &&
                                consultationFormRef == null
                            ? null
                            : () async {
                                if (!reportQuillController.document.isEmpty()) {
                                  bool? result = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: const Text('Warning'),
                                            content: const Text(
                                                'Are you sure you want to overwrite the current report?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Continue'),
                                              ),
                                            ],
                                          ));

                                  if (result == false) {
                                    return;
                                  }
                                }
                                setState(() {
                                  isGeneratingReport = true;
                                });

                                reportQuillController.document =
                                    await generateReport(
                                  requestData: RequestData(
                                    text: request.requestDetails,
                                    file: request.requestFormRef,
                                    requestType: request.requestType!,
                                  ),
                                  consultationData: ConsultationData(
                                    text: null,
                                    file: consultationFormRef,
                                  ),
                                ).whenComplete(() {
                                  hasGeneratedReport = true;
                                  setState(() {
                                    isGeneratingReport = false;
                                  });
                                });
                              },
                        label: Text(hasGeneratedReport
                            ? "Redo Report"
                            : 'Write Report'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (isUploadingConsultations || isGeneratingReport) ...[
                    const LinearProgressIndicator(),
                    if (isGeneratingReport) ...[
                      const SizedBox(
                        height: 5,
                      ),
                      Text("Report generation can take up to 30 seconds",
                          style: Theme.of(context).textTheme.bodySmall)
                    ],
                  ] else if (consultationFormName != null &&
                      consultationFormRef != null) ...[
                    FormBuilderField(
                      name: 'consultation_form_ref',
                      builder: (context) => Row(
                        children: [
                          Text('$consultationFormName'),
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
                          //include consultation details in report button
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 200,
                            child: FormBuilderCheckbox(
                                name: 'include_consultation_details',
                                initialValue: false,
                                title: const Text('Include file with report'),
                                onChanged: (value) {
                                  setState(() {
                                    includeConsultationDetailsInReport = value!;
                                  });
                                }),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                          label: const Text('Import Consultations'),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
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
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
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
                if (isGeneratingReport) // This condition checks if the report is being generated
                  Positioned.fill(
                    // Overlay that covers the entire Quill editor area
                    child: Container(
                      //border radius
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white.withOpacity(0.8),
                      ),

                      child: const Center(
                        child: Text(
                          'Creating Report...',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ), // Optional: Show a loading indicator
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
        body: FormBuilder(
      key: _consultationsFormKey,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Stepper(
          currentStep: _currentStep,
          physics: const NeverScrollableScrollPhysics(),
          type: StepperType.horizontal,
          onStepTapped: (step) {
            setState(() {
              _currentStep = step;
            });
          },
          //TODO: [prevent submission if report is empty]
          onStepContinue: () {
            setState(() {
              if (_currentStep < steps.length - 1) {
                _currentStep++;
              } else {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Submit Response'),
                        content: const Text(
                            'Are you sure you want to submit this response?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await submitResponse();
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Submit'),
                          ),
                        ],
                      );
                    });
              }
            });
          },
          onStepCancel: () {
            setState(() {
              if (_currentStep > 0) {
                _currentStep--;
              } else {
                Navigator.of(context).pop();
              }
            });
          },
          steps: steps,
        ),
      ),
    ));
  }

  Future<void> submitResponse() async {
    //if include_consultation_details is true, add consultation details to response, otherwise delete consultation details
    bool includeConsultationDetails = _consultationsFormKey
        .currentState!.fields['include_consultation_details']!.value as bool;

    BoomarangResponse response = BoomarangResponse(
      id: id,
      holderUserId: auth.currentUser!.uid,
      requesterUserId: request.requesterUserId,
      consultationFormRef:
          includeConsultationDetails ? consultationFormRef : null,
      report: reportQuillController.document.toDelta().toJson(),
    );

    await firestore.collection('responses').doc(id).set(response.toMap());
  }
}

class RejectRequestDialog extends StatefulWidget {
  const RejectRequestDialog({
    super.key,
    required this.id,
  });

  final String id;

  @override
  State<RejectRequestDialog> createState() => _RejectRequestDialogState();
}

class _RejectRequestDialogState extends State<RejectRequestDialog> {
  bool isLoading = false;
  TextEditingController reasonController = TextEditingController();

  List reasons = [
    'Insufficient information',
    'Innapproriate request',
    'Other',
  ];

  String value = '';

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Are you sure you want to reject this request?'),
      children: [
        //radio list of reasons
        ...List.generate(
          reasons.length,
          (index) => RadioListTile(
            title: Text(reasons[index]),
            value: reasons[index],
            groupValue: value,
            onChanged: (value) {
              setState(() {
                this.value = value as String;
                if (value == 'Other') {
                  reasonController.text = '';
                } else {
                  reasonController.text = value;
                }
              });
            },
          ),
        ),
        if (value == 'Other')
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              autofocus: true,
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isLoading)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });
                        await Future.delayed(const Duration(seconds: 1));
                        await functions.httpsCallable('rejectRequest').call({
                          'requestId': widget.id,
                          'reason': reasonController.text,
                        });
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                child: isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text('Reject'),
              ),
            ],
          ),
        )
      ],
    );
  }
}
