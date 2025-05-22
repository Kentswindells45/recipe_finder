import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeProvider with ChangeNotifier {
  final List<Recipe> _recipes = [
    Recipe(title: 'Spaghetti', description: 'Classic Italian pasta.'),
    Recipe(title: 'Pancakes', description: 'Fluffy breakfast treat.'),
  ];

  List<Recipe> get recipes => _recipes;

  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    notifyListeners();
  }
}
