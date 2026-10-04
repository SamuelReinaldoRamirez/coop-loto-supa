import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class GroupsPage extends StatefulWidget {
  final String username;

  const GroupsPage({
    super.key,
    required this.username,
  });

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final ApiService _api = ApiService();

  bool _loading = true;
  List<dynamic> _userGroups = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final userGroups = await _api.fetchMyGroups();

      setState(() {
        _userGroups = userGroups;
      });
    } catch (e) {
      print('[Groups] Error loading groups: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _buyGridsForGroups() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Achat de grilles pour les groupes — bientôt disponible.',
        ),
      ),
    );
  }

  void _addPaidGrid() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Ajout d’une grille déjà payée — bientôt disponible.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home', extra: widget.username);
          },
        ),
        title: const Text(
          'Mes groupes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Acheter des grilles pour mes groupes',
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: _buyGridsForGroups,
          ),
        ],
        elevation: 0,
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: _userGroups.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 100),
                        _buildEmptyState(),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // =========================
                        // ACTIONS
                        // =========================

                        _buildActionCard(
                          context,
                          icon: Icons.shopping_cart_rounded,
                          title: 'Acheter des grilles pour mes groupes',
                          subtitle:
                              'Acheter des grilles et les attribuer à mes groupes',
                          onTap: _buyGridsForGroups,
                        ),

                        const SizedBox(height: 12),

                        _buildActionCard(
                          context,
                          icon: Icons.add_photo_alternate_outlined,
                          title: 'Ajouter une grille déjà payée',
                          subtitle:
                              'Ajouter une grille achetée en dehors de l’application',
                          onTap: _addPaidGrid,
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Mes groupes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // =========================
                        // GROUPES
                        // =========================

                        for (final g in _userGroups)
                          _buildGroupCard(
                            context,
                            group: g,
                            name: (g is Map && g['name'] != null)
                                ? g['name'].toString()
                                : (g is Map && g['id'] != null)
                                    ? 'Groupe ${g['id']}'
                                    : g.toString(),
                            groupId: g is Map ? g['id'] : null,
                          ),
                      ],
                    ),
            ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 27,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context, {
    required dynamic group,
    required String name,
    required dynamic groupId,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          final encoded = Uri.encodeComponent(widget.username);

          context.push(
            '/group/$groupId/menu?username=$encoded',
            extra: group,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (groupId != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Groupe #$groupId',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups_outlined,
                size: 45,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Aucun groupe',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Vous ne faites actuellement partie d’aucun groupe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../services/api_service.dart';

// class GroupsPage extends StatefulWidget {
//   final String username;

//   const GroupsPage({
//     super.key,
//     required this.username,
//   });

//   @override
//   State<GroupsPage> createState() => _GroupsPageState();
// }

// class _GroupsPageState extends State<GroupsPage> {
//   final ApiService _api = ApiService();

//   bool _loading = true;
//   List<dynamic> _userGroups = [];

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     setState(() => _loading = true);

//     try {
//       final userGroups = await _api.fetchMyGroups();

//       setState(() {
//         _userGroups = userGroups;
//       });
//     } catch (e) {
//       print('[Groups] Error loading groups: $e');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             context.go('/home', extra: widget.username);
//           },
//         ),
//         title: const Text(
//           'Mes groupes',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         elevation: 0,
//       ),
//       body: _loading
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : _userGroups.isEmpty
//               ? _buildEmptyState()
//               : RefreshIndicator(
//                   onRefresh: _load,
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: _userGroups.length,
//                     itemBuilder: (context, idx) {
//                       final g = _userGroups[idx];

//                       final name = (g is Map && g['name'] != null)
//                           ? g['name'].toString()
//                           : (g is Map && g['id'] != null)
//                               ? 'Groupe ${g['id']}'
//                               : g.toString();

//                       final groupId =
//                           g is Map ? g['id'] : null;

//                       return _buildGroupCard(
//                         context,
//                         group: g,
//                         name: name,
//                         groupId: groupId,
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }

//   Widget _buildGroupCard(
//     BuildContext context, {
//     required dynamic group,
//     required String name,
//     required dynamic groupId,
//   }) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 14),
//       elevation: 3,
//       shadowColor: Colors.black.withOpacity(0.12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(18),
//         onTap: () {
//           final encoded = Uri.encodeComponent(widget.username);

//           // context.push(
//           //   '/group/$groupId?username=$encoded',
//           //   extra: group as Map<String, dynamic>,
//           // );
//           context.push(
//             '/group/$groupId/menu?username=$encoded',
//             extra: group,
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(18),
//           child: Row(
//             children: [
//               // Icône du groupe
//               Container(
//                 width: 52,
//                 height: 52,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context)
//                       .colorScheme
//                       .primary
//                       .withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Icon(
//                   Icons.groups_rounded,
//                   size: 28,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ),

//               const SizedBox(width: 16),

//               // Nom + ID
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     if (groupId != null) ...[
//                       const SizedBox(height: 5),
//                       Text(
//                         'Groupe #$groupId',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),

//               // Flèche
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.chevron_right_rounded,
//                   size: 24,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 90,
//               height: 90,
//               decoration: BoxDecoration(
//                 color: Theme.of(context)
//                     .colorScheme
//                     .primary
//                     .withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.groups_outlined,
//                 size: 45,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Aucun groupe',
//               style: TextStyle(
//                 fontSize: 21,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Vous ne faites actuellement partie d’aucun groupe.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }