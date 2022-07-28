import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uni_links/uni_links.dart';

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initUniLinks();
    });
  }

  Future<void> initUniLinks() async {
    try {
      final Uri? uri = await getInitialUri();
      if (uri != null) {
        Map<String, String> parameters = uri.queryParameters;
        debugPrint("uri.queryParameters=$parameters");
        if (parameters.containsKey("app_link")) {
          var appLink = parameters['app_link']!;
          debugPrint("app_link=$appLink");
          appLink = Uri.decodeFull(appLink);
          debugPrint("decoded=$appLink");
        }
      }
      // Use the uri and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on FormatException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }
}
