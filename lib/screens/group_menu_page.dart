import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'group_members_section.dart';
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
    final title =
        group['name'] ?? group['id'] ?? 'Groupe';

    final groupName = title.toString();

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
          16,
        ),
        children: [

          // ====================================================
          // ACTIONS RAPIDES
          // ====================================================

          GroupMenuActionCard(
            icon: Icons.shopping_cart_rounded,
            title: 'Acheter des grilles',
            subtitle:
                'Acheter des grilles pour ce groupe',
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
            title: 'Simuler une nouvelle grille',
            subtitle:
                'Analyser les numéros, retards, fréquences et combinaisons',
            onTap: () {
              context.push(
                '/group/${group['id']}/simulate-grid'
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
            subtitle:
                'Historique, statistiques, gains',
            children: [

              GroupMenuOption(
                icon: Icons.casino_rounded,
                title: 'Historique des tirages',
                onTap: () {
                  context.push(
                    '/group/${group['id']}/draws'
                    '?username=${Uri.encodeComponent(username)}',
                    extra: group,
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

          const SizedBox(height: 14),

          // ====================================================
          // MEMBRES
          // ====================================================

          Row(
            children: [
              const Text(
                'Membres',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              Icon(
                Icons.groups_rounded,
                size: 22,
                color: Colors.grey.shade600,
              ),
            ],
          ),

          const SizedBox(height: 8),

          GroupMembersSection(
            groupId: group['id'] as int,
            username: username,
          ),
        ],
      ),
    );
  }
}