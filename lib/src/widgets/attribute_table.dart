import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AttributeTable extends StatelessWidget {
  final Map<String, String> attributes;

  const AttributeTable({Key key, this.attributes = const <String, String>{}}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: {
        0: FlexColumnWidth(),
        1: FlexColumnWidth(),
      },
      border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey[300])),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        ...attributes.keys
            .map<TableRow>(
              (String key) => TableRow(
                children: [
                  TableCell(
                    child: Padding(padding: EdgeInsets.all(8.0), child: Text(key)),
                  ),
                  TableCell(
                    child: InkWell(
                      onTap: () => _onTapRow(context, key),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(attributes[key]),
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ],
    );
  }

  Future<void> _onTapRow(BuildContext context, String key) async {
    await Clipboard.setData(ClipboardData(text: attributes[key]));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$key wurde in die Zwischenablage kopiert'),
      duration: const Duration(seconds: 1),
    ));
  }
}
