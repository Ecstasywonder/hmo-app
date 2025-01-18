import 'package:flutter/material.dart';
import '../models/provider_model.dart';

class ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showDetails;

  const ProviderCard({
    Key? key,
    required this.provider,
    this.onTap,
    this.isSelected = false,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: provider.logo != null
                  ? Image.network(
                      provider.logo!,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (provider.isVerified)
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${provider.city}, ${provider.state}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        provider.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${provider.reviewCount} reviews',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (showDetails) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Plans', provider.stats['plansCount'] ?? 0),
                        _buildStat('Hospitals', provider.stats['hospitalsCount'] ?? 0),
                        _buildStat('Subscribers', provider.subscriberCount),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: provider.features
                          .take(3)
                          .map((feature) => Chip(
                                label: Text(
                                  feature,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 120,
      color: Colors.grey[200],
      child: const Icon(Icons.business, size: 48),
    );
  }

  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
} 