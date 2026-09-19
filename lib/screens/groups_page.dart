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
      final groups = await _api.fetchGroups();
      final members = await _api.fetchMembers();

      // try to find groups for the logged username
      // heuristics: member row may contain keys like name, username, email, member_name
      final username = widget.username.toLowerCase();

      // find member rows matching username
      final matchedMembers = members.where((m) {
        if (m is Map) {
          for (final key in m.keys) {
            final value = m[key];
            if (value is String && value.toLowerCase() == username) return true;
          }
        }
        return false;
      }).toList();

      // attempt to map group ids: look for common member->group key
      List<dynamic> userGroups = [];

      if (matchedMembers.isNotEmpty) {
        final member = matchedMembers.first as Map;
        // check some keys that may reference group id
        final possibleKeys = ['group_id', 'group', 'groups', 'Group', 'GroupId'];
        dynamic groupRef;
        for (final k in possibleKeys) {
          if (member.containsKey(k)) {
            groupRef = member[k];
            break;
          }
        }

        if (groupRef != null) {
          // find group(s) matching id or name
          userGroups = groups.where((g) {
            if (g is Map) {
              if (groupRef is String || groupRef is num) {
                return g.values.any((v) => v == groupRef);
              }
            }
            return false;
          }).toList();
        }
      }

      // fallback: show all groups if unable to match
      if (userGroups.isEmpty) userGroups = groups;

      setState(() {
        _groups = groups;
        _members = members;
        _userGroups = userGroups;
      });
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Groups for ${widget.username}')),
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
                    context.go('/group/${idx}?username=$encoded', extra: g as Map<String, dynamic>?);
                  },
                );
              },
            ),
    );
  }
}
