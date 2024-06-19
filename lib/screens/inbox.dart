import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang/models/request.dart';
import 'package:boomarang/screens/add_request.dart';
import 'package:boomarang/screens/view_request.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<BoomarangRequest> _requests = [];
  String? errorMessage;
  late StreamSubscription requestStreamSubscription;

  @override
  void initState() {
    requestStreamSubscription =
        firestore.collection('requests').snapshots().listen((snapshot) {
      _requests =
          snapshot.docs.map((e) => BoomarangRequest.fromMap(e.data())).toList();
      _requests.sort((a, b) {
        return b.dateCreated.compareTo(a.dateCreated);
      });
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    requestStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Inbox'),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New Request'),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: const SizedBox(
                            width: 1200,
                            height: 800,
                            child: AddRequestScreen(
                              request: null,
                            ),
                          ),
                        );
                      });
                },
              ),
            ),
          ],
        ),
        body: Builder(builder: (context) {
          return DataTable2(
            headingTextStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.bold),
            columns: const [
              DataColumn(
                label: Text('Date'),
                tooltip: 'The date of the request',
              ),
              DataColumn(
                label: Text('Authoriser'),
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
              //type§
              DataColumn(
                label: Text('Type'),
                tooltip: 'The type of request',
              ),
              DataColumn(
                label: Text("Actions"),
              ),
            ],
            rows: _requests
                .map((request) => DataRow(
                      cells: [
                        DataCell(
                          Text(request.formattedCreatedDate),
                        ),
                        DataCell(Text(
                            '${request.authoriserFirstName} ${request.authoriserLastName}')),
                        DataCell(Text(request.requesterOrgName ?? 'Unknown')),
                        DataCell(Text(request.consentStatus ?? 'Unknown')),
                        DataCell(Text(request.paymentStatus ?? 'Unknown')),
                        DataCell(Text(request.holderUserId ?? 'Unknown')),
                        DataCell(Text(request.requestStatus ?? 'Unknown')),
                        DataCell(Text(request.requestType ?? 'Unknown')),
                        DataCell(
                          Builder(
                            builder: (context) {
                              if (request.isSubmitted == true) {
                                return TextButton.icon(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: SizedBox(
                                              width: 1200,
                                              height: 800,
                                              child: ViewRequestScreen(
                                                request: request,
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  label: const Text("Respond"),
                                );
                              } else {
                                return TextButton.icon(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: SizedBox(
                                              width: 1200,
                                              height: 800,
                                              child: AddRequestScreen(
                                                request: request,
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  label: const Text("Edit"),
                                );
                              }
                            },
                          ),
                        )
                      ],
                    ))
                .toList(),
          );
        }));
  }
}
