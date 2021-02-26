import 'package:flutter/material.dart';

import '../../models/crate.dart';
import '../../models/item.dart';

class CrateListTile extends StatelessWidget {
  final Crate crate;
  final Item item;
  final Function() onPressed;
  final Function() onLongPress;

  const CrateListTile({this.crate, this.item, this.onPressed, this.onLongPress});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(crate.name ?? (item != null ? 'Kiste mit ${item.title}' : 'Kiste')),
      subtitle: Text(item != null ? item.title + ' - ' + item.description : ''),
      trailing: Text('${crate.level}/${crate.size == 0 ? 'Unbegrenzt' : crate.size}'),
      onLongPress: onLongPress,
      onTap: onPressed,
    );
  }
}
