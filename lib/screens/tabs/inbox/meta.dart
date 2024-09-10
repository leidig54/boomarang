import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart';

class RequestMeta extends StatelessWidget {
  const RequestMeta({
    super.key,
    required this.selectedRequest,
  });

  final BoomarangRequest selectedRequest;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        //received date
        const Text("Details"),
        ListTile(
          subtitle: const Text("Received"),
          title: Text(
            selectedRequest.formattedCreatedFullDate,
          ),
          leading: const Icon(Icons.calendar_today),
        ),
        const SizedBox(
          height: 16,
        ),
        const Text("Requester"),
        //sender email
        ListTile(
          subtitle: const Text("Email"),
          title: Text(
            selectedRequest.senderEmail ?? "Unknown",
          ),
          leading: const Icon(Icons.send),
        ),
        const SizedBox(
          height: 16,
        ),
        const Text("Subject"),
        //subject details
        ListTile(
          subtitle: const Text("Name"),
          title: Text(
            "${selectedRequest.subjectFirstName} ${selectedRequest.subjectLastName}",
          ),
          leading: const Icon(Icons.person),
        ),
        //dob verified
        ListTile(
          subtitle: const Text("Date of Birth"),
          title: Text(
            selectedRequest.formattedSubjectDob,
          ),
          leading: const Icon(Icons.cake),
        ),
        ListTile(
          subtitle: const Text("Email"),
          title: Text(
            selectedRequest.subjectEmail ?? "Unknown",
          ),
          leading: const Icon(Icons.email),
        ),
        const SizedBox(
          height: 16,
        ),
        const Text("Identity Verification"),
        //email verified
        ListTile(
          title: const Text("Email"),
          subtitle: Text(
            selectedRequest.subjectEmailVerified == true
                ? "Verified"
                : "Not Verified",
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
          title: const Text("Date of Birth"),
          subtitle: Text(
            selectedRequest.subjectDOBVerified == true
                ? "Verified"
                : "Not Verified",
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
          height: 16,
        ),
        //consent details
        const Text("Consent Details"),
        ListTile(
          title: const Text("Standard Consent Policy"),
          subtitle: Text(
            selectedRequest.consentVerified == true
                ? "Accepted"
                : "Not Accepted",
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
          height: 16,
        ),
        //consent details
        const Text("Response"),
        ListTile(
          subtitle: const Text("Status"),
          title: Text(
            selectedRequest.requestStatus == "response_submitted"
                ? "Submitted"
                : "Incomplete",
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
