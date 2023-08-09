import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:twilio_voice_mimp/twilio_voice.dart';
import 'call_screen.dart';
import 'firebase_options.dart';
import 'ui/common/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: DialScreen());
  }
}

class DialScreen extends StatefulWidget {
  @override
  _DialScreenState createState() => _DialScreenState();
}

class _DialScreenState extends State<DialScreen> with WidgetsBindingObserver {
  final TextEditingController _controller =
      TextEditingController(text: "live_ihs_9136");
  late String userId;

  registerUser() {
    log("voip- service init");
    // if (TwilioVoice.instance.deviceToken != null) {
    //   log("device token changed");
    // }

    register();

    TwilioVoice.instance.setOnDeviceTokenChanged((token) {
      log("voip-device token changed");
      register();
    });
  }

  register() async {
    log("voip-registtering with token ");
    log("voip-calling voice-accessToken");
    // final function =
    //     FirebaseFunctions.instance.httpsCallable("voice-accessToken");

    // final data = {
    //   "platform": Platform.isIOS ? "iOS" : "Android",
    // };

    // final result = await function.call(data);
    log("voip-result");
    // log(result.data);
    String? androidToken;
    if (Platform.isAndroid) {
      androidToken = await FirebaseMessaging.instance.getToken();
      log("androidToken is ${androidToken!}");
    }
    TwilioVoice.instance
        .setTokens(accessToken: accessToken, deviceToken: androidToken);
  }

  var registered = false;
  waitForLogin() {
    final auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((user) async {
      log("authStateChanges $user");
      if (user == null) {
        log("user is anonomous");
        await auth.signInAnonymously();
      } else if (!registered) {
        registered = true;
        userId = user.uid;
        log("registering user ${user.uid}");
        registerUser();

        FirebaseMessaging.instance.requestPermission();
        // FirebaseMessaging.instance.configure(
        //     onMessage: (Map<String, dynamic> message) {
        //   log("onMessage");
        //   log(message);
        //   return;
        // }, onLaunch: (Map<String, dynamic> message) {
        //   log("onLaunch");
        //   log(message);
        //   return;
        // }, onResume: (Map<String, dynamic> message) {
        //   log("onResume");
        //   log(message);
        //   return;
        // });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    waitForLogin();

    super.initState();
    waitForCall();
    WidgetsBinding.instance.addObserver(this);

    const partnerId = "alicesId";
    TwilioVoice.instance.registerClient(partnerId, "Alice");
  }

  checkActiveCall() async {
    final isOnCall = await TwilioVoice.instance.call.isOnCall();
    log("checkActiveCall $isOnCall");
    if (isOnCall &&
        !hasPushedToCall &&
        TwilioVoice.instance.call.activeCall?.callDirection ==
            CallDirection.incoming) {
      log("user is on call");
      pushToCallScreen();
      hasPushedToCall = true;
    }
  }

  var hasPushedToCall = false;

  void waitForCall() {
    checkActiveCall();
    TwilioVoice.instance.callEventsListener.listen((event) {
      log("voip-onCallStateChanged=> ${event}");
      switch (event) {
        case CallEvent.answer:
          //at this point android is still paused
          if (Platform.isIOS && state == null ||
              state == AppLifecycleState.resumed) {
            pushToCallScreen();
            hasPushedToCall = true;
          }
          break;
        case CallEvent.ringing:
          final activeCall = TwilioVoice.instance.call.activeCall;
          if (activeCall != null) {
            final customData = activeCall.customParams;
            if (customData != null) {
              log("voip-customData $customData");
            }
          }
          break;
        case CallEvent.connected:
          if (Platform.isAndroid &&
              TwilioVoice.instance.call.activeCall!.callDirection ==
                  CallDirection.incoming) {
            if (state != AppLifecycleState.resumed) {
              TwilioVoice.instance.showBackgroundCallUI();
            } else if (state == null || state == AppLifecycleState.resumed) {
              pushToCallScreen();
              hasPushedToCall = true;
            }
          }
          break;
        case CallEvent.callEnded:
          hasPushedToCall = false;
          break;
        case CallEvent.returningCall:
          pushToCallScreen();
          hasPushedToCall = true;
          break;
        default:
          log(event.name.toString());

          break;
      }
    });
  }

  AppLifecycleState? state;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    this.state = state;
    log("didChangeAppLifecycleState");
    if (state == AppLifecycleState.resumed) {
      checkActiveCall();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _controller,
                  decoration: const InputDecoration(
                      labelText: 'Client Identifier or Phone Number'),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  child: const Text("Make Call"),
                  onPressed: () async {
                    if (!await (TwilioVoice.instance.hasMicAccess())) {
                      log("request mic access");
                      TwilioVoice.instance.requestMicAccess();
                      return;
                    }
                    log("starting call to ${_controller.text}");
                    TwilioVoice.instance.call
                        .place(to: _controller.text, from: userId);
                    pushToCallScreen();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void pushToCallScreen() {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        fullscreenDialog: true, builder: (context) => CallScreen()));
  }
}
