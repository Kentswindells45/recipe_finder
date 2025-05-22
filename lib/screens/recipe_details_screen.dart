import 'dart:io';

import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.imagePath != null)
              Image.file(
                File(recipe.imagePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            Text(recipe.description, style: const TextStyle(fontSize: 16)),
            if (recipe.latitude != null && recipe.longitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  'Location: (${recipe.latitude!.toStringAsFixed(4)}, ${recipe.longitude!.toStringAsFixed(4)})',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
