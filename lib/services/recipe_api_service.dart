import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeApiService {
  Future<List<Recipe>> searchRecipes(String query) async {
    final response = await http.get(
      Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$query'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meals = data['meals'];
      if (meals == null) return [];
      // Ensure meals is a List before mapping
      if (meals is List) {
        return meals.map<Recipe>((meal) => Recipe.fromJson(meal) as Recipe).toList();
      }
    }
    return [];
  }
}
