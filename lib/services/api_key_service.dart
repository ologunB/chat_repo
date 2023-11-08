import 'app_provisioning.dart';
import 'constants.dart';

class ApiKeyService {
  // ignore: do_not_use_environment
  static const envKey = String.fromEnvironment(Constants.ablyApiKey);
  static const apiKey =
      '9hmcFw.VOIRxg:2ZN1S8tYYmNrjlrfWzA5s22x6tTq-FzxoUUuvGSS3Y4';

  Future<ApiKeyProvision> getOrProvisionApiKey() async {
    if (apiKey.isNotEmpty) {
      final tokenData = await AppProvisioning().getToken(apiKey.split(':'));
      print(tokenData);
      return ApiKeyProvision(
        token: tokenData,
        source: ApiKeySource.env,
      );
    } else {
      final provisionedKey = await AppProvisioning().provisionApp();
      return ApiKeyProvision(
        key: provisionedKey,
        source: ApiKeySource.testProvision,
      );
    }
  }
}

class ApiKeyProvision {
  String? key;

  ApiKeySource? source;
  dynamic? token;

  ApiKeyProvision({this.key, this.source, this.token});
}

enum ApiKeySource { env, testProvision }
