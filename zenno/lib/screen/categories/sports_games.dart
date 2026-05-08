import 'package:flutter/material.dart';
import '../category_games.dart';

class SportsGamesScreen extends StatelessWidget {
  const SportsGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryGamesScreen(categoryName: 'SPORTS');
  }
}