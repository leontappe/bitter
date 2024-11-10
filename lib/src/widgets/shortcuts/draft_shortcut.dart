import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../models/draft.dart';
import '../../models/vendor.dart';
import '../../pages/drafts/draft_creator.dart';
import '../../util/format_util.dart';
import 'base_shortcut.dart';

class DraftShortcut extends StatelessWidget {
  final BuildContext context;
  final Draft draft;
  final Customer? customer;
  final Vendor? vendor;
  final bool showVendor;

  const DraftShortcut(
    this.context, {
    super.key,
    required this.draft,
    this.customer,
    this.vendor,
    this.showVendor = true,
  });

  @override
  Widget build(BuildContext context) {
    return BaseShortcut(
      context,
      onTap: () => Navigator.push<bool>(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  DraftCreatorPage(draft: draft))),
      children: <Widget>[
        Text('Entwurf ${draft.id}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.bold),
            textScaleFactor: 1.1,
            overflow: TextOverflow.ellipsis),
        if (showVendor)
          Text(vendor?.name ?? '', overflow: TextOverflow.ellipsis),
        if (customer != null)
          Text(customer!.fullCompany ?? customer!.fullName,
              overflow: TextOverflow.ellipsis)
        else
          Text(''),
        Text('${draft.items.length} Artikel', overflow: TextOverflow.ellipsis),
        Text(formatFigure(draft.sum), overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
