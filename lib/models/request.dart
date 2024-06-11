// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class BoomarangRequest {
  String id;
  String authoriserFirstName;
  String authoriserLastName;
  String authoriserEmail;
  String authoriserPhoneNumber;
  String requesterUserId;
  String holderUserId;
  DateTime dateCreated;
  DateTime dateUpdated;
  String consentStatus;
  String paymentStatus;
  String requestStatus;
  BoomarangRequest({
    required this.id,
    required this.authoriserFirstName,
    required this.authoriserLastName,
    required this.authoriserEmail,
    required this.authoriserPhoneNumber,
    required this.requesterUserId,
    required this.holderUserId,
    required this.dateCreated,
    required this.dateUpdated,
    required this.consentStatus,
    required this.paymentStatus,
    required this.requestStatus,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'authoriserFirstName': authoriserFirstName,
      'authoriserLastName': authoriserLastName,
      'authoriserEmail': authoriserEmail,
      'authoriserPhoneNumber': authoriserPhoneNumber,
      'requesterUserId': requesterUserId,
      'holderUserId': holderUserId,
      'dateCreated': Timestamp.fromDate(dateCreated),
      'dateUpdated': Timestamp.fromDate(dateUpdated),
      'consentStatus': consentStatus,
      'paymentStatus': paymentStatus,
      'requestStatus': requestStatus,
    };
  }

  factory BoomarangRequest.fromMap(Map<String, dynamic> map) {
    return BoomarangRequest(
      id: (map['id']) as String,
      authoriserFirstName: (map['authoriserFirstName']) as String,
      authoriserLastName: (map['authoriserLastName']) as String,
      authoriserEmail: (map['authoriserEmail']) as String,
      authoriserPhoneNumber: (map['authoriserPhoneNumber']) as String,
      requesterUserId: (map['requesterUserId']) as String,
      holderUserId: (map['holderUserId']) as String,
      dateCreated:
          ((map['dateCreated'] ?? Timestamp(0, 0)) as Timestamp).toDate(),
      dateUpdated:
          ((map['dateUpdated'] ?? Timestamp(0, 0)) as Timestamp).toDate(),
      consentStatus: (map['consentStatus']) as String,
      paymentStatus: (map['paymentStatus']) as String,
      requestStatus: (map['requestStatus']) as String,
    );
  }
}
