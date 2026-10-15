import 'package:flutter/material.dart';

import '../services/api_service.dart';

class PendingJoinRequestsSection extends StatefulWidget {
  final int groupId;

  const PendingJoinRequestsSection({
    super.key,
    required this.groupId,
  });

  @override
  State<PendingJoinRequestsSection> createState() =>
      _PendingJoinRequestsSectionState();
}

class _PendingJoinRequestsSectionState
    extends State<PendingJoinRequestsSection> {
  final ApiService _api = ApiService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void didUpdateWidget(
    covariant PendingJoinRequestsSection oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.groupId != widget.groupId) {
      _loadRequests();
    }
  }

  Future<void> _loadRequests() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final allMembers =
          await _api.fetchGroupMembers(widget.groupId);

      final requests = allMembers
          .whereType<Map>()
          .where(
            (member) =>
                member['request_status']?.toString().toLowerCase() ==
                'pending',
          )
          .map(
            (member) => Map<String, dynamic>.from(member),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _requests = requests;
        _loading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('[PendingJoinRequestsSection] Erreur : $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _error = 'Impossible de charger les demandes en attente.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.error_outline),
          title: Text(_error!),
          trailing: IconButton(
            tooltip: 'Réessayer',
            onPressed: _loadRequests,
            icon: const Icon(Icons.refresh),
          ),
        ),
      );
    }

    if (_requests.isEmpty) {
      return Card(
        child: ListTile(
          leading: Icon(
            Icons.check_circle_outline,
            color: Colors.grey.shade600,
          ),
          title: const Text('Aucune demande en attente'),
          subtitle: const Text(
            'Les nouvelles demandes apparaîtront ici.',
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final request in _requests)
          _buildRequestCard(context, request),
      ],
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    Map<String, dynamic> request,
  ) {
    final name =
        request['pseudo']?.toString() ?? 'Utilisateur inconnu';

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identité de la personne
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person_add_alt_1,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Demande d’adhésion en attente',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Boutons volontairement inactifs pour le moment.
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: null,
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: null,
                    child: const Text('Accepter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}