import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'GOOGLE_API_KEY', obfuscate: true)
  static final String googleApiKey = _Env.googleApiKey;
  @EnviedField(varName: 'JWT_SOCIEATY_SECRET_KEY')
  static final String jwtSocieatySecretKey = _Env.jwtSocieatySecretKey;
}
