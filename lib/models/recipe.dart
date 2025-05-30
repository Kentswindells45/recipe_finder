class Recipe {
  final String title;
  final String description;
  final String? imagePath;
  final double? latitude;
  final double? longitude;
  final String? origin;
  bool isFavorite;
  final String? category;

  Recipe({
    required this.title,
    required this.description,
    this.imagePath,
    this.latitude,
    this.longitude,
    this.origin,
    this.isFavorite = false,
    this.category,
  });

  // Factory constructor for creating a Recipe from TheMealDB API JSON
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['strMeal'] ?? '',
      description: json['strInstructions'] ?? '',
      imagePath: json['strMealThumb'],
      origin: json['strArea'],
      category: json['strCategory'],
      // latitude and longitude are not provided by TheMealDB, so leave as null
      // isFavorite is always false for new online recipes
    );
  }

  // Optionally, add toJson if you use it for persistence
}
