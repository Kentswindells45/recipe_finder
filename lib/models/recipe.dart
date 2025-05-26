class Recipe {
  final String title;
  final String description;
  final String? imagePath;
  final double? latitude;
  final double? longitude;
  final String? origin;
  bool isFavorite; // <-- Change made here
  final String? category; // <-- Add this

  Recipe({
    required this.title,
    required this.description,
    this.imagePath,
    this.latitude,
    this.longitude,
    this.origin,
    this.isFavorite = false,
    this.category, // <-- Add this
  });

  // Add toJson/fromJson if you use them for persistence
}
