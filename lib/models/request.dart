// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BoomarangRequest {
  String id;
  String creatorId;
  String? authoriserFirstName;
  String? authoriserLastName;
  String? authoriserEmail;
  String? requesterUserId;
  String? requesterOrgName;
  String? holderUserId;
  String? holderOrgId;
  DateTime dateCreated;
  DateTime? dateUpdated;
  DateTime? dateSubmitted;
  String? consentStatus;
  String? paymentStatus;
  String? requestStatus;
  String? requestType;
  String? requestDetails;
  String? requestFormRef;
  String? consentTemplateId;
  String? consentFormRef;
  bool? isSubmitted;
  String? knowsHolder;
  bool? hasConsent;
  BoomarangRequest({
    required this.id,
    required this.creatorId,
    required this.authoriserFirstName,
    required this.authoriserLastName,
    required this.authoriserEmail,
    required this.requesterUserId,
    required this.requesterOrgName,
    required this.holderUserId,
    required this.holderOrgId,
    required this.dateCreated,
    required this.dateUpdated,
    required this.dateSubmitted,
    required this.consentStatus,
    required this.paymentStatus,
    required this.requestStatus,
    required this.requestType,
    this.requestDetails,
    this.requestFormRef,
    required this.consentTemplateId,
    this.consentFormRef,
    required this.isSubmitted,
    required this.knowsHolder,
    required this.hasConsent,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'creatorId': creatorId,
      'authoriserFirstName': authoriserFirstName,
      'authoriserLastName': authoriserLastName,
      'authoriserEmail': authoriserEmail,
      'requesterUserId': requesterUserId,
      'requesterOrgName': requesterOrgName,
      'holderUserId': holderUserId,
      'holderOrgId': holderOrgId,
      'dateCreated': Timestamp.fromDate(dateCreated),
      'dateUpdated':
          dateUpdated != null ? Timestamp.fromDate(dateUpdated!) : null,
      'dateSubmitted':
          dateSubmitted != null ? Timestamp.fromDate(dateSubmitted!) : null,
      'consentStatus': consentStatus,
      'paymentStatus': paymentStatus,
      'requestStatus': requestStatus,
      'requestType': requestType,
      'requestDetails': requestDetails,
      'requestFormRef': requestFormRef,
      'consentTemplateId': consentTemplateId,
      'consentFormRef': consentFormRef,
      'isSubmitted': isSubmitted,
      'knowsHolder': knowsHolder,
      'hasConsent': hasConsent,
    };
  }

  factory BoomarangRequest.fromMap(Map<String, dynamic> map) {
    return BoomarangRequest(
      id: (map['id']) as String,
      creatorId: (map['creatorId']) as String,
      authoriserFirstName: map['authoriserFirstName'] != null
          ? map['authoriserFirstName'] as String
          : null,
      authoriserLastName: map['authoriserLastName'] != null
          ? map['authoriserLastName'] as String
          : null,
      authoriserEmail: map['authoriserEmail'] != null
          ? map['authoriserEmail'] as String
          : null,
      requesterUserId: map['requesterUserId'] != null
          ? map['requesterUserId'] as String
          : null,
      requesterOrgName: map['requesterOrgName'] != null
          ? map['requesterOrgName'] as String
          : null,
      holderUserId:
          map['holderUserId'] != null ? map['holderUserId'] as String : null,
      holderOrgId:
          map['holderOrgId'] != null ? map['holderOrgId'] as String : null,
      dateCreated:
          ((map['dateCreated'] ?? Timestamp(0, 0)) as Timestamp).toDate(),
      dateUpdated: map['dateUpdated'] != null
          ? ((map['dateUpdated'] ?? Timestamp(0, 0)) as Timestamp).toDate()
          : null,
      dateSubmitted: map['dateSubmitted'] != null
          ? ((map['dateSubmitted'] ?? Timestamp(0, 0)) as Timestamp).toDate()
          : null,
      consentStatus:
          map['consentStatus'] != null ? map['consentStatus'] as String : null,
      paymentStatus:
          map['paymentStatus'] != null ? map['paymentStatus'] as String : null,
      requestStatus:
          map['requestStatus'] != null ? map['requestStatus'] as String : null,
      requestType:
          map['requestType'] != null ? map['requestType'] as String : null,
      requestDetails: map['requestDetails'] != null
          ? map['requestDetails'] as String
          : null,
      requestFormRef: map['requestFormRef'] != null
          ? map['requestFormRef'] as String
          : null,
      consentTemplateId: map['consentTemplateId'] != null
          ? map['consentTemplateId'] as String
          : null,
      consentFormRef: map['consentFormRef'] != null
          ? map['consentFormRef'] as String
          : null,
      isSubmitted:
          map['isSubmitted'] != null ? map['isSubmitted'] as bool : null,
      knowsHolder:
          map['knowsHolder'] != null ? map['knowsHolder'] as String : null,
      hasConsent: map['hasConsent'] != null ? map['hasConsent'] as bool : null,
    );
  }

  String get formattedCreatedDate {
    return DateFormat.yMMMMEEEEd().add_jms().format(dateCreated);
  }
}
