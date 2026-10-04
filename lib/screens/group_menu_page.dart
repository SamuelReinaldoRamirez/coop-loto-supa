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

  Widget _buildDistributionFunction(
    BuildContext context, {
    required String criterion,
    required String function,
    required String weight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [

          Expanded(
            child: Text(
              criterion,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade800,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              function,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 42,
            child: Text(
              weight,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

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

          // =========================
          // ACTIONS RAPIDES
          // =========================

          _buildMenuCard(
            context,
            icon: Icons.shopping_cart_rounded,
            title: 'Acheter des grilles',
            subtitle: 'Acheter des grilles pour ce groupe',
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

          _buildMenuCard(
            context,
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

          _buildMenuCard(
            context,
            icon: Icons.auto_awesome_rounded,
            title: 'Simuler une nouvelle grille',
            subtitle:
                'Analyser les numéros, retards, fréquences et combinaisons',
            onTap: () {
              context.push(
                '/group/${group['id']}/simulate-grid?username=${Uri.encodeComponent(username)}',
                extra: group,
              );
            },
          ),

          const SizedBox(height: 10),

          // =========================
          // OPTIONS DU GROUPE
          // =========================

          _buildExpansionCard(
            context,
            icon: Icons.menu_rounded,
            title: 'Options du groupe',
            subtitle: 'Historique, statistiques, gains',
            children: [

              _buildCompactOption(
                context,
                icon: Icons.casino_rounded,
                title: 'Historique des tirages',
                onTap: () {
                  context.push(
                    '/group/${group['id']}/draws?username=${Uri.encodeComponent(username)}',
                    extra: group,
                  );
                },
              ),

              _buildCompactOption(
                context,
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

              _buildCompactOption(
                context,
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

          // =========================
          // RÈGLES DU GROUPE
          // =========================

          _buildExpansionCard(
            context,
            icon: Icons.rule_rounded,
            title: 'Règles du groupe',
            subtitle: 'Gouvernance, conditions de jeu et stratégie',
            children: [

              // ---------------------------------
              // 1. QUI PEUT MODIFIER LES RÈGLES ?
              // ---------------------------------

              _buildRuleCard(
                context,
                icon: Icons.admin_panel_settings_outlined,
                title: 'Modification des règles',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildRuleValue(
                      context,
                      icon: Icons.lock_outline,
                      title: 'Mode actuel',
                      value: 'Démocratie',
                      valueColor: Colors.green.shade700,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Les règles peuvent être modifiées par un vote '
                      'des membres du groupe.',
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
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    _buildBullet(
                      'Règles verrouillées : personne ne peut les modifier.',
                    ),

                    _buildBullet(
                      'Démocratie : les membres votent pour modifier les règles.',
                    ),

                    _buildBullet(
                      'Administrateur : l’administrateur du groupe peut modifier les règles.',
                    ),
                    _buildBullet(
                      'des membres elus choisissent',
                    ),
                    _buildBullet(
                      'le ou les membres avec le plus de depenses dans ce groupe peuvent jouer',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ---------------------------------
              // 2. QUAND JOUER ?
              // ---------------------------------

              _buildRuleCard(
                context,
                icon: Icons.calendar_month_outlined,
                title: 'Quand jouer ?',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildRuleValue(
                      context,
                      icon: Icons.play_arrow_rounded,
                      title: 'Condition actuelle',
                      value: 'Combinaison de règles',
                      valueColor: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Le groupe joue si au moins une des conditions '
                      'suivantes est remplie :',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    _buildCondition(
                      context,
                      icon: Icons.casino_outlined,
                      text: 'À chaque tirage',
                      enabled: false,
                    ),

                    _buildCondition(
                      context,
                      icon: Icons.euro_rounded,
                      text: 'Jackpot compris entre 50 M€ et 100 M€',
                      enabled: true,
                    ),

                    _buildCondition(
                      context,
                      icon: Icons.event_outlined,
                      text: 'Le tirage a lieu un vendredi',
                      enabled: true,
                    ),

                    _buildCondition(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      text: 'La cagnotte permet d’acheter au moins 10 grilles',
                      enabled: true,
                    ),

                    _buildCondition(
                      context,
                      icon: Icons.person_outline,
                      text: 'Décision de l’administrateur',
                      enabled: false,
                    ),

                    _buildCondition(
                      context,
                      icon: Icons.how_to_vote_outlined,
                      text: 'Décision démocratique du groupe',
                      enabled: false,
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Les conditions pourront ensuite être combinées '
                        'avec des opérateurs ET / OU.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ---------------------------------
              // 3. ACHAT DES GRILLES
              // ---------------------------------

              _buildRuleCard(
                context,
                icon: Icons.confirmation_number_outlined,
                title: 'Achat des grilles',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildRuleValue(
                      context,
                      icon: Icons.storefront_outlined,
                      title: 'Mode actuel',
                      value: 'Achat dans ou hors application',
                      valueColor: Colors.green.shade700,
                    ),

                    const SizedBox(height: 10),

                    _buildCondition(
                      context,
                      icon: Icons.phone_android_outlined,
                      text: 'Les grilles peuvent être achetées dans l’application',
                      enabled: true,
                    ),

                    _buildCondition(
                      context,
                      icon: Icons.store_outlined,
                      text: 'Les grilles peuvent être achetées en dehors de l’application',
                      enabled: true,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Une grille achetée à l’extérieur pourra être '
                      'ajoutée manuellement au groupe avec ses informations '
                      'de ticket.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ---------------------------------
              // 4. STRATÉGIE DE JEU
              // ---------------------------------

              _buildRuleCard(
                context,
                icon: Icons.psychology_outlined,
                title: 'Stratégie de jeu',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildRuleValue(
                      context,
                      icon: Icons.auto_awesome_rounded,
                      title: 'Stratégie actuelle',
                      value: 'Modèle B',
                      valueColor: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Modes de stratégie disponibles :',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    _buildBullet(
                      'Libre : aucune stratégie imposée.',
                    ),

                    _buildBullet(
                      'Choix individuel : chaque membre choisit ses propres grilles.',
                    ),

                    _buildBullet(
                      'Aléatoire : les grilles sont générées aléatoirement.',
                    ),

                    _buildBullet(
                      'Modèle A : les grilles sont proposées par le modèle A.',
                    ),

                    _buildBullet(
                      'Modèle B : les grilles sont proposées par le modèle B.',
                    ),

                    _buildBullet(
                      'Modèle C : les grilles sont proposées par le modèle C.',
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Modification des propositions du modèle :',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    _buildCondition(
                      context,
                      icon: Icons.block_outlined,
                      text: 'Aucune grille proposée ne peut être ignorée',
                      enabled: false,
                    ),

                    _buildCondition(
                      context,
                      icon: Icons.person_outline,
                      text: 'L’administrateur peut ignorer certaines propositions',
                      enabled: true,
                    ),

                    _buildCondition(
                      context,
                      icon: Icons.how_to_vote_outlined,
                      text: 'Les membres votent pour ignorer certaines propositions',
                      enabled: false,
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Exemple : le modèle B propose 10 grilles. '
                        'L’administrateur peut actuellement en retirer '
                        'certaines avant l’achat.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple.shade800,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ---------------------------------
              // 5. RÉPARTITION DES GAINS
              // ---------------------------------

              _buildRuleCard(
                context,
                icon: Icons.payments_outlined,
                title: 'Répartition des gains',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildRuleValue(
                      context,
                      icon: Icons.tune_rounded,
                      title: 'Mode actuel',
                      value: 'Combinaison personnalisée',
                      valueColor: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Critères pris en compte :',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    _buildCondition(
                      context,
                      icon: Icons.history_outlined,
                      text: 'Ancienneté dans le groupe',
                      enabled: true,
                    ),

                    _buildCondition(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      text: 'Dépenses totales dans le groupe',
                      enabled: true,
                    ),

                    _buildCondition(
                      context,
                      icon: Icons.calendar_today_outlined,
                      text: 'Dépenses au dernier tirage',
                      enabled: true,
                    ),

                    _buildCondition(
                      context,
                      icon: Icons.casino_outlined,
                      text: 'Nombre de tirages auxquels le membre a contribué',
                      enabled: true,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Fonctions appliquées :',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    _buildDistributionFunction(
                      context,
                      criterion: 'Ancienneté',
                      function: 'log(1 + x)',
                      weight: '10 %',
                    ),

                    _buildDistributionFunction(
                      context,
                      criterion: 'Dépenses totales',
                      function: '√x',
                      weight: '40 %',
                    ),

                    _buildDistributionFunction(
                      context,
                      criterion: 'Dernier tirage',
                      function: 'x',
                      weight: '30 %',
                    ),

                    _buildDistributionFunction(
                      context,
                      criterion: 'Participations',
                      function: '√x',
                      weight: '20 %',
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'La part finale de chaque membre est calculée '
                        'à partir de son score relatif par rapport aux '
                        'autres membres du groupe.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade800,
                          height: 1.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Fonctions disponibles :',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    _buildBullet(
                      'Proportionnelle : f(x) = x',
                    ),

                    _buildBullet(
                      'Racine carrée : f(x) = √x',
                    ),

                    _buildBullet(
                      'Logarithmique : f(x) = log(1 + x)',
                    ),

                    _buildBullet(
                      'Exponentielle : f(x) = x² ou xᵖ',
                    ),

                    _buildBullet(
                      'Facteur : f(x) = k × x',
                    ),

                    _buildBullet(
                      'Plafonnée : possibilité de limiter l’influence d’un critère.',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // =========================
          // MEMBRES
          // =========================

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

  // ============================================================
  // CARTE PRINCIPALE COMPACTE
  // ============================================================

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.10),
      margin: const EdgeInsets.only(bottom: 7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            children: [

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MENU DÉROULANT
  // ============================================================

  Widget _buildExpansionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.10),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            10,
            0,
            10,
            8,
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 21,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          children: children,
        ),
      ),
    );
  }

  // ============================================================
  // OPTION DU MENU
  // ============================================================

  Widget _buildCompactOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        child: Row(
          children: [

            Icon(
              icon,
              size: 21,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ENCADRÉ DE RÈGLE
  // ============================================================

  Widget _buildRuleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // VALEUR PRINCIPALE D'UNE RÈGLE
  // ============================================================

  Widget _buildRuleValue(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
              children: [
                TextSpan(
                  text: '$title : ',
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONDITION ACTIVÉE / DÉSACTIVÉE
  // ============================================================

  Widget _buildCondition(
    BuildContext context, {
    required IconData icon,
    required String text,
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(
            enabled
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            size: 18,
            color: enabled
                ? Colors.green.shade700
                : Colors.grey.shade400,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                color: enabled
                    ? Colors.grey.shade800
                    : Colors.grey.shade500,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BULLET
  // ============================================================

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            '• ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}