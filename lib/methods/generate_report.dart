import 'package:boomarang/main.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

Future<String> generateReport(String request, String consultations) async {
  String input = "Request:  $request\nConsultations:  $consultations";

  String prompt =
      "You are an medical admin assistant you need to write a medical report to satisfy the following request, given the following information. Only use what is containined in the information provided. Do not add any extra findings, recommendations or anything else that is not explicitly stated in the information provided.$input";

  GenerateContentResponse response =
      await model.generateContent([Content.text(prompt)]);

  if (response.text == null) {
    throw Exception('Failed to generate report');
  }

  return response.text!;
}
