import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'How do I make a claim?',
      'answer':
          'To make a claim, go to the Claims section in the app and fill out the claim form. You\'ll need to provide details about the service and upload relevant documents.',
    },
    {
      'question': 'What hospitals are covered under my plan?',
      'answer':
          'You can view all covered hospitals in the Find Hospital section. Your Premium Health Plan covers all major hospitals in our network.',
    },
    {
      'question': 'How do I book an appointment?',
      'answer':
          'Use the Book Appointment feature in the app to schedule appointments with doctors and specialists in our network.',
    },
    {
      'question': 'What is the waiting period for new members?',
      'answer':
          'The standard waiting period is 30 days for new members. However, emergency services are covered immediately.',
    },
    {
      'question': 'How do I add dependents to my plan?',
      'answer':
          'You can add dependents through your profile settings. Additional charges may apply based on your plan type.',
    },
    {
      'question': 'What is not covered by my plan?',
      'answer':
          'Certain cosmetic procedures, experimental treatments, and non-medical services are not covered. Check your plan details for full information.',
    },
    {
      'question': 'How do I renew my plan?',
      'answer':
          'Plans are automatically renewed annually. You\'ll receive a notification 30 days before renewal.',
    },
    {
      'question': 'What should I do in an emergency?',
      'answer':
          'In case of emergency, visit the nearest hospital and call our 24/7 emergency line at 0800-CARELINK.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search FAQs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // FAQ List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        faqs[index]['question']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            faqs[index]['answer']!,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 