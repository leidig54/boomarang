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
        .where('requesterId', isEqualTo: auth.currentUser!.uid)
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
            //holder
            DataColumn(
              label: Text('Holder'),
              tooltip: 'The entity who holds the data',
            ),
            //status
            DataColumn(
              label: Text('Status'),
              tooltip: 'The status of the request',
            ),
            DataColumn(
              label: Text('Actions'),
              tooltip: 'The actions that can be taken on the request',
            ),
          ],
          rows: _requests.map((e) {
            return DataRow(
              cells: [
                DataCell(Text(e.formattedCreatedDate)),
                DataCell(Text(e.authoriserEmail ?? 'Unknown')),
                DataCell(Text(e.holderEmail ?? 'Unknown')),
                DataCell(Text(e.formattedRequestStatus)),
                DataCell(
                  e.isSubmitted == true
                      ? TextButton(
                          child: const Text('View'),
                          onPressed: () {},
                        )
                      : TextButton(
                          child: const Text('Edit'),
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
                ),
              ],
            );
          }).toList()),
    );
  }
}
