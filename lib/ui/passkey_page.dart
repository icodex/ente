import 'dart:convert';

import 'package:ente_auth/core/configuration.dart';
import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PasskeyPage extends StatefulWidget {
  final String sessionID;
  final String userPassword;
  final Uint8List keyEncryptionKey;

  const PasskeyPage(
    this.sessionID, {
    Key? key,
    required this.userPassword,
    required this.keyEncryptionKey,
  }) : super(key: key);

  @override
  State<PasskeyPage> createState() => _PasskeyPageState();
}

class _PasskeyPageState extends State<PasskeyPage> {
  final Logger _logger = Logger("PasskeyPage");

  @override
  void initState() {
    launchPasskey();
    _initDeepLinks();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> launchPasskey() async {
    await launchUrlString(
      "https://accounts.ente.io/passkeys/flow?"
      "passkeySessionID=${widget.sessionID}"
      "&redirect=enteauth://passkey",
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _handleDeeplink(String? link) async {
    if (Configuration.instance.hasConfiguredAccount() ||
        link == null ||
        !context.mounted) {
      return;
    }
    if (mounted && link.toLowerCase().startsWith("enteauth://passkey")) {
      final uri = Uri.parse(link).queryParameters['response'];

      // response to json
      final res = utf8.decode(base64.decode(uri!));
      final json = jsonDecode(res) as Map<String, dynamic>;

      await UserService.instance.acceptPasskey(
        context,
        json,
        widget.userPassword,
        widget.keyEncryptionKey,
      );
    }
  }

  Future<bool> _initDeepLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final String? initialLink = await getInitialLink();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      if (initialLink != null) {
        _handleDeeplink(initialLink);
        return true;
      } else {
        _logger.info("No initial link received.");
      }
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
      _logger.severe("PlatformException thrown while getting initial link");
    }

    // Attach a listener to the stream
    linkStream.listen(
      _handleDeeplink,
      onError: (err) {
        _logger.severe(err);
      },
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.twoFactorAuthTitle,
        ),
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    final l10n = context.l10n;

    return Center(
      child: Text(
        l10n.waitingForBrowserRequest,
        style: const TextStyle(
          height: 1.4,
          fontSize: 16,
        ),
      ),
    );
  }
}
