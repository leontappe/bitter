import 'package:flutter/material.dart';

import '../../models/crate.dart';
import '../../models/item.dart';

class CrateListTile extends StatelessWidget {
  final Crate crate;
  final Item item;
  final Widget trailing;
  final Function() onPressed;
  final Function() onLongPress;

  final bool compact;

  const CrateListTile({
    this.crate,
    this.item,
    this.onPressed,
    this.onLongPress,
    this.trailing,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(crate.name ?? (item != null ? 'Kiste mit ${item.title}' : 'Kiste')),
      subtitle: Text(item != null ? item.title + ' - ' + item.description : ''),
      leading: Text('${crate.level}/${crate.size == 0 ? '∞' : crate.size}'),
      trailing: compact ? null : trailing,
      onLongPress: onLongPress,
      onTap: onPressed,
    );
  }
}
