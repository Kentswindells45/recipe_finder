import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';
import '../services/recipe_api_service.dart';

class OnlineRecipeSearchDelegate extends SearchDelegate<Recipe?> {
  final void Function(Recipe) onAddFavorite;
  static const String _boxName = 'searchHistoryBox';
  static const String _key = 'history';

  OnlineRecipeSearchDelegate({required this.onAddFavorite});

  Future<List<String>> _getHistory() async {
    final box = Hive.box<List>(_boxName);
    return (box.get(_key, defaultValue: <String>[]) as List).cast<String>();
  }

  Future<void> _addToHistory(String query) async {
    final box = Hive.box<List>(_boxName);
    List<String> history =
        (box.get(_key, defaultValue: <String>[]) as List).cast<String>();
    if (!history.contains(query)) {
      history.insert(0, query);
      if (history.length > 10) history = history.sublist(0, 10);
      await box.put(_key, history);
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Type to search for recipes...'));
    }
    return FutureBuilder<List<Recipe>>(
      future: RecipeApiService().searchRecipes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No recipes found.'));
        }
        List<Recipe> recipes = snapshot.data!;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return ListTile(
                    leading:
                        recipe.imagePath != null
                            ? Image.network(
                              recipe.imagePath!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            )
                            : const Icon(Icons.fastfood),
                    title: Text(
                      recipe.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (recipe.category != null)
                          Text(
                            'Category: ${recipe.category!}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        if (recipe.origin != null)
                          Text(
                            'Origin: ${recipe.origin!}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        if (recipe.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              recipe.description.length > 60
                                  ? '${recipe.description.substring(0, 60)}...'
                                  : recipe.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {
                        onAddFavorite(recipe);
                        close(context, recipe);
                      },
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text(recipe.title),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (recipe.imagePath != null)
                                      Image.network(
                                        recipe.imagePath!,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                                    const SizedBox(height: 8),
                                    if (recipe.category != null)
                                      Text('Category: ${recipe.category!}'),
                                    if (recipe.origin != null)
                                      Text('Origin: ${recipe.origin!}'),
                                    const SizedBox(height: 8),
                                    Text(recipe.description),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.favorite_border),
                                  label: const Text('Add to Favorites'),
                                  onPressed: () {
                                    onAddFavorite(recipe);
                                    Navigator.pop(context);
                                    close(context, recipe);
                                  },
                                ),
                              ],
                            ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getHistory(),
      builder: (context, snapshot) {
        final suggestions =
            snapshot.data
                ?.where((h) => h.toLowerCase().contains(query.toLowerCase()))
                .toList() ??
            [];

        if (query.isEmpty) {
          return ListView(
            children: [
              if (suggestions.isEmpty)
                const ListTile(title: Text('No recent searches')),
              ...suggestions.map(
                (s) => ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(s),
                  onTap: () {
                    query = s;
                    showResults(context);
                  },
                ),
              ),
            ],
          );
        }

        return FutureBuilder<List<Recipe>>(
          future: RecipeApiService().searchRecipes(query),
          builder: (context, snapshot) {
            final List<Widget> children = [
              if (suggestions.isNotEmpty)
                ...suggestions.map(
                  (s) => ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(s),
                    onTap: () {
                      query = s;
                      showResults(context);
                    },
                  ),
                ),
            ];

            if (snapshot.connectionState == ConnectionState.waiting) {
              children.add(
                const ListTile(
                  leading: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  title: Text('Searching...'),
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              children.addAll(
                snapshot.data!.map(
                  (recipe) => ListTile(
                    leading:
                        recipe.imagePath != null
                            ? Image.network(
                              recipe.imagePath!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                            : const Icon(Icons.fastfood),
                    title: Text(recipe.title),
                    subtitle:
                        recipe.category != null
                            ? Text('Category: ${recipe.category!}')
                            : null,
                    onTap: () {
                      query = recipe.title;
                      showResults(context);
                    },
                  ),
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              children.add(
                const ListTile(title: Text('No suggestions found.')),
              );
            }

            return ListView(children: children);
          },
        );
      },
    );
  }

  @override
  void showResults(BuildContext context) {
    if (query.isNotEmpty) {
      _addToHistory(query);
    }
    super.showResults(context);
  }
}
