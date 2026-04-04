import 'package:finanzas_moviles/presentation/screens/admin/edit_user_screen.dart';
import 'package:flutter/material.dart';
import '../../../data/services/admin_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../domain/entities/user.dart';
import 'image_picker_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();

  bool _isLoading = true;
  UserModel? _currentUser;
  Map<String, dynamic>? _fullUserData; // ✅ Guardamos los datos completos

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      _currentUser = _authService.currentUser;

      // ✅ Obtener datos completos del backend (incluye info)
      if (_currentUser != null && _currentUser!.id != null) {
        _fullUserData = await _adminService.getUserById(_currentUser!.id!);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("Error cargando perfil: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar perfil: $e")));
    }
  }

  void _openEditProfile() {
    if (_currentUser == null || _fullUserData == null) return;

    // ✅ Usar los datos completos del backend
    final userJson = _fullUserData;

    debugPrint("📱 Enviando a EditUserScreen: $userJson");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(
          userJson: userJson!, // ✅ Pasamos los datos completos con info
          onSave: (id, data) async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );

            try {
              final success = await _adminService.updateUser(id, data);
              if (mounted) Navigator.pop(context);

              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Perfil actualizado con éxito"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  await _loadUserData(); // ✅ Recargar datos
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Error al actualizar el perfil"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } catch (e) {
              if (mounted) Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            }
          },
        ),
      ),
    );
  }

  void _updatePhoto(String? imagePath) {
    if (imagePath == null) return;
    // TODO: Subir foto al servidor
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Próximamente: Guardar foto")));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentUser == null || _fullUserData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Mi Perfil"),
          backgroundColor: Colors.indigo,
        ),
        body: const Center(child: Text("No se pudieron cargar los datos")),
      );
    }

    // ✅ Extraer info del fullUserData
    final info = _fullUserData!['info'] ?? {};
    final correo = info['correo'] ?? _currentUser!.correo ?? "No registrado";
    final telefono =
        info['telefono'] ?? _currentUser!.telefono ?? "No registrado";
    final profesion =
        info['profesion'] ?? _currentUser!.profesion ?? "No registrada";
    final sueldo = (info['sueldoActual'] ?? _currentUser!.sueldo ?? 0)
        .toDouble();

    final isAdmin = _currentUser?.idRol == 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: isAdmin ? Colors.blueGrey[900] : Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Foto de perfil
            ImagePickerWidget(
              radius: 70,
              initialImagePath: _currentUser?.foto,
              onImageSelected: _updatePhoto,
            ),

            const SizedBox(height: 20),

            // Nombre
            Text(
              "${_currentUser!.nombres} ${_currentUser!.apellidos}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            // Rol
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isAdmin ? Colors.blueGrey[200] : Colors.indigo[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAdmin ? "Administrador" : "Usuario",
                style: TextStyle(
                  color: isAdmin ? Colors.blueGrey[800] : Colors.indigo[800],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Tarjeta con información
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email, "Correo", correo),
                    const Divider(),
                    _buildInfoRow(Icons.phone, "Teléfono", telefono),
                    const Divider(),
                    _buildInfoRow(Icons.work, "Profesión", profesion),
                    const Divider(),
                    _buildInfoRow(
                      Icons.monetization_on,
                      "Sueldo",
                      "\$${sueldo.toStringAsFixed(2)}",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Botón para editar perfil
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _openEditProfile,
                icon: const Icon(Icons.edit),
                label: const Text(
                  "Editar Datos Personales",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botón para cambiar contraseña
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Próximamente")));
                },
                icon: const Icon(Icons.lock_reset),
                label: const Text("Cambiar Contraseña"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
