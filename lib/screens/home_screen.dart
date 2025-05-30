import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe_details_screen.dart';
import 'add_recipe_screen.dart';
import '../services/notification_service.dart';
import 'settings_screen.dart';
import '../widgets/online_search_delegate.dart'; // Make sure this is the correct path

/// The main screen displaying a list of recipes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  bool _showFavorites = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
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

    if (_isOffline) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No internet connection',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Finder',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 3,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showFavorites ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                _showFavorites = !_showFavorites;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings & About',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
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
                  onPressed: () async {
                    final provider = Provider.of<RecipeProvider>(
                      context,
                      listen: false,
                    );
                    await showSearch(
                      context: context,
                      delegate: OnlineRecipeSearchDelegate(
                        onAddFavorite: (recipe) {
                          provider.addRecipe(recipe);
                          NotificationService.showNotification(
                            title: 'Recipe Added',
                            body: '${recipe.title} was added!',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${recipe.title} saved!')),
                          );
                        },
                      ),
                    );
                  },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Recipe'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
