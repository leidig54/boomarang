import 'dart:async';

import 'package:boomarang/holder/screens/respond_request.dart';
import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class HolderDatagridScreen extends StatefulWidget {
  const HolderDatagridScreen({super.key});

  @override
  State<HolderDatagridScreen> createState() => _HolderDatagridScreenState();
}

class _HolderDatagridScreenState extends State<HolderDatagridScreen> {
  List<BoomarangRequest> _requests = [];
  late StreamSubscription requestStreamSubscription;

  late HolderDataSource _dataSource;

  @override
  void initState() {
    _dataSource = HolderDataSource(requests: _requests);
    requestStreamSubscription = firestore
        .collection('requests')
        .where('holderUserId', isEqualTo: auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      _requests =
          snapshot.docs.map((e) => BoomarangRequest.fromMap(e.data())).toList();
      _requests.sort((a, b) {
        return b.dateCreated.compareTo(a.dateCreated);
      });
      _dataSource.buildDataGridRows(requests: _requests);
      _dataSource.updateDataGridSource();
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
      body: SfDataGrid(
        source: _dataSource,
        columnWidthMode: ColumnWidthMode.fill,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        onCellDoubleTap: (details) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RespondRequestScreen(
                request: _requests[details.rowColumnIndex.rowIndex - 1],
              ),
            ),
          );
        },
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
      ),
    );
  }
}

class HolderDataSource extends DataGridSource {
  HolderDataSource({required List<BoomarangRequest> requests}) {
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
                  columnName: 'status', value: e.formattedRequestStatus),
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
