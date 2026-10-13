import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/euromillions/draw_card.dart';

class GroupDrawHistoryPage extends StatefulWidget {
  final int groupId;

  const GroupDrawHistoryPage({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupDrawHistoryPage> createState() =>
      _GroupDrawHistoryPageState();
}

class _GroupDrawHistoryPageState
    extends State<GroupDrawHistoryPage> {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _draws = [];
  List<Map<String, dynamic>> _groupGrids = [];

  bool _loading = true;
  String? _error;

  // Une seule date peut être dépliée à la fois.
  String? _expandedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _api.fetchEuromillionsDraws(),
        _api.fetchGroupGrids(widget.groupId),
      ]);

      final draws = (results[0] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      final grids = (results[1] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      if (!mounted) return;

      // Les tirages les plus récents apparaissent en premier.
      draws.sort((a, b) {
        return _dateKey(b['draw_date'])
            .compareTo(_dateKey(a['draw_date']));
      });

      setState(() {
        _draws = draws;
        _groupGrids = grids;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Impossible de charger l’historique : $e';
      });

      debugPrint('Erreur historique du groupe : $e');
    }
  }

  /// Normalise une date ISO en YYYY-MM-DD.
  /// Les dates absentes ou invalides renvoient une chaîne vide.
  String _dateKey(dynamic value) {
    if (value == null) return '';

    final text = value.toString().trim();
    if (text.isEmpty) return '';

    final parsed = DateTime.tryParse(text);

    if (parsed != null) {
      final date = parsed.toLocal();

      return '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }

    // Repli pour les dates déjà au format YYYY-MM-DD.
    if (text.length >= 10 &&
        RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(text)) {
      return text.substring(0, 10);
    }

    return '';
  }

  List<Map<String, dynamic>> _gridsForDate(String date) {
    if (date.isEmpty) return [];

    return _groupGrids.where((grid) {
      return _dateKey(grid['draw_date']) == date;
    }).toList();
  }

  bool _isPaid(Map<String, dynamic> grid) {
    final status =
        (grid['status'] ?? '').toString().trim().toLowerCase();

    return status == 'payé' ||
        status == 'payée' ||
        status == 'paye' ||
        status == 'payee' ||
        status == 'paid';
  }

  bool _hasStarPlus(Map<String, dynamic> grid) {
    // Prend en charge plusieurs noms possibles.
    // À adapter au nom exact du champ renvoyé par ton API.
    final value = grid['star_plus'] ??
        grid['etoile_plus'] ??
        grid['étoile_plus'] ??
        grid['starPlus'] ??
        grid['is_star_plus'];

    if (value is bool) return value;

    if (value is num) return value != 0;

    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }

    return false;
  }

  int _totalExpense(List<Map<String, dynamic>> grids) {
    var total = 0;

    for (final grid in grids) {
      if (!_isPaid(grid)) continue;

      total += 250;

      if (_hasStarPlus(grid)) {
        total += 100;
      }
    }

    return total;
  }

  String _formatCredits(int credits) {
    final formatted = credits.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ' ',
    );

    return '$formatted crédits';
  }

  void _toggleDate(String date) {
    setState(() {
      _expandedDate = _expandedDate == date ? null : date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique du groupe'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _loading ? null : _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildHistory(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    if (_draws.isEmpty) {
      return const Center(
        child: Text('Aucun tirage disponible.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 4,
          bottom: 16,
        ),
        itemCount: _draws.length,
        itemBuilder: (context, index) {
          final draw = _draws[index];
          final date = _dateKey(draw['draw_date']);
          final grids = _gridsForDate(date);
          final expanded = _expandedDate == date;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => _toggleDate(date),
                child: Column(
                  children: [
                    // Réutilise la carte existante.
                    // L'InkWell rend la carte cliquable.
                    DrawCard(
                      draw: draw,
                      statsMode: false,
                      stats: null,
                      onTap: () => _toggleDate(date),
                    ),

                    _buildGroupSummary(
                      grids: grids,
                      expanded: expanded,
                    ),
                  ],
                ),
              ),

              // Les grilles n'apparaissent que sous le
              // tirage actuellement sélectionné.
              if (expanded)
                _buildPlayedGrids(grids),

              const SizedBox(height: 6),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroupSummary({
    required List<Map<String, dynamic>> grids,
    required bool expanded,
  }) {
    final paidCount = grids.where(_isPaid).length;
    final expense = _totalExpense(grids);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 0,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    icon: Icons.grid_view,
                    label: 'Grilles jouées',
                    value: '${grids.length}',
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    icon: Icons.payments_outlined,
                    label: 'Dépenses',
                    value: _formatCredits(expense),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    icon: Icons.check_circle_outline,
                    label: 'Grilles payées',
                    value: '$paidCount',
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    icon: Icons.emoji_events_outlined,
                    label: 'Gains',
                    value: '0 crédits',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  expanded
                      ? 'Masquer les grilles'
                      : 'Afficher les grilles jouées',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayedGrids(
    List<Map<String, dynamic>> grids,
  ) {
    if (grids.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Aucune grille enregistrée pour ce tirage.',
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 4,
              bottom: 6,
            ),
            child: Text(
              'Grilles du groupe (${grids.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ...grids.map(_buildGridCard),
        ],
      ),
    );
  }

  Widget _buildGridCard(Map<String, dynamic> grid) {
    final numbers = List<int>.generate(
      5,
      (index) => _asInt(grid['n${index + 1}']),
    );

    final stars = [
      _asInt(grid['e1']),
      _asInt(grid['e2']),
    ];

    final paid = _isPaid(grid);
    final starPlus = _hasStarPlus(grid);

    final author = (grid['author_pseudo'] ??
            grid['author'] ??
            'Membre')
        .toString();

    final status = (grid['status'] ?? 'suggérée').toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    author,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatus(status),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 7,
              runSpacing: 7,
              children: [
                ...numbers.map(
                  (number) => _buildBall(
                    number,
                    isStar: false,
                  ),
                ),
                const SizedBox(width: 4),
                ...stars.map(
                  (number) => _buildBall(
                    number,
                    isStar: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  starPlus
                      ? Icons.star
                      : Icons.star_border,
                  size: 17,
                  color: starPlus
                      ? Colors.amber.shade800
                      : Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    starPlus ? 'Étoile+ activée' : 'Sans Étoile+',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(
                  paid
                      ? '${250 + (starPlus ? 100 : 0)} crédits'
                      : 'Non comptée',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: paid
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBall(
    int number, {
    required bool isStar,
  }) {
    final color = isStar
        ? Colors.amber.shade700
        : Colors.blue.shade700;

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildStatus(String status) {
    final isPaid = _isPaid({'status': status});

    final color = isPaid
        ? Colors.green
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}