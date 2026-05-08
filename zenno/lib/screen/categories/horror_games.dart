import 'package:flutter/material.dart';
import '../category_games.dart';

class HorrorGamesScreen extends StatelessWidget {
  const HorrorGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryGamesScreen(categoryName: 'HORROR');
  }
}