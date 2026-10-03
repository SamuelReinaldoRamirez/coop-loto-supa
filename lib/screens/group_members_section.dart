import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GroupMembersSection extends StatefulWidget {
  final int groupId;
  final String username;

  const GroupMembersSection({
    super.key,
    required this.groupId,
    this.username = '',
  });

  @override
  State<GroupMembersSection> createState() =>
      _GroupMembersSectionState();
}

class _GroupMembersSectionState
    extends State<GroupMembersSection> {

  final ApiService _api = ApiService();

  bool _loading = true;
  List<dynamic> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _loading = true);

    try {
      final members =
          await _api.fetchGroupMembers(widget.groupId);

      if (!mounted) return;

      setState(() {
        _members = members;
      });
    } catch (e) {
      print('[GroupMembersSection] Error loading members: $e');
    } finally {
      if (!mounted) return;

      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_members.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        for (int idx = 0; idx < _members.length; idx++)
          _buildMemberCard(
            context,
            _members[idx],
            idx,
          ),
      ],
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    dynamic member,
    int index,
  ) {
    final m = member as Map;

    final name =
        m['pseudo']?.toString() ?? 'Inconnu';

    final totalSpent =
        m['total_spent'] ?? 0;

    final isCurrentUser =
        name == widget.username;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [

            // =========================
            // Avatar
            // =========================

            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty
                      ? name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // =========================
            // Nom
            // =========================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (isCurrentUser) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Vous',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // =========================
            // Apport
            // =========================

            Text(
              'apport : $totalSpent',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(width: 12),

            // =========================
            // Icône membre
            // =========================

            Icon(
              isCurrentUser
                  ? Icons.person
                  : Icons.person_outline,
              color: isCurrentUser
                  ? Theme.of(context)
                      .colorScheme
                      .primary
                  : Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
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
                Icons.person_off_outlined,
                size: 45,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Aucun membre',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Ce groupe ne contient encore aucun membre.',
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