import 'dart:async';

import 'package:flutter/material.dart';

import '/src/models/database_error.dart';
import '/src/providers/inherited_database.dart';

class DatabaseErrorWatcher extends StatefulWidget {
  final Widget child;

  const DatabaseErrorWatcher({super.key, required this.child});

  @override
  _DatabaseErrorWatcherState createState() => _DatabaseErrorWatcherState();
}

class _DatabaseErrorWatcherState extends State<DatabaseErrorWatcher> {
  StreamSubscription<DatabaseError>? listener;

  /// the last errors that went through listener
  /// used to sort out big bulks of identical errors
  List<DatabaseError> lastErrors = [];

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    final db = InheritedDatabase.of(context);

    listener = db.errors
        .where((DatabaseError error) =>
            !lastErrors.contains(error) ||
            error.timestamp
                    .difference(lastErrors.first.timestamp)
                    .compareTo(const Duration(seconds: 30)) >
                0)
        .listen((DatabaseError error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.description ?? ''),
          duration: const Duration(seconds: 3)));
      lastErrors.add(error);
      lastErrors.removeWhere((DatabaseError error) => error.timestamp
          .isBefore(DateTime.now().subtract(const Duration(seconds: 5))));
    });

    super.didChangeDependencies();
  }

  @override
  void dispose() async {
    super.dispose();
    await listener?.cancel();
  }
}
