class DatabaseError {
  /// human-readable description text for this error
  final String? description;

  /// raw exception if available
  final Exception? exception;

  /// specifies what db operation the error originates from
  final DatabaseErrorCategory category;

  /// creation time of this DatabaseError
  final DateTime timestamp;

  DatabaseError(this.category, {this.description, this.exception})
      : timestamp = DateTime.now();

  @override
  int get hashCode => Object.hashAll([description, timestamp, category]);

  @override
  bool operator ==(Object other) =>
      other is DatabaseError && other.hashCode == hashCode;

  @override
  String toString() => 'DatabaseError [$category, "$description", $exception]';
}

enum DatabaseErrorCategory {
  open,
  create,
  select,
  selectSingle,
  insert,
  update,
  delete,
  drop,
}
