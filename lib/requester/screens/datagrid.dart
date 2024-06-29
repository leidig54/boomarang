import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang/requester/screens/add_request.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class RequesterDatagridScreen extends StatefulWidget {
  const RequesterDatagridScreen({super.key});

  @override
  State<RequesterDatagridScreen> createState() =>
      _RequesterDatagridScreenState();
}

class _RequesterDatagridScreenState extends State<RequesterDatagridScreen> {
  List<BoomarangRequest> _requests = [];
  late StreamSubscription requestStreamSubscription;

  late RequesterDataSource _dataSource;

  @override
  void initState() {
    _dataSource = RequesterDataSource(requests: _requests);
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
      _dataSource.buildDataGridRows(requests: _requests);
      _dataSource.updateDataGridSource();
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
                      child: AddRequestScreen(),
                    ),
                  );
                });
          },
          icon: const Icon(Icons.add),
        ),
        body: SfDataGrid(
          source: _dataSource,
          columnWidthMode: ColumnWidthMode.fill,
          frozenRowsCount: 1,
          gridLinesVisibility: GridLinesVisibility.both,
          headerGridLinesVisibility: GridLinesVisibility.both,
          allowSorting: true,
          allowFiltering: true,
          columns: [
            GridColumn(
                columnName: 'date',
                label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: const Text('Date'),
                )),
            GridColumn(
                columnName: 'subjectEmail',
                label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: const Text('Subject'),
                )),
            GridColumn(
                columnName: 'requestEmail',
                label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: const Text('Requester'),
                )),
            GridColumn(
              columnName: 'status',
              label: Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                child: const Text('Status'),
              ),
            ),
          ],
        ));
  }
}

class RequesterDataSource extends DataGridSource {
  RequesterDataSource({required List<BoomarangRequest> requests}) {
    buildDataGridRows(requests: requests);
  }

  void buildDataGridRows({required List<BoomarangRequest> requests}) {
    dataGridRows = requests
        .map(
          (e) => DataGridRow(
            cells: [
              DataGridCell<String>(
                  columnName: 'date', value: e.formattedCreatedDate),
              DataGridCell<String>(
                  columnName: 'subjectEmail', value: e.subjectEmail),
              DataGridCell<String>(
                  columnName: 'requestEmail', value: e.requestEmail),
              DataGridCell<String>(
                  columnName: 'status', value: e.requestStatus),
            ],
          ),
        )
        .toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(e.value.toString()),
        );
      }).toList(),
    );
  }

  void updateDataGridSource() {
    notifyListeners();
  }
}
