import 'package:boomarang/app/logic/generate_report.dart';
import 'package:boomarang/app/screens/dialogs/llm_explainer.dart';
import 'package:boomarang/app/screens/dialogs/overwrite_report.dart';
import 'package:boomarang/app/screens/dialogs/reject_request.dart';
import 'package:boomarang/app/screens/dialogs/view_request_type.dart';
import 'package:boomarang/main.dart';
import 'package:boomarang/misc/custom_stepper.dart';
import 'package:boomarang/shared/alert_dialog.dart';
import 'package:boomarang_shared/data/request_types.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:boomarang_shared/models/request_type.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Stepper, Step, StepperType;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_quill/flutter_quill.dart';

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
                      Text("Subject Details",
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
                                  ..onTap = requestType.recipientDescription ==
                                          null
                                      ? null
                                      : () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return ViwewRequestType(
                                                    requestType: requestType);
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
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          text: 'Sender: ',
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(
                                text: request.senderEmail,
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
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              if (request.requestDetails != null) ...[
                const SizedBox(
                  height: 20,
                ),
                //request details
                Text("Additional Details",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Container(
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
                                child: const LlmExplainerDialog(),
                              ),
                            ],
                          );
                        });
                  },
              ),
            ),
            SizedBox(
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
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
                                      if (!reportQuillController.document
                                          .isEmpty()) {
                                        bool? result = await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const OverwriteReportDialog());

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
                            const SizedBox(width: 10),
                            if (consultationFormName == null)
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: isUploadingConsultations
                                        ? null
                                        : () async {
                                            setState(() {
                                              isUploadingConsultations = true;
                                            });
                                            final result = await FilePicker
                                                .platform
                                                .pickFiles(
                                              type: FileType.custom,
                                              allowedExtensions: ['pdf'],
                                              withData: true,
                                            );

                                            if (result == null) {
                                              setState(() {
                                                isUploadingConsultations =
                                                    false;
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
                                                          contentType:
                                                              'application/pdf'));

                                              consultationFormRef = await storage
                                                  .ref(
                                                      'consultations/$id/consultation_form/$consultationFormFileName')
                                                  .getDownloadURL();

                                              _consultationsFormKey
                                                  .currentState!
                                                  .fields[
                                                      'consultation_form_ref']
                                                  ?.didChange(
                                                      consultationFormRef);

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
                                                isUploadingConsultations =
                                                    false;
                                              });
                                            }
                                            setState(() {
                                              isUploadingConsultations = false;
                                            });
                                          },
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text('Import Consultations'),
                                  ),
                                  isUploadingConsultations
                                      ? const Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                          ],
                        ),
                        if (consultationFormName != null &&
                            consultationFormRef != null) ...[
                          FormBuilderField(
                            name: 'consultation_form_ref',
                            builder: (context) => Row(
                              children: [
                                Text('$consultationFormName'),
                                Tooltip(
                                  message: 'Delete file',
                                  child: IconButton(
                                    onPressed: isGeneratingReport
                                        ? null
                                        : () {
                                            storage
                                                .ref(
                                                    'consultations/$id/consultation_form/$consultationFormName')
                                                .delete()
                                                .then((value) {
                                              setState(() {
                                                consultationFormName = null;
                                                consultationFormRef = null;
                                                includeConsultationDetailsInReport =
                                                    false;
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
                                ),
                                //include consultation details in report button
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 200,
                                  child: Tooltip(
                                    message:
                                        'Checking this box will give the sender access to this file.',
                                    child: FormBuilderCheckbox(
                                        name: 'include_consultation_details',
                                        initialValue:
                                            includeConsultationDetailsInReport,
                                        title: const Text(
                                            'Include file with report'),
                                        onChanged: (value) {
                                          setState(() {
                                            includeConsultationDetailsInReport =
                                                value!;
                                          });
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          value: isGeneratingReport ? null : 0,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                            !isGeneratingReport
                                ? ""
                                : "Report generation can take up to 30 seconds",
                            style: Theme.of(context).textTheme.bodySmall)
                      ],
                    ),
                  )
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
                      controller: reportQuillController,
                      configurations: const QuillSimpleToolbarConfigurations(
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
                          controller: reportQuillController,
                          configurations: const QuillEditorConfigurations(
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
          onStepContinue: () {
            setState(() {
              if (_currentStep < steps.length - 1) {
                _currentStep++;
              } else {
                if (reportQuillController.document.isEmpty()) {
                  buildErrorAlertDialog(
                      'Please write a report before submitting');
                } else {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return SubmitResponseDialog(
                            submitResponse: submitResponse);
                      });
                }
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
    //TODO: populate response
  }
}

class SubmitResponseDialog extends StatelessWidget {
  const SubmitResponseDialog({
    super.key,
    required this.submitResponse,
  });

  final Future<void> Function() submitResponse;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Submit Response'),
      content: const Text('Are you sure you want to submit this response?'),
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
  }
}
