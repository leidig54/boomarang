import 'dart:convert';

import 'package:boomarang/main.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

Future<Document?> extractQuillDeltaFromFile(BuildContext context) async {
  FilePickerResult? file = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
    allowMultiple: false,
  );

  if (file == null) {
    return null;
  } else {
    //generate a random id for the file
    String fileId = const Uuid().v4();

    debugPrint('Uploading file to firebase storage...');
    //upload the file to firebase storage
    UploadTask uploadTask = storage
        .ref('${auth.currentUser!.uid}/$fileId')
        .putData(file.files.single.bytes!,
            SettableMetadata(contentType: 'application/pdf'));

    //wait for the upload to complete
    await uploadTask.catchError((error) {
      debugPrint('Error: $error');
      showAdaptiveDialog(
          context: context,
          builder: (context) {
            return AlertDialog.adaptive(
              title: const Text('Error'),
              content: const Text(
                  'An error occurred while uploading the file. Please try again.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
      throw error;
    });

    debugPrint('File uploaded successfully.');

    //Make a call to the extract text cloud function with the file id
    HttpsCallableResult result = await functions
        .httpsCallable('extractQuillDeltaFromFile')
        .call({'fileId': fileId, 'userId': auth.currentUser!.uid}).catchError(
            (error) {
      debugPrint('Error: $error');

      showAdaptiveDialog(
          context: context,
          builder: (context) {
            return AlertDialog.adaptive(
              title: const Text('Error'),
              content: const Text(
                  'An error occurred while extracting the text from the file. Please try again.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });

      throw error;
    }).whenComplete(() {
      // //delete the file from firebase storage
      // storage.ref('${auth.currentUser!.uid}/files/$fileId').delete();
    });

    print(result.data);

    dynamic json = jsonDecode(result.data);

    //if the json doesnt start and end with square brackes, add them
    if (json is Map) {
      json = [json];
    }

    Document? document;
    try {
      document = Document.fromJson(json);
    } on Exception catch (e) {
      print(e);
      return null;
    }
    return document;

    // return document;
  }
}
