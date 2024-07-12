import 'dart:async';

import 'package:boomarang/holder/screens/respond_request.dart';
import 'package:boomarang/main.dart';
import 'package:boomarang_shared/data/request_types.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:boomarang_shared/models/request_type.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_core/theme.dart';
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
      body: SfDataGridTheme(
        data: SfDataGridThemeData(
          filterPopupTextStyle: Theme.of(context).textTheme.bodyMedium,
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
          onCellDoubleTap: (details) {
            BoomarangRequest request =
                _requests[details.rowColumnIndex.rowIndex - 1];

            if (request.requestStatus == 'awaiting_response') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RespondRequestScreen(
                    request: request,
                  ),
                ),
              );
            }
          },
          columns: [
            GridColumn(
                columnName: 'received',
                allowFiltering: false,
                allowSorting: true,
                columnWidthMode: ColumnWidthMode.auto,
                label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Text(
                    'Received',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                )),
            GridColumn(
                columnName: 'subjectName',
                allowSorting: true,
                filterPopupMenuOptions: const FilterPopupMenuOptions(
                  canShowSortingOptions: false,
                  showColumnName: false,
                  filterMode: FilterMode.checkboxFilter,
                ),
                label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Text(
                    'Patient',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                )),
            GridColumn(
                columnName: 'fee_charged',
                allowSorting: false,
                allowFiltering: false,
                columnWidthMode: ColumnWidthMode.fitByColumnName,
                label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Text(
                    'Fee Charged',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                )),
            GridColumn(
              columnName: 'requestType',
              allowSorting: true,
              filterPopupMenuOptions: const FilterPopupMenuOptions(
                canShowSortingOptions: false,
                showColumnName: false,
                filterMode: FilterMode.checkboxFilter,
              ),
              label: Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                child: Text(
                  'Type',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            GridColumn(
              columnName: 'status',
              allowSorting: true,
              columnWidthMode: ColumnWidthMode.fitByColumnName,
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
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HolderDataSource extends DataGridSource {
  HolderDataSource({required List<BoomarangRequest> requests}) {
    buildDataGridRows(requests: requests);
  }

  void buildDataGridRows({required List<BoomarangRequest> requests}) {
    dataGridRows = requests.map(
      (e) {
        RequestType requestType =
            requestTypes.firstWhere((element) => element.id == e.requestType);
        return DataGridRow(
          cells: [
            DataGridCell(columnName: 'received', value: e.dateCreated),
            DataGridCell<String>(
                columnName: 'subjectName',
                value: "${e.subjectFirstName} ${e.subjectLastName}"),
            DataGridCell<String>(columnName: 'fee', value: e.formattedFee),
            // DataGridCell<bool>(columnName: 'fee_paid', value: e.feePaid),
            DataGridCell<String>(
                columnName: 'requestType', value: requestType.name),
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
            alignment: Alignment.centerRight,
            child: Text(
              formattedDateTime,
              style:
                  Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!,
            ),
          );
        }

        //if column is "Complete", show a checkbox icon
        if (e.columnName == 'status') {
          return Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Builder(builder: (context) {
              if (e.value == 'Awaiting Response') {
                return const Tooltip(
                  message: 'Awaiting Response',
                  child: Icon(
                    Icons.check_box_outline_blank,
                    color: Colors.grey,
                  ),
                );
              } else if (e.value == 'Rejected') {
                return const Tooltip(
                  message: 'Rejected',
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                );
              } else {
                return Tooltip(
                  message: 'Complete',
                  child: Icon(
                    Icons.check_box,
                    color: Theme.of(navigatorKey.currentContext!).primaryColor,
                  ),
                );
              }
            }),
          );
        }

        //if column is "fee_paid", show a checkbox icon
        if (e.columnName == 'fee_paid') {
          return Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Builder(
                builder: (context) {
                  //if null, show a dash
                  if (e.value == null) {
                    return const Text('-');
                  } else {
                    return e.value
                        ? Icon(
                            Icons.check_box,
                            color: Theme.of(navigatorKey.currentContext!)
                                .primaryColor,
                          )
                        : const Icon(
                            Icons.check_box_outline_blank,
                            color: Colors.grey,
                          );
                  }
                },
              ));
        }

        //in fee column, if fee = £0.00, show a dash
        if (e.columnName == 'fee') {
          if (e.value == '£0.00') {
            return Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerRight,
              child: const Text(
                '-',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            );
          }
        }

        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerRight,
          child: Text(
            e.value.toString(),
            style: Theme.of(navigatorKey.currentContext!).textTheme.bodyLarge!,
          ),
        );
      }).toList(),
    );
  }

  void updateDataGridSource() {
    notifyListeners();
  }
}
