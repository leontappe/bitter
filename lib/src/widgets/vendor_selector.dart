import 'package:flutter/material.dart';

import '/src/providers/inherited_database.dart';
import '/src/repositories/vendor_repository.dart';

class VendorSelector extends StatefulWidget {
  final int initialValue;
  final Function(Vendor) onChanged;
  final bool disabled;

  const VendorSelector({
    super.key,
    required this.onChanged,
    required this.initialValue,
    this.disabled = false,
  });

  @override
  _VendorSelectorState createState() => _VendorSelectorState();
}

class _VendorSelectorState extends State<VendorSelector> {
  late VendorRepository repo;

  List<Vendor> _vendors = [];
  Vendor? _vendor = Vendor.empty();

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      hint:
          Text((widget.disabled) ? _vendor?.name ?? '' : 'Verkäufer auswählen'),
      isExpanded: true,
      value: _vendor?.id,
      onChanged: (widget.disabled)
          ? null
          : (int? value) {
              if (value == null) return;
              setState(() =>
                  _vendor = _vendors.singleWhere((Vendor v) => v.id == value));
              if (_vendor != null) widget.onChanged(_vendor!);
            },
      items: <DropdownMenuItem<int>>[
        ..._vendors
            .map<DropdownMenuItem<int>>((Vendor v) =>
                DropdownMenuItem<int>(value: v.id, child: Text(v.name)))
            .toList()
      ],
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    repo = VendorRepository(InheritedDatabase.of(context));

    await repo.setUp();

    _vendors = await repo.select();

    try {
      _vendor = await repo.selectSingle(widget.initialValue);
    } catch (e) {
      print(e);
    }

    if (mounted) setState(() => _vendors);
  }

  @override
  void initState() {
    super.initState();
  }
}
