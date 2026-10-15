import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';

class SearchGroupsPage extends StatefulWidget {
  final String username;

  const SearchGroupsPage({
    super.key,
    required this.username,
  });

  @override
  State<SearchGroupsPage> createState() => _SearchGroupsPageState();
}

class _SearchGroupsPageState extends State<SearchGroupsPage> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController =
      TextEditingController();

  bool _loading = true;
  String? _error;

  List<dynamic> _allGroups = [];
  Map<int, String?> _membershipStatuses = {};

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
  if (mounted) {
    setState(() {
      _loading = true;
      _error = null;
    });
  }

  try {
    final results = await Future.wait<dynamic>([
      _api.fetchGroups(),
      _api.fetchMe(),
      _api.fetchMembers(),
    ]);

    final allGroups = results[0] as List<dynamic>;
    final me = Map<String, dynamic>.from(results[1] as Map);
    final members = results[2] as List<dynamic>;

    final userId = int.tryParse(me['id'].toString());

    if (userId == null) {
      throw Exception(
        'Impossible de récupérer l’identifiant de l’utilisateur.',
      );
    }

    // Dernière adhésion connue pour chaque groupe.
    final latestMemberships = <int, Map<String, dynamic>>{};

    for (final member in members) {
      if (member is! Map) continue;

      final row = Map<String, dynamic>.from(member);

      final memberUserId =
          int.tryParse(row['user'].toString());
      final groupId =
          int.tryParse(row['group'].toString());
      final membershipId =
          int.tryParse(row['id'].toString());

      if (memberUserId != userId ||
          groupId == null ||
          membershipId == null) {
        continue;
      }

      final previous = latestMemberships[groupId];
      final previousId = previous == null
          ? null
          : int.tryParse(previous['id'].toString());

      if (previousId == null || membershipId > previousId) {
        latestMemberships[groupId] = row;
      }
    }

    final statuses = <int, String?>{};

    for (final entry in latestMemberships.entries) {
      statuses[entry.key] =
          entry.value['request_status']?.toString();
    }

    if (!mounted) return;

    setState(() {
      _allGroups = allGroups;
      _membershipStatuses = statuses;
      _loading = false;
    });
  } catch (e) {
    debugPrint('[SearchGroups] Erreur : $e');

    if (!mounted) return;

    setState(() {
      _error = 'Impossible de charger les groupes.';
      _loading = false;
    });
  }
}

  List<dynamic> get _filteredGroups {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _allGroups;
    }

    return _allGroups.where((group) {
      if (group is! Map) {
        return group.toString().toLowerCase().contains(query);
      }

      final name = (group['name'] ?? '').toString().toLowerCase();
      final id = (group['id'] ?? '').toString();

      return name.contains(query) || id.contains(query);
    }).toList();
  }

  String _groupName(dynamic group) {
    if (group is Map && group['name'] != null) {
      return group['name'].toString();
    }

    if (group is Map && group['id'] != null) {
      return 'Groupe ${group['id']}';
    }

    return 'Groupe';
  }

  int? _groupId(dynamic group) {
    if (group is Map && group['id'] != null) {
      return int.tryParse(group['id'].toString());
    }

    return null;
  }

  void _openPublicGroup(dynamic group) {
    final groupId = _groupId(group);

    if (groupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir ce groupe : identifiant manquant.'),
        ),
      );
      return;
    }

    context.push(
      '/public-group/$groupId',
      extra: {
        'username': widget.username,
        'group': group,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _filteredGroups;

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _allGroups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadGroups,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Découvrir les groupes',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Explore les groupes et trouve celui que tu souhaites rejoindre.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Rechercher un groupe...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Effacer la recherche',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tous les groupes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${groups.length} résultat${groups.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 54,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _allGroups.isEmpty
                        ? 'Aucun groupe disponible pour le moment.'
                        : 'Aucun groupe ne correspond à ta recherche.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            )
          else
            for (final group in groups)
              _buildGroupCard(group),
        ],
      ),
    );
  }

  Widget _buildGroupCard(dynamic group) {
    final id = _groupId(group);
    final name = _groupName(group);
    final status = id == null ? null : _membershipStatuses[id];

    final isMember = status == 'accepted';
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: id == null ? null : () => _openPublicGroup(group),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  size: 29,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (id != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Groupe #$id',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (isMember || isPending || isRejected) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            isMember
                                ? Icons.check_circle
                                : isPending
                                    ? Icons.hourglass_top_rounded
                                    : Icons.cancel_outlined,
                            size: 15,
                            color: isMember
                                ? Colors.green
                                : isPending
                                    ? Colors.orange.shade800
                                    : Colors.red,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isMember
                                ? 'Tu es membre'
                                : isPending
                                    ? 'Demande en attente'
                                    : 'Demande refusée',
                            style: TextStyle(
                              fontSize: 12,
                              color: isMember
                                  ? Colors.green
                                  : isPending
                                      ? Colors.orange.shade800
                                      : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade600,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}