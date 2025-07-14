import 'package:flutter/material.dart';
import 'screens/contact_list_screen.dart';

void main() {
  runApp(const AddressBookApp());
}

class AddressBookApp extends StatelessWidget {
  const AddressBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '楽々住所録',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),
      home: const ContactListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
