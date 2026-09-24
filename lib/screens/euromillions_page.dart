import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
  bool statsMode = false;

  List<dynamic> draws = [];

  // Stats indexées par l'id du tirage
  final Map<int, Map<String, dynamic>> stats = {};

  // Stats actuelles pour préparer le prochain tirage
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
      // -------------------------------------------------
      // 1. Statistiques actuelles pour le prochain tirage
      // -------------------------------------------------

      final current =
          await api.fetchCurrentEuromillionsStats();

      if (!mounted) return;

      setState(() {
        currentStats = current;
      });

      // -------------------------------------------------
      // 2. Statistiques historiques des tirages existants
      // -------------------------------------------------

      final data =
          await api.fetchAllEuromillionsStats();

      if (!mounted) return;

      setState(() {
        stats.clear();

        for (final entry in data.entries) {
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
    if (!statsMode) {
      setState(() {
        statsMode = true;
      });

      await _loadStats();
    } else {
      setState(() {
        statsMode = false;
      });
    }
  }

  // -----------------------------------------------------
  // Boule
  // -----------------------------------------------------

  Widget ball(
    dynamic n,
    Color color, {
    double radius = 16,
    double fontSize = 14,
    Color numberColor = Colors.white,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        '$n',
        style: TextStyle(
          color: numberColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // -----------------------------------------------------
  // Format jackpot
  // -----------------------------------------------------

  String _formatJackpot(dynamic jackpot) {
    final value = int.parse(
      jackpot.toString(),
    );

    return value
        .toString()
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
        );
  }

  // -----------------------------------------------------
  // Couleur de la card selon le nombre de gagnants
  // -----------------------------------------------------

  Color _getCardColor(dynamic winners) {
    final count = int.parse(
      winners.toString(),
    );

    if (count == 1) {
      return const Color(0xFFD2B48C);
    }

    if (count > 1) {
      return const Color(0xFFF4CCCC);
    }

    return Colors.white;
  }

  // -----------------------------------------------------
  // Jour du tirage
  // -----------------------------------------------------

  String _getDrawDay(dynamic drawDate) {
    final date = DateTime.parse(
      drawDate.toString(),
    );

    return DateFormat(
      'EEEE',
      'fr_FR',
    ).format(date);
  }

  // -----------------------------------------------------
  // Récupère la couleur statistique d'un numéro
  //
  // Priorité :
  // Hot > Cold > Retard
  // -----------------------------------------------------

  Color? _getNumberStatsColor(
    dynamic number,
    Map<String, dynamic> drawStats,
  ) {
    final numberValue = int.parse(
      number.toString(),
    );

    final hot =
        (drawStats['hot'] as List?) ?? [];

    final cold =
        (drawStats['cold'] as List?) ?? [];

    final overdue =
        (drawStats['overdue'] as List?) ?? [];

    final hotNumbers = hot.map(
      (item) => int.parse(
        item['number'].toString(),
      ),
    );

    final coldNumbers = cold.map(
      (item) => int.parse(
        item['number'].toString(),
      ),
    );

    final overdueNumbers = overdue.map(
      (item) => int.parse(
        item['number'].toString(),
      ),
    );

    // Hot = rouge
    if (hotNumbers.contains(numberValue)) {
      return Colors.red;
    }

    // Cold = bleu
    if (coldNumbers.contains(numberValue)) {
      return Colors.blue.shade900;
    }

    // Retard = jaune
    if (overdueNumbers.contains(numberValue)) {
      return Colors.yellow;
    }

    return null;
  }

  // -----------------------------------------------------
  // Contenu normal d'un tirage
  // -----------------------------------------------------

  Widget _normalContent(dynamic d) {
    final day = _getDrawDay(
      d['draw_date'],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${d['draw_date']} — $day',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          'Jackpot : ${_formatJackpot(d['jackpot'])} €',
        ),

        Text(
          'Gagnants : ${d['winners']}',
          style: const TextStyle(
            height: 1.0,
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------
  // Contenu du prochain tirage
  // -----------------------------------------------------

  Widget _nextDrawContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'X',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          'Jackpot : X',
        ),

        Text(
          'Gagnants : X',
          style: TextStyle(
            height: 1.0,
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------
  // Contenu statistiques
  // -----------------------------------------------------

  Widget _statsContent(
    Map<String, dynamic> drawStats, {
    List<dynamic>? drawNumbers,
  }) {
    final hot =
        (drawStats['hot'] as List?) ?? [];

    final cold =
        (drawStats['cold'] as List?) ?? [];

    final overdue =
        (drawStats['overdue'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statsLine(
          'Hot : ',
          hot,
          drawStats,
          drawNumbers,
          showCount: true,
        ),

        const SizedBox(height: 2),

        _statsLine(
          'Cold : ',
          cold,
          drawStats,
          drawNumbers,
          showCount: true,
        ),

        const SizedBox(height: 2),

        _overdueLine(
          overdue,
          drawStats,
          drawNumbers,
        ),
      ],
    );
  }

  // -----------------------------------------------------
  // Ligne Hot / Cold
  // -----------------------------------------------------

  Widget _statsLine(
    String label,
    List numbers,
    Map<String, dynamic> drawStats,
    List<dynamic>? drawNumbers, {
    required bool showCount,
  }) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.clip,
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          height: 1.15,
        ),
        children: [
          TextSpan(
            text: label,
          ),

          ...numbers.map(
            (item) {
              final number = item['number'];

              final isInDraw =
                  drawNumbers?.contains(
                    int.parse(
                      number.toString(),
                    ),
                  ) ??
                  false;

              Color? numberColor;

              if (isInDraw) {
                numberColor = _getNumberStatsColor(
                  number,
                  drawStats,
                );
              }

              return TextSpan(
                text: showCount
                    ? '$number(${item['count']})  '
                    : '$number  ',
                style: TextStyle(
                  color: numberColor ??
                      Colors.black,
                  fontWeight: numberColor != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------
  // Ligne Retard
  // -----------------------------------------------------

  Widget _overdueLine(
    List overdue,
    Map<String, dynamic> drawStats,
    List<dynamic>? drawNumbers,
  ) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.clip,
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          height: 1.15,
        ),
        children: [
          const TextSpan(
            text: 'Retard : ',
          ),

          ...overdue.map(
            (item) {
              final number = item['number'];

              final isInDraw =
                  drawNumbers?.contains(
                    int.parse(
                      number.toString(),
                    ),
                  ) ??
                  false;

              Color? numberColor;

              if (isInDraw) {
                numberColor = _getNumberStatsColor(
                  number,
                  drawStats,
                );
              }

              return TextSpan(
                text: '$number  ',
                style: TextStyle(
                  color: numberColor ??
                      Colors.black,
                  fontWeight: numberColor != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------
  // Stats du prochain tirage
  // -----------------------------------------------------

  Widget _nextDrawStatsContent() {
    if (currentStats == null) {
      return const Text(
        'Chargement des statistiques...',
        style: TextStyle(
          fontSize: 11,
        ),
      );
    }

    return _statsContent(
      currentStats!,
    );
  }

  // -----------------------------------------------------
  // Card prochain tirage
  // -----------------------------------------------------

  Widget _buildNextDrawCard() {
    return SizedBox(
      height: 100,
      child: Card(
        color: Colors.white,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),

          title: Row(
            children: [
              for (int i = 0; i < 5; i++)
                Padding(
                  padding:
                      const EdgeInsets.only(
                    right: 3,
                  ),
                  child: ball(
                    'X',
                    Colors.blue,
                    radius: 13,
                    fontSize: 11,
                  ),
                ),

              const SizedBox(width: 5),

              ball(
                'X',
                Colors.orange,
                radius: 13,
                fontSize: 11,
              ),

              const SizedBox(width: 3),

              ball(
                'X',
                Colors.orange,
                radius: 13,
                fontSize: 11,
              ),
            ],
          ),

          subtitle: statsMode
              ? _nextDrawStatsContent()
              : _nextDrawContent(),

          isThreeLine: !statsMode,
        ),
      ),
    );
  }

  // -----------------------------------------------------
  // Build
  // -----------------------------------------------------

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

            onPressed: loading
                ? null
                : _toggleStats,
          ),

          if (_pseudo == 'adminsam')
            IconButton(
              icon: const Icon(
                Icons.cloud_download,
              ),
              onPressed: () {
                context.push(
                  '/collect-euromillions',
                );
              },
            ),
        ],
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              // +1 pour la carte du prochain tirage
              itemCount: draws.length + 1,

              itemBuilder: (context, i) {
                // -----------------------------------------
                // Premier élément = prochain tirage
                // -----------------------------------------

                if (i == 0) {
                  return _buildNextDrawCard();
                }

                // -----------------------------------------
                // Tirages historiques
                // -----------------------------------------

                final d = draws[i - 1];

                final drawId = int.parse(
                  d['id'].toString(),
                );

                final drawStats =
                    stats[drawId];

                final drawNumbers = [
                  int.parse(
                    d['n1'].toString(),
                  ),
                  int.parse(
                    d['n2'].toString(),
                  ),
                  int.parse(
                    d['n3'].toString(),
                  ),
                  int.parse(
                    d['n4'].toString(),
                  ),
                  int.parse(
                    d['n5'].toString(),
                  ),
                ];

                return SizedBox(
                  height: 100,

                  child: Card(
                    color: _getCardColor(
                      d['winners'],
                    ),

                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),

                      title: Row(
                        children: [
                          // ---------------------------------
                          // 5 numéros
                          // ---------------------------------

                          for (final n in [
                            d['n1'],
                            d['n2'],
                            d['n3'],
                            d['n4'],
                            d['n5'],
                          ])
                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                right: 3,
                              ),
                              child: ball(
                                n,
                                Colors.blue,
                                radius: 13,
                                fontSize: 11,

                                // La boule reste bleue.
                                // Seul le numéro change de couleur.
                                numberColor:
                                    statsMode &&
                                    drawStats != null
                                        ? _getNumberStatsColor(
                                            n,
                                            drawStats,
                                          ) ??
                                          Colors.white
                                        : Colors.white,
                              ),
                            ),

                          const SizedBox(width: 5),

                          // ---------------------------------
                          // Etoiles
                          // ---------------------------------

                          ball(
                            d['e1'],
                            Colors.orange,
                            radius: 13,
                            fontSize: 11,
                          ),

                          const SizedBox(width: 3),

                          ball(
                            d['e2'],
                            Colors.orange,
                            radius: 13,
                            fontSize: 11,
                          ),
                        ],
                      ),

                      subtitle: statsMode
                          ? drawStats == null
                              ? const Text(
                                  'Chargement des statistiques...',
                                  style: TextStyle(
                                    fontSize: 11,
                                  ),
                                )
                              : _statsContent(
                                  drawStats,
                                  drawNumbers:
                                      drawNumbers,
                                )
                          : _normalContent(d),

                      isThreeLine: !statsMode,

                      onTap: () {
                        context.push(
                          '/euromillions/${d['id']}',
                          extra: d,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';

// import '../services/api_service.dart';
// import '../services/auth_service.dart';

// class EuromillionsPage extends StatefulWidget {
//   const EuromillionsPage({super.key});

//   @override
//   State<EuromillionsPage> createState() =>
//       _EuromillionsPageState();
// }

// class _EuromillionsPageState
//     extends State<EuromillionsPage> {

//   final ApiService api = ApiService();
//   final AuthService _auth = AuthService.instance;

//   String? _pseudo;

//   bool loading = true;
//   bool statsMode = false;

//   List<dynamic> draws = [];

//   // Stats indexées par l'id du tirage
//   final Map<int, Map<String, dynamic>> stats = {};

//   // Stats actuelles pour préparer le prochain tirage
//   Map<String, dynamic>? currentStats;

//   @override
//   void initState() {
//     super.initState();

//     _loadPseudo();
//     load();
//   }

//   Future<void> _loadPseudo() async {
//     final pseudo = await _auth.getPseudo();

//     if (!mounted) return;

//     setState(() {
//       _pseudo = pseudo;
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
//       // -------------------------------------------------
//       // 1. Statistiques actuelles pour le prochain tirage
//       // -------------------------------------------------

//       final current =
//           await api.fetchCurrentEuromillionsStats();

//       if (!mounted) return;

//       setState(() {
//         currentStats = current;
//       });

//       // -------------------------------------------------
//       // 2. Statistiques historiques des tirages existants
//       // -------------------------------------------------

//       final data =
//           await api.fetchAllEuromillionsStats();

//       if (!mounted) return;

//       setState(() {
//         stats.clear();

//         for (final entry in data.entries) {
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
//     if (!statsMode) {
//       setState(() {
//         statsMode = true;
//       });

//       await _loadStats();
//     } else {
//       setState(() {
//         statsMode = false;
//       });
//     }
//   }

//   // -----------------------------------------------------
//   // Boule
//   // -----------------------------------------------------

//   Widget ball(
//     dynamic n,
//     Color color, {
//     double radius = 16,
//     double fontSize = 14,
//     bool highlighted = false,
//   }) {
//     return CircleAvatar(
//       radius: radius,
//       backgroundColor: color,
//       child: Text(
//         '$n',
//         style: TextStyle(
//           // La boule garde sa couleur.
//           // Seul le numéro devient rouge.
//           color: highlighted
//               ? Colors.red
//               : Colors.white,
//           fontSize: fontSize,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   // -----------------------------------------------------
//   // Format jackpot
//   // -----------------------------------------------------

//   String _formatJackpot(dynamic jackpot) {
//     final value = int.parse(
//       jackpot.toString(),
//     );

//     return value
//         .toString()
//         .replaceAllMapped(
//           RegExp(r'\B(?=(\d{3})+(?!\d))'),
//           (match) => ' ',
//         );
//   }

//   // -----------------------------------------------------
//   // Couleur de la card selon le nombre de gagnants
//   // -----------------------------------------------------

//   Color _getCardColor(dynamic winners) {
//     final count = int.parse(
//       winners.toString(),
//     );

//     if (count == 1) {
//       return const Color(0xFFD2B48C);
//     }

//     if (count > 1) {
//       return const Color(0xFFF4CCCC);
//     }

//     return Colors.white;
//   }

//   // -----------------------------------------------------
//   // Jour du tirage
//   // -----------------------------------------------------

//   String _getDrawDay(dynamic drawDate) {
//     final date = DateTime.parse(
//       drawDate.toString(),
//     );

//     return DateFormat(
//       'EEEE',
//       'fr_FR',
//     ).format(date);
//   }

//   // -----------------------------------------------------
//   // Vérifie si un numéro appartient à hot/cold/retard
//   // -----------------------------------------------------

//   bool _isNumberInStats(
//     dynamic number,
//     Map<String, dynamic> drawStats,
//   ) {
//     final numberValue = int.parse(
//       number.toString(),
//     );

//     final hot =
//         (drawStats['hot'] as List?) ?? [];

//     final cold =
//         (drawStats['cold'] as List?) ?? [];

//     final overdue =
//         (drawStats['overdue'] as List?) ?? [];

//     final hotNumbers = hot.map(
//       (item) => int.parse(
//         item['number'].toString(),
//       ),
//     );

//     final coldNumbers = cold.map(
//       (item) => int.parse(
//         item['number'].toString(),
//       ),
//     );

//     final overdueNumbers = overdue.map(
//       (item) => int.parse(
//         item['number'].toString(),
//       ),
//     );

//     return hotNumbers.contains(numberValue) ||
//         coldNumbers.contains(numberValue) ||
//         overdueNumbers.contains(numberValue);
//   }

//   // -----------------------------------------------------
//   // Contenu normal d'un tirage
//   // -----------------------------------------------------

//   Widget _normalContent(dynamic d) {
//     final day = _getDrawDay(
//       d['draw_date'],
//     );

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '${d['draw_date']} — $day',
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),

//         Text(
//           'Jackpot : ${_formatJackpot(d['jackpot'])} €',
//         ),

//         Text(
//           'Gagnants : ${d['winners']}',
//           style: const TextStyle(
//             height: 1.0,
//           ),
//         ),
//       ],
//     );
//   }

//   // -----------------------------------------------------
//   // Contenu du prochain tirage
//   // -----------------------------------------------------

//   Widget _nextDrawContent() {
//     return const Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'X',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),

//         Text(
//           'Jackpot : X',
//         ),

//         Text(
//           'Gagnants : X',
//           style: TextStyle(
//             height: 1.0,
//           ),
//         ),
//       ],
//     );
//   }

//   // -----------------------------------------------------
//   // Contenu statistiques
//   // -----------------------------------------------------

//   Widget _statsContent(
//     Map<String, dynamic> drawStats,
//   ) {
//     final hot =
//         (drawStats['hot'] as List?) ?? [];

//     final cold =
//         (drawStats['cold'] as List?) ?? [];

//     final overdue =
//         (drawStats['overdue'] as List?) ?? [];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _statsLine(
//           'Hot : ',
//           hot,
//           showCount: true,
//         ),

//         const SizedBox(height: 2),

//         _statsLine(
//           'Cold : ',
//           cold,
//           showCount: true,
//         ),

//         const SizedBox(height: 2),

//         _overdueLine(overdue),
//       ],
//     );
//   }

//   Widget _statsLine(
//     String label,
//     List numbers, {
//     required bool showCount,
//   }) {
//     return Text(
//       label +
//           numbers
//               .map(
//                 (item) => showCount
//                     ? '${item['number']}(${item['count']})'
//                     : '${item['number']}',
//               )
//               .join('  '),
//       style: const TextStyle(
//         fontSize: 11,
//         height: 1.15,
//       ),
//       maxLines: 1,
//       overflow: TextOverflow.clip,
//     );
//   }

//   Widget _overdueLine(List overdue) {
//     return Text(
//       'Retard : ' +
//           overdue
//               .map(
//                 (item) => '${item['number']}',
//               )
//               .join('  '),
//       style: const TextStyle(
//         fontSize: 11,
//         height: 1.15,
//       ),
//       maxLines: 1,
//       overflow: TextOverflow.clip,
//     );
//   }

//   // -----------------------------------------------------
//   // Stats du prochain tirage
//   // -----------------------------------------------------

//   Widget _nextDrawStatsContent() {
//     if (currentStats == null) {
//       return const Text(
//         'Chargement des statistiques...',
//         style: TextStyle(
//           fontSize: 11,
//         ),
//       );
//     }

//     return _statsContent(
//       currentStats!,
//     );
//   }

//   // -----------------------------------------------------
//   // Card prochain tirage
//   // -----------------------------------------------------

//   Widget _buildNextDrawCard() {
//     return SizedBox(
//       height: 100,
//       child: Card(
//         color: Colors.white,
//         child: ListTile(
//           contentPadding:
//               const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 0,
//           ),

//           title: Row(
//             children: [
//               for (int i = 0; i < 5; i++)
//                 Padding(
//                   padding:
//                       const EdgeInsets.only(
//                     right: 3,
//                   ),
//                   child: ball(
//                     'X',
//                     Colors.blue,
//                     radius: 13,
//                     fontSize: 11,
//                   ),
//                 ),

//               const SizedBox(width: 5),

//               ball(
//                 'X',
//                 Colors.orange,
//                 radius: 13,
//                 fontSize: 11,
//               ),

//               const SizedBox(width: 3),

//               ball(
//                 'X',
//                 Colors.orange,
//                 radius: 13,
//                 fontSize: 11,
//               ),
//             ],
//           ),

//           subtitle: statsMode
//               ? _nextDrawStatsContent()
//               : _nextDrawContent(),

//           isThreeLine: !statsMode,
//         ),
//       ),
//     );
//   }

//   // -----------------------------------------------------
//   // Build
//   // -----------------------------------------------------

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

//             onPressed: loading
//                 ? null
//                 : _toggleStats,
//           ),

//           if (_pseudo == 'adminsam')
//             IconButton(
//               icon: const Icon(
//                 Icons.cloud_download,
//               ),
//               onPressed: () {
//                 context.push(
//                   '/collect-euromillions',
//                 );
//               },
//             ),
//         ],
//       ),

//       body: loading
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : ListView.builder(
//               // +1 pour la carte du prochain tirage
//               itemCount: draws.length + 1,

//               itemBuilder: (context, i) {
//                 // -----------------------------------------
//                 // Premier élément = prochain tirage
//                 // -----------------------------------------

//                 if (i == 0) {
//                   return _buildNextDrawCard();
//                 }

//                 // -----------------------------------------
//                 // Tirages historiques
//                 // -----------------------------------------

//                 final d = draws[i - 1];

//                 final drawId = int.parse(
//                   d['id'].toString(),
//                 );

//                 final drawStats =
//                     stats[drawId];

//                 return SizedBox(
//                   height: 100,

//                   child: Card(
//                     color: _getCardColor(
//                       d['winners'],
//                     ),

//                     child: ListTile(
//                       contentPadding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 4,
//                       ),

//                       title: Row(
//                         children: [
//                           // ---------------------------------
//                           // 5 numéros
//                           // ---------------------------------

//                           for (final n in [
//                             d['n1'],
//                             d['n2'],
//                             d['n3'],
//                             d['n4'],
//                             d['n5'],
//                           ])
//                             Padding(
//                               padding:
//                                   const EdgeInsets.only(
//                                 right: 3,
//                               ),
//                               child: ball(
//                                 n,
//                                 Colors.blue,
//                                 radius: 13,
//                                 fontSize: 11,
//                                 highlighted:
//                                     statsMode &&
//                                     drawStats != null &&
//                                     _isNumberInStats(
//                                       n,
//                                       drawStats,
//                                     ),
//                               ),
//                             ),

//                           const SizedBox(width: 5),

//                           // ---------------------------------
//                           // Etoiles
//                           // ---------------------------------

//                           ball(
//                             d['e1'],
//                             Colors.orange,
//                             radius: 13,
//                             fontSize: 11,
//                           ),

//                           const SizedBox(width: 3),

//                           ball(
//                             d['e2'],
//                             Colors.orange,
//                             radius: 13,
//                             fontSize: 11,
//                           ),
//                         ],
//                       ),

//                       subtitle: statsMode
//                           ? drawStats == null
//                               ? const Text(
//                                   'Chargement des statistiques...',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                   ),
//                                 )
//                               : _statsContent(
//                                   drawStats,
//                                 )
//                           : _normalContent(d),

//                       isThreeLine: !statsMode,

//                       onTap: () {
//                         context.push(
//                           '/euromillions/${d['id']}',
//                           extra: d,
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';

// // import '../services/api_service.dart';
// // import '../services/auth_service.dart';

// // class EuromillionsPage extends StatefulWidget {
// //   const EuromillionsPage({super.key});

// //   @override
// //   State<EuromillionsPage> createState() =>
// //       _EuromillionsPageState();
// // }

// // class _EuromillionsPageState
// //     extends State<EuromillionsPage> {

// //   final ApiService api = ApiService();
// //   final AuthService _auth = AuthService.instance;

// //   String? _pseudo;

// //   bool loading = true;
// //   bool statsMode = false;

// //   List<dynamic> draws = [];

// //   // Stats indexées par l'id du tirage
// //   final Map<int, Map<String, dynamic>> stats = {};

// //   // Stats actuelles pour préparer le prochain tirage
// //   Map<String, dynamic>? currentStats;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _loadPseudo();
// //     load();
// //   }

// //   Future<void> _loadPseudo() async {
// //     final pseudo = await _auth.getPseudo();

// //     if (!mounted) return;

// //     setState(() {
// //       _pseudo = pseudo;
// //     });
// //   }

// //   Future<void> load() async {
// //     final data = await api.fetchEuromillionsDraws();

// //     if (!mounted) return;

// //     setState(() {
// //       draws = data;
// //       loading = false;
// //     });
// //   }

// //   Future<void> _loadStats() async {
// //     try {
// //       // -------------------------------------------------
// //       // 1. Statistiques actuelles pour le prochain tirage
// //       // -------------------------------------------------

// //       final current =
// //           await api.fetchCurrentEuromillionsStats();

// //       if (!mounted) return;

// //       setState(() {
// //         currentStats = current;
// //       });

// //       // -------------------------------------------------
// //       // 2. Statistiques historiques des tirages existants
// //       // -------------------------------------------------

// //       final data =
// //           await api.fetchAllEuromillionsStats();

// //       if (!mounted) return;

// //       setState(() {
// //         stats.clear();

// //         for (final entry in data.entries) {
// //           stats[int.parse(entry.key)] =
// //               entry.value as Map<String, dynamic>;
// //         }
// //       });

// //     } catch (e) {
// //       debugPrint(
// //         'Erreur lors du chargement des statistiques : $e',
// //       );
// //     }
// //   }

// //   Future<void> _toggleStats() async {

// //     if (!statsMode) {

// //       setState(() {
// //         statsMode = true;
// //       });

// //       await _loadStats();

// //     } else {

// //       setState(() {
// //         statsMode = false;
// //       });
// //     }
// //   }

// //   Widget ball(
// //     dynamic n,
// //     Color color, {
// //     double radius = 16,
// //     double fontSize = 14,
// //   }) {
// //     return CircleAvatar(
// //       radius: radius,
// //       backgroundColor: color,
// //       child: Text(
// //         '$n',
// //         style: TextStyle(
// //           color: Colors.white,
// //           fontSize: fontSize,
// //           fontWeight: FontWeight.bold,
// //         ),
// //       ),
// //     );
// //   }

// //   String _formatJackpot(dynamic jackpot) {

// //     final value = int.parse(
// //       jackpot.toString(),
// //     );

// //     return value
// //         .toString()
// //         .replaceAllMapped(
// //           RegExp(r'\B(?=(\d{3})+(?!\d))'),
// //           (match) => ' ',
// //         );
// //   }

// //   Color _getCardColor(dynamic winners) {

// //     final count = int.parse(
// //       winners.toString(),
// //     );

// //     if (count == 1) {
// //       return const Color(0xFFD2B48C);
// //     }

// //     if (count > 1) {
// //       return const Color(0xFFF4CCCC);
// //     }

// //     return Colors.white;
// //   }

// //   Widget _normalContent(dynamic d) {

// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [

// //         Text(
// //           '${d['draw_date']}',
// //           style: const TextStyle(
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),

// //         // const SizedBox(height: 4),

// //         Text(
// //           'Jackpot : ${_formatJackpot(d['jackpot'])} €',
// //         ),

// //         Text(
// //           'Gagnants : ${d['winners']}',
// //           style: const TextStyle(
// //             height: 1.0,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _nextDrawContent() {

// //     return const Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [

// //         Text(
// //           'X',
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),

// //         // SizedBox(height: 4),

// //         Text(
// //           'Jackpot : X',
// //         ),

// //         Text(
// //           'Gagnants : X',
// //           style: TextStyle(
// //             height: 1.0,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _statsContent(
// //     Map<String, dynamic> drawStats,
// //   ) {

// //     final hot = drawStats['hot'] as List;
// //     final cold = drawStats['cold'] as List;
// //     final overdue = drawStats['overdue'] as List;

// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [

// //         _statsLine(
// //           'Hot : ',
// //           hot,
// //           showCount: true,
// //         ),

// //         const SizedBox(height: 2),

// //         _statsLine(
// //           'Cold : ',
// //           cold,
// //           showCount: true,
// //         ),

// //         const SizedBox(height: 2),

// //         _overdueLine(overdue),
// //       ],
// //     );
// //   }

// //   Widget _statsLine(
// //     String label,
// //     List numbers, {
// //     required bool showCount,
// //   }) {

// //     return Text(
// //       label +
// //           numbers
// //               .map(
// //                 (item) => showCount
// //                     ? '${item['number']}(${item['count']})'
// //                     : '${item['number']}',
// //               )
// //               .join('  '),
// //       style: const TextStyle(
// //         fontSize: 11,
// //         height: 1.15,
// //       ),
// //       maxLines: 1,
// //       overflow: TextOverflow.clip,
// //     );
// //   }

// //   Widget _overdueLine(List overdue) {

// //     return Text(
// //       'Retard : ' +
// //           overdue
// //               .map(
// //                 (item) => '${item['number']}',
// //               )
// //               .join('  '),
// //       style: const TextStyle(
// //         fontSize: 11,
// //         height: 1.15,
// //       ),
// //       maxLines: 1,
// //       overflow: TextOverflow.clip,
// //     );
// //   }

// //   Widget _nextDrawStatsContent() {

// //     if (currentStats == null) {
// //       return const Text(
// //         'Chargement des statistiques...',
// //         style: TextStyle(
// //           fontSize: 11,
// //         ),
// //       );
// //     }

// //     return _statsContent(
// //       currentStats!,
// //     );
// //   }

// //   Widget _buildNextDrawCard() {

// //     return SizedBox(
// //       height: 100,
// //       child: Card(
// //         color: Colors.white,

// //         child: ListTile(

// //           contentPadding:
// //               const EdgeInsets.symmetric(
// //             horizontal: 16,
// //             vertical: 0
// //           ),

// //           title: Row(
// //             children: [

// //               for (int i = 0; i < 5; i++)
// //                 Padding(
// //                   padding:
// //                       const EdgeInsets.only(
// //                     right: 3,
// //                   ),
// //                   child: ball(
// //                     'X',
// //                     Colors.blue,
// //                     radius: 13,
// //                     fontSize: 11,
// //                   ),
// //                 ),

// //               const SizedBox(width: 5),

// //               ball(
// //                 'X',
// //                 Colors.orange,
// //                 radius: 13,
// //                 fontSize: 11,
// //               ),

// //               const SizedBox(width: 3),

// //               ball(
// //                 'X',
// //                 Colors.orange,
// //                 radius: 13,
// //                 fontSize: 11,
// //               ),
// //             ],
// //           ),

// //           subtitle: statsMode
// //               ? _nextDrawStatsContent()
// //               : _nextDrawContent(),

// //           isThreeLine: !statsMode,
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Euromillions'),

// //         actions: [

// //           IconButton(
// //             tooltip: statsMode
// //                 ? 'Masquer les statistiques'
// //                 : 'Afficher les statistiques',

// //             icon: Icon(
// //               statsMode
// //                   ? Icons.bar_chart
// //                   : Icons.bar_chart_outlined,
// //             ),

// //             onPressed: loading
// //                 ? null
// //                 : _toggleStats,
// //           ),

// //           if (_pseudo == 'adminsam')
// //             IconButton(
// //               icon: const Icon(
// //                 Icons.cloud_download,
// //               ),
// //               onPressed: () {
// //                 context.push(
// //                   '/collect-euromillions',
// //                 );
// //               },
// //             ),
// //         ],
// //       ),

// //       body: loading

// //           ? const Center(
// //               child: CircularProgressIndicator(),
// //             )

// //           : ListView.builder(

// //               // +1 pour la carte du prochain tirage
// //               itemCount: draws.length + 1,

// //               itemBuilder: (context, i) {

// //                 // -----------------------------------------
// //                 // Premier élément = prochain tirage
// //                 // -----------------------------------------

// //                 if (i == 0) {
// //                   return _buildNextDrawCard();
// //                 }

// //                 // -----------------------------------------
// //                 // Tirages historiques
// //                 // -----------------------------------------

// //                 final d = draws[i - 1];

// //                 final drawId = int.parse(
// //                   d['id'].toString(),
// //                 );

// //                 final drawStats = stats[drawId];

// //                 return SizedBox(
// //                   height: 100,

// //                   child: Card(
// //                     color: _getCardColor(
// //                       d['winners'],
// //                     ),

// //                     child: ListTile(

// //                       contentPadding:
// //                           const EdgeInsets.symmetric(
// //                         horizontal: 16,
// //                         vertical: 4,
// //                       ),

// //                       title: Row(
// //                         children: [

// //                           for (final n in [
// //                             d['n1'],
// //                             d['n2'],
// //                             d['n3'],
// //                             d['n4'],
// //                             d['n5'],
// //                           ])
// //                             Padding(
// //                               padding:
// //                                   const EdgeInsets.only(
// //                                 right: 3,
// //                               ),
// //                               child: ball(
// //                                 n,
// //                                 Colors.blue,
// //                                 radius: 13,
// //                                 fontSize: 11,
// //                               ),
// //                             ),

// //                           const SizedBox(width: 5),

// //                           ball(
// //                             d['e1'],
// //                             Colors.orange,
// //                             radius: 13,
// //                             fontSize: 11,
// //                           ),

// //                           const SizedBox(width: 3),

// //                           ball(
// //                             d['e2'],
// //                             Colors.orange,
// //                             radius: 13,
// //                             fontSize: 11,
// //                           ),
// //                         ],
// //                       ),

// //                       subtitle: statsMode

// //                           ? drawStats == null
// //                               ? const Text(
// //                                   'Chargement des statistiques...',
// //                                   style: TextStyle(
// //                                     fontSize: 11,
// //                                   ),
// //                                 )
// //                               : _statsContent(
// //                                   drawStats,
// //                                 )

// //                           : _normalContent(d),

// //                       isThreeLine: !statsMode,

// //                       onTap: () {
// //                         context.push(
// //                           '/euromillions/${d['id']}',
// //                           extra: d,
// //                         );
// //                       },
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //     );
// //   }
// // }
