import 'package:boomarang/main.dart';
import 'package:boomarang/methods/generate_report.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SandboxScreen extends StatefulWidget {
  const SandboxScreen({super.key});

  @override
  State<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends State<SandboxScreen> {
  TextEditingController requestController = TextEditingController();
  TextEditingController consultationsController = TextEditingController();
  TextEditingController reportController = TextEditingController();

  bool isGeneratingReport = false;
  bool isExtractingRequest = false;
  bool isExtractingConsultations = false;

  @override
  void initState() {
    //use emulators if in debug mode

    if (kDebugMode) {
      requestController.text =
          'Confirm if this patient has diverticulitis for which they take antibiotics.';
      consultationsController.text =
          'Consultation: This patient has diverticulitis and is on antibiotics.';
    }

    requestController.addListener(() {
      setState(() {});
    });

    consultationsController.addListener(() {
      setState(() {});
    });

    reportController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            children: [
              Text(
                'Request',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                maxLines: 5,
                controller: requestController,
                decoration: const InputDecoration(
                  helperText:
                      'Copy and paste your request, or use the button below to upload a file.',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              isExtractingRequest
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          isExtractingRequest = true;
                        });

                        await extractTextFromFile(context).then((value) {
                          if (value != null) {
                            requestController.text = value;
                          }
                        }).whenComplete(() {
                          setState(() {
                            isExtractingRequest = false;
                          });
                        });
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Request'),
                    ),
              //upload consultations area
              const SizedBox(height: 20),
              Text(
                'Consultations',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                maxLines: 5,
                controller: consultationsController,
                decoration: const InputDecoration(
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
                        await extractTextFromFile(context).then((value) {
                          if (value != null) {
                            consultationsController.text = value;
                          }
                        }).whenComplete(() {
                          setState(() {
                            isExtractingConsultations = false;
                          });
                        });
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Consultations'),
                    ),
              //show generated report area
              const SizedBox(height: 20),
              Text(
                'Report',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                maxLines: 5,
                controller: reportController,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              //download report button
              const SizedBox(height: 20),
              if (reportController.text.isNotEmpty)
                TextButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.download),
                  label: const Text('Download Report'),
                )
              else
                isGeneratingReport
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: consultationsController.text.isNotEmpty &&
                                requestController.text.isNotEmpty
                            ? () async {
                                setState(() {
                                  isGeneratingReport = true;
                                });

                                await generateReport(requestController.text,
                                        consultationsController.text)
                                    .then((value) {
                                  reportController.text = value;
                                }).whenComplete(() {
                                  setState(() {
                                    isGeneratingReport = false;
                                  });
                                });
                              }
                            : null,
                        icon: const Icon(Icons.create),
                        label: const Text('Generate Report'),
                      )
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> extractTextFromFile(BuildContext context) async {
    FilePickerResult? file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      allowMultiple: false,
    );

    if (file == null) {
      return null;
    } else {
      //get the file extension / mime type
      String? extension = file.files.single.extension;

      //format the extension as a mime type
      String mimeType =
          extension == 'pdf' ? 'application/pdf' : 'image/$extension';

      debugPrint('Mime type: $mimeType');

      //get the file as a byte array
      Uint8List bytes = file.files.single.bytes!;

      debugPrint('File size: ${bytes.length} bytes');

      TextPart prompt = TextPart('Extract text');
      DataPart data = DataPart(mimeType, bytes);

      //upload the file to the model
      GenerateContentResponse response = await model.generateContent([
        Content.multi([prompt, data])
      ]).catchError((error) {
        showAdaptiveDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog.adaptive(
            title: const Text('Error'),
            content: SelectableText(error.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
        throw error;
      });

      //return the extracted text
      return response.text;
    }
  }
}
