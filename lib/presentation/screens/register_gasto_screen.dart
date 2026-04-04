// lib/presentation/screens/register_gasto_screen.dart
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import '../data/services/gasto_service.dart';
// import '../data/services/budget_service.dart';
// import '../data/services/category_service.dart';
// import '../domain/entities/budget.dart';
// import '../domain/entities/category_model.dart';
// import '../domain/entities/gasto_model.dart';

class RegisterGastoScreen extends StatefulWidget {
  const RegisterGastoScreen({super.key});

  @override
  State<RegisterGastoScreen> createState() => _RegisterGastoScreenState();
}

class _RegisterGastoScreenState extends State<RegisterGastoScreen> {
  // final GastoService _gastoService = GastoService();
  // final BudgetService _budgetService = BudgetService();
  // final CategoryService _categoryService = CategoryService();

  // final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  // final _descriptionController = TextEditingController();

  // Budget? _selectedBudget;
  // Category? _selectedCategory;
  // DateTime _selectedDate = DateTime.now();
  // File? _selectedImage;
  // bool _isLoading = false;
  // bool _isLoadingData = true;

  // List<Budget> _budgets = [];
  // List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    // _loadData();
  }

  @override
  void dispose() {
    _montoController.dispose();
    // _descriptionController.dispose();
    super.dispose();
  }

  // Future<void> _loadData() async {
  //   setState(() => _isLoadingData = true);
  //   final budgetsResult = await _budgetService.getMyBudgets();
  //   final categories = await _categoryService.getCategories();
  //   if (budgetsResult['success']) {
  //     final data = budgetsResult['data'];
  //     if (data is List) {
  //       setState(() {
  //         _budgets = data.map((b) => Budget.fromJson(b)).toList();
  //         _categories = categories;
  //         _isLoadingData = false;
  //       });
  //     }
  //   } else {
  //     setState(() => _isLoadingData = false);
  //   }
  // }

  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     setState(() => _selectedImage = File(pickedFile.path));
  //   }
  // }

  // Future<void> _pickImageFromGallery() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() => _selectedImage = File(pickedFile.path));
  //   }
  // }

  // void _showImageSourceDialog() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => SafeArea(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.camera_alt),
  //             title: const Text('Tomar foto'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _pickImage();
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.photo_library),
  //             title: const Text('Elegir de galería'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _pickImageFromGallery();
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Future<void> _saveGasto() async {
  //   if (_montoController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Ingresa un monto')),
  //     );
  //     return;
  //   }
  //   if (_selectedBudget == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Selecciona un presupuesto')),
  //     );
  //     return;
  //   }
  //   if (_selectedCategory == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Selecciona una categoría')),
  //     );
  //     return;
  //   }
  //   setState(() => _isLoading = true);
  //   final gasto = Gasto(
  //     budgetId: _selectedBudget!.id,
  //     categoryId: _selectedCategory!.id,
  //     amount: double.parse(_montoController.text),
  //     description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
  //     expenseDate: _selectedDate.toIso8601String().split('T').first,
  //     photoPath: _selectedImage?.path,
  //   );
  //   final result = await _gastoService.createGasto(gasto);
  //   setState(() => _isLoading = false);
  //   if (result['success']) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('✅ Gasto registrado con éxito')),
  //     );
  //     Navigator.pop(context, true);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('❌ Error: ${result['message']}')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Gasto'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💰 Nuevo Gasto',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Campo de monto
            TextField(
              controller: _montoController,
              decoration: const InputDecoration(
                labelText: 'Monto del gasto',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 30),

            // Mensaje informativo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Funcionalidad en desarrollo.\nPróximamente podrás seleccionar presupuesto, categoría y tomar foto del comprobante.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Botón guardar (demostrativo)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_montoController.text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✅ Gasto de \$${_montoController.text} registrado (Demo)',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor ingresa un monto'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar Registro',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
