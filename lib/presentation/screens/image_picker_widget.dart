import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(String) onImageSelected;

  const ImagePickerWidget({super.key, required this.onImageSelected});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _image;
  final ImagePicker _picker = ImagePicker();


Future<void> _pickMedia(ImageSource source) async {
  // 1. Determinar qué permiso pedir
  Permission status = (source == ImageSource.camera) 
      ? Permission.camera 
      : Permission.photos;

  // 2. Pedir el permiso
  final result = await status.request();

  // 3. Solo si el permiso es concedido, procedemos
  if (result.isGranted) {
    final XFile? selected = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (selected != null) {
      setState(() => _image = File(selected.path));
      widget.onImageSelected(selected.path);
    }
  } else if (result.isPermanentlyDenied) {
    // Si el usuario dijo que NO para siempre, lo mandamos a Ajustes
    openAppSettings();
  } else {
    // Si denegó una vez, le avisamos
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permiso denegado para acceder al recurso.")),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Contenedor de previsualización
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: _image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.file(_image!, fit: BoxFit.cover),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_search, size: 50, color: Colors.grey),
                    Text(
                      "Sin evidencia adjunta",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 15),

        // Fila de botones para las 2 funcionalidades nativas
        Row(
          children: [
            // Funcionalidad 1: Cámara (Hardware)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickMedia(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Cámara"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[50],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Funcionalidad 2: Galería (File System)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickMedia(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text("Archivo"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[50],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
