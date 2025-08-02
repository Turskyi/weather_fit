import 'package:weather_fit/entities/enums/feedback_rating.dart';
import 'package:weather_fit/entities/enums/feedback_type.dart';
import 'package:weather_fit/res/constants.dart' as constants;

/// A data type holding user feedback consisting of a feedback type, free from
/// feedback text, and a sentiment rating.
class FeedbackDetails {
  const FeedbackDetails({this.feedbackType, this.feedbackText, this.rating});

  final FeedbackType? feedbackType;
  final String? feedbackText;
  final FeedbackRating? rating;

  @override
  String toString() {
    return <String, String?>{
      if (rating != null) constants.ratingProperty: rating.toString(),
      constants.feedbackTypeProperty: feedbackType.toString(),
      constants.feedbackTextProperty: feedbackText,
    }.toString();
  }

  /// Creates a new [FeedbackDetails] instance with optional new values.
  ///
  /// If a parameter is not provided, the value from the original object is
  /// used.
  FeedbackDetails copyWith({
    FeedbackType? feedbackType,
    String? feedbackText,
    FeedbackRating? rating,
  }) {
    return FeedbackDetails(
      feedbackType: feedbackType ?? this.feedbackType,
      feedbackText: feedbackText ?? this.feedbackText,
      rating: rating ?? this.rating,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (rating != null) constants.ratingProperty: rating,
      constants.feedbackTypeProperty: feedbackType,
      constants.feedbackTextProperty: feedbackText,
    };
  }
}
