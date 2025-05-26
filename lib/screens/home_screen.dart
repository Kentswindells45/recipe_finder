import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe_details_screen.dart';
import 'add_recipe_screen.dart';
import '../services/recipe_api_service.dart';
import '../services/notification_service.dart';

/// The main screen displaying a list of recipes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  final RecipeApiService _apiService = RecipeApiService();
  bool _showFavorites = false;

  Future<void> _searchOnline(String query) async {
    final results = await _apiService.searchRecipes(query);
    if (results.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No recipes found online.')));
      return;
    }
    // Show results in a dialog or a new screen
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Online Recipes'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final recipe = results[index];
                  return ListTile(
                    leading:
                        recipe.imagePath != null && recipe.imagePath!.isNotEmpty
                            ? Image.network(
                              recipe.imagePath!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                            : null,
                    title: Text(recipe.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (recipe.origin != null && recipe.origin!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.public,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Origin: ${recipe.origin}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.green,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.save_alt,
                        color: Colors.deepPurple,
                      ),
                      tooltip: 'Save to My Recipes',
                      onPressed: () {
                        final provider = Provider.of<RecipeProvider>(
                          context,
                          listen: false,
                        );
                        if (provider.containsRecipeTitle(recipe.title)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Recipe "${recipe.title}" already exists!',
                              ),
                            ),
                          );
                          return;
                        }
                        provider.addRecipe(recipe);
                        NotificationService.showNotification(
                          'Recipe Added',
                          '${recipe.title} was added!',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${recipe.title} saved!')),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);
    final recipes =
        _showFavorites ? provider.favoriteRecipes : provider.recipes;
    // Filter recipes based on the search query.
    final filteredRecipes =
        recipes
            .where(
              (recipe) =>
                  (_selectedCategory == null ||
                      recipe.category == _selectedCategory) &&
                  recipe.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Finder'),
        actions: [
          IconButton(
            icon: Icon(_showFavorites ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                _showFavorites = !_showFavorites;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar for filtering recipes.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
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
                IconButton(
                  icon: const Icon(Icons.cloud),
                  tooltip: 'Search Online',
                  onPressed: () => _searchOnline(_searchQuery),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: _selectedCategory,
              hint: const Text('Filter by Category'),
              isExpanded: true,
              items:
                  <String>[
                        'All',
                        ...Provider.of<RecipeProvider>(context).categories,
                      ]
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val == 'All' ? null : val;
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
                        return Dismissible(
                          key: ValueKey(
                            filteredRecipes[index].title +
                                filteredRecipes[index].description,
                          ),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Delete Recipe'),
                                    content: const Text(
                                      'Are you sure you want to delete this recipe?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirm == true) {
                              final provider = Provider.of<RecipeProvider>(
                                context,
                                listen: false,
                              );
                              final realIndex = provider.recipes.indexOf(
                                filteredRecipes[index],
                              );
                              await provider.deleteRecipe(realIndex);
                            } else {
                              setState(
                                () {},
                              ); // Rebuild to restore the item if deletion is cancelled
                            }
                          },
                          child: RecipeCard(
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
                            onLongPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AddRecipeScreen(
                                        recipe: filteredRecipes[index],
                                        recipeIndex: recipes.indexOf(
                                          filteredRecipes[index],
                                        ),
                                      ),
                                ),
                              );
                            },
                          ),
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
