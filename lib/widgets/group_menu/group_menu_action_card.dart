import 'package:flutter/material.dart';

class GroupMenuActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const GroupMenuActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor:
          Colors.black.withOpacity(0.10),
      margin: const EdgeInsets.only(bottom: 7),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            children: [

              Container(
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

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}