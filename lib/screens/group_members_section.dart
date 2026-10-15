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

class _GroupMembersSectionState extends State<GroupMembersSection>
    with AutomaticKeepAliveClientMixin<GroupMembersSection> {
  final ApiService _api = ApiService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _members = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void didUpdateWidget(covariant GroupMembersSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.groupId != widget.groupId) {
      _loadMembers();
    }
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final allMembers =
          await _api.fetchGroupMembers(widget.groupId);

      final members = allMembers
          .whereType<Map>()
          .where(
            (member) =>
                member['request_status']?.toString().toLowerCase() ==
                'accepted',
          )
          .map(
            (member) => Map<String, dynamic>.from(member),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('[GroupMembersSection] Erreur : $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _error = 'Impossible de charger les membres du groupe.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(30),
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
            onPressed: _loadMembers,
            icon: const Icon(Icons.refresh),
          ),
        ),
      );
    }

    if (_members.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        for (final member in _members)
          _buildMemberCard(context, member),
      ],
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    Map<String, dynamic> member,
  ) {
    final name = member['pseudo']?.toString() ?? 'Inconnu';
    final totalSpent = member['total_spent'] ?? 0;
    final isCurrentUser =
        widget.username.isNotEmpty && name == widget.username;

    final primaryColor = Theme.of(context).colorScheme.primary;

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
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Nom et statut
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
                  if (isCurrentUser) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Vous',
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Apport
            Text(
              'Apport : $totalSpent',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(width: 12),

            // Icône du membre
            Icon(
              isCurrentUser ? Icons.person : Icons.person_outline,
              color: isCurrentUser ? primaryColor : Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 45,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun membre accepté',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les membres apparaîtront ici une fois leur demande acceptée.',
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

// import 'package:flutter/material.dart';
// import '../services/api_service.dart';

// class GroupMembersSection extends StatefulWidget {
//   final int groupId;
//   final String username;

//   const GroupMembersSection({
//     super.key,
//     required this.groupId,
//     this.username = '',
//   });

//   @override
//   State<GroupMembersSection> createState() =>
//       _GroupMembersSectionState();
// }

// class _GroupMembersSectionState
//     extends State<GroupMembersSection>
//     with AutomaticKeepAliveClientMixin<GroupMembersSection> {

//   final ApiService _api = ApiService();

//   bool _loading = true;
//   List<dynamic> _members = [];

//   @override
//   bool get wantKeepAlive => true;

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _loadMembers();
//   // }

//   @override
//   void initState() {
//     super.initState();

//     print('🟢 GroupMembersSection INIT');

//     _loadMembers();
//   }

//   @override
//   void dispose() {
//     print('🔴 GroupMembersSection DISPOSE');

//     super.dispose();
//   }

//   Future<void> _loadMembers() async {
//     setState(() => _loading = true);

//     try {
//       final allMembers =
//           await _api.fetchGroupMembers(widget.groupId);

//       final members = allMembers.where((member) {
//         if (member is! Map) return false;

//         return member['request_status'] == 'accepted';
//       }).toList();

//       if (!mounted) return;

//       setState(() {
//         _members = members;
//       });
//     } catch (e) {
//       print('[GroupMembersSection] Error loading members: $e');
//     } finally {
//       if (!mounted) return;

//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     if (_loading) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.all(30),
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     if (_members.isEmpty) {
//       return _buildEmptyState();
//     }

//     return Column(
//       children: [
//         for (int idx = 0; idx < _members.length; idx++)
//           _buildMemberCard(
//             context,
//             _members[idx],
//             idx,
//           ),
//       ],
//     );
//   }

//   Widget _buildMemberCard(
//     BuildContext context,
//     dynamic member,
//     int index,
//   ) {
//     final m = member as Map;

//     final name =
//         m['pseudo']?.toString() ?? 'Inconnu';

//     final totalSpent =
//         m['total_spent'] ?? 0;

//     final isCurrentUser =
//         name == widget.username;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shadowColor: Colors.black.withOpacity(0.1),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 14,
//         ),
//         child: Row(
//           children: [

//             // =========================
//             // Avatar
//             // =========================

//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: Theme.of(context)
//                     .colorScheme
//                     .primary
//                     .withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: Text(
//                   name.isNotEmpty
//                       ? name[0].toUpperCase()
//                       : '?',
//                   style: TextStyle(
//                     fontSize: 19,
//                     fontWeight: FontWeight.bold,
//                     color: Theme.of(context)
//                         .colorScheme
//                         .primary,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(width: 14),

//             // =========================
//             // Nom
//             // =========================

//             Expanded(
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [

//                   Text(
//                     name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),

//                   if (isCurrentUser) ...[
//                     const SizedBox(height: 3),
//                     Text(
//                       'Vous',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Theme.of(context)
//                             .colorScheme
//                             .primary,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),

//             // =========================
//             // Apport
//             // =========================

//             Text(
//               'apport : $totalSpent',
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey.shade600,
//               ),
//             ),

//             const SizedBox(width: 12),

//             // =========================
//             // Icône membre
//             // =========================

//             Icon(
//               isCurrentUser
//                   ? Icons.person
//                   : Icons.person_outline,
//               color: isCurrentUser
//                   ? Theme.of(context)
//                       .colorScheme
//                       .primary
//                   : Colors.grey.shade500,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [

//             Container(
//               width: 90,
//               height: 90,
//               decoration: BoxDecoration(
//                 color: Theme.of(context)
//                     .colorScheme
//                     .primary
//                     .withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.person_off_outlined,
//                 size: 45,
//                 color: Theme.of(context)
//                     .colorScheme
//                     .primary,
//               ),
//             ),

//             const SizedBox(height: 20),

//             const Text(
//               'Aucun membre',
//               style: TextStyle(
//                 fontSize: 21,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 8),

//             Text(
//               'Ce groupe ne contient encore aucun membre.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class PendingJoinRequestsSection extends StatefulWidget {
//   final int groupId;

//   const PendingJoinRequestsSection({
//     super.key,
//     required this.groupId,
//   });

//   @override
//   State<PendingJoinRequestsSection> createState() =>
//       _PendingJoinRequestsSectionState();
// }

// class _PendingJoinRequestsSectionState
//     extends State<PendingJoinRequestsSection> {
//   final ApiService _api = ApiService();

//   bool _loading = true;
//   String? _error;
//   List<dynamic> _requests = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadRequests();
//   }

//   Future<void> _loadRequests() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       final members =
//           await _api.fetchGroupMembers(widget.groupId);

//       final requests = members.where((member) {
//         if (member is! Map) return false;

//         return member['request_status'] == 'pending';
//       }).toList();

//       if (!mounted) return;

//       setState(() {
//         _requests = requests;
//         _loading = false;
//       });
//     } catch (e) {
//       debugPrint('[PendingJoinRequests] Erreur : $e');

//       if (!mounted) return;

//       setState(() {
//         _error = 'Impossible de charger les demandes.';
//         _loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Padding(
//         padding: EdgeInsets.all(20),
//         child: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     if (_error != null) {
//       return Card(
//         child: ListTile(
//           title: Text(_error!),
//           trailing: IconButton(
//             onPressed: _loadRequests,
//             icon: const Icon(Icons.refresh),
//           ),
//         ),
//       );
//     }

//     if (_requests.isEmpty) {
//       return const Card(
//         child: ListTile(
//           leading: Icon(Icons.check_circle_outline),
//           title: Text('Aucune demande en attente'),
//         ),
//       );
//     }

//     return Column(
//       children: [
//         for (final request in _requests)
//           if (request is Map)
//             Card(
//               margin: const EdgeInsets.only(bottom: 10),
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.person_add_alt_1),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             request['pseudo']?.toString() ??
//                                 'Utilisateur inconnu',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () {},
//                             child: const Text('Refuser'),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: FilledButton(
//                             onPressed: () {},
//                             child: const Text('Accepter'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//       ],
//     );
//   }
// }