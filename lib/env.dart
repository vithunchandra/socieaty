import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env') // Specify the path to your .env file
abstract class Env {
  @EnviedField(varName: 'GOOGLE_API_KEY', obfuscate: true)
  static final String googleApiKey = _Env.googleApiKey; // Use obfuscate: true for extra security (optional)
  @EnviedField(varName: 'JWT_SOCIEATY_SECRET_KEY')
  static final String jwtSocieatySecretKey = _Env.jwtSocieatySecretKey;
}
