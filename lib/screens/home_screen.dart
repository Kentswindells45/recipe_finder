import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
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
  String _sortBy = 'Name';
  final List<String> _sortOptions = ['Name', 'Newest', 'Favorites'];
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

  Future<void> _refreshRecipes() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 600));
  }

  List _sortRecipes(List recipes) {
    List sorted = List.from(recipes);
    if (_sortBy == 'Name') {
      sorted.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    } else if (_sortBy == 'Newest') {
      sorted = sorted.reversed.toList();
    } else if (_sortBy == 'Favorites') {
      sorted.sort((a, b) => b.isFavorite == true ? 1 : -1);
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);
    final recipes =
        _showFavorites ? provider.favoriteRecipes : provider.recipes;
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
    final sortedRecipes = _sortRecipes(filteredRecipes);

    if (_isOffline) {
      return const Scaffold(
        backgroundColor: Color(0xFF181A20),
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          isDark ? const Color(0xFF181A20) : const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6D5FFD), Color(0xFF46A0FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Recipe Finder',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _showFavorites
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _showFavorites = !_showFavorites;
                          });
                        },
                        tooltip: 'Show Favorites',
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        tooltip: 'Settings & About',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Elegant Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(18),
                shadowColor:
                    isDark ? Colors.black54 : Colors.grey.withOpacity(0.2),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [
                                const Color(0xFF23243A),
                                const Color(0xFF181A20),
                              ]
                              : [
                                const Color(0xFFF6F7FB),
                                const Color(0xFFE3E6F3),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search recipes...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF6D5FFD),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cloud, color: Color(0xFF46A0FC)),
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
                                  SnackBar(
                                    content: Text('${recipe.title} saved!'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Quick Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                      selectedColor: const Color(0xFF6D5FFD).withOpacity(0.2),
                    ),
                    ...Provider.of<RecipeProvider>(context).categories.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: _selectedCategory == cat,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? cat : null;
                            });
                          },
                          selectedColor: const Color(
                            0xFF6D5FFD,
                          ).withOpacity(0.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Glassmorphism Category Dropdown & Sorting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF6D5FFD).withOpacity(0.2),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              hint: const Text('Filter by Category'),
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF6D5FFD),
                              ),
                              items:
                                  <String>[
                                        'All',
                                        ...Provider.of<RecipeProvider>(
                                          context,
                                        ).categories,
                                      ]
                                      .map(
                                        (cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(cat),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedCategory = val == 'All' ? null : val;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Sorting Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF6D5FFD).withOpacity(0.2),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        icon: const Icon(Icons.sort, color: Color(0xFF6D5FFD)),
                        items:
                            _sortOptions
                                .map(
                                  (opt) => DropdownMenuItem(
                                    value: opt,
                                    child: Text('Sort: $opt'),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setState(() {
                            _sortBy = val!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Recipe count indicator
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 2, bottom: 2),
              child: Text(
                '${sortedRecipes.length} recipe${sortedRecipes.length == 1 ? '' : 's'} found',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Animated List of Recipes with Pull-to-Refresh and animated empty state
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshRecipes,
                child:
                    sortedRecipes.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOut,
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors.white10
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(60),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          isDark
                                              ? Colors.black26
                                              : Colors.grey.withOpacity(0.15),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'No recipes found.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.settings,
                                  color: Color(0xFF6D5FFD),
                                ),
                                label: const Text(
                                  'Settings',
                                  style: TextStyle(color: Color(0xFF6D5FFD)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          itemCount: sortedRecipes.length,
                          itemBuilder: (context, index) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(
                                milliseconds: 500 + index * 60,
                              ),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 30 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: AnimatedContainer(
                                duration: Duration(
                                  milliseconds: 400 + (index * 30),
                                ),
                                curve: Curves.easeOutCubic,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Dismissible(
                                  key: ValueKey(
                                    sortedRecipes[index].title +
                                        sortedRecipes[index].description,
                                  ),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.redAccent.withOpacity(
                                            0.15,
                                          ),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  onDismissed: (direction) async {
                                    final deletedRecipe = sortedRecipes[index];
                                    final provider =
                                        Provider.of<RecipeProvider>(
                                          context,
                                          listen: false,
                                        );
                                    final realIndex = provider.recipes.indexOf(
                                      deletedRecipe,
                                    );
                                    await provider.deleteRecipe(realIndex);
                                    HapticFeedback.mediumImpact();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Recipe deleted'),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          onPressed: () {
                                            provider.addRecipe(deletedRecipe);
                                          },
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  },
                                  child: Hero(
                                    tag: 'recipe_${sortedRecipes[index].title}',
                                    child: Material(
                                      elevation: 4,
                                      borderRadius: BorderRadius.circular(16),
                                      shadowColor:
                                          isDark
                                              ? Colors.black54
                                              : Colors.grey.withOpacity(0.15),
                                      child: RecipeCard(
                                        recipe: sortedRecipes[index],
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => RecipeDetailScreen(
                                                    recipe:
                                                        sortedRecipes[index],
                                                  ),
                                            ),
                                          );
                                        },
                                        onLongPress: () {
                                          HapticFeedback.selectionClick();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => AddRecipeScreen(
                                                    recipe:
                                                        sortedRecipes[index],
                                                    recipeIndex: recipes
                                                        .indexOf(
                                                          sortedRecipes[index],
                                                        ),
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
            );
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Recipe',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF6D5FFD),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
