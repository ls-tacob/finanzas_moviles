// lib/presentation/screens/budgets/edit_budget_screen.dart
import 'package:finanzas_moviles/domain/entities/budget.dart';
import 'package:finanzas_moviles/domain/entities/category_model.dart';
import 'package:flutter/material.dart';
import '../../../data/services/budget_service.dart';
import '../../../data/services/category_service.dart';

class EditBudgetScreen extends StatefulWidget {
  final Budget budget;

  const EditBudgetScreen({Key? key, required this.budget}) : super(key: key);

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final BudgetService _budgetService = BudgetService();
  final CategoryService _categoryService = CategoryService();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _totalAmountController;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  // Lista de categorías disponibles
  List<Category> _categories = [];

  // Detalles actuales del presupuesto
  List<EditBudgetDetailItem> _details = [];

  // Controladores para nueva categoría
  final _newCategoryNameController = TextEditingController();
  bool _isCreatingCategory = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.budget.name);
    _totalAmountController = TextEditingController(
      text: widget.budget.totalAmount.toString(),
    );
    _startDate = DateTime.tryParse(widget.budget.startDate);
    _endDate = DateTime.tryParse(widget.budget.endDate);

    // Cargar categorías y convertir detalles existentes
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalAmountController.dispose();
    _newCategoryNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingCategories = true);

    // Cargar categorías disponibles
    final categories = await _categoryService.getCategories();

    // Convertir detalles existentes
    final existingDetails =
        widget.budget.details
            ?.map(
              (d) => EditBudgetDetailItem(
                id: d.id,
                categoryId: d.categoryId,
                categoryName: _getCategoryName(d.categoryId, categories),
                estimatedAmount: d.estimatedAmount,
              ),
            )
            .toList() ??
        [];

    setState(() {
      _categories = categories;
      _details = existingDetails;
      _isLoadingCategories = false;
    });
  }

  String _getCategoryName(int categoryId, List<Category> categories) {
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () =>
          Category(id: categoryId, name: 'Categoría $categoryId', status: 1),
    );
    return category.name;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
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

  // Mostrar diálogo para agregar categoría existente
  void _showAddCategoryDialog() {
    Category? selectedCategory;
    final amountController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    // Filtrar categorías que ya están agregadas
    final availableCategories = _categories
        .where((cat) => !_details.any((d) => d.categoryId == cat.id))
        .toList();

    if (availableCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay más categorías disponibles para agregar'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Agregar Categoría'),
            content: Form(
              key: dialogFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Category>(
                    decoration: const InputDecoration(
                      labelText: 'Selecciona una categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: availableCategories.map((cat) {
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
                    validator: (value) =>
                        value == null ? 'Selecciona una categoría' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto Estimado',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
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
                  if (dialogFormKey.currentState!.validate()) {
                    if (selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecciona una categoría'),
                        ),
                      );
                      return;
                    }
                    final amount = double.parse(amountController.text);
                    setState(() {
                      _details.add(
                        EditBudgetDetailItem(
                          categoryId: selectedCategory!.id,
                          categoryName: selectedCategory!.name,
                          estimatedAmount: amount,
                        ),
                      );
                    });
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
                await _loadData(); // Recargar categorías
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

  // Editar monto de un detalle
  void _editDetailAmount(int index) {
    final detail = _details[index];
    final amountController = TextEditingController(
      text: detail.estimatedAmount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Monto'),
        content: TextFormField(
          controller: amountController,
          decoration: const InputDecoration(
            labelText: 'Nuevo Monto',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Ingresa un monto';
            if (double.tryParse(value) == null) return 'Monto inválido';
            if (double.parse(value) <= 0) return 'Monto debe ser mayor a 0';
            return null;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newAmount = double.tryParse(amountController.text);
              if (newAmount != null && newAmount > 0) {
                setState(() {
                  _details[index] = EditBudgetDetailItem(
                    id: detail.id,
                    categoryId: detail.categoryId,
                    categoryName: detail.categoryName,
                    estimatedAmount: newAmount,
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
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

  Color _getColorFromString(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  Future<void> _updateBudget() async {
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

    // Preparar actualizaciones
    final updates = <String, dynamic>{};

    if (_nameController.text != widget.budget.name) {
      updates['name'] = _nameController.text;
    }
    if (totalAmount != widget.budget.totalAmount) {
      updates['totalAmount'] = totalAmount;
    }
    if (_startDate!.toIso8601String().split('T').first !=
        widget.budget.startDate) {
      updates['startDate'] = _startDate!.toIso8601String().split('T').first;
    }
    if (_endDate!.toIso8601String().split('T').first != widget.budget.endDate) {
      updates['endDate'] = _endDate!.toIso8601String().split('T').first;
    }

    // NOTA: La actualización de detalles requiere un endpoint adicional
    // Por ahora solo actualizamos datos básicos
    // Los detalles se manejarían con endpoints específicos para agregar/editar/eliminar

    if (updates.isEmpty &&
        _details.length == (widget.budget.details?.length ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cambios para guardar')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final result = await _budgetService.updateBudget(widget.budget.id, updates);

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Presupuesto actualizado con éxito')),
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
    final totalAmount =
        double.tryParse(_totalAmountController.text) ??
        widget.budget.totalAmount;
    final isExceeding = _details.isNotEmpty && totalDetails > totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Presupuesto'),
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
              if (_isLoadingCategories)
                const Center(child: CircularProgressIndicator())
              else if (_details.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Center(
                    child: Text(
                      'No hay categorías asignadas.\nAgrega una usando los botones de abajo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
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
                                Icons.edit,
                                color: Colors.blue,
                                size: 20,
                              ),
                              onPressed: () => _editDetailAmount(index),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              iconSize: 20,
                            ),
                            const SizedBox(width: 4),
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

              const SizedBox(height: 12),

              // Botones para agregar categorías
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
                  onPressed: _isLoading ? null : _updateBudget,
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
                          'Guardar Cambios',
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

// Modelo interno para edición
class EditBudgetDetailItem {
  final int? id;
  final int categoryId;
  final String categoryName;
  final double estimatedAmount;

  EditBudgetDetailItem({
    this.id,
    required this.categoryId,
    required this.categoryName,
    required this.estimatedAmount,
  });
}
