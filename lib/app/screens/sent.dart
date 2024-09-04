import 'dart:async';

import 'package:boomarang/app/screens/view_response.dart';
import 'package:boomarang/main.dart';
import 'package:boomarang/misc/tab_index_provider.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:boomarang_shared/models/response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SentScreen extends StatefulWidget {
  const SentScreen({super.key});

  @override
  State<SentScreen> createState() => _SentScreenState();
}

class _SentScreenState extends State<SentScreen> {
  List<BoomarangRequest> _requests = [];
  late StreamSubscription requestStreamSubscription;

  late SenderDataSource _dataSource;

  @override
  void initState() {
    _dataSource = SenderDataSource(requests: _requests);
    requestStreamSubscription = firestore
        .collection('requests')
        .where('senderUserId', isEqualTo: auth.currentUser!.uid)
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
        body: SfDataGrid(
      source: _dataSource,
      columnWidthMode: ColumnWidthMode.fill,
      gridLinesVisibility: GridLinesVisibility.both,
      headerGridLinesVisibility: GridLinesVisibility.both,
      onCellDoubleTap: (details) async {
        final row = details.rowColumnIndex.rowIndex;

        //if request status is pending_completion, navigate to the add request screen
        if (_requests[row - 1].requestStatus == 'pending_completion') {
          context.read<TabIndexProvider>().setScreen(_requests[row - 1]);
          return;
        }
        //get the response for the request
        final responseData = await firestore
            .collection('responses')
            .where('id', isEqualTo: _requests[row - 1].id)
            .get();

        BoomarangResponse response =
            BoomarangResponse.fromMap(responseData.docs.first.data());

        if (!context.mounted) return;

        //navigate to the response screen
        showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: ViewResponseScreen(response: response),
              );
            });

        //
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
            columnName: 'subject',
            label: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: const Text('Subject'),
            )),
        GridColumn(
            columnName: 'recipientEmail',
            label: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: const Text('Recipient'),
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

class SenderDataSource extends DataGridSource {
  SenderDataSource({required List<BoomarangRequest> requests}) {
    buildDataGridRows(requests: requests);
  }

  void buildDataGridRows({required List<BoomarangRequest> requests}) {
    dataGridRows = requests
        .map(
          (e) => DataGridRow(
            cells: [
              DataGridCell<String>(
                  columnName: 'date', value: e.formattedCreatedDateOrTime),
              DataGridCell<String>(
                  columnName: 'subject',
                  value: "${e.subjectFirstName} ${e.subjectLastName}"),
              DataGridCell<String>(
                  columnName: 'recipientEmail', value: e.recipientEmail),
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
