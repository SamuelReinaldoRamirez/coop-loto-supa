import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {

    final games = [
      'Euromillions',
      'Loto',
      'Keno',
      'Courses hippiques',
      'Jeux téléphoniques',
      'Roulette',
      'Grattages',
      'Trading - Cryptos, actions',
      'Paris, Lol, Polymarket, Poker, etc.',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text('Jeux'),
      ),

      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, i) {

          return Card(
            child: ListTile(
              title: Text(games[i]),

              trailing: const Icon(Icons.chevron_right),

              onTap: () {

                if (games[i] == 'Euromillions') {
                  context.push('/euromillions');
                }
              },
            ),
          );
        },
      ),
    );
  }
}