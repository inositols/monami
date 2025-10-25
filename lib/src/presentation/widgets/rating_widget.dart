import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monami/src/data/remote/rating_service.dart';

/// Widget for displaying and submitting product ratings
class RatingWidget extends StatefulWidget {
  final String productId;
  final double currentRating;
  final int reviewCount;
  final bool isReadOnly;
  final Function(double rating, String? review)? onRatingSubmitted;

  const RatingWidget({
    Key? key,
    required this.productId,
    required this.currentRating,
    required this.reviewCount,
    this.isReadOnly = false,
    this.onRatingSubmitted,
  }) : super(key: key);

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  final RatingService _ratingService = RatingService();
  final TextEditingController _reviewController = TextEditingController();
  
  double _selectedRating = 0.0;
  bool _isSubmitting = false;
  bool _hasUserRated = false;
  Map<String, dynamic>? _userRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.currentRating;
    _checkUserRating();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _checkUserRating() async {
    try {
      final userRating = await _ratingService.getUserRating(widget.productId);
      if (userRating != null) {
        setState(() {
          _hasUserRated = true;
          _userRating = userRating;
          _selectedRating = (userRating['rating'] as num).toDouble();
          _reviewController.text = userRating['review'] ?? '';
        });
      }
    } catch (e) {
      print('Error checking user rating: $e');
    }
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a rating',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      bool success;
      if (_hasUserRated && _userRating != null) {
        // Update existing rating
        success = await _ratingService.updateRating(
          ratingId: _userRating!['id'],
          rating: _selectedRating,
          review: _reviewController.text.trim().isEmpty ? null : _reviewController.text.trim(),
        );
      } else {
        // Submit new rating
        success = await _ratingService.submitRating(
          productId: widget.productId,
          rating: _selectedRating,
          review: _reviewController.text.trim().isEmpty ? null : _reviewController.text.trim(),
        );
      }

      if (success) {
        setState(() {
          _hasUserRated = true;
        });

        if (widget.onRatingSubmitted != null) {
          widget.onRatingSubmitted!(_selectedRating, _reviewController.text.trim());
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _hasUserRated ? 'Rating updated successfully!' : 'Rating submitted successfully!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green.shade400,
          ),
        );
      } else {
        throw Exception('Failed to submit rating');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error submitting rating: ${e.toString()}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _deleteRating() async {
    if (_userRating == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _ratingService.deleteRating(_userRating!['id']);
      
      if (success) {
        setState(() {
          _hasUserRated = false;
          _userRating = null;
          _selectedRating = 0.0;
          _reviewController.clear();
        });

        if (widget.onRatingSubmitted != null) {
          widget.onRatingSubmitted!(0.0, null);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rating deleted successfully!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green.shade400,
          ),
        );
      } else {
        throw Exception('Failed to delete rating');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting rating: ${e.toString()}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _hasUserRated ? 'Your Rating' : 'Rate this Product',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3748),
                ),
              ),
              if (_hasUserRated)
                TextButton(
                  onPressed: _isSubmitting ? null : _deleteRating,
                  child: Text(
                    'Delete',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Star Rating
          Row(
            children: [
              Text(
                'Rating:',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(width: 12),
              if (!widget.isReadOnly)
                Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        if (!widget.isReadOnly) {
                          setState(() {
                            _selectedRating = (index + 1).toDouble();
                          });
                        }
                      },
                      child: Icon(
                        index < _selectedRating.floor()
                            ? Icons.star
                            : Icons.star_outline,
                        color: Colors.orange,
                        size: 28,
                      ),
                    );
                  }),
                )
              else
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < _selectedRating.floor()
                          ? Icons.star
                          : Icons.star_outline,
                      color: Colors.orange,
                      size: 20,
                    );
                  }),
                ),
              const SizedBox(width: 8),
              Text(
                _selectedRating.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Review Text Field
          if (!widget.isReadOnly) ...[
            Text(
              'Review (Optional):',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your experience with this product...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _hasUserRated ? 'Update Rating' : 'Submit Rating',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ] else if (_reviewController.text.isNotEmpty) ...[
            Text(
              'Your Review:',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                _reviewController.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}



