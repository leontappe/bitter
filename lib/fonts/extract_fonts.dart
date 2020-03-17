import 'dart:io';

void main() async {
  final liberationSans = File('LiberationSans-Regular.ttf');
  final liberationMono = File('LiberationMono-Regular.ttf');

  final sansOut = File('LiberationSans.dart')..createSync();
  final monoOut = File('LiberationMono.dart')..createSync();

  var sink = monoOut.openWrite();

  sink.write('const List<int> liberationMono = ');
  final List<int> monoBytes = await liberationMono.readAsBytes();
  sink.write(monoBytes);
  sink.write(';');

  await sink.flush();
  await sink.close();

  sink = sansOut.openWrite();

  sink.write('const List<int> liberationSans = ');
  final List<int> sansBytes = await liberationSans.readAsBytes();
  sink.write(sansBytes);
  sink.write(';');
}
