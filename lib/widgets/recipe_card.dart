import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    Widget leadingWidget;
    if (recipe.imagePath != null && recipe.imagePath!.isNotEmpty) {
      if (recipe.imagePath!.startsWith('http')) {
        leadingWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            recipe.imagePath!,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        );
      } else if (recipe.imagePath!.startsWith('/')) {
        // File path
        leadingWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(recipe.imagePath!),
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        );
      } else {
        // Asset path
        leadingWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            recipe.imagePath!,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        );
      }
    } else {
      leadingWidget = const Icon(
        Icons.restaurant_menu,
        size: 40,
        color: Colors.deepPurple,
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: leadingWidget,
        title: Text(
          recipe.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.category != null)
              Text(
                recipe.category!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            Text(
              recipe.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // ...origin/location if needed...
          ],
        ),
        onTap: onTap,
        onLongPress: onLongPress,
        trailing: IconButton(
          icon: Icon(
            recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: recipe.isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: () {
            final provider = Provider.of<RecipeProvider>(
              context,
              listen: false,
            );
            final index = provider.recipes.indexOf(recipe);
            provider.toggleFavorite(index);
          },
        ),
      ),
    );
  }
}
