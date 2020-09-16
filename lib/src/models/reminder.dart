class Reminder {
  ReminderIteration iteration;
  DateTime deadline;
  String text;
  int fee;

  Reminder({this.iteration, this.deadline, this.text, this.fee});

  factory Reminder.fromMap(Map map) => Reminder(
        iteration: map['iteration'] as ReminderIteration,
        deadline: DateTime.parse(map['deadline'] as String),
        text: map['text'] as String,
        fee: map['fee'] as int,
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'iteration': iteration.index,
        'deadline': deadline,
        'text': text,
        'fee': fee,
      };
}

enum ReminderIteration { first, second, third }
