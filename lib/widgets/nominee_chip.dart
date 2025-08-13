import 'package:flutter/material.dart';

class NomineeChip extends StatelessWidget {
  final Map<String, String> nominee;
  final Function(String name, String id) onPressed;

  const NomineeChip({
    super.key,
    required this.nominee,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final name = nominee['name'] ?? '';
    final id = nominee['id'] ?? '';
    final hasValidId = id.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (hasValidId) ...[
            const SizedBox(width: 2),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                minimumSize: const Size(0, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => onPressed(name, id),
              child: const Text(
                'Nominations',
                style: TextStyle(color: Colors.amber, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
