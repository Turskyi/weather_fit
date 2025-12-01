import 'package:mocktail/mocktail.dart';
import 'package:weather_fit/services/home_widget_service.dart';

class MockHomeWidgetService extends Mock implements HomeWidgetService {
  // Cannot be `const` because of the `Mock`.
  MockHomeWidgetService();
}
