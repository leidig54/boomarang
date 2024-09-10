import 'package:boomarang/providers/request_provider.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestMeta extends StatelessWidget {
  const RequestMeta({
    super.key,
    required this.selectedRequest,
  });

  final BoomarangRequest selectedRequest;

  @override
  Widget build(BuildContext context) {
    BoomarangRequest request =
        context.watch<RequestProvider>().receivedRequests.firstWhere(
              (element) => element.id == selectedRequest.id,
            );
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32),
      children: [
        //received date
        const Text("Details"),
        ListTile(
          subtitle: const Text("Received"),
          title: Text(
            request.formattedCreatedFullDate,
          ),
          leading: const Icon(Icons.calendar_today),
        ),
        const SizedBox(
          height: 32,
        ),
        const Text("Requester"),
        //sender email
        ListTile(
          subtitle: const Text("Email"),
          title: Text(
            request.senderEmail ?? "Unknown",
          ),
          leading: const Icon(Icons.send),
        ),
        const SizedBox(
          height: 32,
        ),
        const Text("Subject"),
        //subject details
        ListTile(
          subtitle: const Text("Name"),
          title: Text(
            "${request.subjectFirstName} ${request.subjectLastName}",
          ),
          leading: const Icon(Icons.person),
        ),
        //dob verified
        ListTile(
          subtitle: const Text("Date of Birth"),
          title: Text(
            request.formattedSubjectDob,
          ),
          leading: const Icon(Icons.cake),
        ),
        ListTile(
          subtitle: const Text("Email"),
          title: Text(
            request.subjectEmail ?? "Unknown",
          ),
          leading: const Icon(Icons.email),
        ),
        const SizedBox(
          height: 32,
        ),
        const Text("Identity Verification"),
        //email verified
        ListTile(
          title: const Text("Email"),
          subtitle: Text(
            request.subjectEmailVerified == true ? "Verified" : "Not Verified",
          ),
          leading: request.subjectEmailVerified == true
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
            request.subjectDOBVerified == true ? "Verified" : "Not Verified",
          ),
          leading: request.subjectDOBVerified == true
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
        const Text("Consent Details"),
        ListTile(
          title: const Text("Standard Consent Policy"),
          subtitle: Text(
            request.consentVerified == true ? "Accepted" : "Not Accepted",
          ),
          leading: request.consentVerified == true
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
        const Text("Response"),
        ListTile(
          subtitle: const Text("Status"),
          title: Text(
            request.responseSubmitted ? "Submitted" : "Incomplete",
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
