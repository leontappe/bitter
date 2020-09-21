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

class DatabaseError {
  /// human-readable description text for this error
  final String description;

  /// raw exception if availiable
  final Exception exception;

  /// specifies what db operation the error originates from
  final DatabaseErrorCategory category;

  /// creation tiem of this DatabaseError
  final DateTime timestamp;

  DatabaseError(this.category, {this.description, this.exception}) : timestamp = DateTime.now();

  @override
  String toString() => 'DatabaseError [$category, "$description", $exception]';

  @override
  bool operator ==(Object other) => other is DatabaseError && other.description == description;
}
