import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({super.key, required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading:
            recipe.imagePath != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    recipe.imagePath!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                )
                : const Icon(
                  Icons.restaurant_menu,
                  size: 40,
                  color: Colors.deepPurple,
                ),
        title: Text(
          recipe.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          recipe.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      ),
    );
  }
}
