import 'dart:convert';

import 'package:finanzas_moviles/core/constants.dart';
import 'package:finanzas_moviles/presentation/screens/admin/edit_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/admin_service.dart';
import '../../../domain/entities/user.dart';

// 1. La clase principal debe ser StatefulWidget
class AdminUsersListScreen extends StatefulWidget {
  const AdminUsersListScreen({super.key});

  @override
  State<AdminUsersListScreen> createState() => _AdminUsersListScreenState();
}

// 2. Aquí es donde vive toda la lógica (initState, setState, etc.)
class _AdminUsersListScreenState extends State<AdminUsersListScreen> {
  final AdminService _adminService = AdminService();

  List<UserModel> _allUsers = []; // Datos originales del Back
  List<UserModel> _filteredUsers = []; // Datos que se muestran (filtrados)
  bool _isLoading = true;
  bool _isSearching = false; // Controla si la barra de búsqueda está activa
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Carga inicial
  }

 Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _adminService.getAllUsers();
      setState(() {
        // ✅ Solo usuarios ACTIVOS (NO eliminados Y estado Activo)
        _allUsers = users
            .where((user) => user.dellog == 'N' && user.estado == 'A')
            .toList();
        _filteredUsers = _allUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar usuarios: $e")));
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _allUsers
          .where(
            (user) =>
                user.nombres.toLowerCase().contains(query.toLowerCase()) ||
                user.apellidos.toLowerCase().contains(query.toLowerCase()) ||
                user.cedula.contains(query),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Color.fromARGB(255, 34, 24, 24)),
                decoration: const InputDecoration(
                  hintText: "Buscar por nombre o cédula...",
                  hintStyle: TextStyle(color: Color.fromARGB(179, 14, 2, 2)),
                  border: InputBorder.none,
                ),
                onChanged: _filterUsers,
              )
            : const Text("Lista de Usuarios"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _filteredUsers = _allUsers; // Resetear filtro
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchUsers),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredUsers.isEmpty
          ? const Center(child: Text("No se encontraron usuarios"))
          : ListView.separated(
              itemCount: _filteredUsers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.nombres[0].toUpperCase()),
                  ),
                  title: Text("${user.nombres} ${user.apellidos}"),
                  subtitle: Text(user.cedula),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // BOTÓN EDITAR
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _navigateToEdit(user);
                        },
                      ),
                      // BOTÓN ELIMINAR
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          _confirmDelete(user);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text(
          "¿Estás seguro de que deseas eliminar a ${user.nombres}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await _adminService.deleteUser(user.id!);
              if (success) {
                _fetchUsers(); // Refrescamos la UI automáticamente
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Usuario eliminado correctamente"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

// ✅ CÓMO DEBE QUEDAR (reconstruye el JSON con la estructura 'info')
  void _navigateToEdit(UserModel user) async {
    // Primero obtenemos los datos completos del usuario desde el backend
    // para tener la estructura 'info' completa
    final fullUserData = await _adminService.getUserById(user.id!);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(
          userJson: fullUserData, // ← Pasamos el JSON completo con 'info'
          onSave: (id, data) async {
            // Mostrar loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );

            try {
              final success = await _adminService.updateUser(id, data);

              // Cerrar loading
              if (mounted) Navigator.pop(context);

              if (success) {
                if (mounted) Navigator.pop(context);
                _fetchUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Usuario actualizado con éxito"),
                  ),
                );
              }
            } catch (e) {
              // Cerrar loading
              if (mounted) Navigator.pop(context);

              final errorMsg = e.toString();
              if (errorMsg.contains('CONFLICT:')) {
                // Extraer mensaje amigable
                final friendlyMsg = errorMsg.replaceFirst('CONFLICT:', '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(friendlyMsg),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Error al actualizar el usuario"),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
