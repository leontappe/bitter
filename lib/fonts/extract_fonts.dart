import 'dart:io';

void main() async {
  final liberationSans = File('LiberationSans-Bold.ttf');

  final sansOut = File('LiberationSansBold.dart')..createSync();

  var sink = sansOut.openWrite();

  sink.write('const List<int> liberationSans = ');
  final List<int> sansBytes = await liberationSans.readAsBytes();
  sink.write(sansBytes);
  sink.write(';');

  await sink.flush();
  await sink.close();

  final liberationSansBold = File('LiberationSans-Bold.ttf');

  final sansBoldOut = File('LiberationSansBold.dart')..createSync();

  final boldSink = sansBoldOut.openWrite();

  boldSink.write('const List<int> liberationSansBold = ');
  final List<int> sansBoldBytes = await liberationSansBold.readAsBytes();
  boldSink.write(sansBoldBytes);
  boldSink.write(';');

  await boldSink.flush();
  await boldSink.close();
}
