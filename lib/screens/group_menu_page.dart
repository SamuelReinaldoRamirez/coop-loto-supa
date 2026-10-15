import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'group_members_section.dart';
import 'pending_join_requests_section.dart';

import '../widgets/group_menu/group_menu_action_card.dart';
import '../widgets/group_menu/group_menu_expansion_card.dart';
import '../widgets/group_menu/group_menu_option.dart';
import '../widgets/group_menu/group_rules_section.dart';

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
    final title = group['name'] ?? group['id'] ?? 'Groupe';
    final groupName = title.toString();

    // Accepte un identifiant transmis sous forme d'entier
    // ou de chaîne de caractères.
    final dynamic rawGroupId = group['id'];
    final int? groupId = rawGroupId is int
        ? rawGroupId
        : int.tryParse(rawGroupId?.toString() ?? '');

    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(groupName),
        ),
        body: const Center(
          child: Text(
            'Impossible d’ouvrir ce groupe : identifiant invalide.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          groupName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          24,
        ),
        children: [
          // ====================================================
          // ACTIONS RAPIDES
          // ====================================================

          GroupMenuActionCard(
            icon: Icons.shopping_cart_rounded,
            title: 'Acheter des grilles',
            subtitle: 'Acheter des grilles en batch pour ce groupe',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Achat de grilles — bientôt disponible.',
                  ),
                ),
              );
            },
          ),

          GroupMenuActionCard(
            icon: Icons.add_photo_alternate_outlined,
            title: 'Ajouter une grille déjà payée',
            subtitle:
                'Ajouter une grille achetée en dehors de l’application',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Ajout d’une grille déjà payée — bientôt disponible.',
                  ),
                ),
              );
            },
          ),

          GroupMenuActionCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Nouvelle grille',
            subtitle:
                'Analyser les numéros, retards, fréquences et combinaisons',
            onTap: () {
              context.push(
                '/group/$groupId/simulate-grid'
                '?username=${Uri.encodeComponent(username)}',
                extra: group,
              );
            },
          ),

          const SizedBox(height: 10),

          // ====================================================
          // OPTIONS DU GROUPE
          // ====================================================

          GroupMenuExpansionCard(
            icon: Icons.menu_rounded,
            title: 'Options du groupe',
            subtitle: 'Historique, statistiques, gains',
            children: [
              GroupMenuOption(
                icon: Icons.casino_rounded,
                title: 'Historique des tirages',
                onTap: () {
                  context.push(
                    '/group/$groupId/draw-history',
                  );
                },
              ),

              GroupMenuOption(
                icon: Icons.bar_chart_rounded,
                title: 'Statistiques',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Statistiques — bientôt disponible.',
                      ),
                    ),
                  );
                },
              ),

              GroupMenuOption(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Gains et dépenses',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Gains et dépenses — bientôt disponible.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ====================================================
          // RÈGLES DU GROUPE
          // ====================================================

          const GroupRulesSection(),

          const SizedBox(height: 20),

          // ====================================================
          // MEMBRES ACCEPTÉS
          // ====================================================

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Membres du groupe',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.groups_rounded,
                size: 22,
                color: Colors.grey.shade600,
              ),
            ],
          ),

          const SizedBox(height: 8),

          GroupMembersSection(
            key: ValueKey('accepted-members-$groupId'),
            groupId: groupId,
            username: username,
          ),

          const SizedBox(height: 20),

          // ====================================================
          // DEMANDES D'ADHÉSION EN ATTENTE
          // ====================================================

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Demandes en attente',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.person_add_alt_1_rounded,
                size: 22,
                color: Colors.grey.shade600,
              ),
            ],
          ),

          const SizedBox(height: 8),

          PendingJoinRequestsSection(
            key: ValueKey('pending-requests-$groupId'),
            groupId: groupId,
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// import 'group_members_section.dart';
// import '../widgets/group_menu/group_menu_action_card.dart';
// import '../widgets/group_menu/group_menu_expansion_card.dart';
// import '../widgets/group_menu/group_menu_option.dart';
// import '../widgets/group_menu/group_rules_section.dart';
// import 'pending_join_requests_section.dart';

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

//     final groupName = title.toString();

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
//           groupName,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         elevation: 0,
//       ),

//       body: ListView(
//         padding: const EdgeInsets.fromLTRB(
//           16,
//           10,
//           16,
//           16,
//         ),
//         children: [

//           // ====================================================
//           // ACTIONS RAPIDES
//           // ====================================================

//           GroupMenuActionCard(
//             icon: Icons.shopping_cart_rounded,
//             title: 'Acheter des grilles',
//             subtitle:
//                 'Acheter des grilles en batch pour ce groupe',
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text(
//                     'Achat de grilles — bientôt disponible.',
//                   ),
//                 ),
//               );
//             },
//           ),

//           GroupMenuActionCard(
//             icon: Icons.add_photo_alternate_outlined,
//             title: 'Ajouter une grille déjà payée',
//             subtitle:
//                 'Ajouter une grille achetée en dehors de l’application',
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text(
//                     'Ajout d’une grille déjà payée — bientôt disponible.',
//                   ),
//                 ),
//               );
//             },
//           ),

//           GroupMenuActionCard(
//             icon: Icons.auto_awesome_rounded,
//             title: 'Nouvelle grille',
//             subtitle:
//                 'Analyser les numéros, retards, fréquences et combinaisons',
//             onTap: () {
//               context.push(
//                 '/group/${group['id']}/simulate-grid'
//                 '?username=${Uri.encodeComponent(username)}',
//                 extra: group,
//               );
//             },
//           ),

//           const SizedBox(height: 10),

//           // ====================================================
//           // OPTIONS DU GROUPE
//           // ====================================================

//           GroupMenuExpansionCard(
//             icon: Icons.menu_rounded,
//             title: 'Options du groupe',
//             subtitle:
//                 'Historique, statistiques, gains',
//             children: [

//               GroupMenuOption(
//                 icon: Icons.casino_rounded,
//                 title: 'Historique des tirages',
//                 onTap: () {
//                   // context.push(
//                   //   '/group/${group['id']}/draws'
//                   //   '?username=${Uri.encodeComponent(username)}',
//                   //   extra: group,
//                   // );
//                   context.push(
//                     '/group/${group['id']}/draw-history',
//                   );
//                 },
//               ),

//               GroupMenuOption(
//                 icon: Icons.bar_chart_rounded,
//                 title: 'Statistiques',
//                 onTap: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text(
//                         'Statistiques — bientôt disponible.',
//                       ),
//                     ),
//                   );
//                 },
//               ),

//               GroupMenuOption(
//                 icon: Icons.account_balance_wallet_rounded,
//                 title: 'Gains et dépenses',
//                 onTap: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text(
//                         'Gains et dépenses — bientôt disponible.',
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),

//           const SizedBox(height: 8),

//           // ====================================================
//           // RÈGLES DU GROUPE
//           // ====================================================

//           const GroupRulesSection(),

//           const SizedBox(height: 14),

//           // ====================================================
//           // MEMBRES
//           // ====================================================

//           Row(
//             children: [
//               const Text(
//                 'Membres',
//                 style: TextStyle(
//                   fontSize: 19,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const Spacer(),

//               Icon(
//                 Icons.groups_rounded,
//                 size: 22,
//                 color: Colors.grey.shade600,
//               ),
//             ],
//           ),

//           const SizedBox(height: 8),

//           GroupMembersSection(
//             groupId: group['id'] as int,
//             username: username,
//           ),
//           //demandes en attente
//           PendingJoinRequestsSection(
//             groupId: group['id'] as int,
//           ),

//           // GroupMembersSection(
//           //   groupId: group['id'] as int,
//           //   username: username,
//           // ),
//         ],
//       ),
//     );
//   }
// }