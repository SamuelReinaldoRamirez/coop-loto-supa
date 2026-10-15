
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../services/api_service.dart';

class PublicGroupPage extends StatefulWidget {
  final String username;
  final int groupId;
  final dynamic initialGroup;

  const PublicGroupPage({
    super.key,
    required this.username,
    required this.groupId,
    this.initialGroup,
  });

  @override
  State<PublicGroupPage> createState() => _PublicGroupPageState();
}

class _PublicGroupPageState extends State<PublicGroupPage> {
  final ApiService _api = ApiService();

  bool _isSubmittingRequest = false;

  late dynamic _group;

  bool _loading = true;
  bool _isMember = false;
  bool _hasPendingRequest = false;
  bool _hasRejectedRequest = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _group = widget.initialGroup;
    _loadGroup();
  }

  Future<void> _loadGroup() async {
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

      dynamic foundGroup;

      for (final group in allGroups) {
        if (group is Map &&
            int.tryParse(group['id'].toString()) == widget.groupId) {
          foundGroup = group;
          break;
        }
      }

      Map<String, dynamic>? latestMembership;

      if (userId != null) {
        for (final member in members) {
          if (member is! Map) continue;

          final row = Map<String, dynamic>.from(member);

          final memberUserId =
              int.tryParse(row['user'].toString());
          final memberGroupId =
              int.tryParse(row['group'].toString());
          final membershipId =
              int.tryParse(row['id'].toString());

          if (memberUserId != userId ||
              memberGroupId != widget.groupId ||
              membershipId == null) {
            continue;
          }

          final previousId = latestMembership == null
              ? null
              : int.tryParse(latestMembership['id'].toString());

          if (previousId == null || membershipId > previousId) {
            latestMembership = row;
          }
        }
      }

      final status =
          latestMembership?['request_status']?.toString();

      if (!mounted) return;

      setState(() {
        if (foundGroup != null) {
          _group = foundGroup;
        }

        _isMember = status == 'accepted';
        _hasPendingRequest = status == 'pending';
        _hasRejectedRequest = status == 'rejected';

        _loading = false;

        _error = foundGroup == null && _group == null
            ? 'Ce groupe est introuvable.'
            : null;
      });
    } catch (e) {
      debugPrint('[PublicGroup] Erreur : $e');

      if (!mounted) return;

      setState(() {
        _loading = false;

        if (_group == null) {
          _error = 'Impossible de charger ce groupe.';
        }
      });
    }
  }

  String get _groupName {
    if (_group is Map && _group['name'] != null) {
      return _group['name'].toString();
    }

    return 'Groupe ${widget.groupId}';
  }

  String? _descriptionValue() {
    if (_group is! Map) return null;

    for (final key in ['description', 'public_description']) {
      final value = _group[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return null;
  }

  Future<void> _requestToJoin() async {
    if (_isSubmittingRequest || _isMember || _hasPendingRequest) {
      return;
    }

    setState(() {
      _hasPendingRequest = true;
      _hasRejectedRequest = false;
    });

    try {
      await _api.requestToJoinGroup(widget.groupId);

      if (!mounted) return;

      // La demande est maintenant connue comme étant en attente.
      setState(() {
        _hasPendingRequest = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Votre demande pour rejoindre le groupe a été envoyée.',
          ),
        ),
      );
    } on DioError catch (e) {
      if (!mounted) return;

      final responseData = e.response?.data;
      String message = 'Impossible d’envoyer la demande.';

      if (responseData is Map && responseData['detail'] != null) {
        message = responseData['detail'].toString();

        // Si le serveur confirme qu'une demande est déjà en attente,
        // on affiche aussi cet état dans la page.
        if (e.response?.statusCode == 409 &&
            message.toLowerCase().contains('attente')) {
          setState(() {
            _hasPendingRequest = true;
          });
        }

        if (e.response?.statusCode == 409 &&
            message.toLowerCase().contains('déjà membre')) {
          setState(() {
            _isMember = true;
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint('[PublicGroup] Erreur demande : $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Une erreur est survenue. Veuillez réessayer.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingRequest = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final description = _descriptionValue();

    final Color statusColor;
    final IconData statusIcon;
    final String statusText;

    if (_isMember) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_rounded;
      statusText = 'Tu es déjà membre de ce groupe.';
    } else if (_hasPendingRequest) {
      statusColor = Colors.orange.shade800;
      statusIcon = Icons.hourglass_top_rounded;
      statusText = 'Ta demande est en cours de traitement.';
    } else if (_hasRejectedRequest) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_outlined;
      statusText = 'Ta demande précédente a été refusée.';
    } else {
      statusColor = Colors.blueGrey;
      statusIcon = Icons.info_outline_rounded;
      statusText = 'Tu ne fais pas encore partie de ce groupe.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Présentation du groupe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading && _group == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null && _group == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.groups_outlined,
                          size: 52,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _loadGroup,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadGroup,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.groups_rounded,
                                size: 46,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              _groupName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Groupe #${widget.groupId}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildInformationCard(
                        title: 'À propos du groupe',
                        child: Text(
                          description ??
                              'Aucune description publique n’est disponible pour le moment.',
                          style: TextStyle(
                            height: 1.5,
                            fontSize: 15,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildInformationCard(
                        title: 'Ton statut',
                        child: Row(
                          children: [
                            Icon(
                              statusIcon,
                              color: statusColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                statusText,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isMember ||
                                  _hasPendingRequest ||
                                  _isSubmittingRequest
                              ? null
                              : _requestToJoin,
                          icon: _isSubmittingRequest
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  _isMember
                                      ? Icons.check_circle_outline
                                      : _hasPendingRequest
                                          ? Icons.hourglass_top_rounded
                                          : _hasRejectedRequest
                                              ? Icons.refresh
                                              : Icons.group_add_outlined,
                                ),
                          label: Text(
                            _isSubmittingRequest
                                ? 'Envoi de la demande...'
                                : _isMember
                                    ? 'Tu es déjà membre'
                                    : _hasPendingRequest
                                        ? 'Demande en attente'
                                        : _hasRejectedRequest
                                            ? 'Renvoyer une demande'
                                            : 'Demander à rejoindre le groupe',
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      if (_loading) ...[
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            'Actualisation des informations...',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildInformationCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
