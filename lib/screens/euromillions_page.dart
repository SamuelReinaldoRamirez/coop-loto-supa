
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

  bool _isSuperAdmin = false;

  // Identifiants des tirages dont la suppression est en cours.
  final Set<int> _deletingDrawIds = {};

  List<dynamic> draws = [];

  final Map<int, Map<String, dynamic>> stats = {};

  Map<String, dynamic>? currentStats;

  @override
  void initState() {
    super.initState();
    _loadIsSuperAdmin();
    load();
  }

  // ---------------------------------------------------------------------------
  // Chargement du profil
  // ---------------------------------------------------------------------------

  Future<void> _loadIsSuperAdmin() async {
    final isSuperAdmin = await _auth.getIsSuperAdmin();

    if (!mounted) return;

    setState(() {
      _isSuperAdmin = isSuperAdmin;
    });
  }

  // ---------------------------------------------------------------------------
  // Chargement des tirages
  // ---------------------------------------------------------------------------

  Future<void> load() async {
    try {
      final data = await api.fetchEuromillionsDraws();

      if (!mounted) return;

      setState(() {
        draws = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du chargement des tirages : $e',
          ),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Suppression d'un tirage
  // ---------------------------------------------------------------------------

  Future<void> _confirmDeleteDraw(
    int drawId,
  ) async {
    if (!_isSuperAdmin || _deletingDrawIds.contains(drawId)) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer ce tirage ?'),
          content: Text(
            'Le tirage n°$drawId sera définitivement supprimé. '
            'Cette action peut être irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await _deleteDraw(drawId);
  }

  Future<void> _deleteDraw(int drawId) async {
    if (!_isSuperAdmin || _deletingDrawIds.contains(drawId)) {
      return;
    }

    setState(() {
      _deletingDrawIds.add(drawId);
    });

    try {
      // Appel DELETE /euromillions/draws/{drawId}.
      await api.deleteEuromillionsDraw(drawId);

      if (!mounted) return;

      setState(() {
        draws.removeWhere((draw) {
          return int.tryParse(draw['id'].toString()) == drawId;
        });

        // Les statistiques du tirage supprimé ne doivent plus être affichées.
        stats.remove(drawId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le tirage n°$drawId a été supprimé.'),
          backgroundColor: Colors.green,
        ),
      );

      // Si le mode statistiques est actif, actualiser les données.
      if (statsMode) {
        await _loadStats();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de supprimer le tirage : '
            '${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingDrawIds.remove(drawId);
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Chargement des statistiques
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Interface
  // ---------------------------------------------------------------------------

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
          if (_isSuperAdmin)
            IconButton(
              tooltip: 'Collecter les tirages',
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
                // La carte du prochain tirage n'est pas supprimable.
                if (index == 0) {
                  return NextDrawCard(
                    statsMode: statsMode,
                    currentStats: currentStats,
                  );
                }

                final draw = draws[index - 1];
                final drawId = int.parse(draw['id'].toString());
                final isDeleting =
                    _deletingDrawIds.contains(drawId);

                return Stack(
                  children: [
                    DrawCard(
                      draw: draw,
                      statsMode: statsMode,
                      stats: stats[drawId],
                      onTap: () {
                        context.push(
                          '/euromillions/${draw['id']}',
                          extra: draw,
                        );
                      },
                    ),

                    // La croix n'existe dans l'interface
                    // que pour les super-administrateurs.
                    if (_isSuperAdmin)
                      Positioned(
                        top: 4,
                        right: 8,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: isDeleting
                                ? const Padding(
                                    padding: EdgeInsets.all(9),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.red,
                                    ),
                                  )
                                : IconButton(
                                    tooltip: 'Supprimer ce tirage',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      _confirmDeleteDraw(drawId);
                                    },
                                  ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

// // page utilisée dans euromillions
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// import '../services/api_service.dart';
// import '../services/auth_service.dart';

// import '../widgets/euromillions/draw_card.dart';
// import '../widgets/euromillions/next_draw_card.dart';

// class EuromillionsPage extends StatefulWidget {
//   const EuromillionsPage({super.key});

//   @override
//   State<EuromillionsPage> createState() => _EuromillionsPageState();
// }

// class _EuromillionsPageState extends State<EuromillionsPage> {
//   final ApiService api = ApiService();
//   final AuthService _auth = AuthService.instance;

//   bool loading = true;
//   bool statsMode = false;

//   bool _isSuperAdmin = false;

//   List<dynamic> draws = [];

//   final Map<int, Map<String, dynamic>> stats = {};

//   Map<String, dynamic>? currentStats;

//   @override
//   void initState() {
//     super.initState();
//     _loadIsSuperAdmin();
//     load();
//   }

//   Future<void> _loadIsSuperAdmin() async {
//     final isSuperAdmin = await _auth.getIsSuperAdmin();

//     if (!mounted) return;

//     setState(() {
//       _isSuperAdmin = isSuperAdmin;
//     });
//   }

//   Future<void> load() async {
//     final data = await api.fetchEuromillionsDraws();

//     if (!mounted) return;

//     setState(() {
//       draws = data;
//       loading = false;
//     });
//   }

//   Future<void> _loadStats() async {
//     try {
//       final current = await api.fetchCurrentEuromillionsStats();
//       final history = await api.fetchAllEuromillionsStats();

//       if (!mounted) return;

//       setState(() {
//         currentStats = current;

//         stats.clear();

//         for (final entry in history.entries) {
//           stats[int.parse(entry.key)] =
//               entry.value as Map<String, dynamic>;
//         }
//       });
//     } catch (e) {
//       debugPrint(
//         'Erreur lors du chargement des statistiques : $e',
//       );
//     }
//   }

//   Future<void> _toggleStats() async {
//     if (statsMode) {
//       setState(() {
//         statsMode = false;
//       });
//       return;
//     }

//     setState(() {
//       statsMode = true;
//     });

//     await _loadStats();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Euromillions'),
//         actions: [
//           IconButton(
//             tooltip: statsMode
//                 ? 'Masquer les statistiques'
//                 : 'Afficher les statistiques',
//             icon: Icon(
//               statsMode
//                   ? Icons.bar_chart
//                   : Icons.bar_chart_outlined,
//             ),
//             onPressed: loading ? null : _toggleStats,
//           ),
//           if (_isSuperAdmin)
//             IconButton(
//               icon: const Icon(Icons.cloud_download),
//               onPressed: () {
//                 context.push('/collect-euromillions');
//               },
//             ),
//         ],
//       ),
//       body: loading
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : ListView.builder(
//               itemCount: draws.length + 1,
//               itemBuilder: (context, index) {
//                 if (index == 0) {
//                   return NextDrawCard(
//                     statsMode: statsMode,
//                     currentStats: currentStats,
//                   );
//                 }

//                 final draw = draws[index - 1];
//                 final drawId = int.parse(draw['id'].toString());

//                 return DrawCard(
//                   draw: draw,
//                   statsMode: statsMode,
//                   stats: stats[drawId],
//                   onTap: () {
//                     context.push(
//                       '/euromillions/${draw['id']}',
//                       extra: draw,
//                     );
//                   },
//                 );
//               },
//             ),
//     );
//   }
// }