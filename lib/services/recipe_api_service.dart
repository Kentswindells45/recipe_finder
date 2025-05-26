import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeApiService {
  static const String _baseUrl =
      'https://www.themealdb.com/api/json/v1/1/search.php?s=';

  Future<List<Recipe>> searchRecipes(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl$query'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meals = data['meals'];
      if (meals == null) return [];
      return List<Recipe>.from(
        meals.map(
          (meal) => Recipe(
            title: meal['strMeal'] ?? '',
            description: meal['strInstructions'] ?? '',
            imagePath: meal['strMealThumb'] ?? '',
            latitude: null,
            longitude: null,
            origin: meal['strArea'], // <-- Add this line
          ),
        ),
      );
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}
