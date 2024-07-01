import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

Future<void> submitRequest({
  required GlobalKey<FormBuilderState> contactDetailsFormKey,
  required GlobalKey<FormBuilderState> requestDetailsFormKey,
  required GlobalKey<FormBuilderState> consentDetailsFormKey,
  required String? requestFormName,
  required String? consentFormName,
  required String id,
}) async {
  BoomarangRequest newRequest = BoomarangRequest(
    id: id,
    holderEmail:
        contactDetailsFormKey.currentState!.fields['holder_email']?.value,
    subjectFirstName:
        contactDetailsFormKey.currentState!.fields['subject_first_name']?.value,
    subjectLastName:
        contactDetailsFormKey.currentState!.fields['subject_last_name']?.value,
    subjectEmail:
        contactDetailsFormKey.currentState!.fields['subject_email']?.value,
    subjectDOB: DateFormat('dd/MM/yyyy').tryParse(
        contactDetailsFormKey.currentState!.fields['subject_dob']?.value ?? ""),
    subjectEmailVerified: false,
    requesterUserId: auth.currentUser!.uid,
    requesterOrgName: null,
    requestEmail: auth.currentUser!.email,
    holderUserId: null,
    holderOrgId: null,
    dateCreated: DateTime.now(),
    dateUpdated: DateTime.now(),
    dateSubmitted: DateTime.now(),
    consentVerified: false,
    paymentStatus: 'payment_pending',
    requestStatus: 'awaiting_response',
    requestType: requestDetailsFormKey.currentState!.fields['type']?.value,
    requestDetails:
        requestDetailsFormKey.currentState!.fields['request_details']?.value,
    requestFormRef: requestFormName == null
        ? null
        : requestDetailsFormKey.currentState!.fields['request_form_ref']?.value,
    consentTemplateId:
        consentDetailsFormKey.currentState!.fields['consent_template']?.value,
    consentFormRef: consentFormName == null
        ? null
        : consentDetailsFormKey.currentState!.fields['consent_form_ref']?.value,
  );

  return await firestore.collection('requests').doc(id).set(newRequest.toMap());
}
