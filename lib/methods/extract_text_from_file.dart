import 'package:boomarang/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
