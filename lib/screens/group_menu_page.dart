import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'group_members_section.dart';

class GroupMenuPage extends StatelessWidget {
  final Map<String, dynamic> group;
  final String username;

  const GroupMenuPage({
    super.key,
    required this.group,
    this.username = '',
  });

  @override
  Widget build(BuildContext context) {
    final title =
        group['name'] ?? group['id'] ?? 'Groupe';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          title.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),

      body: ListView(
      padding: const EdgeInsets.all(16),
      children: [

        // =========================
        // MENU
        // =========================

        _buildMenuCard(
          context,
          icon: Icons.casino_rounded,
          title: 'Historique des tirages',
          subtitle: 'Voir les tirages joués par le groupe',
          onTap: () {
            context.push(
              '/group/${group['id']}/draws?username=${Uri.encodeComponent(username)}',
              extra: group,
            );
          },
        ),

        const SizedBox(height: 12),

        _buildMenuCard(
          context,
          icon: Icons.bar_chart_rounded,
          title: 'Statistiques',
          subtitle: 'Voir les statistiques du groupe',
          onTap: () {
            // À faire
          },
        ),

        const SizedBox(height: 12),

        _buildMenuCard(
          context,
          icon: Icons.account_balance_wallet_rounded,
          title: 'Gains et dépenses',
          subtitle: 'Suivre les dépenses et les gains du groupe',
          onTap: () {
            // À faire
          },
        ),

        const SizedBox(height: 24),

        // =========================
        // MEMBRES
        // =========================

        const Text(
          'Membres',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        GroupMembersSection(
          groupId: group['id'] as int,
          username: username,
        ),
      ],
    ),
    );
  }

  Widget _buildMenuCard(
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
          padding: const EdgeInsets.all(20),

          child: Row(
            children: [

              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
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
}


// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class GroupMenuPage extends StatelessWidget {
//   final Map<String, dynamic> group;
//   final String username;

//   const GroupMenuPage({
//     super.key,
//     required this.group,
//     this.username = '',
//   });

//   @override
//   Widget build(BuildContext context) {
//     final title =
//         group['name'] ?? group['id'] ?? 'Groupe';

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             context.pop();
//           },
//         ),
//         title: Text(
//           title.toString(),
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         elevation: 0,
//       ),

//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Historique des tirages
//           _buildMenuCard(
//             context,
//             icon: Icons.casino_rounded,
//             title: 'Historique des tirages',
//             subtitle: 'Voir les tirages joués par le groupe',
//             onTap: () {
//               context.push(
//                 '/group/${group['id']}/draws?username=${Uri.encodeComponent(username)}',
//                 extra: group,
//               );
//             },
//           ),

//           const SizedBox(height: 14),

//           // Membres
//           _buildMenuCard(
//             context,
//             icon: Icons.groups_rounded,
//             title: 'Membres',
//             subtitle: 'Voir les membres et leurs dépenses',
//             onTap: () {
//               context.push(
//                 '/group/{group[\'id\']}?username=${Uri.encodeComponent(username)}',
//                 extra: group,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMenuCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       elevation: 3,
//       shadowColor: Colors.black.withOpacity(0.12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(18),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               Container(
//                 width: 58,
//                 height: 58,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context)
//                       .colorScheme
//                       .primary
//                       .withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Icon(
//                   icon,
//                   size: 30,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ),

//               const SizedBox(width: 16),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const Icon(
//                 Icons.chevron_right_rounded,
//                 size: 28,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }