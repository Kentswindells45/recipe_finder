import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe_details_screen.dart';
import 'add_recipe_screen.dart';

/// The main screen displaying a list of recipes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Access the list of recipes from the provider.
    final recipes = Provider.of<RecipeProvider>(context).recipes;
    // Filter recipes based on the search query.
    final filteredRecipes =
        recipes
            .where(
              (recipe) => recipe.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Finder')),
      body: Column(
        children: [
          // Search bar for filtering recipes.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search recipes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Display the filtered list of recipes.
          Expanded(
            child:
                filteredRecipes.isEmpty
                    ? const Center(child: Text('No recipes found.'))
                    : ListView.builder(
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) {
                        return RecipeCard(
                          recipe: filteredRecipes[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => RecipeDetailScreen(
                                      recipe: filteredRecipes[index],
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Recipe',
      ),
    );
  }
}
