import 'package:home_widget/home_widget.dart';

abstract class HomeWidgetService {
  const HomeWidgetService();

  Future<void> setAppGroupId(String appGroupId);

  Future<bool?> saveWidgetData<T>(String id, T? data);

  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  });
}

class HomeWidgetServiceImpl implements HomeWidgetService {
  const HomeWidgetServiceImpl();

  @override
  Future<void> setAppGroupId(String appGroupId) {
    return HomeWidget.setAppGroupId(appGroupId);
  }

  @override
  Future<bool?> saveWidgetData<T>(String id, T? data) {
    return HomeWidget.saveWidgetData<T>(id, data);
  }

  @override
  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) {
    return HomeWidget.updateWidget(iOSName: iOSName, androidName: androidName);
  }
}
