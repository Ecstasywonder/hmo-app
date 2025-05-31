import 'package:flutter/material.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'General',
    'Plans & Coverage',
    'Claims',
    'Providers',
    'Billing',
    'Technical Support',
  ];

  // This would typically come from an API
  final List<Map<String, dynamic>> _faqs = [
    {
      'category': 'General',
      'question': 'What is HMO insurance?',
      'answer':
          'HMO (Health Maintenance Organization) insurance is a type of healthcare coverage that typically requires you to select a primary care physician and get referrals to see specialists. HMOs generally have lower out-of-pocket costs but require you to use providers within their network.',
    },
    {
      'category': 'Plans & Coverage',
      'question': 'How do I know what services are covered?',
      'answer':
          'Your covered services are detailed in your plan documents. You can also log into your member portal to view your benefits summary or contact our customer service team for specific coverage questions.',
    },
    {
      'category': 'Claims',
      'question': 'How do I submit a claim?',
      'answer':
          'Most claims are submitted directly by your healthcare provider. If you need to submit a claim yourself, you can do so through the member portal or by completing a claim form and mailing it to our claims department.',
    },
    // Add more FAQs here
  ];

  List<Map<String, dynamic>> get _filteredFaqs {
    final searchTerm = _searchController.text.toLowerCase();
    return _faqs.where((faq) {
      final matchesCategory =
          _selectedCategory == 'All' || faq['category'] == _selectedCategory;
      final matchesSearch = searchTerm.isEmpty ||
          faq['question'].toLowerCase().contains(searchTerm) ||
          faq['answer'].toLowerCase().contains(searchTerm);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search FAQs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedCategory = category);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredFaqs.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.help_outline,
                    title: 'No FAQs Found',
                    message:
                        'Try adjusting your search or category to find relevant FAQs.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFaqs.length,
              itemBuilder: (context, index) {
                      final faq = _filteredFaqs[index];
                return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      title: Text(
                            faq['question'],
                        style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            faq['category'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                        ),
                      ),
                      children: [
                        Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(faq['answer']),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.thumb_up_outlined),
                                        label: const Text('Helpful'),
                                        onPressed: () {
                                          // TODO: Implement feedback
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Thank you for your feedback!'),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        icon: const Icon(Icons.share),
                                        label: const Text('Share'),
                                        onPressed: () {
                                          // TODO: Implement sharing
                                        },
                                      ),
                                    ],
                        ),
                      ],
                    ),
                            ),
                          ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/support/ticket', arguments: {
            'type': 'question',
            'subject': 'FAQ Question',
          });
        },
        icon: const Icon(Icons.help_outline),
        label: const Text('Ask a Question'),
      ),
    );
  }
} 