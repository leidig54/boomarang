import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:boomarang_shared/models/response.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class HolderScreen extends StatefulWidget {
  const HolderScreen({super.key});

  @override
  State<HolderScreen> createState() => _HolderScreenState();
}

class _HolderScreenState extends State<HolderScreen> {
  List<BoomarangRequest> _requests = [];
  List<BoomarangResponse> _responses = [];
  late StreamSubscription requestStreamSubscription;
  late StreamSubscription responseStreamSubscription;

  late HolderDataSource _dataSource;

  @override
  void initState() {
    _dataSource = HolderDataSource(requests: _requests);
    requestStreamSubscription = firestore
        .collection('requests')
        .where('holderUserId', isEqualTo: auth.currentUser!.uid)
        .where('isSubmitted', isEqualTo: true)
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
    responseStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfDataGrid(
        source: _dataSource,
        frozenRowsCount: 1,
        columnWidthMode: ColumnWidthMode.fill,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.none,
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
