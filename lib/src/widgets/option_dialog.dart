import 'package:flutter/material.dart';

class OptionDialog extends StatefulWidget {
  final String titleText;
  final List<Widget> children;
  final List<Widget> actions;

  final bool disableCheckbox;
  final bool checked;
  final Function(bool)? onChecked;
  final String checkboxText;

  const OptionDialog({
    super.key,
    required this.titleText,
    this.actions = const <Widget>[],
    this.children = const <Widget>[],
    this.disableCheckbox = false,
    this.checked = true,
    this.onChecked,
    this.checkboxText = '',
  });

  @override
  _OptionDialogState createState() => _OptionDialogState();
}

class _OptionDialogState extends State<OptionDialog> {
  bool checked = false;

  @override
  void initState() {
    checked = widget.checked;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(16.0),
      title: Text(widget.titleText),
      children: [
        ...widget.children,
        if (!widget.disableCheckbox)
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: CheckboxListTile(
              value: checked,
              onChanged: (bool? input) {
                setState(() => checked = input ?? false);
                
                widget.onChecked?.call(checked);
              },
              title: Text(widget.checkboxText),
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [...widget.actions],
          ),
        ),
      ],
    );
  }
}
