import 'package:flutter/material.dart';

class VibeManualListsView extends StatelessWidget {
  const VibeManualListsView({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = ['Desayuno', 'Cena', 'Almuerzo', 'Snacks'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Listas', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(groups[index], style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
              },
            ),
          );
        },
      ),
    );
  }
}
