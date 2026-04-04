import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(String?) onImageSelected;
  final String? initialImagePath;
  final double radius;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.initialImagePath,
    this.radius = 60,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Calidad de la imagen
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
        widget.onImageSelected(_imagePath);
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al seleccionar imagen: $e")),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text("Tomar foto"),
              subtitle: const Text("Usar la cámara del dispositivo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text("Elegir de galería"),
              subtitle: const Text("Seleccionar desde la galería"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey[200],
            backgroundImage: _imagePath != null
                ? FileImage(File(_imagePath!))
                : null,
            child: _imagePath == null
                ? Icon(
                    Icons.camera_alt,
                    size: widget.radius * 0.5,
                    color: Colors.grey[400],
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _showImageSourceDialog,
          icon: const Icon(Icons.camera_alt, size: 16),
          label: const Text("Cambiar foto"),
          style: TextButton.styleFrom(foregroundColor: Colors.blue),
        ),
      ],
    );
  }
}
