import 'package:flutter/material.dart';
import '../../../core/session_manager.dart';
import '../../../data/services/auth_service.dart';

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> userJson;
  final Function(int id, Map<String, dynamic> data) onSave;

  const EditUserScreen({
    super.key,
    required this.userJson,
    required this.onSave,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isAdmin = false;
  bool _isLoading = true;

  // Controllers
  late TextEditingController _cedulaController;
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _profesionController;
  late TextEditingController _sueldoController;
  late String _selectedEstado;
  late int _selectedRol;
  late String _selectedDellog;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _initializeControllers();
  }

  void _checkUserRole() {
    final currentUser = _authService.currentUser;
    setState(() {
      _isAdmin = currentUser?.idRol == 1;
      _isLoading = false;
    });
  }

  void _initializeControllers() {
    final user = widget.userJson;
    final info = user['info'] ?? {};

    _cedulaController = TextEditingController(text: user['cedula'] ?? '');
    _nombresController = TextEditingController(text: user['nombres'] ?? '');
    _apellidosController = TextEditingController(text: user['apellidos'] ?? '');
    _correoController = TextEditingController(
      text: info['correo'] ?? user['correo'] ?? '',
    );
    _telefonoController = TextEditingController(
      text: info['telefono'] ?? user['telefono'] ?? '',
    );
    _profesionController = TextEditingController(
      text: info['profesion'] ?? user['profesion'] ?? '',
    );
    _sueldoController = TextEditingController(
      text: (info['sueldoActual'] ?? user['sueldo'] ?? 0).toString(),
    );
    _selectedEstado = user['estado'] ?? 'A';
    _selectedDellog = user['dellog'] ?? 'N';
    _selectedRol = user['idRol'] ?? 2;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isAdmin ? "Editar Usuario (Admin)" : "Mi Perfil",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _isAdmin ? Colors.blueGrey[900] : Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeader("DATOS PERSONALES", Icons.person),

            // Cédula SOLO para admin
            _buildField(
              _cedulaController,
              "Cédula",
              Icons.badge,
              enabled: _isAdmin,
            ),

            _buildField(_nombresController, "Nombres", Icons.person),
            _buildField(
              _apellidosController,
              "Apellidos",
              Icons.person_outline,
            ),

            // Campos SOLO visibles para ADMIN
            if (_isAdmin) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildRoleDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatusDropdown()),
                ],
              ),
              const SizedBox(height: 8),
              _buildDellogDropdown(),
            ],

            const SizedBox(height: 20),
            _buildHeader("CONTACTO", Icons.contact_phone),
            _buildField(
              _correoController,
              "Correo Electrónico",
              Icons.email,
              type: TextInputType.emailAddress,
            ),
            _buildField(
              _telefonoController,
              "Teléfono",
              Icons.phone,
              type: TextInputType.phone,
            ),

            const SizedBox(height: 20),
            _buildHeader("INFORMACIÓN FINANCIERA", Icons.attach_money),
            _buildField(_profesionController, "Profesión", Icons.work),
            _buildField(
              _sueldoController,
              "Sueldo Mensual",
              Icons.monetization_on,
              type: TextInputType.number,
            ),

            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded, color: Colors.white),
              label: Text(
                _isAdmin ? "GUARDAR CAMBIOS (Admin)" : "ACTUALIZAR MI PERFIL",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAdmin
                    ? Colors.blueAccent[700]
                    : Colors.green,
                minimumSize: const Size.fromHeight(55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 22),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Campo requerido" : null,
      ),
    );
  }

  Widget _buildRoleDropdown() {
    // Asegurar que _selectedRol tenga un valor válido
    final validRol = (_selectedRol == 1 || _selectedRol == 2)
        ? _selectedRol
        : 2;

    return DropdownButtonFormField<int>(
      value: validRol, // Usar valor validado
      decoration: InputDecoration(
        labelText: "Rol",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 1, child: Text("Administrador")),
        DropdownMenuItem(value: 2, child: Text("Usuario")),
      ],
      onChanged: (val) => setState(() => _selectedRol = val ?? 2),
    );
  }

  Widget _buildStatusDropdown() {
    // Asegurar que _selectedEstado tenga un valor válido
    final validEstado = (_selectedEstado == 'A' || _selectedEstado == 'I')
        ? _selectedEstado
        : 'A';

    return DropdownButtonFormField<String>(
      value: validEstado, // Usar valor validado
      decoration: InputDecoration(
        labelText: "Estado",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 'A', child: Text("Activo")),
        DropdownMenuItem(value: 'I', child: Text("Inactivo")),
      ],
      onChanged: (val) => setState(() => _selectedEstado = val ?? 'A'),
    );
  }

  Widget _buildDellogDropdown() {
    // Asegurar que _selectedDellog tenga un valor válido
    final validDellog = (_selectedDellog == 'N' || _selectedDellog == 'S')
        ? _selectedDellog
        : 'N';

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DropdownButtonFormField<String>(
        value: validDellog, // Usar valor validado
        decoration: InputDecoration(
          labelText: "Borrado Lógico",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: const [
          DropdownMenuItem(value: 'N', child: Text("Activo (No eliminado)")),
          DropdownMenuItem(value: 'S', child: Text("Eliminado")),
        ],
        onChanged: (val) => setState(() => _selectedDellog = val ?? 'N'),
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final payload = <String, dynamic>{
        "nombres": _nombresController.text,
        "apellidos": _apellidosController.text,
        "info": {
          "correo": _correoController.text,
          "telefono": _telefonoController.text,
          "profesion": _profesionController.text,
          "sueldoActual": double.tryParse(_sueldoController.text) ?? 0.0,
        },
      };

      // Solo admin puede enviar estos campos
      if (_isAdmin) {
        payload["cedula"] = _cedulaController.text;
        payload["idRol"] = _selectedRol;
        payload["estado"] = _selectedEstado;
        payload["dellog"] = _selectedDellog;
      }

      widget.onSave(widget.userJson['id'], payload);
    }
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _profesionController.dispose();
    _sueldoController.dispose();
    super.dispose();
  }
}
