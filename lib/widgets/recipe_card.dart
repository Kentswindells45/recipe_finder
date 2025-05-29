import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        leading:
            recipe.imagePath?.isNotEmpty == true
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: recipe.imagePath!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => const CircularProgressIndicator(),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.broken_image),
                  ),
                )
                : const Icon(
                  Icons.fastfood,
                  size: 40,
                  color: Colors.deepPurple,
                ),
        title: Text(
          recipe.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Row(
          children: [
            if (recipe.category != null && recipe.category!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  recipe.category ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            Text(
              recipe.origin ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
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
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
