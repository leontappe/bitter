import 'package:flutter/widgets.dart';

import 'database_provider.dart';

class InheritedDatabase extends InheritedWidget {
  final DatabaseProvider provider;

  InheritedDatabase({this.provider, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedDatabase oldWidget) => false;

  static InheritedDatabase of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedDatabase>();
}
