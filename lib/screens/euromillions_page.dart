import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class EuromillionsPage extends StatefulWidget {
  const EuromillionsPage({super.key});

  @override
  State<EuromillionsPage> createState() =>
      _EuromillionsPageState();
}

class _EuromillionsPageState
    extends State<EuromillionsPage> {

  final ApiService api = ApiService();
  final AuthService _auth = AuthService.instance;
  String? _pseudo;

  bool loading = true;

  List<dynamic> draws = [];

  @override
  void initState() {
    super.initState();
    _loadPseudo();
    load();
  }

  Future<void> _loadPseudo() async {
    final pseudo = await _auth.getPseudo();

    if (!mounted) return;

    setState(() {
      _pseudo = pseudo;
    });
  }

  Future<void> load() async {
    final data = await api.fetchEuromillionsDraws();

    if (!mounted) return;

    setState(() {
      draws = data;
      loading = false;
    });
  }

  Widget ball(int n, Color c) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: c,
      child: Text(
        '$n',
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatJackpot(dynamic jackpot) {
    final value = int.parse(jackpot.toString());

    return value
        .toString()
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
        );
  }

  Color _getCardColor(dynamic winners) {
    final count = int.parse(winners.toString());

    if (count == 1) {
      return const Color(0xFFD2B48C); // Ocre
    }

    if (count > 1) {
      return const Color(0xFFF4CCCC); // Rouge pâle
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Euromillions'),
        actions: [
          if (_pseudo == 'adminsam')
            IconButton(
              icon: const Icon(Icons.cloud_download),
              onPressed: () {
                context.push('/collect-euromillions');
              },
            ),
        ],
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: draws.length,
              itemBuilder: (context, i) {
                final d = draws[i];

                return Card(
                  color: _getCardColor(d['winners']),
                  child: ListTile(
                    title: Row(
                      children: [
                        for (final n in [
                          d['n1'],
                          d['n2'],
                          d['n3'],
                          d['n4'],
                          d['n5'],
                        ])
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 4,
                            ),
                            child: ball(n, Colors.blue),
                          ),

                        const SizedBox(width: 8),

                        ball(d['e1'], Colors.orange),
                        const SizedBox(width: 4),
                        ball(d['e2'], Colors.orange),
                      ],
                    ),

                    subtitle: Text(
                      '${d['draw_date']}\n'
                      'Jackpot : ${_formatJackpot(d['jackpot'])} €\n'
                      'Gagnants : ${d['winners']}',
                    ),

                    isThreeLine: true,

                    onTap: () {
                      context.push(
                        '/euromillions/${d['id']}',
                        extra: d,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
