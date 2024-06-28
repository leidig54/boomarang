import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang/screens/add_request.dart';
import 'package:boomarang/screens/view_response.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:boomarang_shared/models/response.dart';
import 'package:collection/collection.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class RequesterScreen extends StatefulWidget {
  const RequesterScreen({super.key});

  @override
  State<RequesterScreen> createState() => _RequesterScreenState();
}

class _RequesterScreenState extends State<RequesterScreen> {
  List<BoomarangRequest> _requests = [];
  List<BoomarangResponse> _responses = [];
  late StreamSubscription requestStreamSubscription;
  late StreamSubscription responseStreamSubscription;

  @override
  void initState() {
    requestStreamSubscription = firestore
        .collection('requests')
        .where('requesterUserId', isEqualTo: auth.currentUser!.uid)
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
        .where('requesterUserId', isEqualTo: auth.currentUser!.uid)
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
            BoomarangResponse? response =
                _responses.firstWhereOrNull((element) => element.id == e.id);
            return DataRow(
              cells: [
                DataCell(Text(e.formattedCreatedDate)),
                DataCell(Text(e.authoriserEmail ?? 'Unknown')),
                DataCell(Text(e.holderEmail ?? 'Unknown')),
                DataCell(
                  Text(response?.status != null
                      ? response!.status!
                      : e.formattedRequestStatus),
                ),
                DataCell(Builder(builder: (context) {
                  if (e.isSubmitted == false) {
                    return TextButton(
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
                    );
                  } else if (response?.isSubmitted == true) {
                    return TextButton(
                      child: const Text('View'),
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
                                  child: ViewResponseScreen(
                                    response: response!,
                                  ),
                                ),
                              );
                            });
                      },
                    );
                  } else {
                    return Container();
                  }
                })),
              ],
            );
          }).toList()),
    );
  }
}
