import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class GroupsPage extends StatefulWidget {
  final String username;

  const GroupsPage({
    super.key,
    required this.username,
  });

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final ApiService _api = ApiService();

  bool _loading = true;
  List<dynamic> _userGroups = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final userGroups = await _api.fetchMyGroups();

      setState(() {
        _userGroups = userGroups;
      });
    } catch (e) {
      print('[Groups] Error loading groups: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home', extra: widget.username);
          },
        ),
        title: const Text(
          'Mes groupes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _userGroups.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _userGroups.length,
                    itemBuilder: (context, idx) {
                      final g = _userGroups[idx];

                      final name = (g is Map && g['name'] != null)
                          ? g['name'].toString()
                          : (g is Map && g['id'] != null)
                              ? 'Groupe ${g['id']}'
                              : g.toString();

                      final groupId =
                          g is Map ? g['id'] : null;

                      return _buildGroupCard(
                        context,
                        group: g,
                        name: name,
                        groupId: groupId,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context, {
    required dynamic group,
    required String name,
    required dynamic groupId,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          final encoded = Uri.encodeComponent(widget.username);

          // context.push(
          //   '/group/$groupId?username=$encoded',
          //   extra: group as Map<String, dynamic>,
          // );
          context.push(
            '/group/$groupId/menu?username=$encoded',
            extra: group,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Icône du groupe
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(width: 16),

              // Nom + ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (groupId != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Groupe #$groupId',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Flèche
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                Icons.groups_outlined,
                size: 45,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun groupe',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous ne faites actuellement partie d’aucun groupe.',
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
// import 'package:go_router/go_router.dart';
// import '../services/api_service.dart';

// class GroupsPage extends StatefulWidget {
//   final String username;
//   const GroupsPage({super.key, required this.username});

//   @override
//   State<GroupsPage> createState() => _GroupsPageState();
// }

// class _GroupsPageState extends State<GroupsPage> {
//   final ApiService _api = ApiService();
//   bool _loading = true;
//   List<dynamic> _groups = [];
//   List<dynamic> _members = [];
//   List<dynamic> _userGroups = [];

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     setState(() => _loading = true);
//     try {
//       // fetch only groups for the authenticated user
//       final userGroups = await _api.fetchMyGroups();

//       setState(() {
//         _userGroups = userGroups;
//       });
//     } catch (e) {
//       print('[Groups] Error loading groups: $e');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             context.go('/home', extra: widget.username);
//           },
//         ),
//         title: Text('Groups for ${widget.username}'),
//         ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _userGroups.length,
//               itemBuilder: (context, idx) {
//                 final g = _userGroups[idx];
//                 final name = (g is Map && g['name'] != null) ? g['name'] : (g is Map ? g.values.first.toString() : g.toString());
//                 return ListTile(
//                   title: Text(name),
//                   onTap: () {
//                     // navigate to group detail using GoRouter and pass group map + username as query
//                     final encoded = Uri.encodeComponent(widget.username);
//                     context.push(
//                       '/group/${g['id']}?username=$encoded',
//                       extra: g as Map<String, dynamic>,
//                     );
//                     // context.go('/group/${idx}?username=$encoded', extra: g as Map<String, dynamic>?);
//                   },
//                 );
//               },
//             ),
//     );
//   }
// }
