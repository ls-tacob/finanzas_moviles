import 'package:finanzas_moviles/presentation/screens/admin/edit_user_screen.dart';
import 'package:flutter/material.dart';
import '../../../data/services/admin_service.dart';
import '../../../domain/entities/user.dart';
import '../../../core/session_manager.dart';

class AdminHistoricalUsersScreen extends StatefulWidget {
  const AdminHistoricalUsersScreen({super.key});

  @override
  State<AdminHistoricalUsersScreen> createState() =>
      _AdminHistoricalUsersScreenState();
}

class _AdminHistoricalUsersScreenState
    extends State<AdminHistoricalUsersScreen> {
  final AdminService _adminService = AdminService();
  final SessionManager _sessionManager = SessionManager();

  List<UserModel> _deletedUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'eliminados'; // eliminados, inactivos

  @override
  void initState() {
    super.initState();
    _fetchHistoricalUsers();
  }

 Future<void> _fetchHistoricalUsers() async {
    setState(() => _isLoading = true);
    try {
      final allUsers = await _adminService.getAllUsers();

      // 🔍 DEBUG: Ver todos los usuarios que trae el backend
      print("========== TODOS LOS USUARIOS ==========");
      for (var user in allUsers) {
        print(
          "ID: ${user.id}, Nombre: ${user.nombres}, Estado: ${user.estado}, Dellog: ${user.dellog}",
        );
      }
      print("=========================================");

      // 🔍 DEBUG: Ver cuántos inactivos hay
      final inactivos = allUsers.where((user) => user.estado == 'I').toList();
      print("🔍 Usuarios inactivos encontrados: ${inactivos.length}");

      setState(() {
        _deletedUsers = allUsers
            .where(
              (user) =>
                  user.dellog == 'S' ||
                  (user.estado == 'I' && user.dellog == 'N'),
            )
            .toList();
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar históricos: $e")));
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'eliminados') {
        // Solo usuarios ELIMINADOS (dellog == 'S')
        _filteredUsers = _deletedUsers
            .where((user) => user.dellog == 'S')
            .toList();
      } else if (_selectedFilter == 'inactivos') {
        // Solo usuarios INACTIVOS (estado == 'I' y NO eliminados)
        _filteredUsers = _deletedUsers
            .where((user) => user.estado == 'I' && user.dellog == 'N')
            .toList();
      } else {
        // 'todos' - mostrar ambos: eliminados + inactivos
        _filteredUsers = _deletedUsers;
      }

      // Aplicar búsqueda si hay query
      if (_searchController.text.isNotEmpty) {
        _filteredUsers = _filteredUsers
            .where(
              (user) =>
                  user.nombres.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ) ||
                  user.apellidos.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ) ||
                  user.cedula.contains(_searchController.text),
            )
            .toList();
      }
    });
  }

  void _navigateToEdit(UserModel user) {
    final fullUserJson = {
      'id': user.id,
      'cedula': user.cedula,
      'nombres': user.nombres,
      'apellidos': user.apellidos,
      'idRol': user.idRol,
      'estado': user.estado,
      'dellog': user.dellog,
      'info': {
        'correo': user.correo,
        'telefono': user.telefono,
        'sueldoActual': user.sueldo,
        'profesion': user.profesion,
      },
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(
          userJson: fullUserJson,
          onSave: (id, data) async {
            final success = await _adminService.updateUser(id, data);
            if (success) {
              if (mounted) Navigator.pop(context);
              _fetchHistoricalUsers();
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
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (query) => _applyFilter(),
              )
            : const Text("Histórico de Usuarios"),
        backgroundColor: Colors.orange[800],
        foregroundColor: const Color.fromARGB(255, 48, 40, 40),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _applyFilter();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHistoricalUsers,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  "Filtrar:",
                  style: TextStyle(
                    color: Color.fromARGB(255, 23, 20, 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                _buildFilterChip("Eliminados", "eliminados"),
                const SizedBox(width: 8),
                _buildFilterChip("Inactivos", "inactivos"),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredUsers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: const Color.fromARGB(255, 28, 20, 20)),
                  const SizedBox(height: 16),
                  Text(
                    "No hay usuarios en el histórico",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _filteredUsers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                final isDeleted = user.dellog == 'S';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isDeleted
                          ? Colors.red[100]
                          : Colors.orange[100],
                      child: Text(
                        user.nombres[0].toUpperCase(),
                        style: TextStyle(
                          color: isDeleted ? Colors.red : Colors.orange,
                        ),
                      ),
                    ),
                    title: Text(
                      "${user.nombres} ${user.apellidos}",
                      style: TextStyle(
                        decoration: isDeleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isDeleted ? Colors.red : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.cedula),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDeleted
                                ? Colors.red[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isDeleted ? "ELIMINADO" : "INACTIVO",
                            style: TextStyle(
                              fontSize: 10,
                              color: isDeleted ? Colors.red : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _navigateToEdit(user),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
          _applyFilter();
        });
      },
      backgroundColor: const Color.fromARGB(60, 193, 51, 51),
      selectedColor: Colors.blueAccent,
      labelStyle: TextStyle(
        color: _selectedFilter == value ? Colors.white : Colors.white70,
      ),
      checkmarkColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
