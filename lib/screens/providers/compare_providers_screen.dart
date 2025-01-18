import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/provider_service.dart';
import '../../models/provider_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class CompareProvidersScreen extends StatefulWidget {
  final List<String> providerIds;

  const CompareProvidersScreen({
    Key? key,
    required this.providerIds,
  }) : super(key: key);

  @override
  _CompareProvidersScreenState createState() => _CompareProvidersScreenState();
}

class _CompareProvidersScreenState extends State<CompareProvidersScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  List<ProviderModel> _providers = [];
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final providers = await Future.wait(
        widget.providerIds.map((id) => 
          context.read<ProviderService>().getProviderDetails(id)
        ),
      );

      setState(() {
        _providers = providers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading providers...'),
      );
    }

    if (_hasError) {
      return Scaffold(
        body: EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Error Loading Providers',
          message: 'Failed to load provider details. Please try again.',
          buttonText: 'Retry',
          onButtonPressed: _loadProviders,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Providers'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _verticalScrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _horizontalScrollController,
          child: DataTable(
            columnSpacing: 24,
            headingRowHeight: 80,
            columns: [
              const DataColumn(
                label: Text(
                  'Features',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ..._providers.map((provider) {
                return DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (provider.logo != null)
                        Image.network(
                          provider.logo!,
                          height: 40,
                          width: 40,
                          fit: BoxFit.contain,
                        )
                      else
                        const Icon(Icons.business, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        provider.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
            ],
            rows: [
              _buildDataRow(
                'Rating',
                _providers.map((p) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[700]),
                    const SizedBox(width: 4),
                    Text(p.rating.toStringAsFixed(1)),
                  ],
                )).toList(),
              ),
              _buildDataRow(
                'Reviews',
                _providers.map((p) => Text('${p.reviewCount}')).toList(),
              ),
              _buildDataRow(
                'Subscribers',
                _providers.map((p) => Text('${p.subscriberCount}')).toList(),
              ),
              _buildDataRow(
                'Year Established',
                _providers.map((p) => Text(p.yearEstablished?.toString() ?? '-')).toList(),
              ),
              _buildDataRow(
                'Location',
                _providers.map((p) => Text('${p.city}, ${p.state}')).toList(),
              ),
              _buildDataRow(
                'Features',
                _providers.map((p) => Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: p.features.map((f) => Chip(
                    label: Text(f, style: const TextStyle(fontSize: 12)),
                    padding: EdgeInsets.zero,
                  )).toList(),
                )).toList(),
              ),
              _buildDataRow(
                'Coverage',
                _providers.map((p) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: p.coverage.entries.map((e) => Text(
                    '${e.key}: ${e.value}',
                    style: const TextStyle(fontSize: 12),
                  )).toList(),
                )).toList(),
              ),
              _buildDataRow(
                'Operating Hours',
                _providers.map((p) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: p.operatingHours.entries.map((e) => Text(
                    '${e.key}: ${e.value}',
                    style: const TextStyle(fontSize: 12),
                  )).toList(),
                )).toList(),
              ),
              _buildDataRow(
                'Contact',
                _providers.map((p) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.phone),
                    Text(p.email, style: const TextStyle(fontSize: 12)),
                    if (p.website != null)
                      Text(p.website!, style: const TextStyle(fontSize: 12)),
                  ],
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(String label, List<Widget> values) {
    return DataRow(
      cells: [
        DataCell(Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        ...values.map((value) => DataCell(value)),
      ],
    );
  }
} 