import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class GroupsPage extends StatefulWidget {
  final String username;
  const GroupsPage({super.key, required this.username});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final ApiService _api = ApiService();
  bool _loading = true;
  List<dynamic> _groups = [];
  List<dynamic> _members = [];
  List<dynamic> _userGroups = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // fetch only groups for the authenticated user
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home', extra: widget.username);
          },
        ),
        title: Text('Groups for ${widget.username}'),
        ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _userGroups.length,
              itemBuilder: (context, idx) {
                final g = _userGroups[idx];
                final name = (g is Map && g['name'] != null) ? g['name'] : (g is Map ? g.values.first.toString() : g.toString());
                return ListTile(
                  title: Text(name),
                  onTap: () {
                    // navigate to group detail using GoRouter and pass group map + username as query
                    final encoded = Uri.encodeComponent(widget.username);
                    context.push(
                      '/group/${g['id']}?username=$encoded',
                      extra: g as Map<String, dynamic>,
                    );
                    // context.go('/group/${idx}?username=$encoded', extra: g as Map<String, dynamic>?);
                  },
                );
              },
            ),
    );
  }
}
