import 'package:flutter/widgets.dart';

import 'database_provider.dart';

class InheritedDatabase extends InheritedWidget {
  final DatabaseProvider provider;

  InheritedDatabase({required this.provider, required Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(InheritedDatabase oldWidget) => false;

  static DatabaseProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedDatabase>()!.provider;
}
