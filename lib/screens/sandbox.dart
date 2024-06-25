// import 'package:boomarang/methods/generate_report.dart';
// import 'package:boomarang/misc/custom_stepper.dart' as custom_stepper;
// import 'package:boomarang/misc/custom_stepper.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:file_saver/file_saver.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart' hide Stepper, StepperType;
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' as pdf_thing;
// import 'package:quill_html_converter/quill_html_converter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class SandboxScreen extends StatefulWidget {
//   const SandboxScreen({super.key});

//   @override
//   State<SandboxScreen> createState() => _SandboxScreenState();
// }

// class _SandboxScreenState extends State<SandboxScreen> {
//   TextEditingController requestController = TextEditingController();
//   TextEditingController consultationsController = TextEditingController();

//   QuillController reportQuillController = QuillController.basic();

//   ScrollController reportScrollController = ScrollController();
//   ScrollController stepperScrollController = ScrollController();

//   int _currentStep = 0;

//   FilePickerResult? requestFile;
//   FilePickerResult? consultationsFile;

//   String requestHintText = 'Describe the request...';
//   String requestHelperText =
//       'If you have a request form, you can use the button below to upload a PDF file.';

//   String consultationsHintText = 'Copy and paste your consultations here...';
//   String consultationsHelperText =
//       'If you have a file with consultations, you can use the button below to upload it.';

//   bool isGeneratingReport = false;

//   @override
//   void initState() {
//     if (kDebugMode) {
//       requestController.text =
//           'Please confirm whether or not the patient: David Spacey, has diverticulitis and is taking antibiotics.';
//       consultationsController.text =
//           'The patient, David Spacey, has been diagnosed with diverticulitis and is currently taking antibiotics. The patient is also experiencing severe abdominal pain and has been advised to rest and take the antibiotics as prescribed.';
//     }
//     requestController.addListener(() {
//       setState(() {});
//     });

//     consultationsController.addListener(() {
//       setState(() {});
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sandbox'),
//       ),
//       body: Container(
//         constraints: const BoxConstraints(maxWidth: 1200),
//         child: ScrollConfiguration(
//           behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
//           child: custom_stepper.Stepper(
//             controller: stepperScrollController,
//             type: StepperType.vertical,
//             currentStep: _currentStep,
//             onStepTapped: null,

//             onStepContinue: (_currentStep == 0 &&
//                         (requestFile == null &&
//                             requestController.text.isEmpty)) ||
//                     (_currentStep == 1 &&
//                         (consultationsFile == null &&
//                             consultationsController.text.isEmpty)) ||
//                     (_currentStep == 2 &&
//                         reportQuillController.document.isEmpty())
//                 ? null
//                 : () {
//                     if (_currentStep == 2) {
//                       //showDialog
//                       showDialog(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: const Text('Finish'),
//                           content: const Text(
//                               'Are you sure you want to finish? This will close the window.'),
//                           actions: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                                 setState(() {
//                                   _currentStep = 0;
//                                   requestController.clear();
//                                   consultationsController.clear();
//                                   requestFile = null;
//                                   consultationsFile = null;
//                                   requestHintText = 'Describe the request...';
//                                   requestHelperText =
//                                       'If you have a request form, you can use the button below to upload a PDF file.';
//                                   consultationsHintText =
//                                       'Copy and paste your consultations here...';
//                                   consultationsHelperText =
//                                       'If you have a file with consultations, you can use the button below to upload it.';
//                                   reportQuillController.document = Document();
//                                 });
//                               },
//                               child: const Text('OK'),
//                             ),
//                           ],
//                         ),
//                       );
//                     } else {
//                       setState(() {
//                         _currentStep++;
//                       });
//                     }
//                   },
//             onStepCancel: _currentStep == 0
//                 ? null
//                 : () {
//                     setState(() {
//                       _currentStep--;
//                     });
//                   },
//             //change text to finish on the last step and disable if the reportQuillController is empty
//             controlsBuilder:
//                 (BuildContext context, custom_stepper.ControlsDetails details) {
//               return Column(
//                 children: [
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Row(
//                     children: [
//                       OutlinedButton(
//                         onPressed: details.onStepCancel,
//                         //rectangle
//                         style: OutlinedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                         ),
//                         child: const Text('Back'),
//                       ),
//                       const SizedBox(width: 10),
//                       OutlinedButton(
//                         onPressed: details.onStepContinue,
//                         //rectangle
//                         style: OutlinedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                         ),
//                         child: Text(_currentStep == 2 ? 'Finish' : 'Next'),
//                       ),
//                     ],
//                   ),
//                 ],
//               );
//             },
//             steps: [
//               custom_stepper.Step(
//                 title: const Text('Request'),
//                 isActive: _currentStep == 0,
//                 content: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 20),
//                     TextField(
//                       maxLines: 5,
//                       controller: requestController,
//                       decoration: InputDecoration(
//                         hintText: requestHintText,
//                         helperText: requestHelperText,
//                         alignLabelWithHint: true,
//                         border: const UnderlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     if (requestFile != null)
//                       Row(
//                         children: [
//                           const SizedBox(
//                             width: 20,
//                           ),
//                           Text(requestFile!.files.single.name),
//                           const SizedBox(width: 20),
//                           TextButton.icon(
//                             iconAlignment: IconAlignment.end,
//                             onPressed: () {
//                               setState(() {
//                                 requestFile = null;
//                                 requestHintText = 'Describe the request...';
//                                 requestHelperText =
//                                     'If you have a request form, you can use the button below to upload a PDF file.';
//                               });
//                             },
//                             icon: const Icon(Icons.delete),
//                             label: const Text('Remove'),
//                           ),
//                         ],
//                       )
//                     else
//                       TextButton.icon(
//                         onPressed: () async {
//                           requestFile = await FilePicker.platform.pickFiles(
//                             allowMultiple: false,
//                             type: FileType.custom,
//                             allowedExtensions: ['pdf'],
//                             withData: true,
//                           );
//                           setState(() {
//                             requestHintText =
//                                 'Add any additional context here...';
//                             requestHelperText =
//                                 'Request uploaded successfully.';
//                           });
//                         },
//                         icon: const Icon(Icons.upload_file),
//                         label: const Text('Upload Request'),
//                       ),
//                   ],
//                 ),
//               ),
//               custom_stepper.Step(
//                 title: const Text('Consultations'),
//                 content: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextField(
//                       maxLines: 5,
//                       controller: consultationsController,
//                       decoration: InputDecoration(
//                         hintText: consultationsHintText,
//                         helperText: consultationsHelperText,
//                         alignLabelWithHint: true,
//                         border: const UnderlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     if (consultationsFile != null)
//                       Row(
//                         children: [
//                           const SizedBox(
//                             width: 20,
//                           ),
//                           Text(consultationsFile!.files.single.name),
//                           const SizedBox(width: 20),
//                           TextButton.icon(
//                             iconAlignment: IconAlignment.end,
//                             onPressed: () {
//                               setState(() {
//                                 consultationsFile = null;
//                                 consultationsHintText =
//                                     'Copy and paste your consultations here...';
//                                 consultationsHelperText =
//                                     'If you have a file with consultations, you can use the button below to upload it.';
//                               });
//                             },
//                             icon: const Icon(Icons.delete),
//                             label: const Text('Remove'),
//                           ),
//                         ],
//                       )
//                     else
//                       TextButton.icon(
//                         onPressed: () async {
//                           consultationsFile =
//                               await FilePicker.platform.pickFiles(
//                             allowMultiple: false,
//                             type: FileType.custom,
//                             allowedExtensions: ['pdf'],
//                             withData: true,
//                           );
//                           setState(() {
//                             consultationsHintText =
//                                 'Add any additional context here...';
//                             consultationsHelperText =
//                                 'Consultations uploaded successfully.';
//                           });
//                         },
//                         icon: const Icon(Icons.upload_file),
//                         label: const Text('Upload Consultations'),
//                       ),
//                   ],
//                 ),
//               ),
//               custom_stepper.Step(
//                 title: const Text('Report'),
//                 content: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     if (reportQuillController.document.isEmpty())
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(
//                             height: 20,
//                           ),
//                           FloatingActionButton.extended(
//                               icon: isGeneratingReport
//                                   ? const CircularProgressIndicator.adaptive()
//                                   : const Icon(Icons.create),
//                               onPressed: isGeneratingReport
//                                   ? null
//                                   : () async {
//                                       setState(() {
//                                         isGeneratingReport = true;
//                                       });
//                                       reportQuillController.document =
//                                           await generateReport(
//                                         requestData: RequestData(
//                                           text: requestController.text,
//                                           file: 
//                                         ),
//                                         consultationData: ConsultationData(
//                                           text: consultationsController.text,
//                                           file: consultationsFile,
//                                         ),
//                                       ).whenComplete(() {
//                                         setState(() {
//                                           isGeneratingReport = false;
//                                         });
//                                       });
//                                     },
//                               label: isGeneratingReport
//                                   ? const Text('Generating')
//                                   : const Text('Generate Report')),
//                         ],
//                       )
//                     else
//                       Column(
//                         children: [
//                           QuillToolbar.simple(
//                             configurations: QuillSimpleToolbarConfigurations(
//                               controller: reportQuillController,
//                               showInlineCode: false,
//                               showColorButton: false,
//                               showCodeBlock: false,
//                               showSubscript: false,
//                               showSuperscript: false,
//                               showLink: false,
//                               showFontFamily: false,
//                               showSearchButton: false,
//                               showClipboardCopy: false,
//                               showClipboardCut: false,
//                               showClipboardPaste: false,
//                               showQuote: false,
//                               showBackgroundColorButton: false,
//                               showStrikeThrough: false,
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           Container(
//                             height: MediaQuery.of(context).size.height * 0.5,
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: Colors.grey,
//                               ),
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: QuillEditor.basic(
//                                 configurations: QuillEditorConfigurations(
//                                   controller: reportQuillController,
//                                   showCursor: true,
//                                 ),
//                                 // scrollController: requestScrollController,
//                               ),
//                             ),
//                           ),
//                           //download report button
//                           const SizedBox(height: 20),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               TextButton.icon(
//                                 onPressed: () async {
//                                   //download the report as a pdf
//                                   final String report = reportQuillController
//                                       .document
//                                       .toPlainText();

//                                   launchUrl(
//                                     Uri.parse(
//                                         'mailto:?subject=Report&body=$report'),
//                                   );
//                                 },
//                                 icon: const Icon(Icons.email),
//                                 label: const Text('Email Report'),
//                               ),
//                               const SizedBox(width: 20),
//                               TextButton.icon(
//                                 onPressed: () async {
//                                   final newPdf = pdf_thing.Document();

//                                   //download the report as a pdf
//                                   final dynamic widgets =
//                                       await pdf_thing.HTMLToPdf().convert(
//                                           reportQuillController.document
//                                               .toDelta()
//                                               .toHtml());

//                                   newPdf.addPage(
//                                     pdf_thing.MultiPage(
//                                       build: (context) {
//                                         return widgets;
//                                       },
//                                       maxPages: 200,
//                                     ),
//                                   );

//                                   //download file
//                                   final pdf = await newPdf.save();

//                                   await FileSaver.instance.saveFile(
//                                     name: 'example.pdf',
//                                     mimeType: MimeType.pdf,
//                                     bytes: pdf,
//                                   );
//                                 },
//                                 icon: const Icon(Icons.download),
//                                 label: const Text('Download as PDF'),
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
