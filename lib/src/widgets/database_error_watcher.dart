import 'dart:async';

import 'package:flutter/material.dart';

import '../models/database_error.dart';
import '../providers/inherited_database.dart';

class DatabaseErrorWatcher extends StatefulWidget {
  final Widget child;

  const DatabaseErrorWatcher({Key key, @required this.child}) : super(key: key);

  @override
  _DatabaseErrorWatcherState createState() => _DatabaseErrorWatcherState();
}

class _DatabaseErrorWatcherState extends State<DatabaseErrorWatcher> {
  StreamSubscription listener;

  /// the last error that went through listener
  /// used to sort out big bulks of identical errors
  DatabaseError lastError;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    final db = InheritedDatabase.of(context);

    listener = db.errors
        .where((DatabaseError error) =>
            error != lastError ||
            error.timestamp.difference(lastError.timestamp).compareTo(const Duration(seconds: 30)) >
                0)
        .listen((DatabaseError error) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(error.description), duration: const Duration(seconds: 3)));
      lastError = error;
    });

    super.didChangeDependencies();
  }

  @override
  void dispose() async {
    super.dispose();
    await listener.cancel();
  }
}
