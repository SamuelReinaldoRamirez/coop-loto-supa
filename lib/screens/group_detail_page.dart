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
      final groupId = widget.group['id'] as int;

      final members = await _api.fetchGroupMembers(groupId);

      setState(() {
        _members = members;
      });
    } catch (e) {
      print('[GroupDetail] Error loading members: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.group['name'] ?? widget.group['id'] ?? 'Group';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text('$title'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, idx) {
                final m = _members[idx];

                final display = (m is Map)
                    ? (m['pseudo'] ??
                        m['name'] ??
                        m['username'] ??
                        m['member_name'] ??
                        m.values.first.toString())
                    : m.toString();

                return ListTile(
                  title: Text(display.toString()),
                );
              },
            ),
    );
  }
}