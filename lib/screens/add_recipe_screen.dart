import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/notification_service.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  File? _imageFile;
  double? _latitude;
  double? _longitude;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Request location permission and get current location
  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission permanently denied.'),
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Provider.of<RecipeProvider>(context, listen: false).addRecipe(
        Recipe(
          title: _title,
          description: _description,
          imagePath: _imageFile?.path,
          latitude: _latitude,
          longitude: _longitude,
        ),
      );
      NotificationService.showNotification(
        'Recipe Added',
        '$_title was added!',
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Image preview and picker
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child:
                    _imageFile != null
                        ? Image.file(
                          _imageFile!,
                          height: 180,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.camera_alt,
                            size: 60,
                            color: Colors.deepPurple,
                          ),
                        ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Camera'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              // Description field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter a description'
                            : null,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.location_on),
                    label: const Text('Tag Location'),
                    onPressed: _getLocation,
                  ),
                  if (_latitude != null && _longitude != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '(${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
              ElevatedButton(
                onPressed: _saveRecipe,
                child: const Text('Save Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
