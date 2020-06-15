int parseFloat(String input) {
  final split = input.replaceAll(',', '.').split('.');
  return (int.parse(split.first) * 100) +
      ((split.length > 1)
          ? int.parse((split.last.length > 1) ? split.last.substring(0, 2) : split.last + '0')
          : 0);
}
