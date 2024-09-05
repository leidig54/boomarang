import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang/screens/misc/header_text_style.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<BoomarangRequest> _requests = [];
  late StreamSubscription requestStreamSubscription;

  late RecipientDataSource _dataSource;

  @override
  void initState() {
    _dataSource = RecipientDataSource(requests: _requests);
    requestStreamSubscription = firestore
        .collection('requests')
        .where('recipientUserId', isEqualTo: auth.currentUser!.uid)
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
                  "Inbox",
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
                onCellDoubleTap: (details) {},
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
                    ),
                  ),
                  GridColumn(
                    columnName: 'subjectName',
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
                        'Subject',
                        style: headerTextStyle,
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'sender',
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
                        'Sender',
                        style: headerTextStyle,
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'status',
                    allowSorting: false,
                    // columnWidthMode: ColumnWidthMode.fitByColumnName,
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
      ),
    );
  }
}

class RecipientDataSource extends DataGridSource {
  RecipientDataSource({required List<BoomarangRequest> requests}) {
    buildDataGridRows(requests: requests);
  }

  void buildDataGridRows({required List<BoomarangRequest> requests}) {
    dataGridRows = requests.map(
      (e) {
        return DataGridRow(
          cells: [
            DataGridCell(columnName: 'received', value: e.dateCreated),
            DataGridCell<String>(
                columnName: 'subjectName',
                value: "${e.subjectFirstName} ${e.subjectLastName}"),
            DataGridCell(columnName: 'senderEmail', value: e.senderEmail),
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
  int compare(DataGridRow? a, DataGridRow? b, SortColumnDetails sortColumn) {
    //if subjectName, sort by last name
    if (sortColumn.name == 'subjectName') {
      final String? value1 = a
          ?.getCells()
          .firstWhereOrNull((element) => element.columnName == sortColumn.name)
          ?.value
          .toString();
      final String? value2 = b
          ?.getCells()
          .firstWhereOrNull((element) => element.columnName == sortColumn.name)
          ?.value
          .toString();

      if (value1 == null || value2 == null) {
        return 0;
      }

      final List<String> aName = value1.split(' ');
      final List<String> bName = value2.split(' ');

      final String aLastName = aName.last;
      final String bLastName = bName.last;

      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return aLastName.compareTo(bLastName);
      } else {
        return bLastName.compareTo(aLastName);
      }
    }
    return super.compare(a, b, sortColumn);
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        if (e.columnName == 'received') {
          late String formattedDateTime;

          //if today, show time only
          if (e.value.day == DateTime.now().day &&
              e.value.month == DateTime.now().month &&
              e.value.year == DateTime.now().year) {
            formattedDateTime = DateFormat.jm().format(e.value);
          } else {
            //show date only, no time
            formattedDateTime = DateFormat.yMMMd().format(e.value);
          }

          return Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(
              formattedDateTime,
              style:
                  Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!,
            ),
          );
        }

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
