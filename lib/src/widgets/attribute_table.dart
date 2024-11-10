import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AttributeTable extends StatelessWidget {
  final Map<String, String> attributes;
  final double? dataRowHeight;

  const AttributeTable({
    super.key,
    this.attributes = const <String, String>{},
    this.dataRowHeight,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      showCheckboxColumn: false,
      headingRowHeight: 0.0,
      dataRowHeight: dataRowHeight,
      columns: [DataColumn(label: Container()), DataColumn(label: Container())],
      rows: [
        ...attributes.keys
            .map<DataRow>((String key) => DataRow(
                  onSelectChanged: (_) => _onTapRow(context, key),
                  cells: [
                    DataCell(Text(key,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(
                      Text(attributes[key] ?? '', overflow: TextOverflow.clip),
                    )
                  ],
                ))
            .toList(),
      ],
    );
  }

  Future<void> _onTapRow(BuildContext context, String key) async {
    await Clipboard.setData(ClipboardData(text: attributes[key] ?? ''));
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar(reason: SnackBarClosedReason.hide);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$key wurde in die Zwischenablage kopiert'),
      duration: const Duration(seconds: 1),
    ));
  }
}
