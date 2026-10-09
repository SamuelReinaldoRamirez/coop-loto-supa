import 'package:flutter/material.dart';

class GroupPlayedGridsPage extends StatelessWidget {
  final int groupId;
  final String username;

  const GroupPlayedGridsPage({
    super.key,
    required this.groupId,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Grilles jouées par votre groupe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGridCard(context, date: '02/10/2026', author: 'adminsam', numbers: [4, 12, 18, 27, 43], stars: [3, 9], strategy: 'Modèle B'),
          _buildGridCard(context, date: '30/09/2026', author: 'Alice', numbers: [2, 14, 21, 35, 48], stars: [5, 11], strategy: 'Choix individuel'),
          _buildGridCard(context, date: '25/09/2026', author: 'Bob', numbers: [7, 16, 24, 31, 42], stars: [2, 8], strategy: 'Aléatoire'),
          _buildGridCard(context, date: '23/09/2026', author: 'adminsam', numbers: [1, 9, 19, 28, 44], stars: [4, 10], strategy: 'Modèle A'),
        ],
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context, {
    required String date,
    required String author,
    required List<int> numbers,
    required List<int> stars,
    required String strategy,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.confirmation_number_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Text(author, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Stratégie : $strategy', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: numbers.map((number) => _buildBall(number.toString(), Colors.grey.shade200)).toList(),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              children: stars.map((star) => _buildBall('★$star', Colors.amber.shade100)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBall(String value, Color backgroundColor) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(
        child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
