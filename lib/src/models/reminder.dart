class Reminder {
  ReminderIteration iteration;
  DateTime deadline;
  String text;
  int fee;

  Reminder({this.iteration, this.deadline, this.text, this.fee});

  factory Reminder.fromMap(Map map) => Reminder(
        iteration: iterationFromInt(map['iteration'] as int),
        deadline: DateTime.parse(map['deadline'] as String),
        text: map['text'] as String,
        fee: map['fee'] as int,
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'iteration': iteration.index,
        'deadline': deadline.toString(),
        'text': text,
        'fee': fee,
      };
}

ReminderIteration iterationFromInt(int number) => (number == 0)
    ? ReminderIteration.first
    : (number == 1)
        ? ReminderIteration.second
        : ReminderIteration.third;
        
enum ReminderIteration { first, second, third }
