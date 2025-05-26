import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  RecipeProvider() {
    loadRecipes();
  }

  Future<void> addRecipe(Recipe recipe) async {
    _recipes.add(recipe);
    await saveRecipes();
    notifyListeners();
  }

  Future<void> deleteRecipe(int index) async {
    _recipes.removeAt(index);
    await saveRecipes();
    notifyListeners();
  }

  void updateRecipe(int index, Recipe recipe) async {
    _recipes[index] = recipe;
    await saveRecipes();
    notifyListeners();
  }

  Future<void> saveRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipeList =
        _recipes
            .map(
              (r) => jsonEncode({
                'title': r.title,
                'description': r.description,
                'imagePath': r.imagePath,
                'latitude': r.latitude,
                'longitude': r.longitude,
                'origin': r.origin,
                'category': r.category,
                'isFavorite': r.isFavorite, // Save favorite status
              }),
            )
            .toList();
    await prefs.setStringList('recipes', recipeList);
  }

  Future<void> loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipeList = prefs.getStringList('recipes') ?? [];
    _recipes =
        recipeList.map((str) {
          final map = jsonDecode(str);
          return Recipe(
            title: map['title'],
            description: map['description'],
            imagePath: map['imagePath'],
            latitude: map['latitude']?.toDouble(),
            longitude: map['longitude']?.toDouble(),
            origin: map['origin'],
            category: map['category'],
            isFavorite: map['isFavorite'] ?? false,
          );
        }).toList();
    notifyListeners();
  }

  bool containsRecipeTitle(String title) {
    return _recipes.any(
      (r) => r.title.trim().toLowerCase() == title.trim().toLowerCase(),
    );
  }

  void toggleFavorite(int index) async {
    _recipes[index].isFavorite = !_recipes[index].isFavorite;
    await saveRecipes();
    notifyListeners();
  }

  List<Recipe> get favoriteRecipes =>
      _recipes.where((r) => r.isFavorite).toList();

  List<String> get categories {
    final allCategories =
        _recipes.map((r) => r.category).whereType<String>().toSet().toList();
    allCategories.removeWhere((cat) => cat.isEmpty);
    return allCategories;
  }
}
