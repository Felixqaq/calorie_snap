
import 'package:flutter/material.dart';

AppBar buildAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.primary,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.menu, color: Colors.white),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
    centerTitle: true,
  );
}