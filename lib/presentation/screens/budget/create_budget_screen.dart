// lib/presentation/screens/budgets/create_budget_screen.dart
import 'package:finanzas_moviles/domain/entities/budget.dart';
import 'package:finanzas_moviles/domain/entities/category_model.dart';
import 'package:flutter/material.dart';
import '../../../data/services/budget_service.dart';
import '../../../data/services/category_service.dart';

class CreateBudgetScreen extends StatefulWidget {
  const CreateBudgetScreen({Key? key}) : super(key: key);

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final BudgetService _budgetService = BudgetService();
  final CategoryService _categoryService = CategoryService();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalAmountController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  // Lista de categorías disponibles
  List<Category> _categories = [];

  // Detalles seleccionados
  final List<_BudgetDetailItem> _details = [];

  // Controladores para nueva categoría
  final _newCategoryNameController = TextEditingController();
  bool _isCreatingCategory = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalAmountController.dispose();
    _newCategoryNameController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    final categories = await _categoryService.getCategories();
    setState(() {
      _categories = categories;
      _isLoadingCategories = false;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Mostrar diálogo para crear nueva categoría
  void _showCreateCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Categoría'),
        content: TextField(
          controller: _newCategoryNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la categoría',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _newCategoryNameController.text.trim();
              if (name.isEmpty) return;

              setState(() => _isCreatingCategory = true);
              final result = await _categoryService.createCategory(name);
              setState(() => _isCreatingCategory = false);

              if (result['success']) {
                await _loadCategories();
                _newCategoryNameController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Categoría creada con éxito')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Error: ${result['message']}')),
                );
              }
            },
            child: _isCreatingCategory
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Crear'),
          ),
        ],
      ),
    );
  }

  // Agregar detalle a la lista
  void _addDetail(Category category, double amount) {
    setState(() {
      _details.add(
        _BudgetDetailItem(
          categoryId: category.id,
          categoryName: category.name,
          estimatedAmount: amount,
        ),
      );
    });
  }

 // Mostrar diálogo para agregar categoría con monto
  void _showAddCategoryDialog() {
    Category? selectedCategory;
    final amountController = TextEditingController();
    final _formKey = GlobalKey<FormState>(); // ✅ Agregar FormKey

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Agregar Categoría'),
            content: Form(
              // ✅ Envolver en Form
              key: _formKey, // ✅ Usar FormKey
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Category>(
                    // ✅ Usar DropdownButtonFormField
                    decoration: const InputDecoration(
                      labelText: 'Selecciona una categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(
                              Icons.category,
                              color: _getColorFromString(cat.color),
                            ),
                            const SizedBox(width: 8),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedCategory = value),
                    validator: (value) => value == null
                        ? 'Selecciona una categoría'
                        : null, // ✅ Aquí sí funciona
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    // ✅ Cambiar a TextFormField
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto Estimado',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      // ✅ Validator funciona en TextFormField
                      if (value == null || value.isEmpty)
                        return 'Ingresa un monto';
                      if (double.tryParse(value) == null)
                        return 'Monto inválido';
                      if (double.parse(value) <= 0)
                        return 'Monto debe ser mayor a 0';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      selectedCategory != null) {
                    final amount = double.parse(amountController.text);
                    _addDetail(selectedCategory!, amount);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Agregar'),
              ),
            ],
          );
        },
      ),
    );
  }
  // Eliminar detalle
  void _removeDetail(int index) {
    setState(() {
      _details.removeAt(index);
    });
  }

  // Calcular suma de detalles
  double _getTotalDetailsAmount() {
    return _details.fold(0, (sum, item) => sum + item.estimatedAmount);
  }

  // Convertir string de color a Color
  Color _getColorFromString(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  Future<void> _createBudget() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona las fechas del presupuesto')),
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha inicio no puede ser mayor a la fecha fin'),
        ),
      );
      return;
    }

    final totalAmount = double.parse(_totalAmountController.text);
    final totalDetails = _getTotalDetailsAmount();

    if (_details.isNotEmpty && totalDetails > totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ La suma de detalles (\$${totalDetails.toStringAsFixed(2)}) excede el monto total',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _budgetService.createBudget(
      name: _nameController.text,
      startDate: _startDate!.toIso8601String().split('T').first,
      endDate: _endDate!.toIso8601String().split('T').first,
      totalAmount: totalAmount,
      details: _details.isNotEmpty
          ? _details
                .map(
                  (d) => BudgetDetail(
                    categoryId: d.categoryId,
                    estimatedAmount: d.estimatedAmount,
                  ),
                )
                .toList()
          : null,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Presupuesto creado con éxito')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: ${result['message']}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalDetails = _getTotalDetailsAmount();
    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0;
    final isExceeding = _details.isNotEmpty && totalDetails > totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Presupuesto'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del Presupuesto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del presupuesto',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _totalAmountController,
                decoration: InputDecoration(
                  labelText: 'Monto Total',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: const OutlineInputBorder(),
                  errorText: isExceeding
                      ? 'Los detalles exceden el monto total'
                      : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value!.isEmpty) return 'Ingresa el monto';
                  if (double.tryParse(value) == null) return 'Monto inválido';
                  if (double.parse(value) <= 0)
                    return 'Monto debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fechas
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha Inicio',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _startDate == null
                        ? 'Selecciona una fecha'
                        : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                    style: TextStyle(
                      color: _startDate == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha Fin',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _endDate == null
                        ? 'Selecciona una fecha'
                        : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                    style: TextStyle(
                      color: _endDate == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ========== DETALLES POR CATEGORÍA ==========
              const Divider(),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Distribución por Categorías',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_details.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Total: \$${totalDetails.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Lista de categorías seleccionadas
              if (_details.isNotEmpty)
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _details.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (context, index) {
                      final detail = _details[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.category,
                          color: Colors.orange,
                        ),
                        title: Text(detail.categoryName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${detail.estimatedAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _removeDetail(index),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              iconSize: 24,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              // Botones para agregar categorías
              if (_isLoadingCategories)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showAddCategoryDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar Categoría'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _showCreateCategoryDialog,
                      icon: const Icon(Icons.add_box, size: 18),
                      label: const Text('Nueva Categoría'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),

              if (_categories.isEmpty && !_isLoadingCategories)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'No hay categorías disponibles. Crea una nueva.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),

              if (isExceeding)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'La suma de detalles (\$${totalDetails.toStringAsFixed(2)}) excede el monto total (\$${totalAmount.toStringAsFixed(2)})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createBudget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Crear Presupuesto',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modelo interno
class _BudgetDetailItem {
  final int categoryId;
  final String categoryName;
  final double estimatedAmount;

  _BudgetDetailItem({
    required this.categoryId,
    required this.categoryName,
    required this.estimatedAmount,
  });
}
