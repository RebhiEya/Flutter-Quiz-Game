import 'package:flutter/material.dart';
import 'HomePage.dart'; // Importation de la page d'accueil

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(), // Page d'accueil par défaut
    );
  }
}
