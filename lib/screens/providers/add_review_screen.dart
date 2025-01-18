import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/provider_service.dart';
import '../../widgets/loading_widget.dart';

class AddReviewScreen extends StatefulWidget {
  final String providerId;
  final String providerName;

  const AddReviewScreen({
    Key? key,
    required this.providerId,
    required this.providerName,
  }) : super(key: key);

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      setState(() => _error = 'Please select a rating');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await context.read<ProviderService>().addProviderReview(
        widget.providerId,
        rating: _rating,
        comment: _commentController.text.isNotEmpty ? _commentController.text : null,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${widget.providerName}'),
      ),
      body: _isSubmitting
          ? const LoadingWidget(message: 'Submitting review...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'How would you rate your experience?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      return IconButton(
                        icon: Icon(
                          rating <= _rating ? Icons.star : Icons.star_border,
                          size: 40,
                          color: rating <= _rating ? Colors.amber[700] : Colors.grey,
                        ),
                        onPressed: () => setState(() => _rating = rating),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _commentController,
                    maxLines: 5,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      labelText: 'Write your review (optional)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Share your experience with this provider...',
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitReview,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Review',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 