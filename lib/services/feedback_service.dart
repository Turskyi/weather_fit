import 'package:resend/resend.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;

abstract class FeedbackService {
  const FeedbackService();

  Future<void> sendAutomaticFeedback({
    required String subject,
    required String text,
  });
}

class FeedbackServiceImpl implements FeedbackService {
  const FeedbackServiceImpl();

  @override
  Future<void> sendAutomaticFeedback({
    required String subject,
    required String text,
  }) {
    return Resend.instance.sendEmail(
      from: constants.feedbackEmailSender,
      to: <String>[constants.kSupportEmail],
      subject: subject,
      text: text,
    );
  }
}
