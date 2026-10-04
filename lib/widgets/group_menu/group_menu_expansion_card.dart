import 'package:flutter/material.dart';

class GroupMenuExpansionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const GroupMenuExpansionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor:
          Colors.black.withOpacity(0.10),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          childrenPadding:
              const EdgeInsets.fromLTRB(
            10,
            0,
            10,
            8,
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 21,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
}