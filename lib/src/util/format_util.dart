import 'package:intl/intl.dart';

final dateFormat = DateFormat('dd.MM.yyyy', 'de_DE');
final dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm', 'de_DE');
final filenameDateFormat = DateFormat('yyMMdd', 'de_DE');

String formatDate(DateTime date) => dateFormat.format(date);
String formatDateTime(DateTime date) => dateTimeFormat.format(date);
String formatFigure(int value) =>
    value != null ? (value / 100.0).toStringAsFixed(2).replaceAll('.', ',') + ' €' : null;

String formatFilenameDate(DateTime date) => filenameDateFormat.format(date);

int parseFloat(String input) {
  final split = input.replaceAll(',', '.').split('.');
  return (int.parse(split.first) * 100) +
      ((split.length > 1)
          ? int.parse((split.last.length > 1) ? split.last.substring(0, 2) : split.last + '0')
          : 0);
}
