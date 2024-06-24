import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang/screens/add_request.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class SentScreen extends StatefulWidget {
  const SentScreen({super.key});

  @override
  State<SentScreen> createState() => _SentScreenState();
}

class _SentScreenState extends State<SentScreen> {
  List<BoomarangRequest> _requests = [];
  late StreamSubscription requestStreamSubscription;

  @override
  void initState() {
    requestStreamSubscription = firestore
        .collection('requests')
        .where('creatorId', isEqualTo: auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
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
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Add Request'),
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
        icon: const Icon(Icons.add),
      ),
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
              label: Text('Consent'),
              tooltip: 'The consent status of the request',
            ),
            DataColumn(
              label: Text('Actions'),
              tooltip: 'Actions that can be performed on the request',
            ),
          ],
          rows: _requests.map((e) {
            return DataRow(
              cells: [
                DataCell(Text(e.dateCreated.toString())),
                DataCell(Text(e.authoriserEmail ?? 'Unknown')),
                DataCell(Text(e.requesterOrgName ?? 'Unknown')),
                DataCell(Text(e.consentStatus ?? 'Unknown')),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
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
                                      request: e,
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Request'),
                                  content: const Text(
                                      'Are you sure you want to delete this request?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        firestore
                                            .collection('requests')
                                            .doc(e.id)
                                            .delete();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Yes'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('No'),
                                    ),
                                  ],
                                );
                              });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList()),
    );
  }
}
