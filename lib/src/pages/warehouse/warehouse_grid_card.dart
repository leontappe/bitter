import 'package:flutter/material.dart';

class WarehouseGridCard extends StatelessWidget {
  final Function() onTap;
  final List<Widget> children;
  final String title;

  const WarehouseGridCard({
    this.children = const <Widget>[],
    required this.onTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(right: 8.0, left: 16.0, top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headline4,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Divider(),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
