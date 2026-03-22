import 'package:finanzas_moviles/domain/entities/gasto.dart';
import 'package:flutter/material.dart';
import 'package:finanzas_moviles/presentation/screens/image_picker_widget.dart'; // Tu widget de cámara

class RegisterGastoScreen extends StatefulWidget {
  const RegisterGastoScreen({super.key});

  @override
  State<RegisterGastoScreen> createState() => _RegisterGastoScreenState();
}

class _RegisterGastoScreenState extends State<RegisterGastoScreen> {
  final _montoController = TextEditingController();
  String? _fotoPath; // Aquí se guarda el resultado de la cámara

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Gasto")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _montoController,
              decoration: const InputDecoration(labelText: "Monto del Gasto"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // AQUÍ INTEGRAMOS EL WIDGET DE LA CÁMARA
            ImagePickerWidget(
              onImageSelected: (path) {
                setState(() {
                  _fotoPath = path;
                });
              },
            ),

            const Spacer(),
            ElevatedButton(
              // Dentro del ElevatedButton en RegisterGastoScreen
              onPressed: () async {
                if (_montoController.text.isEmpty) {
                  // Validación rápida
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor ingresa un monto')),
                  );
                  return;
                }

                // 1. Creamos el objeto Gasto completo
                final nuevoGasto = Gasto(
                  id: DateTime.now().millisecondsSinceEpoch
                      .toString(), // ID temporal
                  monto: double.parse(_montoController.text),
                  fecha: DateTime.now(),
                  nota:
                      "Gasto con recibo", // Puedes añadir un controller para esto
                  categoriaId: "1", // Por ahora estático, luego puedes elegir
                  fotoPath: _fotoPath, // AQUÍ SE GUARDA LA RUTA DE LA FOTO
                );

                // 2. Lo enviamos a la Base de Datos
                // Aquí llamarías a tu DatabaseHelper.insertGasto(nuevoGasto)

                print("Gasto guardado con éxito: ${nuevoGasto.monto}");
                Navigator.pop(context); // Regresamos al Home
              },
              child: const Text("Guardar Registro"),
            ),
          ],
        ),
      ),
    );
  }
}
