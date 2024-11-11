import 'package:flutter/material.dart';

class BaseShortcut extends StatelessWidget {
  final BuildContext context;
  final List<Widget> children;
  final Function()? onTap;

  const BaseShortcut(
    this.context, {
    super.key,
    required this.children,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 0.0,
      color: Theme.of(context).splashColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
