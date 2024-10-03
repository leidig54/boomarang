import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart';

class RequestMeta extends StatelessWidget {
  const RequestMeta({
    super.key,
    required this.selectedRequest,
    required this.inbox,
  });

  final BoomarangRequest selectedRequest;
  final bool inbox;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32),
      children: [
        //received date
        const Text(
          "Details",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        ListTile(
          subtitle: const Text(
            "Received",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          title: Text(
            selectedRequest.formattedCreatedFullDate,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const Icon(Icons.calendar_today),
        ),
        //request type
        ListTile(
          subtitle: const Text(
            "Type",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          title: Text(
            selectedRequest.form.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const Icon(Icons.select_all),
        ),
        const SizedBox(
          height: 32,
        ),
        Text(
          inbox ? "Sender" : "Recipient",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        //sender email
        ListTile(
          subtitle: const Text(
            "Email",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          title: Text(
            inbox
                ? selectedRequest.senderEmail ?? "Unknown"
                : selectedRequest.recipientEmail ?? "Unknown",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const Icon(Icons.send),
        ),
        //Organisation ID
        ListTile(
          title: Text(
            inbox
                ? selectedRequest.senderOrganisationName ?? "Unknown"
                : selectedRequest.recipientOrganisationName ?? "Unknown",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: const Text(
            "Organisation",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const Icon(Icons.business),
        ),
        const SizedBox(
          height: 32,
        ),
        const Text(
          "Subject",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        //subject details
        ListTile(
          subtitle: const Text(
            "Name",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          title: Text(
            "${selectedRequest.subjectFirstName} ${selectedRequest.subjectLastName}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const Icon(Icons.person),
        ),
        //dob verified
        ListTile(
          subtitle: const Text(
            "Date of Birth",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          title: Text(
            selectedRequest.formattedSubjectDob,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const Icon(Icons.cake),
        ),
        ListTile(
          subtitle: const Text(
            "Email",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          title: Text(
            selectedRequest.subjectEmail ?? "Unknown",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const Icon(Icons.email),
        ),
        const SizedBox(
          height: 32,
        ),
        const Text(
          "Identity Verification",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        //email verified
        ListTile(
          title: const Text(
            "Email",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            selectedRequest.subjectEmailVerified == true
                ? "Verified"
                : "Not Verified",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: selectedRequest.subjectEmailVerified == true
              ? const Icon(
                  Icons.verified,
                )
              : const Icon(
                  Icons.warning,
                ),
        ),
        //dob verified
        ListTile(
          title: const Text(
            "Date of Birth",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            selectedRequest.subjectDOBVerified == true
                ? "Verified"
                : "Not Verified",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: selectedRequest.subjectDOBVerified == true
              ? const Icon(
                  Icons.verified,
                )
              : const Icon(
                  Icons.warning,
                ),
        ),
        const SizedBox(
          height: 32,
        ),
        //consent details
        const Text(
          "Consent Details",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        ListTile(
          title: const Text(
            "Standard Consent Policy",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            selectedRequest.consentVerified == true
                ? "Accepted"
                : "Not Accepted",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: selectedRequest.consentVerified == true
              ? const Icon(
                  Icons.verified,
                )
              : const Icon(
                  Icons.warning,
                ),
          //generic consent policy highlights in a list
        ),
        const SizedBox(
          height: 32,
        ),
        //consent details
        const Text(
          "Response",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        ListTile(
          subtitle: const Text(
            "Status",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          title: Text(
            selectedRequest.formattedRequestStatus,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          leading: const Icon(Icons.info),
        ),
        const SizedBox(
          height: 100,
        ),
      ],
    );
  }
}
