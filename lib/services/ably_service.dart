import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter/ably_flutter.dart';

import 'api_key_service.dart';
import 'constants.dart';

class AblyService {
  late final ably.Realtime realtime;
  // late final ably.Rest rest;
  // late final PushNotificationService pushNotificationService;
  late final ApiKeyProvision apiKeyProvision;

  AblyService({required this.apiKeyProvision}) {
    realtime = ably.Realtime(
      options: ably.ClientOptions(
        logLevel: ably.LogLevel.verbose,
        environment: apiKeyProvision.source == ApiKeySource.env
            ? null
            : Constants.sandboxEnvironment,
        autoConnect: false,
        tokenDetails: TokenDetails.fromMap(apiKeyProvision.token),
      ),
    );
/*    rest = ably.Rest(
      options: ably.ClientOptions(
        key: apiKeyProvision.key,
        clientId: Constants.clientId,
        logLevel: ably.LogLevel.verbose,
        environment: apiKeyProvision.source == ApiKeySource.env
            ? null
            : Constants.sandboxEnvironment,
      ),
    );*/
    //   pushNotificationService = PushNotificationService(realtime, rest);
  }
}
