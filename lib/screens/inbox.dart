import 'package:boomarang/main.dart';
import 'package:boomarang/models/request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Inbox'),
        ),
        body: FutureBuilder(
            future: kDebugMode && useEmulators
                ? firestore.collection('requests').get()
                : firestore
                    .collection('requests')
                    .where('holderUserId', isEqualTo: auth.currentUser!.uid)
                    .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No requests found'),
                );
              }

              List<BoomarangRequest> requests = snapshot.data!.docs
                  .map((doc) => BoomarangRequest.fromMap(doc.data()))
                  .toList();

              return Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: DataTable(
                        sortColumnIndex: 0,
                        columns: const [
                          DataColumn(
                            label: Text('Date'),
                            tooltip: 'The date of the request',
                          ),
                          DataColumn(
                            label: Text('Name'),
                            tooltip: 'The name of the individual',
                          ),
                          DataColumn(
                            label: Text('Requester'),
                            tooltip: 'The entity who made the request',
                          ),
                          DataColumn(
                            label: Text('Consent'),
                            tooltip: 'The consent status of the request',
                          ),
                          DataColumn(
                            label: Text('Payment'),
                            tooltip: 'The payment status of the request',
                          ),
                          DataColumn(
                            label: Text('Assigned'),
                            tooltip: 'The person assigned to the request',
                          ),
                          DataColumn(
                            label: Text('Complete'),
                            tooltip: 'The completion status of the request',
                          ),
                        ],
                        rows: requests
                            .map((request) => DataRow(
                                  cells: [
                                    DataCell(
                                        Text(request.dateCreated.toString())),
                                    DataCell(Text(
                                        '${request.authoriserFirstName} ${request.authoriserLastName}')),
                                    DataCell(Text(request.authoriserEmail)),
                                    DataCell(Text(request.consentStatus)),
                                    DataCell(Text(request.paymentStatus)),
                                    DataCell(Text(request.holderUserId)),
                                    DataCell(Text(request.requestStatus)),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              );
            }));
  }
}
