// widgets/topic_card.dart
import 'package:flutter/material.dart';

class TopicCard extends StatelessWidget {
  final Map<String, String> topic;
  final VoidCallback onTap;

  const TopicCard({
    super.key,
    required this.topic,
    required this.onTap,
  });

  IconData _getIconData() {
    final iconName = topic['icon'] ?? 'description';
    
    // Map icon names to IconData
    switch (iconName) {
      case 'family_restroom':
        return Icons.family_restroom;
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'gavel':
        return Icons.gavel;
      case 'account_balance':
        return Icons.account_balance;
      case 'attach_money':
        return Icons.attach_money;
      case 'security':
        return Icons.security;
      case 'policy':
      return Icons.policy;
      case 'apartment':
        return Icons.apartment;
      case 'handshake':
        return Icons.handshake;
      case 'medical_services':
        return Icons.medical_services;
      case 'business':
        return Icons.business;
      default:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconData(),
                size: 48.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12.0),
              Text(
                topic['title'] ?? 'Unknown Topic',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                topic['description'] ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}