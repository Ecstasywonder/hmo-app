import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/provider_service.dart';
import '../../models/provider_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class ProviderDetailsScreen extends StatefulWidget {
  final String providerId;

  const ProviderDetailsScreen({
    Key? key,
    required this.providerId,
  }) : super(key: key);

  @override
  _ProviderDetailsScreenState createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasError = false;
  ProviderModel? _provider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProviderDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProviderDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final provider = await context
          .read<ProviderService>()
          .getProviderDetails(widget.providerId);
      setState(() {
        _provider = provider;
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
        body: LoadingWidget(message: 'Loading provider details...'),
      );
    }

    if (_hasError) {
      return Scaffold(
        body: EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Error Loading Provider',
          message: 'Failed to load provider details. Please try again.',
          buttonText: 'Retry',
          onButtonPressed: _loadProviderDetails,
        ),
      );
    }

    if (_provider == null) {
      return const Scaffold(
        body: EmptyStateWidget(
          icon: Icons.business,
          title: 'Provider Not Found',
          message: 'The requested provider could not be found.',
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _provider!.logo != null
                    ? Image.network(
                        _provider!.logo!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.business, size: 64),
                      ),
                title: Text(_provider!.name),
              ),
            ),
            SliverToBoxAdapter(
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Plans'),
                  Tab(text: 'Hospitals'),
                  Tab(text: 'Reviews'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildPlansTab(),
            _buildHospitalsTab(),
            _buildReviewsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          title: 'About',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_provider!.description),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.phone, _provider!.phone),
              _buildInfoRow(Icons.email, _provider!.email),
              _buildInfoRow(Icons.location_on, _provider!.address),
              if (_provider!.website != null)
                _buildInfoRow(Icons.link, _provider!.website!),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Statistics',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Plans', _provider!.stats['plansCount'] ?? 0),
              _buildStat('Hospitals', _provider!.stats['hospitalsCount'] ?? 0),
              _buildStat('Subscribers', _provider!.stats['subscribersCount'] ?? 0),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Features',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _provider!.features.map((feature) {
              return Chip(
                label: Text(feature),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Coverage',
          child: Column(
            children: _provider!.coverage.entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value.toString()),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlansTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: context.read<ProviderService>().getProviderPlans(widget.providerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Error Loading Plans',
            message: 'Failed to load provider plans. Please try again.',
            buttonText: 'Retry',
            onButtonPressed: () => setState(() {}),
          );
        }

        final plans = snapshot.data ?? [];
        if (plans.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.description,
            title: 'No Plans Available',
            message: 'This provider has no active plans at the moment.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(plan['name']),
                subtitle: Text(plan['coverage']),
                trailing: Text(
                  '\$${plan['price']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/plan-details',
                  arguments: plan['id'],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHospitalsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: context.read<ProviderService>().getProviderHospitals(widget.providerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Error Loading Hospitals',
            message: 'Failed to load provider hospitals. Please try again.',
            buttonText: 'Retry',
            onButtonPressed: () => setState(() {}),
          );
        }

        final hospitals = snapshot.data ?? [];
        if (hospitals.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.local_hospital,
            title: 'No Hospitals Available',
            message: 'This provider has no affiliated hospitals at the moment.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: hospitals.length,
          itemBuilder: (context, index) {
            final hospital = hospitals[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(hospital['name']),
                subtitle: Text('${hospital['city']}, ${hospital['state']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[700]),
                    const SizedBox(width: 4),
                    Text(
                      hospital['rating'].toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/hospital-details',
                  arguments: hospital['id'],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: context.read<ProviderService>().getProviderReviews(widget.providerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Error Loading Reviews',
            message: 'Failed to load provider reviews. Please try again.',
            buttonText: 'Retry',
            onButtonPressed: () => setState(() {}),
          );
        }

        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.rate_review,
            title: 'No Reviews Yet',
            message: 'Be the first to review this provider.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: review['user']['avatar'] != null
                              ? NetworkImage(review['user']['avatar'])
                              : null,
                          child: review['user']['avatar'] == null
                              ? Text(
                                  review['user']['firstName'][0],
                                  style: const TextStyle(fontSize: 20),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${review['user']['firstName']} ${review['user']['lastName']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                DateTime.parse(review['createdAt'])
                                    .toLocal()
                                    .toString()
                                    .split('.')[0],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber[700]),
                            const SizedBox(width: 4),
                            Text(
                              review['rating'].toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (review['comment'] != null) ...[
                      const SizedBox(height: 12),
                      Text(review['comment']),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
} 