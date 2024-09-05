import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang/screens/misc/header_text_style.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
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
        body: Column(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          color: Theme.of(context).canvasColor,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Sent",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ),
        Expanded(
          child: SfDataGridTheme(
            data: SfDataGridThemeData(
              filterPopupTextStyle: Theme.of(context).textTheme.bodyMedium,
              headerColor: Theme.of(context).canvasColor,
            ),
            child: SfDataGrid(
              source: _dataSource,
              columnWidthMode: ColumnWidthMode.fill,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              allowFiltering: true,
              showColumnHeaderIconOnHover: false,
              isScrollbarAlwaysShown: true,
              allowSorting: true,
              onCellDoubleTap: (details) async {},
              columns: [
                GridColumn(
                    columnName: 'date',
                    allowFiltering: false,
                    allowSorting: true,
                    label: Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(
                        'Date',
                        style: headerTextStyle,
                      ),
                    )),
                GridColumn(
                    columnName: 'subject',
                    allowSorting: false,
                    filterPopupMenuOptions: const FilterPopupMenuOptions(
                      canShowSortingOptions: false,
                      showColumnName: false,
                      filterMode: FilterMode.checkboxFilter,
                    ),
                    allowFiltering: true,
                    label: Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(
                        'Subject',
                        style: headerTextStyle,
                      ),
                    )),
                GridColumn(
                    columnName: 'recipientEmail',
                    allowFiltering: true,
                    filterPopupMenuOptions: const FilterPopupMenuOptions(
                      canShowSortingOptions: false,
                      showColumnName: false,
                      filterMode: FilterMode.checkboxFilter,
                    ),
                    allowSorting: false,
                    label: Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(
                        'Recipient',
                        style: headerTextStyle,
                      ),
                    )),
                GridColumn(
                  columnName: 'status',
                  allowSorting: false,
                  filterPopupMenuOptions: const FilterPopupMenuOptions(
                    canShowSortingOptions: false,
                    showColumnName: false,
                    filterMode: FilterMode.checkboxFilter,
                  ),
                  label: Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: Text(
                      'Status',
                      style: headerTextStyle,
                    ),
                  ),
                ),
              ],
            ),
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
    dataGridRows = requests.map(
      (e) {
        return DataGridRow(
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
        );
      },
    ).toList();
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
          child: Text(
            e.value.toString(),
            style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!,
          ),
        );
      }).toList(),
    );
  }

  void updateDataGridSource() {
    notifyListeners();
  }
}
