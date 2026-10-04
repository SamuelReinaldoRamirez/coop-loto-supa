import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PreviousDrawsPage extends StatelessWidget {
  final int groupId;
  final String username;

  const PreviousDrawsPage({
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
          'Tirages précédents',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _buildDrawCard(
            context,
            date: '02/10/2026',
            numbers: [4, 12, 18, 27, 43],
            stars: [3, 9],
          ),

          _buildDrawCard(
            context,
            date: '30/09/2026',
            numbers: [2, 14, 21, 35, 48],
            stars: [5, 11],
          ),

          _buildDrawCard(
            context,
            date: '25/09/2026',
            numbers: [7, 16, 24, 31, 42],
            stars: [2, 8],
          ),

          _buildDrawCard(
            context,
            date: '23/09/2026',
            numbers: [1, 9, 19, 28, 44],
            stars: [4, 10],
          ),

          _buildDrawCard(
            context,
            date: '18/09/2026',
            numbers: [6, 13, 22, 33, 47],
            stars: [1, 7],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawCard(
    BuildContext context, {
    required String date,
    required List<int> numbers,
    required List<int> stars,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                const Icon(
                  Icons.casino_rounded,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: numbers
                  .map(
                    (number) => _buildBall(
                      number.toString(),
                      Colors.grey.shade200,
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 7,
              children: stars
                  .map(
                    (star) => _buildBall(
                      '★$star',
                      Colors.amber.shade100,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBall(
    String value,
    Color backgroundColor,
  ) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}