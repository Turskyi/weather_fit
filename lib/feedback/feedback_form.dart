import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/enums/feedback_rating.dart';
import 'package:weather_fit/entities/enums/feedback_type.dart';
import 'package:weather_fit/entities/models/feedback_details.dart';

/// A form that prompts the user for the type of feedback they want to give,
/// free form text feedback, and a sentiment rating.
/// The submit button is disabled until the user provides the feedback type. All
/// other fields are optional.
class FeedbackForm extends StatefulWidget {
  const FeedbackForm({
    required this.onSubmit,
    required this.scrollController,
    super.key,
  });

  final OnSubmit onSubmit;
  final ScrollController? scrollController;

  @override
  State<FeedbackForm> createState() => _CustomFeedbackFormState();
}

class _CustomFeedbackFormState extends State<FeedbackForm> {
  FeedbackDetails _customFeedback = const FeedbackDetails();

  @override
  Widget build(BuildContext _) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              if (widget.scrollController != null)
                const FeedbackSheetDragHandle(),
              ListView(
                controller: widget.scrollController,
                // Pad the top by 20 to match the corner radius if drag is
                // enabled.
                padding: EdgeInsets.fromLTRB(
                  16,
                  widget.scrollController != null ? 20 : 16,
                  16,
                  0,
                ),
                children: <Widget>[
                  Text(translate('feedback.what_kind')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text('*'),
                      ),
                      Flexible(
                        child: DropdownButton<FeedbackType>(
                          value: _customFeedback.feedbackType,
                          items: FeedbackType.values.map(
                            (FeedbackType type) {
                              return DropdownMenuItem<FeedbackType>(
                                value: type,
                                child: Text(type.value),
                              );
                            },
                          ).toList(),
                          onChanged: (FeedbackType? feedbackType) => setState(
                            () => _customFeedback = _customFeedback.copyWith(
                              feedbackType: feedbackType,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(translate('feedback.what_is_your_feedback')),
                  TextField(
                    onChanged: (String newFeedback) => _customFeedback =
                        _customFeedback.copyWith(feedbackText: newFeedback),
                  ),
                  const SizedBox(height: 16),
                  Text(translate('feedback.how_does_this_feel')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: FeedbackRating.values.map(_ratingToIcon).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
        TextButton(
          // disable this button until the user has specified a feedback type
          onPressed: _customFeedback.feedbackType != null
              ? () => widget.onSubmit(
                    _customFeedback.feedbackText ?? '',
                    extras: _customFeedback.toMap(),
                  )
              : null,
          child: Text(translate('submit')),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _ratingToIcon(FeedbackRating rating) {
    final bool isSelected = _customFeedback.rating == rating;
    late IconData icon;
    switch (rating) {
      case FeedbackRating.bad:
        icon = Icons.sentiment_dissatisfied;
        break;
      case FeedbackRating.neutral:
        icon = Icons.sentiment_neutral;
        break;
      case FeedbackRating.good:
        icon = Icons.sentiment_satisfied;
        break;
    }
    return IconButton(
      color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey,
      onPressed: () => setState(
        () => _customFeedback = _customFeedback.copyWith(rating: rating),
      ),
      icon: Icon(icon),
      iconSize: 36,
    );
  }
}
