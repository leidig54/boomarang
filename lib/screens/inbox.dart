import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang/screens/add_request.dart';
import 'package:boomarang/screens/view_request.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:boomarang_shared/models/response.dart';
import 'package:collection/collection.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<BoomarangRequest> _requests = [];
  List<BoomarangResponse> _responses = [];
  late StreamSubscription requestStreamSubscription;
  late StreamSubscription responseStreamSubscription;

  @override
  void initState() {
    requestStreamSubscription = firestore
        .collection('requests')
        .where('holderUserId', isEqualTo: auth.currentUser!.uid)
        .where('isSubmitted', isEqualTo: true)
        .where('hasConsent', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _requests =
          snapshot.docs.map((e) => BoomarangRequest.fromMap(e.data())).toList();
      _requests.sort((a, b) {
        return b.dateCreated.compareTo(a.dateCreated);
      });
      setState(() {});
    });

    responseStreamSubscription = firestore
        .collection('responses')
        .where('holderUserId', isEqualTo: auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      _responses = snapshot.docs
          .map((e) => BoomarangResponse.fromMap(e.data()))
          .toList();
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
      body: DataTable2(
        showBottomBorder: true,
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
            label: Text('Status'),
            tooltip: 'The status of the request',
          ),
          DataColumn(
            label: Text('Actions'),
            tooltip: 'The action to take on the request',
          ),
        ],
        rows: _requests.map(
          (request) {
            BoomarangResponse? response = _responses
                .firstWhereOrNull((element) => element.id == request.id);
            return DataRow(
              cells: [
                DataCell(
                  Text(request.formattedCreatedDate),
                ),
                DataCell(Text(request.authoriserEmail ?? 'Unknown')),
                DataCell(Text(request.requestEmail ?? 'Unknown')),
                DataCell(
                  Text(response?.status ?? 'Not Started'),
                ),
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
                                      borderRadius: BorderRadius.circular(16),
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
                                      borderRadius: BorderRadius.circular(16),
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
            );
          },
        ).toList(),
      ),
    );
  }
}
