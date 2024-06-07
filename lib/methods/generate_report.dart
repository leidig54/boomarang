import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';

Future<Document> generateReport({
  required RequestData requestData,
  required ConsultationData consultationData,
}) async {
  //upload the files (if they exist) to firebase storage and get the download url
  String? requestDataFileUrl;
  String? consultationDataFileUrl;

  if (requestData.file != null) {
    final Reference ref = FirebaseStorage.instance.ref().child(
          'requestData/${requestData.file!.files.single.name}',
        );
    await ref.putData(requestData.file!.files.single.bytes!);
    requestDataFileUrl = await ref.getDownloadURL();
  }

  if (consultationData.file != null) {
    final Reference ref = FirebaseStorage.instance.ref().child(
          'consultationData/${consultationData.file!.files.single.name}',
        );
    await ref.putData(consultationData.file!.files.single.bytes!);
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
  );

  //return the generated report
  String reportText = results.data;

  debugPrint('Generated report: $reportText');

  //
  return Document();
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
