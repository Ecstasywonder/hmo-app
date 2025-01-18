import 'package:flutter/material.dart';
import '../models/provider_model.dart';
import 'provider_card.dart';

class ProviderSelection extends StatefulWidget {
  final List<ProviderModel> providers;
  final List<ProviderModel> selectedProviders;
  final int maxSelections;
  final ValueChanged<List<ProviderModel>> onSelectionChanged;

  const ProviderSelection({
    Key? key,
    required this.providers,
    required this.selectedProviders,
    this.maxSelections = 3,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _ProviderSelectionState createState() => _ProviderSelectionState();
}

class _ProviderSelectionState extends State<ProviderSelection> {
  void _toggleSelection(ProviderModel provider) {
    final isSelected = widget.selectedProviders.contains(provider);
    List<ProviderModel> newSelection;

    if (isSelected) {
      newSelection = widget.selectedProviders.where((p) => p.id != provider.id).toList();
    } else {
      if (widget.selectedProviders.length >= widget.maxSelections) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can only compare up to ${widget.maxSelections} providers',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
      newSelection = [...widget.selectedProviders, provider];
    }

    widget.onSelectionChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Select up to ${widget.maxSelections} providers to compare',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (widget.selectedProviders.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedProviders.map((provider) {
                return Chip(
                  label: Text(provider.name),
                  onDeleted: () => _toggleSelection(provider),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                );
              }).toList(),
            ),
          ),
        ],
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.providers.length,
            itemBuilder: (context, index) {
              final provider = widget.providers[index];
              final isSelected = widget.selectedProviders.contains(provider);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ProviderCard(
                  provider: provider,
                  isSelected: isSelected,
                  showDetails: false,
                  onTap: () => _toggleSelection(provider),
                ),
              );
            },
          ),
        ),
        if (widget.selectedProviders.length >= 2)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/compare-providers',
                  arguments: widget.selectedProviders.map((p) => p.id).toList(),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Compare Selected Providers',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }
} 