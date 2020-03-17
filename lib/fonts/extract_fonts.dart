import 'dart:io';

void main() async {
  final File liberationSans = File('LiberationSans-Regular.ttf');
  final File liberationMono = File('LiberationMono-Regular.ttf');

  final File sansOut = File('LiberationSans.dart')..createSync();
  final File monoOut = File('LiberationMono.dart')..createSync();

  IOSink sink = monoOut.openWrite();

  sink.write('const List<int> liberationMono = ');
  final List<int> monoBytes = await liberationMono.readAsBytes();
  sink.write(monoBytes);
  sink.write(';');

  await sink.flush();
  sink.close();

  sink = sansOut.openWrite();

  sink.write('const List<int> liberationSans = ');
  final List<int> sansBytes = await liberationSans.readAsBytes();
  sink.write(sansBytes);
  sink.write(';');
}
