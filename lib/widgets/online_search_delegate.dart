import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';
import '../services/recipe_api_service.dart';

class OnlineRecipeSearchDelegate extends SearchDelegate<Recipe?> {
  final void Function(Recipe) onAddFavorite;
  static const String _boxName = 'searchHistoryBox';
  static const String _key = 'history';

  Timer? _debounce;
  String _debouncedQuery = '';

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
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        isScrollControlled: true,
                        builder:
                            (_) => Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (recipe.imagePath != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          recipe.imagePath!,
                                          height: 220,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            recipe.title,
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleLarge,
                                          ),
                                        ),
                                        if (recipe.category != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                            ),
                                            child: Chip(
                                              label: Text(recipe.category!),
                                              backgroundColor:
                                                  Colors.deepPurple.shade50,
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (recipe.origin != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.place,
                                              size: 16,
                                              color: Colors.deepPurple,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              recipe.origin!,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const Divider(height: 24),
                                    Text(
                                      recipe.description,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            icon: const Icon(
                                              Icons.favorite_border,
                                            ),
                                            label: const Text(
                                              'Add to Favorites',
                                            ),
                                            onPressed: () {
                                              onAddFavorite(recipe);
                                              Navigator.pop(context);
                                              close(context, recipe);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
    // Cancel previous debounce if still active
    _debounce?.cancel();

    // Start a new debounce
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_debouncedQuery != query) {
        _debouncedQuery = query;
        // Call setState to rebuild with the new debounced query
        // In SearchDelegate, use showSuggestions to trigger a rebuild
        showSuggestions(context);
      }
    });

    // Use _debouncedQuery for API calls
    final currentQuery = _debouncedQuery;

    return FutureBuilder<List<String>>(
      future: _getHistory(),
      builder: (context, snapshot) {
        final suggestions =
            snapshot.data
                ?.where(
                  (h) => h.toLowerCase().contains(currentQuery.toLowerCase()),
                )
                .toList() ??
            [];

        if (currentQuery.isEmpty) {
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
          future: RecipeApiService().searchRecipes(currentQuery),
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
