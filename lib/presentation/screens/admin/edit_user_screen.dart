import 'package:flutter/material.dart';

class EditUserScreen extends StatefulWidget {
final Map<String, dynamic> userJson;
  // Solo id y data, porque el token es responsabilidad del servicio/padre
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

  // Controllers: Tabla Principal
  late TextEditingController _cedulaController;
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late String _selectedEstado;
  late int _selectedRol;

  // Controllers: Tabla UserInfo (Datos de Gastos/Perfil)
  late TextEditingController _edadController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _sueldoController;
  late TextEditingController _profesionController;

  @override
  void initState() {
    super.initState();
    final user = widget.userJson;
    final info = user['info'] ?? {};

    // Carga de datos iniciales
    _cedulaController = TextEditingController(text: user['cedula']);
    _nombresController = TextEditingController(text: user['nombres']);
    _apellidosController = TextEditingController(text: user['apellidos']);
    _selectedEstado = user['estado'] ?? 'A';
    _selectedRol = user['idRol'] ?? 2;

    _edadController = TextEditingController(
      text: info['edad']?.toString() ?? '',
    );
    _correoController = TextEditingController(text: info['correo'] ?? '');
    _telefonoController = TextEditingController(text: info['telefono'] ?? '');
    _sueldoController = TextEditingController(
      text: info['sueldoActual']?.toString() ?? '',
    );
    _profesionController = TextEditingController(text: info['profesion'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gestión de Usuario",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeader("DATOS DE ACCESO", Icons.lock_outline),
            _buildField(_cedulaController, "Cédula de Identidad", Icons.badge),
            _buildField(_nombresController, "Nombres", Icons.person),
            _buildField(
              _apellidosController,
              "Apellidos",
              Icons.person_outline,
            ),

            Row(
              children: [
                Expanded(child: _buildRoleDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _buildStatusDropdown()),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(thickness: 1.2),
            ),

            _buildHeader(
              "PERFIL FINANCIERO & CONTACTO",
              Icons.account_balance_wallet_outlined,
            ),
            _buildField(
              _correoController,
              "Correo Electrónico",
              Icons.email_outlined,
              type: TextInputType.emailAddress,
            ),
            _buildField(
              _telefonoController,
              "Teléfono Móvil",
              Icons.phone_android,
              type: TextInputType.phone,
            ),

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    _edadController,
                    "Edad",
                    Icons.cake_outlined,
                    type: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    _sueldoController,
                    "Sueldo Mensual",
                    Icons.monetization_on_outlined,
                    type: TextInputType.number,
                  ),
                ),
              ],
            ),

            _buildField(
              _profesionController,
              "Profesión / Ocupación",
              Icons.work_outline,
            ),

            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded, color: Colors.white),
              label: const Text(
                "GUARDAR ACTUALIZACIÓN",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent[700],
                minimumSize: const Size.fromHeight(55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _handleSave,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helpers de UI ---

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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedRol,
      decoration: InputDecoration(
        labelText: "Rol",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 1, child: Text("Admin")),
        DropdownMenuItem(value: 2, child: Text("Usuario")),
      ],
      onChanged: (val) => setState(() => _selectedRol = val!),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedEstado,
      decoration: InputDecoration(
        labelText: "Estado",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 'A', child: Text("Activo")),
        DropdownMenuItem(value: 'I', child: Text("Inactivo")),
      ],
      onChanged: (val) => setState(() => _selectedEstado = val!),
    );
  }

  // --- Lógica de Envío ---

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // Estructuramos el JSON exactamente como lo pide tu Service de NestJS
      final payload = {
        "cedula": _cedulaController.text,
        "nombres": _nombresController.text,
        "apellidos": _apellidosController.text,
        "idRol": _selectedRol,
        "estado": _selectedEstado,
        "info": {
          // Objeto anidado para la tabla UserInfo
          "correo": _correoController.text,
          "telefono": _telefonoController.text,
          "edad": int.tryParse(_edadController.text) ?? 0,
          "sueldoActual": double.tryParse(_sueldoController.text) ?? 0.0,
          "profesion": _profesionController.text,
        },
      };

      widget.onSave(widget.userJson['id'], payload);
    }
  }
}
