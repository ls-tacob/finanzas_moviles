import 'package:finanzas_moviles/presentation/screens/admin/admin_historical_users_screen.dart';
import 'package:finanzas_moviles/presentation/screens/admin/admin_users_list_screen.dart';
import 'package:flutter/material.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Administración"),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _adminOptionCard(
            context,
            title: "Gestión de Usuarios",
            subtitle: "Ver, editar y eliminar usuarios del sistema",
            icon: Icons.people_alt_rounded,
            color: Colors.blueAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminUsersListScreen(),
                ),
              );
            },
          ),
          _adminOptionCard(
            context,
            title: "Histórico de Usuarios",
            subtitle: "Ver usuarios eliminados e inactivos",
            icon: Icons.history,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminHistoricalUsersScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          _adminOptionCard(
            context,
            title: "Reportes Globales",
            subtitle: "Próximamente...",
            icon: Icons.bar_chart_rounded,
            color: Colors.grey,
            onTap: () {
              // Por ahora nada
            },
          ),
        ],
      ),
    );
  }

  Widget _adminOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
