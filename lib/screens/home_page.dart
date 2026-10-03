import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({
    super.key,
    required this.username,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final AuthService _auth = AuthService();
  final ApiService _api = ApiService();

  int _credits = 0;
  bool _loadingCredits = true;

  final List<String> _titles = [
    'Mes groupes',
    'Recherche',
    'Jeux',
    'Statistiques',
    'Inviter',
  ];

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    try {
      final user = await _api.fetchMe();

      if (!mounted) return;

      setState(() {
        _credits = user['credits'] ?? 0;
        _loadingCredits = false;
      });
    } catch (e) {
      print('[Home] Error loading credits: $e');

      if (!mounted) return;

      setState(() {
        _loadingCredits = false;
      });
    }
  }

  Future<void> _logout() async {
    print('[Home] Déconnexion...');

    await _auth.clear();

    if (!mounted) return;

    print('[Home] Token supprimé');
    print('[Home] Retour vers Login');

    context.go('/');
  }

  void _buyCredits() {
    context.push('/buy-credits');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Coop Loto ${widget.username}',
        ),
        centerTitle: true,

        actions: [

          // =========================
          // CRÉDITS
          // =========================

          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _buyCredits,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const Icon(
                      Icons.credit_card,
                      size: 20,
                    ),

                    const SizedBox(width: 5),

                    _loadingCredits
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            '$_credits',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                    const SizedBox(width: 2),

                    const Icon(
                      Icons.add_circle_outline,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // =========================
          // SETTINGS
          // =========================

          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) async {
              if (value == 'logout') {
                await _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Se déconnecter'),
              ),
            ],
          ),
        ],
      ),

      body: Center(
        child: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          if (index == 0) {
            context.go(
              '/groups',
              extra: widget.username,
            );
            return;
          }

          if (index == 2) {
            context.push('/games');
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groupes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Jeux',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Inviter',
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:go_router/go_router.dart';

// import '../services/auth_service.dart';

// class HomePage extends StatefulWidget {
//   final String username;
//   const HomePage({super.key, required this.username});
  

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _currentIndex = 0;
//   final AuthService _auth = AuthService();

//   final List<String> _titles = [
//     'Mes groupes',
//     'Recherche',
//     'Jeux',
//     'Statistiques',
//     'Inviter',
//   ];

//   Future<void> _logout() async {
//     print('[Home] Déconnexion...');

//     await _auth.clear();

//     if (!mounted) return;

//     print('[Home] Token supprimé');
//     print('[Home] Retour vers Login');

//     context.go('/');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Coop Loto ${widget.username}'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               // TODO : ouvrir la page des paramètres
//             },
//           ),
//         ],
//       ),

//       body: Center(
//         child: Text(
//           _titles[_currentIndex],
//           style: const TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),

//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         type: BottomNavigationBarType.fixed,
//         onTap: (index) {
//           if (index == 0) {
//             context.go('/groups', extra: widget.username);
//             return;
//           }

//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.group),
//             label: 'Groupes',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: 'Recherche',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.sports_esports),
//             label: 'Jeux',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.bar_chart),
//             label: 'Stats',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_add),
//             label: 'Inviter',
//           ),
//         ],
//       ),
//     );
//   }
// }