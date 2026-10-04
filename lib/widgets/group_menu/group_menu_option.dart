import 'package:flutter/material.dart';

class GroupMenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const GroupMenuOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        child: Row(
          children: [

            Icon(
              icon,
              size: 21,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }
}