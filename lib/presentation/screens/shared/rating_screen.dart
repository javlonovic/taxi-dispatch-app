import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/rating_provider.dart';
import '../../widgets/star_rating_widget.dart';

/// Rating screen for submitting ratings after ride completion
class RatingScreen extends ConsumerStatefulWidget {
  final String rideId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final bool isRatingDriver;

  const RatingScreen({
    Key? key,
    required this.rideId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    required this.isRatingDriver,
  }) : super(key: key);

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  double _rating = 0.0;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    final notifier = ref.read(submitRatingProvider(widget.rideId).notifier);
    await notifier.submitRating(_rating, _feedbackController.text.trim());

    final state = ref.read(submitRatingProvider(widget.rideId));
    
    if (mounted) {
      state.when(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rating submitted successfully')),
          );
          Navigator.of(context).pop(true);
        },
        loading: () {},
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit rating: $error')),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(submitRatingProvider(widget.rideId));
    final isLoading = submitState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Experience'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // User avatar
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.otherUserPhotoUrl != null
                  ? NetworkImage(widget.otherUserPhotoUrl!)
                  : null,
              child: widget.otherUserPhotoUrl == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            
            const SizedBox(height: 16),
            
            // User name
            Text(
              widget.otherUserName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            
            const SizedBox(height: 8),
            
            // Rating prompt
            Text(
              widget.isRatingDriver
                  ? 'How was your driver?'
                  : 'How was your experience?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            
            const SizedBox(height: 32),
            
            // Star rating
            StarRatingWidget(
              rating: _rating,
              onRatingChanged: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
              size: 48,
              interactive: true,
            ),
            
            const SizedBox(height: 40),
            
            // Feedback text field
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: 'Additional Feedback (Optional)',
                hintText: 'Share your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Rating',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Skip button
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }
}
