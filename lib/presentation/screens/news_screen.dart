import 'package:flutter/material.dart';
import '../../data/services/news_service.dart';

class NewsScreen extends StatelessWidget {
  final NewsService _service = NewsService();

  NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Noticias de Emprendimiento")),
      body: FutureBuilder<List<dynamic>>(
        future: _service.getBusinessNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final noticias = snapshot.data ?? [];

          return ListView.builder(
            itemCount: noticias.length,
            itemBuilder: (context, index) {
              final item = noticias[index];
              return ListTile(
                leading: const Icon(Icons.newspaper),
                title: Text(item['titular']),
                subtitle: Text("Fuente: ${item['fuente']}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              );
            },
          );
        },
      ),
    );
  }
}
