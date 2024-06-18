import 'package:boomarang/misc/alert_dialog.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

Future<Document> generateReport({
  required RequestData requestData,
  required ConsultationData consultationData,
}) async {
  final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
    'generateReport',
  );

  final HttpsCallableResult results = await callable.call(
    <String, dynamic>{
      'requestData': {
        'text': requestData.text,
        'fileUrl': requestData.file,
      },
      'consultationData': {
        'text': consultationData.text,
        'fileUrl': consultationData.file,
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
  String? file;

  RequestData({this.text, this.file});
}

class ConsultationData {
  String? text;
  String? file;

  ConsultationData({this.text, this.file});
}
