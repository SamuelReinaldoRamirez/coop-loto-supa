import 'package:flutter/material.dart';

import 'group_menu_expansion_card.dart';
import 'group_rule_card.dart';
import 'group_rule_helpers.dart';

class GroupRulesSection extends StatelessWidget {
  const GroupRulesSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GroupMenuExpansionCard(
      icon: Icons.rule_rounded,
      title: 'Règles du groupe',
      subtitle:
          'Gouvernance, conditions de jeu et stratégie',
      children: [

        _buildRuleManagement(context),

        const SizedBox(height: 8),

        _buildWhenToPlay(context),

        const SizedBox(height: 8),

        _buildGridPurchase(context),

        const SizedBox(height: 8),

        _buildStrategy(context),

        const SizedBox(height: 8),

        _buildPrizeDistribution(context),
      ],
    );
  }

  // ============================================================
  // 1. MODIFICATION DES RÈGLES
  // ============================================================

  Widget _buildRuleManagement(
    BuildContext context,
  ) {
    return GroupRuleCard(
      icon:
          Icons.admin_panel_settings_outlined,
      title: 'Modification des règles',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          GroupRuleHelpers.value(
            context,
            icon: Icons.lock_outline,
            title: 'Mode actuel',
            value: 'Démocratie',
            valueColor:
                Colors.green.shade700,
          ),

          const SizedBox(height: 8),

          Text(
            'Les règles peuvent être modifiées '
            'par un vote des membres du groupe.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Modes disponibles :',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 5),

          GroupRuleHelpers.bullet(
            'Règles verrouillées : personne ne peut les modifier.',
          ),

          GroupRuleHelpers.bullet(
            'Démocratie : les membres votent pour modifier les règles.',
          ),

          GroupRuleHelpers.bullet(
            'Administrateur : l’administrateur du groupe peut modifier les règles.',
          ),

          GroupRuleHelpers.bullet(
            'Des membres élus choisissent les règles.',
          ),

          GroupRuleHelpers.bullet(
            'Le ou les membres avec le plus de dépenses dans ce groupe peuvent jouer.',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 2. QUAND JOUER ?
  // ============================================================

  Widget _buildWhenToPlay(
    BuildContext context,
  ) {
    return GroupRuleCard(
      icon: Icons.calendar_month_outlined,
      title: 'Quand jouer ?',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          GroupRuleHelpers.value(
            context,
            icon:
                Icons.play_arrow_rounded,
            title: 'Condition actuelle',
            value:
                'Combinaison de règles',
            valueColor:
                Theme.of(context)
                    .colorScheme
                    .primary,
          ),

          const SizedBox(height: 10),

          Text(
            'Le groupe joue si au moins une '
            'des conditions suivantes est remplie :',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 6),

          GroupRuleHelpers.condition(
            context,
            icon:
                Icons.casino_outlined,
            text: 'À chaque tirage',
            enabled: false,
          ),

          GroupRuleHelpers.condition(
            context,
            icon: Icons.euro_rounded,
            text:
                'Jackpot compris entre 50 M€ et 100 M€',
            enabled: true,
          ),

          GroupRuleHelpers.condition(
            context,
            icon:
                Icons.event_outlined,
            text:
                'Le tirage a lieu un vendredi',
            enabled: true,
          ),

          GroupRuleHelpers.condition(
            context,
            icon:
                Icons.account_balance_wallet_outlined,
            text:
                'La cagnotte permet d’acheter au moins 10 grilles',
            enabled: true,
          ),

          GroupRuleHelpers.condition(
            context,
            icon:
                Icons.person_outline,
            text:
                'Décision de l’administrateur',
            enabled: false,
          ),

          GroupRuleHelpers.condition(
            context,
            icon:
                Icons.how_to_vote_outlined,
            text:
                'Décision démocratique du groupe',
            enabled: false,
          ),

          const SizedBox(height: 8),

          _buildInfoBox(
            context,
            color: Colors.blue,
            text:
                'Les conditions pourront ensuite être combinées '
                'avec des opérateurs ET / OU.',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 3. ACHAT DES GRILLES
  // ============================================================

  Widget _buildGridPurchase(
    BuildContext context,
  ) {
    return GroupRuleCard(
      icon:
          Icons.confirmation_number_outlined,
      title: 'Achat des grilles',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          GroupRuleHelpers.value(
            context,
            icon:
                Icons.storefront_outlined,
            title: 'Mode actuel',
            value:
                'Achat dans ou hors application',
            valueColor:
                Colors.green.shade700,
          ),

          const SizedBox(height: 10),

          GroupRuleHelpers.condition(
            context,
            icon:
                Icons.phone_android_outlined,
            text:
                'Les grilles peuvent être achetées dans l’application',
            enabled: true,
          ),

          GroupRuleHelpers.condition(
            context,
            icon:
                Icons.store_outlined,
            text:
                'Les grilles peuvent être achetées en dehors de l’application',
            enabled: true,
          ),

          const SizedBox(height: 8),

          Text(
            'Une grille achetée à l’extérieur pourra être '
            'ajoutée manuellement au groupe avec ses '
            'informations de ticket.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 4. STRATÉGIE DE JEU
  // ============================================================

  Widget _buildStrategy(
    BuildContext context,
  ) {
    return GroupRuleCard(
      icon: Icons.psychology_outlined,
      title: 'Stratégie de jeu',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          GroupRuleHelpers.value(
            context,
            icon:
                Icons.auto_awesome_rounded,
            title: 'Stratégie actuelle',
            value: 'Modèle B',
            valueColor:
                Theme.of(context)
                    .colorScheme
                    .primary,
          ),

          const SizedBox(height: 10),

          Text(
            'Modes de stratégie disponibles :',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 5),

          GroupRuleHelpers.bullet(
            'Libre : aucune stratégie imposée.',
          ),

          GroupRuleHelpers.bullet(
            'Choix individuel : chaque membre choisit ses propres grilles.',
          ),

          GroupRuleHelpers.bullet(
            'Aléatoire : les grilles sont générées aléatoirement.',
          ),

          GroupRuleHelpers.bullet(
            'Modèle A : les grilles sont proposées par le modèle A.',
          ),

          GroupRuleHelpers.bullet(
            'Modèle B : les grilles sont proposées par le modèle B.',
          ),

          GroupRuleHelpers.bullet(
            'Modèle C : les grilles sont proposées par le modèle C.',
          ),

          const SizedBox(height: 10),

          Text(
            'Modification des propositions du modèle :',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 5),

          GroupRuleHelpers.condition(
            context,
            icon: Icons.block_outlined,
            text:
                'Aucune grille proposée ne peut être ignorée',
            enabled: false,
          ),

          GroupRuleHelpers.condition(
            context,
            icon:
                Icons.person_outline,
            text:
                'L’administrateur peut ignorer certaines propositions',
            enabled: true,
          ),

          GroupRuleHelpers.condition(
            context,
            icon:
                Icons.how_to_vote_outlined,
            text:
                'Les membres votent pour ignorer certaines propositions',
            enabled: false,
          ),

          const SizedBox(height: 8),

          _buildInfoBox(
            context,
            color: Colors.purple,
            text:
                'Exemple : le modèle B propose 10 grilles. '
                'L’administrateur peut actuellement en retirer '
                'certaines avant l’achat.',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 5. RÉPARTITION DES GAINS
  // ============================================================

  Widget _buildPrizeDistribution(
    BuildContext context,
  ) {
    return GroupRuleCard(
      icon: Icons.payments_outlined,
      title: 'Répartition des gains',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          GroupRuleHelpers.value(
            context,
            icon: Icons.tune_rounded,
            title: 'Mode actuel',
            value:
                'Combinaison personnalisée',
            valueColor:
                Theme.of(context)
                    .colorScheme
                    .primary,
          ),

          const SizedBox(height: 10),

          Text(
            'Critères pris en compte :',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 5),

          GroupRuleHelpers.condition(
            context,
            icon:
                Icons.history_outlined,
            text:
                'Ancienneté dans le groupe',
            enabled: true,
          ),

          GroupRuleHelpers.condition(
            context,
            icon:
                Icons.account_balance_wallet_outlined,
            text:
                'Dépenses totales dans le groupe',
            enabled: true,
          ),

          GroupRuleHelpers.condition(
            context,
            icon:
                Icons.calendar_today_outlined,
            text:
                'Dépenses au dernier tirage',
            enabled: true,
          ),

          GroupRuleHelpers.condition(
            context,
            icon:
                Icons.casino_outlined,
            text:
                'Nombre de tirages auxquels le membre a contribué',
            enabled: true,
          ),

          const SizedBox(height: 10),

          Text(
            'Fonctions appliquées :',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 6),

          GroupRuleHelpers.distributionFunction(
            context,
            criterion: 'Ancienneté',
            function: 'log(1 + x)',
            weight: '10 %',
          ),

          GroupRuleHelpers.distributionFunction(
            context,
            criterion: 'Dépenses totales',
            function: '√x',
            weight: '40 %',
          ),

          GroupRuleHelpers.distributionFunction(
            context,
            criterion: 'Dernier tirage',
            function: 'x',
            weight: '30 %',
          ),

          GroupRuleHelpers.distributionFunction(
            context,
            criterion: 'Participations',
            function: '√x',
            weight: '20 %',
          ),

          const SizedBox(height: 10),

          _buildInfoBox(
            context,
            color: Colors.green,
            text:
                'La part finale de chaque membre est calculée '
                'à partir de son score relatif par rapport aux '
                'autres membres du groupe.',
          ),

          const SizedBox(height: 10),

          Text(
            'Fonctions disponibles :',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 5),

          GroupRuleHelpers.bullet(
            'Proportionnelle : f(x) = x',
          ),

          GroupRuleHelpers.bullet(
            'Racine carrée : f(x) = √x',
          ),

          GroupRuleHelpers.bullet(
            'Logarithmique : f(x) = log(1 + x)',
          ),

          GroupRuleHelpers.bullet(
            'Exponentielle : f(x) = x² ou xᵖ',
          ),

          GroupRuleHelpers.bullet(
            'Facteur : f(x) = k × x',
          ),

          GroupRuleHelpers.bullet(
            'Plafonnée : possibilité de limiter l’influence d’un critère.',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOÎTE D'INFORMATION
  // ============================================================

  Widget _buildInfoBox(
    BuildContext context, {
    required MaterialColor color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color.shade800,
          height: 1.3,
        ),
      ),
    );
  }
}