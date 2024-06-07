import 'package:boomarang/methods/extract_quill_delta_from_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class SandboxScreen extends StatefulWidget {
  const SandboxScreen({super.key});

  @override
  State<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends State<SandboxScreen> {
  QuillController requestQuillController = QuillController.basic();
  QuillController consultationsQuillController = QuillController.basic();
  QuillController reportQuillController = QuillController.basic();

  ScrollController requestScrollController = ScrollController();
  ScrollController consultationsScrollController = ScrollController();
  ScrollController reportScrollController = ScrollController();

  ScrollController stepperScrollController = ScrollController();

  bool isGeneratingReport = false;
  bool isExtractingRequest = false;
  bool isExtractingConsultations = false;

  // @override
  // void initState() {
  //   requestQuillController.addListener(() {
  //     setState(() {});
  //   });

  //   consultationsQuillController.addListener(() {
  //     setState(() {});
  //   });

  //   reportQuillController.addListener(() {
  //     setState(() {});
  //   });
  //   super.initState();
  // }

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sandbox'),
      ),
      body: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Stepper(
          controller: stepperScrollController,
          type: StepperType.vertical,
          onStepTapped: (step) {
            setState(() {
              _currentStep = step;
            });
          },
          currentStep: _currentStep,
          onStepContinue: _currentStep == 2
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
                  QuillToolbar.simple(
                    configurations: QuillSimpleToolbarConfigurations(
                      controller: requestQuillController,
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
                    height: 300,
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
                          controller: requestQuillController,
                          showCursor: true,
                        ),
                        // scrollController: requestScrollController,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  //export document as json

                  isExtractingRequest
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: () async {
                            setState(() {
                              isExtractingRequest = true;
                            });
                            Document? document =
                                await extractQuillDeltaFromFile(context)
                                    .whenComplete(() {
                              setState(() {
                                isExtractingRequest = false;
                              });
                            });

                            if (document != null) {
                              requestQuillController.document = document;
                            }

                            setState(() {
                              isExtractingRequest = false;
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
                children: [
                  const TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      helperText:
                          'Copy and paste your consultations, or use the button below to upload a file.',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  isExtractingConsultations
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: () async {
                            setState(() {
                              isExtractingConsultations = true;
                            });
                            Document? document =
                                await extractQuillDeltaFromFile(context);

                            if (document != null) {
                              consultationsQuillController.document = document;
                            }
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
                children: [
                  const TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
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
            ),
          ],
        ),
      ),
    );
  }
}
