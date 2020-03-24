import 'package:flutter/widgets.dart';

class InheritedDatabase<T> extends InheritedWidget {
  final T provider;

  InheritedDatabase({this.provider, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static InheritedDatabase<T> of<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedDatabase<T>>();
}
