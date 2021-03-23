ReminderIteration iterationFromInt(int number) => (number == 0)
    ? ReminderIteration.first
    : (number == 1)
        ? ReminderIteration.second
        : ReminderIteration.third;

ReminderIteration parseIteration(int i) {
  switch (i) {
    case 0:
      return ReminderIteration.first;
    case 1:
      return ReminderIteration.second;
    case 2:
      return ReminderIteration.third;
    default:
      print('unknown reminder iteration');
      return null;
  }
}

class Reminder {
  ReminderIteration iteration;
  DateTime deadline;
  String title;
  String text;
  int fee;
  int remainder;

  Reminder({
    this.iteration,
    this.deadline,
    this.title,
    this.text,
    this.fee,
    this.remainder,
  });

  factory Reminder.fromMap(Map map) => Reminder(
        iteration: iterationFromInt(map['iteration'] as int),
        deadline: DateTime.parse(map['deadline'] as String),
        title: map['title'] as String,
        text: map['text'] as String,
        fee: map['fee'] as int,
        remainder: map['remainder'] as int,
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'iteration': iteration.index,
        'deadline': deadline.toString(),
        'title': title,
        'text': text,
        'fee': fee,
        'remainder': remainder,
      };
}

enum ReminderIteration { first, second, third }
