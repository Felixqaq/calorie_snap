import 'package:flutter/material.dart';

AppBar buildAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    elevation: Theme.of(context).appBarTheme.elevation,
    leading: IconButton(
      icon: Icon(Icons.menu, color: Theme.of(context).disabledColor),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    ),
    title: Text(
      title,
      style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
        color: Theme.of(context).primaryColor,
      ),
    ),
    centerTitle: Theme.of(context).appBarTheme.centerTitle,
  );
}