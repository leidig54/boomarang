// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:boomarang/main.dart';
import 'package:boomarang/shared/alert_dialog.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';

Future<Document> generateReport({
  required RequestData requestData,
  required ConsultationData consultationData,
}) async {
  final HttpsCallable callable = functions.httpsCallable('generateReport');

  final HttpsCallableResult results = await callable.call(
    <String, dynamic>{
      'requestData': {
        'text': requestData.text,
        'fileUrl': requestData.file,
        'requestType': requestData.requestType,
      },
      'consultationData': {
        'text': consultationData.text,
        'fileUrl': consultationData.file,
      },
      'id': auth.currentUser?.uid,
    },
  ).catchError((error) {
    String errorText = "Error generating report: $error";
    buildErrorAlertDialog(errorText);
    throw error;
  });

  //return the generated report
  String reportTextHtml = results.data;

  debugPrint('Generated report: $reportTextHtml');

  Delta reportTextDelta = HtmlToDelta().convert(reportTextHtml);

  return Document.fromDelta(reportTextDelta);
}

class RequestData {
  String? text;
  String? file;
  String requestType;

  RequestData({
    this.text,
    this.file,
    required this.requestType,
  });
}

class ConsultationData {
  String? text;
  String? file;

  ConsultationData({this.text, this.file});
}
