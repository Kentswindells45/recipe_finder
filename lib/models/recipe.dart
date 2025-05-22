class Recipe {
  final String title;
  final String description;
  final String? imagePath;
  final double? latitude;
  final double? longitude;

  Recipe({
    required this.title,
    required this.description,
    this.imagePath,
    this.latitude,
    this.longitude,
  });
}
