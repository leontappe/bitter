import 'package:flutter/widgets.dart';

import 'base_provider.dart';

class InheritedProvider<T> extends InheritedWidget {
  final BaseProvider<T> provider;

  InheritedProvider({this.provider, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  static InheritedProvider of<T>(BuildContext context) => context.dependOnInheritedWidgetOfExactType<InheritedProvider<T>>();
}
