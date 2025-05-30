import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    Widget? imageWidget;
    if (recipe.imagePath != null && recipe.imagePath!.isNotEmpty) {
      if (recipe.imagePath!.startsWith('http')) {
        imageWidget = CachedNetworkImage(
          imageUrl: recipe.imagePath!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
          errorWidget:
              (context, url, error) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
        );
      } else if (recipe.imagePath!.startsWith('/')) {
        imageWidget = Image.file(
          File(recipe.imagePath!),
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else {
        imageWidget = Image.asset(
          recipe.imagePath!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share('${recipe.title}\n\n${recipe.description}');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          physics: const BouncingScrollPhysics(), // Smooth scrolling
          children: [
            if (imageWidget != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(elevation: 4, child: imageWidget),
              ),
            const SizedBox(height: 24),
            Text(
              "Description",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[700],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  recipe.description,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (recipe.latitude != null && recipe.longitude != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '(${recipe.latitude!.toStringAsFixed(4)}, ${recipe.longitude!.toStringAsFixed(4)})',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            if (recipe.origin != null && recipe.origin!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.public, color: Colors.green, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Origin: ${recipe.origin}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            // New subtitle section
            Text(
              "Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[700],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
