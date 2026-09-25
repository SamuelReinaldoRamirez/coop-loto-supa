import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

import '../widgets/euromillions/draw_card.dart';
import '../widgets/euromillions/next_draw_card.dart';

class EuromillionsPage extends StatefulWidget {
  const EuromillionsPage({super.key});

  @override
  State<EuromillionsPage> createState() => _EuromillionsPageState();
}

class _EuromillionsPageState extends State<EuromillionsPage> {
  final ApiService api = ApiService();
  final AuthService _auth = AuthService.instance;

  bool loading = true;
  bool statsMode = false;

  String? _pseudo;

  List<dynamic> draws = [];

  final Map<int, Map<String, dynamic>> stats = {};

  Map<String, dynamic>? currentStats;

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

  Future<void> _loadStats() async {
    try {
      final current = await api.fetchCurrentEuromillionsStats();
      final history = await api.fetchAllEuromillionsStats();

      if (!mounted) return;

      setState(() {
        currentStats = current;

        stats.clear();

        for (final entry in history.entries) {
          stats[int.parse(entry.key)] =
              entry.value as Map<String, dynamic>;
        }
      });
    } catch (e) {
      debugPrint(
        'Erreur lors du chargement des statistiques : $e',
      );
    }
  }

  Future<void> _toggleStats() async {
    if (statsMode) {
      setState(() {
        statsMode = false;
      });
      return;
    }

    setState(() {
      statsMode = true;
    });

    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Euromillions'),
        actions: [
          IconButton(
            tooltip: statsMode
                ? 'Masquer les statistiques'
                : 'Afficher les statistiques',
            icon: Icon(
              statsMode
                  ? Icons.bar_chart
                  : Icons.bar_chart_outlined,
            ),
            onPressed: loading ? null : _toggleStats,
          ),
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
              itemCount: draws.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return NextDrawCard(
                    statsMode: statsMode,
                    currentStats: currentStats,
                  );
                }

                final draw = draws[index - 1];
                final drawId = int.parse(draw['id'].toString());

                return DrawCard(
                  draw: draw,
                  statsMode: statsMode,
                  stats: stats[drawId],
                  onTap: () {
                    context.push(
                      '/euromillions/${draw['id']}',
                      extra: draw,
                    );
                  },
                );
              },
            ),
    );
  }
}