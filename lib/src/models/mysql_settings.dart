const localhost = '127.0.0.1';

class MySqlSettings {
  String host;
  int port;
  String user;
  String password;
  String database;

  MySqlSettings({
    this.host = localhost,
    this.port = 3306,
    required this.user,
    required this.password,
    required this.database,
  });

  factory MySqlSettings.empty() =>
      MySqlSettings(user: '', password: '', database: '');

  factory MySqlSettings.fromMap(Map<String, dynamic> map) => MySqlSettings(
        host: (map['host'] != null) ? map['host'].toString() : localhost,
        port: map['port'] as int,
        user: map['user'].toString(),
        password: map['password'].toString(),
        database: map['database'].toString(),
      );

  factory MySqlSettings.standard() => MySqlSettings(
        host: '127.0.0.1',
        port: 3306,
        database: 'bitter',
        password: '',
        user: '',
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'host': host,
        'port': port,
        'user': user,
        'password': password,
        'database': database,
      };

  @override
  String toString() => '[MySqlSettings $toMap]';
}
