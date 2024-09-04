import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

Future<void> submitRequest({
  GlobalKey<FormBuilderState>? contactDetailsFormKey,
  GlobalKey<FormBuilderState>? requestDetailsFormKey,
  GlobalKey<FormBuilderState>? consentDetailsFormKey,
  String? requestFormName,
  String? consentFormName,
  required String id,
}) async {
  BoomarangRequest newRequest = BoomarangRequest(
    id: id,
    recipientEmail:
        contactDetailsFormKey?.currentState!.fields['to_email']?.value,
    subjectFirstName: contactDetailsFormKey
        ?.currentState!.fields['subject_first_name']?.value,
    subjectLastName:
        contactDetailsFormKey?.currentState!.fields['subject_last_name']?.value,
    subjectEmail:
        contactDetailsFormKey?.currentState!.fields['subject_email']?.value,
    subjectDOB: DateFormat('dd/MM/yyyy').tryParse(
        contactDetailsFormKey?.currentState!.fields['subject_dob']?.value ??
            ""),
    subjectEmailVerified: false,
    senderUserId: auth.currentUser!.uid,
    recipientUserID: null,
    dateCreated: DateTime.now(),
    consentVerified: false,
    requestStatus: 'awaiting_response',
    requestType: requestDetailsFormKey?.currentState!.fields['type']?.value,
    requestDetails:
        requestDetailsFormKey?.currentState!.fields['request_details']?.value,
  );

  return await firestore.collection('requests').doc(id).set(newRequest.toMap());
}
