import 'package:flutter/material.dart';

import '/src/models/item.dart';
import '/src/util/format_util.dart';

class ItemsCard extends StatelessWidget {
  final List<Item> items;
  final int sum;

  const ItemsCard({super.key, required this.items, required this.sum});

  List<DataRow> get _rows => <DataRow>[
        ...items.map(
          (Item i) => DataRow(
            cells: [
              DataCell(Text(i.title)),
              DataCell(Text(i.description ?? '')),
              DataCell(Text('${i.quantity}x')),
              DataCell(Text('${i.tax}%')),
              DataCell(Text(formatFigure(i.price) ?? '')),
              DataCell(Text(formatFigure(i.sum) ?? '')),
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
          columns: _column(context),
          rows: _rows,
        ),
      ),
    );
  }

  List<DataColumn> _column(BuildContext context) => <DataColumn>[
        DataColumn(
            label: Text(
          'Name',
          style: Theme.of(context).textTheme.labelLarge,
        )),
        DataColumn(
            label: Text(
          'Beschreibung',
          style: Theme.of(context).textTheme.labelLarge,
        )),
        DataColumn(
            label: Text(
          'Menge',
          style: Theme.of(context).textTheme.labelLarge,
        )),
        DataColumn(
            label: Text(
          'Ust.',
          style: Theme.of(context).textTheme.labelLarge,
        )),
        DataColumn(
            label: Text(
          'Einzelpreis',
          style: Theme.of(context).textTheme.labelLarge,
        )),
        DataColumn(
            label: Text(
          'Nettopreis',
          style: Theme.of(context).textTheme.labelLarge,
        )),
      ];
}
