import 'package:flutter/material.dart';

class GesturelessListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final Widget? subtitle;

  /// padding for the whole content of the tile
  final EdgeInsetsGeometry? contentPadding;

  /// makes setting abound height for the tile possible
  final double? height;

  const GesturelessListTile({
    super.key,
    this.leading,
    this.title,
    this.trailing,
    this.subtitle,
    this.contentPadding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: contentPadding ?? EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          leading ?? const SizedBox(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null)
                  RichText(
                    text: WidgetSpan(
                      style: Theme.of(context).textTheme.headlineSmall,
                      child: title!,
                    ),
                  ),
                if (subtitle != null)
                  RichText(
                    text: WidgetSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      child: subtitle!,
                    ),
                  ),
              ],
            ),
          ),
          trailing ?? const SizedBox(),
        ],
      ),
    );
  }
}
