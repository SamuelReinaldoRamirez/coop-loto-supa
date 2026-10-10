
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class GroupPlayedGridsPage extends StatefulWidget {
  final int groupId;
  final String username;

  const GroupPlayedGridsPage({
    super.key,
    required this.groupId,
    required this.username,
  });

  @override
  State<GroupPlayedGridsPage> createState() =>
      _GroupPlayedGridsPageState();
}

class _GroupPlayedGridsPageState
    extends State<GroupPlayedGridsPage> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _grids = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGrids();
  }

  Future<void> _loadGrids() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint(
        '[GroupPlayedGridsPage] '
        'Chargement des grilles du groupe ${widget.groupId}...',
      );

      final response = await _apiService.fetchGroupGrids(
        widget.groupId,
      );

      final grids = response.map((grid) {
        return Map<String, dynamic>.from(grid as Map);
      }).toList();

      debugPrint(
        '[GroupPlayedGridsPage] '
        '${grids.length} grille(s) récupérée(s).',
      );

      if (!mounted) return;

      setState(() {
        _grids = grids;
        _isLoading = false;
        _error = null;
      });
    } catch (error, stackTrace) {
      debugPrint(
        '[GroupPlayedGridsPage] Erreur : $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Impossible de charger les grilles du groupe.';
      });
    }
  }

  String _formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'Date inconnue';
    }

    final date = DateTime.tryParse(value.toString());

    if (date == null) {
      return value.toString();
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<int> _readNumbers(Map<String, dynamic> grid) {
    return [
      _readInt(grid['n1']),
      _readInt(grid['n2']),
      _readInt(grid['n3']),
      _readInt(grid['n4']),
      _readInt(grid['n5']),
    ];
  }

  List<int> _readStars(Map<String, dynamic> grid) {
    return [
      _readInt(grid['e1']),
      _readInt(grid['e2']),
    ];
  }

  String _readAuthor(Map<String, dynamic> grid) {
    final pseudo = grid['author_pseudo']?.toString().trim();

    if (pseudo != null && pseudo.isNotEmpty) {
      return pseudo;
    }

    return 'Utilisateur inconnu';
  }

  String _readStatus(Map<String, dynamic> grid) {
    final status = grid['status']?.toString().trim();

    if (status == null || status.isEmpty) {
      return 'Statut inconnu';
    }

    switch (status.toLowerCase()) {
      case 'suggérée':
      case 'suggeree':
        return 'Suggérée';
      case 'jouée':
      case 'jouee':
        return 'Jouée';
      case 'validée':
      case 'validee':
        return 'Validée';
      case 'annulée':
      case 'annulee':
        return 'Annulée';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Grilles jouées par votre groupe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Actualiser les grilles',
            onPressed: _isLoading ? null : _loadGrids,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadGrids,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_grids.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadGrids,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 100),
            Icon(
              Icons.confirmation_number_outlined,
              size: 56,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucune grille enregistrée',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Les grilles ajoutées à ce groupe apparaîtront ici.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGrids,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _grids.length,
        itemBuilder: (context, index) {
          final grid = _grids[index];

          return _buildGridCard(grid);
        },
      ),
    );
  }

  Widget _buildGridCard(Map<String, dynamic> grid) {
    final numbers = _readNumbers(grid);
    final stars = _readStars(grid);

    final drawDate = _formatDate(grid['draw_date']);
    final author = _readAuthor(grid);
    final status = _readStatus(grid);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    drawDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    author,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Statut : ',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _statusColor(grid['status']),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: numbers
                  .map(
                    (number) => _buildBall(
                      number.toString(),
                      Colors.grey.shade200,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: stars
                  .map(
                    (star) => _buildBall(
                      '★$star',
                      Colors.amber.shade100,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(dynamic value) {
    switch (value?.toString().toLowerCase()) {
      case 'jouée':
      case 'jouee':
      case 'validée':
      case 'validee':
        return Colors.green.shade700;
      case 'annulée':
      case 'annulee':
        return Colors.red.shade700;
      case 'suggérée':
      case 'suggeree':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildBall(String value, Color backgroundColor) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
