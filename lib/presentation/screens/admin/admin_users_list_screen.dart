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
        _allUsers = users;
        _filteredUsers = users;
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
                style: const TextStyle(color: Colors.white),
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
                  subtitle: Text(
                    user.cedula,
                  ), // Cambié a cédula para que sea útil en la lista
                  trailing: Row(
                    mainAxisSize: MainAxisSize
                        .min, // Vital para que no ocupe toda la pantalla
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
            // Dentro del botón de confirmación del diálogo:
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

  // Dentro de tu _UserListScreenState

  void _navigateToEdit(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(
          userJson: user,
          onSave: (id, data) async {
            final success = await _adminService.patchUser(
              id,
              data,
              miTokenGuardado,
            );
            if (success) {
              // Cerramos el Screen de Edición
              if (mounted) Navigator.pop(context);

              // Refrescamos la lista de la pantalla principal
              _fetchUsers();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Usuario actualizado con éxito")),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error al actualizar el usuario")),
              );
            }
          },
        ),
      ),
    );
  }

 
}
