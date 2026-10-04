import 'package:flutter/material.dart';

class GroupRuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const GroupRuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }
}