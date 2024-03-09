import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  /// The variable from `.env` file.
  @EnviedField(varName: 'OPEN_AI_API_KEY')
  static const String apiKey = _Env.apiKey;
  @EnviedField(varName: 'SUPPORT_EMAIL')
  static const String supportEmail = _Env.supportEmail;
}
