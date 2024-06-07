import 'package:boomarang/methods/generate_report.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class SandboxScreen extends StatefulWidget {
  const SandboxScreen({super.key});

  @override
  State<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends State<SandboxScreen> {
  TextEditingController requestController = TextEditingController();
  TextEditingController consultationsController = TextEditingController();

  QuillController reportQuillController = QuillController.basic();

  ScrollController reportScrollController = ScrollController();
  ScrollController stepperScrollController = ScrollController();

  int _currentStep = 2;

  FilePickerResult? requestFile;
  FilePickerResult? consultationsFile;

  String requestHintText = 'Describe the request...';
  String requestHelperText =
      'If you have a request form, you can use the button below to upload a PDF file.';

  String consultationsHintText = 'Copy and paste your consultations here...';
  String consultationsHelperText =
      'If you have a file with consultations, you can use the button below to upload it.';

  bool isGeneratingReport = false;

  @override
  void initState() {
    requestController.addListener(() {
      setState(() {});
    });

    consultationsController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sandbox'),
      ),
      body: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: Stepper(
            controller: stepperScrollController,
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: _currentStep == 2 ||
                    (_currentStep == 0 &&
                        (requestFile == null &&
                            requestController.text.isEmpty)) ||
                    (_currentStep == 1 &&
                        (consultationsFile == null &&
                            consultationsController.text.isEmpty))
                ? null
                : () {
                    setState(() {
                      _currentStep++;
                    });
                  },
            onStepCancel: _currentStep == 0
                ? null
                : () {
                    setState(() {
                      _currentStep--;
                    });
                  },
            steps: [
              Step(
                title: const Text('Request'),
                isActive: _currentStep == 0,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    TextField(
                      maxLines: 5,
                      controller: requestController,
                      decoration: InputDecoration(
                        hintText: requestHintText,
                        helperText: requestHelperText,
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (requestFile != null)
                      Row(
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          Text(requestFile!.files.single.name),
                          const SizedBox(width: 20),
                          TextButton.icon(
                            iconAlignment: IconAlignment.end,
                            onPressed: () {
                              setState(() {
                                requestFile = null;
                                requestHintText = 'Describe the request...';
                                requestHelperText =
                                    'If you have a request form, you can use the button below to upload a PDF file.';
                              });
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Remove'),
                          ),
                        ],
                      )
                    else
                      TextButton.icon(
                        onPressed: () async {
                          requestFile = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                          );
                          setState(() {
                            requestHintText =
                                'Add any additional context here...';
                            requestHelperText = 'Request form added.';
                          });
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload Request'),
                      ),
                  ],
                ),
              ),
              Step(
                title: const Text('Consultations'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      maxLines: 5,
                      controller: consultationsController,
                      decoration: InputDecoration(
                        hintText: consultationsHintText,
                        helperText: consultationsHelperText,
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () async {
                        consultationsFile = await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                        setState(() {
                          consultationsHintText =
                              'Add any additional context here...';
                          consultationsHelperText = 'Consultations added.';
                        });
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Consultations'),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Report'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (reportQuillController.document.isEmpty())
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          FloatingActionButton.extended(
                              icon: const Icon(Icons.create),
                              onPressed: () async {
                                setState(() {
                                  isGeneratingReport = true;
                                });
                                reportQuillController.document =
                                    await generateReport(
                                  requestData: RequestData(
                                    text: requestController.text,
                                    file: requestFile,
                                  ),
                                  consultationData: ConsultationData(
                                    text: consultationsController.text,
                                    file: consultationsFile,
                                  ),
                                ).whenComplete(() {
                                  setState(() {
                                    isGeneratingReport = false;
                                  });
                                });
                              },
                              label: const Text('Generate Report')),
                        ],
                      )
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
                            height: MediaQuery.of(context).size.height * 0.5,
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
                          //download report button
                          const SizedBox(height: 20),
                          TextButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.download),
                            label: const Text('Download Report'),
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
