import 'package:flutter/material.dart';

import '../../models/item.dart';
import '../../util/format_util.dart';

class ItemsCard extends StatelessWidget {
  final List<Item> items;
  final int sum;

  const ItemsCard({Key key, @required this.items, @required this.sum}) : super(key: key);

  List<DataColumn> get _column => <DataColumn>[
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Beschreibung')),
        DataColumn(label: Text('Menge')),
        DataColumn(label: Text('Ust.')),
        DataColumn(label: Text('Einzelpreis')),
        DataColumn(label: Text('Nettopreis')),
      ];

  List<DataRow> get _rows => <DataRow>[
        ...items.map(
          (Item i) => DataRow(
            cells: [
              DataCell(Text(i.title)),
              DataCell(Text(i.description)),
              DataCell(Text('${i.quantity}x')),
              DataCell(Text('${i.tax}%')),
              DataCell(Text(formatFigure(i.price))),
              DataCell(Text(formatFigure(i.sum))),
            ],
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: DataTable(
          headingRowHeight: 40.0,
          showCheckboxColumn: false,
          columns: _column,
          rows: _rows,
        ),
      ),
    );
  }
}
