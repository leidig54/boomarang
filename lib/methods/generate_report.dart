import 'package:boomarang/main.dart';
import 'package:boomarang/misc/alert_dialog.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

Future<Document> generateReport({
  required RequestData requestData,
  required ConsultationData consultationData,
}) async {
  //upload the files (if they exist) to firebase storage and get the download url
  String? requestDataFileUrl;
  String? consultationDataFileUrl;

  if (requestData.file != null) {
    //get a uuid for the file
    String uuid = const Uuid().v4();
    final Reference ref = FirebaseStorage.instance.ref().child(
          'uploads/${auth.currentUser!.uid}/$uuid',
        );
    await ref
        .putData(
            requestData.file!.files.single.bytes!,
            SettableMetadata(
              contentType:
                  'application/${requestData.file!.files.single.extension}',
            ))
        .catchError((error) {
      debugPrint('Error uploading file: $error');
      buildErrorAlertDialog('Error uploading file: $error');
      throw error;
    }).then((value) {
      debugPrint('File uploaded successfully');
    });
    requestDataFileUrl = await ref.getDownloadURL();
  }

  if (consultationData.file != null) {
    String uuid = const Uuid().v4();
    final Reference ref = FirebaseStorage.instance.ref().child(
          'uploads/${auth.currentUser!.uid}/$uuid',
        );
    await ref
        .putData(
            consultationData.file!.files.single.bytes!,
            SettableMetadata(
              contentType:
                  'application/${consultationData.file!.files.single.extension}',
            ))
        .catchError((error) {
      debugPrint('Error uploading file: $error');
      buildErrorAlertDialog('Error uploading file: $error');
      throw error;
    }).then((value) {
      debugPrint('File uploaded successfully');
    });
    consultationDataFileUrl = await ref.getDownloadURL();
  }

  final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
    'generateReport',
  );

  final HttpsCallableResult results = await callable.call(
    <String, dynamic>{
      'requestData': {
        'text': requestData.text,
        'fileUrl': requestDataFileUrl,
      },
      'consultationData': {
        'text': consultationData.text,
        'fileUrl': consultationDataFileUrl,
      },
    },
  ).catchError((error) {
    String errorText = "Error generating report: $error";
    debugPrint(errorText);
    buildErrorAlertDialog(errorText);
    throw error;
  });

  //return the generated report
  String reportText = results.data;

  debugPrint('Generated report: $reportText');

  return Document.fromHtml(reportText);
}

class RequestData {
  String? text;
  FilePickerResult? file;

  RequestData({this.text, this.file});
}

class ConsultationData {
  String? text;
  FilePickerResult? file;

  ConsultationData({this.text, this.file});
}
