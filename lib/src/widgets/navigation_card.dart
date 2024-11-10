import 'package:flutter/material.dart';

class NavigationCard extends StatelessWidget {
  final BuildContext context;
  final String route;
  final List<Widget> children;

  NavigationCard(
    this.context,
    this.route, {
    this.children = const <Widget>[],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.7,
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding:
              EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
