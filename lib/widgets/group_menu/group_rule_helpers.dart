import 'package:flutter/material.dart';

class GroupRuleHelpers {
  static Widget value(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
              children: [
                TextSpan(
                  text: '$title : ',
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget condition(
    BuildContext context, {
    required IconData icon,
    required String text,
    required bool enabled,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 3,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Icon(
            enabled
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            size: 18,
            color: enabled
                ? Colors.green.shade700
                : Colors.grey.shade400,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                color: enabled
                    ? Colors.grey.shade800
                    : Colors.grey.shade500,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget bullet(String text) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          const Text(
            '• ',
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget distributionFunction(
    BuildContext context, {
    required String criterion,
    required String function,
    required String weight,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [

          Expanded(
            child: Text(
              criterion,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade800,
              ),
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius:
                  BorderRadius.circular(6),
            ),
            child: Text(
              function,
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 42,
            child: Text(
              weight,
              textAlign:
                  TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}