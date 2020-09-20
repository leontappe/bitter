import 'package:flutter/material.dart';

import '../../models/item.dart';
import '../../models/vendor.dart';
import '../../pages/items/item_page.dart';
import 'base_shortcut.dart';

class ItemShortcut extends StatelessWidget {
  final BuildContext context;
  final Item item;
  final Vendor vendor;
  final bool showVendor;

  const ItemShortcut(this.context,
      {Key key, @required this.item, this.vendor, this.showVendor = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseShortcut(
      context,
      onTap: () => Navigator.push<bool>(
          context, MaterialPageRoute(builder: (BuildContext context) => ItemPage(item: item))),
      children: <Widget>[
        Text(item.title,
            style: Theme.of(context).textTheme.subtitle1,
            textScaleFactor: 1.1,
            overflow: TextOverflow.ellipsis),
        Text(item.description ?? '', overflow: TextOverflow.ellipsis),
        if (showVendor && vendor != null) Text(vendor.name, overflow: TextOverflow.ellipsis),
        Text('${(item.price / 100.0).toStringAsFixed(2)} €', overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
