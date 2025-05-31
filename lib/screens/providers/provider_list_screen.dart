import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/provider_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/provider_card.dart';
import '../../widgets/provider_selection.dart';
import '../../models/provider_model.dart';

class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({Key? key}) : super(key: key);

  @override
  _ProviderListScreenState createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String? _selectedCity;
  String? _selectedState;
  double? _minRating;
  bool _isLoading = false;
  bool _hasError = false;
  final List<ProviderModel> _providers = [];
  List<ProviderModel> _selectedProviders = [];
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isCompareMode = false;

  @override
  void initState() {
    super.initState();
    _loadProviders();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProviders({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMorePages = true;
        _providers.clear();
      });
    }

    if (!_hasMorePages || _isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final filters = {
        'name': _searchController.text,
        'city': _selectedCity,
        'state': _selectedState,
        'rating': _minRating,
        'page': _currentPage,
        'limit': 10,
      };

      final result = await context.read<ProviderService>().getProviders(filters);
      
      setState(() {
        _providers.addAll(result.providers);
        _hasMorePages = _currentPage < result.pagination.totalPages;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _loadProviders();
    }
  }

  void _toggleCompareMode() {
    setState(() {
      _isCompareMode = !_isCompareMode;
      if (!_isCompareMode) {
        _selectedProviders.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HMO Providers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(_isCompareMode ? Icons.close : Icons.compare_arrows),
            onPressed: _toggleCompareMode,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isCompareMode)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search providers...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (_) => _loadProviders(refresh: true),
              ),
            ),
          if (_hasError)
            EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Error Loading Providers',
              message: 'An error occurred while loading providers. Please try again.',
              buttonText: 'Retry',
              onButtonPressed: () => _loadProviders(refresh: true),
            )
          else if (_providers.isEmpty && !_isLoading)
            const EmptyStateWidget(
              icon: Icons.business,
              title: 'No Providers Found',
              message: 'Try adjusting your search or filters to find providers.',
            )
          else
            Expanded(
              child: _isCompareMode
                  ? ProviderSelection(
                      providers: _providers,
                      selectedProviders: _selectedProviders,
                      onSelectionChanged: (providers) {
                        setState(() => _selectedProviders = providers);
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadProviders(refresh: true),
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _providers.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _providers.length) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final provider = _providers[index];
                          return ProviderCard(
                            provider: provider,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/provider-details',
                              arguments: provider.id,
                            ),
                          );
                        },
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Providers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(labelText: 'City'),
              items: const [], // TODO: Add city list
              onChanged: (value) {
                setState(() => _selectedCity = value);
                _loadProviders(refresh: true);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedState,
              decoration: const InputDecoration(labelText: 'State'),
              items: const [], // TODO: Add state list
              onChanged: (value) {
                setState(() => _selectedState = value);
                _loadProviders(refresh: true);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<double>(
              value: _minRating,
              decoration: const InputDecoration(labelText: 'Minimum Rating'),
              items: [null, 3.0, 4.0, 4.5].map((rating) {
                return DropdownMenuItem(
                  value: rating,
                  child: Text(rating?.toString() ?? 'Any'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _minRating = value);
                _loadProviders(refresh: true);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCity = null;
                _selectedState = null;
                _minRating = null;
              });
              _loadProviders(refresh: true);
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 