import 'package:bitter/src/models/bill.dart';
import 'package:bitter/src/models/customer.dart';
import 'package:bitter/src/models/draft.dart';
import 'package:bitter/src/models/item.dart';
import 'package:bitter/src/models/reminder.dart';
import 'package:bitter/src/models/vendor.dart';

Bill exampleBill = Bill(
  billNr: 'RE1',
  created: DateTime.now(),
  customer: exampleCustomer,
  dueDate: DateTime.now().add(Duration(days: exampleVendor.defaultDueDays)),
  editor: 'Max Mustermann',
  file: [],
  items: exampleDraft.items,
  serviceDate: exampleDraft.serviceDate,
  sum: exampleDraft.items
      .fold<int>(0, (previousValue, item) => previousValue + (item.price * item.quantity)),
  vendor: exampleVendor,
);

Customer exampleCustomer = Customer(
  id: 1,
  name: 'Erika',
  surname: 'Musterfrau',
  gender: Gender.female,
  email: 'e.muster@mail.de',
  zipCode: 12345,
  city: 'Town',
  address: 'Example Road 56',
);

Draft exampleDraft = Draft(
  id: 1,
  tax: 19,
  items: [
    Item(uid: '1', title: 'Papier A4', description: '100 Blatt', price: 100, quantity: 2, tax: 19),
    Item(uid: '2', title: 'Bachelorarbeit', description: '', price: 2000, quantity: 1, tax: 19),
  ],
  customer: 1,
  vendor: 1,
  editor: 'Maximilian Mustermann',
  serviceDate: DateTime.now(),
  dueDays: 14,
);

Reminder exampleReminder = Reminder(
    iteration: ReminderIteration.first,
    deadline: DateTime.now().add(Duration(days: exampleVendor.reminderDeadline)),
    fee: 10,
    text: '''Der Doktor, würdig wie er war, nimmt in Empfang sein Honorar.
So stellte Wilhelm Busch einst dar, wie würdig dieser Doktor war.
Wir wollen auch so taktvoll sein und nicht nach unserem Gelde schrein.
Drum bitten wir Sie sehr diskret, nun zu bezahlen, WENN es GEHT.
''');

Vendor exampleVendor = Vendor(
  name: 'My Company',
  address: 'Example Road 3',
  zipCode: 12345,
  city: 'Town',
  iban: 'DE12 2345 1233 1234',
  bic: 'WELADE3LXXX',
  bank: 'Bank',
  taxNr: '123/234/678',
  vatNr: 'DE12345678',
  website: 'homepage.com',
  fullAddress: 'My Company Example Road 3 12345 Town',
  billPrefix: 'R',
  email: 'info@example.com',
  reminderFees: <ReminderIteration, int>{
    ReminderIteration.first: 0,
    ReminderIteration.second: 500,
    ReminderIteration.third: 500
  },
  defaultDueDays: 14,
  reminderDeadline: 14,
);
