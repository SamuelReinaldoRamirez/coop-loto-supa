import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class GroupDetailPage extends StatefulWidget {
  final Map<String, dynamic> group;
  final String username;
  const GroupDetailPage({super.key, required this.group, this.username = ''});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
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
      final members = await _api.fetchMembers();
      // try to filter by group id or name found in widget.group
      final group = widget.group;
      dynamic groupId;
      if (group.containsKey('id')) groupId = group['id'];
      if (groupId == null) {
        if (group.containsKey('name')) groupId = group['name'];
      }

      List<dynamic> filtered = members;
      if (groupId != null) {
        filtered = members.where((m) {
          if (m is Map) {
            return m.values.any((v) => v == groupId);
          }
          return false;
        }).toList();
      }

      setState(() {
        _members = filtered;
      });
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.group['name'] ?? widget.group['id'] ?? 'Group';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              final encoded = Uri.encodeComponent(widget.username);
              router.go('/groups?username=$encoded');
            }
          },
        ),
        title: Text('$title'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, idx) {
                final m = _members[idx];
                final display = (m is Map)
                    ? (m['name'] ?? m['username'] ?? m['member_name'] ?? m.values.first.toString())
                    : m.toString();
                return ListTile(
                  title: Text(display),
                );
              },
            ),
    );
  }
}
