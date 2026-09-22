import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';

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

  final List<String> _titles = [
    'Mes groupes',
    'Recherche',
    'Jeux',
    'Statistiques',
    'Inviter',
  ];

  Future<void> _logout() async {
    print('[Home] Déconnexion...');

    await _auth.clear();

    if (!mounted) return;

    print('[Home] Token supprimé');
    print('[Home] Retour vers Login');

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coop Loto ${widget.username}'),
        centerTitle: true,
        actions: [
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