import 'dart:io';

void main() async {
  final liberationSans = File('LiberationSans-Regular.ttf');

  final sansOut = File('LiberationSans.dart')..createSync();

  var sink = sansOut.openWrite();

  sink.write('const List<int> liberationSans = ');
  final List<int> sansBytes = await liberationSans.readAsBytes();
  sink.write(sansBytes);
  sink.write(';');

  await sink.flush();
  await sink.close();
}
