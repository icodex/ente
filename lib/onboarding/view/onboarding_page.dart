import 'dart:async';

import 'package:ente_auth/app/view/app.dart';
import 'package:ente_auth/core/configuration.dart';
import 'package:ente_auth/core/event_bus.dart';
import 'package:ente_auth/ente_theme_data.dart';
import 'package:ente_auth/events/trigger_logout_event.dart';
import "package:ente_auth/l10n/l10n.dart";
import 'package:ente_auth/locale.dart';
import 'package:ente_auth/services/user_service.dart';
import 'package:ente_auth/theme/text_style.dart';
import 'package:ente_auth/ui/account/email_entry_page.dart';
import 'package:ente_auth/ui/account/login_page.dart';
import 'package:ente_auth/ui/account/logout_dialog.dart';
import 'package:ente_auth/ui/account/password_entry_page.dart';
import 'package:ente_auth/ui/account/password_reentry_page.dart';
import 'package:ente_auth/ui/common/gradient_button.dart';
import 'package:ente_auth/ui/components/buttons/button_widget.dart';
import 'package:ente_auth/ui/components/models/button_result.dart';
import 'package:ente_auth/ui/home_page.dart';
import 'package:ente_auth/ui/settings/language_picker.dart';
import 'package:ente_auth/utils/dialog_util.dart';
import 'package:ente_auth/utils/navigation_util.dart';
import 'package:ente_auth/utils/toast_util.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logging/logging.dart';
import 'package:uni_links/uni_links.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late StreamSubscription<TriggerLogoutEvent> _triggerLogoutEvent;
  final Logger _logger = Logger("OnboardingPage");

  @override
  void initState() {
    _triggerLogoutEvent =
        Bus.instance.on<TriggerLogoutEvent>().listen((event) async {
      await autoLogoutAlert(context);
    });
    _initDeepLinks();
    super.initState();
  }

  void _handleDeeplink(BuildContext context, String? link) {
    if (!Configuration.instance.hasConfiguredAccount() || link == null) {
      return;
    }
    if (mounted && link.toLowerCase().startsWith("enteauth://passkey")) {
      final res = <String, dynamic>{};
      final uri = Uri.parse(link).queryParameters['response'];

      // response to json
      final json = Uri.decodeComponent(uri!);
      final split = json.split("&");
      for (final s in split) {
        final kv = s.split("=");
        res[kv[0]] = kv[1];
      }

      UserService.instance.acceptPasskey(res);
    }
  }

  Future<bool> _initDeepLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final String? initialLink = await getInitialLink();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      if (initialLink != null) {
        _handleDeeplink(context, initialLink);
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
      (String? link) {
        _handleDeeplink(context, link);
      },
      onError: (err) {
        _logger.severe(err);
      },
    );
    return false;
  }

  @override
  void dispose() {
    _triggerLogoutEvent.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building OnboardingPage");
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints.tightFor(height: 800, width: 450),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40),
                child: Column(
                  children: [
                    Column(
                      children: [
                        kDebugMode
                            ? GestureDetector(
                                child: const Align(
                                  alignment: Alignment.topRight,
                                  child: Text("Lang"),
                                ),
                                onTap: () async {
                                  final locale = await getLocale();
                                  routeToPage(
                                    context,
                                    LanguageSelectorPage(
                                      appSupportedLocales,
                                      (locale) async {
                                        await setLocale(locale);
                                        App.setLocale(context, locale);
                                      },
                                      locale,
                                    ),
                                  ).then((value) {
                                    setState(() {});
                                  });
                                },
                              )
                            : const SizedBox(),
                        Image.asset(
                          "assets/sheild-front-gradient.png",
                          width: 200,
                          height: 200,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "ente",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            fontSize: 42,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Authenticator",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          l10n.onBoardingBody,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Colors.white38,
                                    // color: Theme.of(context)
                                    //                            .colorScheme
                                    //                            .mutedTextColor,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GradientButton(
                        onTap: _navigateToSignUpPage,
                        text: l10n.newUser,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Hero(
                        tag: "log_in",
                        child: ElevatedButton(
                          style: Theme.of(context)
                              .colorScheme
                              .optionalActionButtonStyle,
                          onPressed: _navigateToSignInPage,
                          child: Text(
                            l10n.existingUser,
                            style: const TextStyle(
                              color: Colors.black, // same for both themes
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: GestureDetector(
                        onTap: _optForOfflineMode,
                        child: Center(
                          child: Text(
                            l10n.useOffline,
                            style: body.copyWith(
                              color:
                                  Theme.of(context).colorScheme.mutedTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _optForOfflineMode() async {
    bool canCheckBio = await LocalAuthentication().canCheckBiometrics;
    if (!canCheckBio) {
      showToast(
        context,
        "Sorry, biometric authentication is not supported on this device.",
      );
      return;
    }
    final bool hasOptedBefore = Configuration.instance.hasOptedForOfflineMode();
    ButtonResult? result;
    if (!hasOptedBefore) {
      result = await showChoiceActionSheet(
        context,
        title: context.l10n.warning,
        body: context.l10n.offlineModeWarning,
        secondButtonLabel: context.l10n.cancel,
        firstButtonLabel: context.l10n.ok,
      );
    }
    if (hasOptedBefore || result?.action == ButtonAction.first) {
      await Configuration.instance.optForOfflineMode();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const HomePage();
          },
        ),
      );
    }
  }

  void _navigateToSignUpPage() {
    Widget page;
    if (Configuration.instance.getEncryptedToken() == null) {
      page = const EmailEntryPage();
    } else {
      // No key
      if (Configuration.instance.getKeyAttributes() == null) {
        // Never had a key
        page = const PasswordEntryPage(
          mode: PasswordEntryMode.set,
        );
      } else if (Configuration.instance.getKey() == null) {
        // Yet to decrypt the key
        page = const PasswordReentryPage();
      } else {
        // All is well, user just has not subscribed
        page = const HomePage();
      }
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }

  void _navigateToSignInPage() {
    Widget page;
    if (Configuration.instance.getEncryptedToken() == null) {
      page = const LoginPage();
    } else {
      // No key
      if (Configuration.instance.getKeyAttributes() == null) {
        // Never had a key
        page = const PasswordEntryPage(
          mode: PasswordEntryMode.set,
        );
      } else if (Configuration.instance.getKey() == null) {
        // Yet to decrypt the key
        page = const PasswordReentryPage();
      } else {
        // All is well, user just has not subscribed
        // page = getSubscriptionPage(isOnBoarding: true);
        page = const HomePage();
      }
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }
}
