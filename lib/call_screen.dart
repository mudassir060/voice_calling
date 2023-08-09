import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:twilio_voice_mimp/twilio_voice.dart';

class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  var speaker = false;
  var mute = false;
  var isHolding = false;
  var isBluetoothOn = false;
  var isEnded = false;

  String message = "";
  late StreamSubscription<CallEvent> callStateListener;

  void listenCall() {
    callStateListener = TwilioVoice.instance.callEventsListener.listen((event) {
      log("voip-onCallStateChanged $event");
      switch (event) {
        case CallEvent.callEnded:
          log("call Ended");
          if (!isEnded) {
            isEnded = true;
            Navigator.of(context).pop();
          }
          break;
        case CallEvent.mute:
          log("received mute");
          setState(() {
            mute = true;
          });
          break;
        case CallEvent.connected:
          log("call connected");
          setState(() {
            message = "Connected!";
          });
          break;
        case CallEvent.unmute:
          log("received unmute");
          setState(() {
            mute = false;
          });
          break;
        case CallEvent.speakerOn:
          log("received speakerOn");
          setState(() {
            speaker = true;
          });
          break;
        case CallEvent.speakerOff:
          log("received speakerOf");
          setState(() {
            speaker = false;
          });
          break;
        case CallEvent.ringing:
          log("ringing");
          setState(() {
            message = "Ringing...";
          });
          break;
        case CallEvent.declined:
          setState(() {
            message = "Declined";
          });
          if (!isEnded) {
            isEnded = true;
            Navigator.of(context).pop();
          }
          break;
        case CallEvent.answer:
          log("call answered");
          final activeCall = TwilioVoice.instance.call.activeCall;
          if (activeCall != null &&
              activeCall.callDirection == CallDirection.incoming) {
            setState(() {
              message = "Answered";
            });
          }
          break;
        case CallEvent.hold:
        case CallEvent.log:
        case CallEvent.unhold:
          break;
        default:
          break;
      }
    });
  }

  late String caller;

  String getCaller() {
    final activeCall = TwilioVoice.instance.call.activeCall;
    if (activeCall != null) {
      return activeCall.callDirection == CallDirection.outgoing
          ? activeCall.toFormatted
          : activeCall.fromFormatted;
    }
    return "Unknown";
  }

  @override
  void initState() {
    super.initState();
    message = "Connecting...";
    listenCall();
    caller = getCaller();
    _loadCallState();
  }

  Future<void> _loadCallState() async {
    await Future.wait([
      _updateMuteState(),
      _updateSpeakerState(),
      _updateHoldState(),
      // _updateBluetoothState(),
    ]);
  }

  Future<void> _updateMuteState() async {
    // final isMuted = await TwilioVoice.instance.call.isMuted();
    setState(() {
      mute = !mute;
    });
  }

  Future<void> _updateSpeakerState() async {
    // TwilioVoice.instance.call.isOnSpeaker().then((value) {
    //   setState(() {
    //     speaker = value ?? false;
    //   });
    // });
  }

  Future<void> _updateHoldState() async {
    // final isHolding = await TwilioVoice.instance.call.isHolding();
    // setState(() {
    //   this.isHolding = isHolding ?? false;
    // });
  }

  // Future<void> _updateBluetoothState() async {
  //   final isBluetoothOn = await TwilioVoice.instance.call.isBluetoothOn();
  //   setState(() {
  //     this.isBluetoothOn = isBluetoothOn ?? false;
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
    callStateListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Call Screen"),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: Container(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        caller,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Material(
                          type: MaterialType
                              .transparency, //Makes it usable on any background color, thanks @IanSmith
                          child: Ink(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white, width: 1.0),
                              color: speaker
                                  ? Theme.of(context).primaryColor
                                  : Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              //This keeps the splash effect within the circle
                              borderRadius: BorderRadius.circular(
                                  1000.0), //Something large to ensure a circle
                              child: const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.volume_up,
                                  size: 40.0,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                log("speaker!");
                                // setState(() {
                                //   speaker = !speaker;
                                // });
                                TwilioVoice.instance.call
                                    .toggleSpeaker(!speaker)
                                    .then((value) {
                                  _updateSpeakerState();
                                });
                              },
                            ),
                          ),
                        ),
                        Material(
                          type: MaterialType
                              .transparency, //Makes it usable on any background color, thanks @IanSmith
                          child: Ink(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white, width: 1.0),
                              color: mute
                                  ? Theme.of(context).colorScheme.secondary
                                  : Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              //This keeps the splash effect within the circle
                              borderRadius: BorderRadius.circular(
                                  1000.0), //Something large to ensure a circle
                              child: const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.bluetooth,
                                  size: 40.0,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                // BLuetooth functionality is not supported on web or macos
                                if (kIsWeb || Platform.isMacOS) {
                                  return;
                                }
                                final newState = !isBluetoothOn;
                                log("bluetooth? ${newState ? "on" : "off"}");
                                // TwilioVoice.instance.call.toggleBluetooth(bluetoothOn: newState).then((value) {
                                //   _updateBluetoothState();
                                // });
                                // setState(() {
                                //   mute = !mute;
                                // });
                              },
                            ),
                          ),
                        ),
                        Material(
                          type: MaterialType
                              .transparency, //Makes it usable on any background color, thanks @IanSmith
                          child: Ink(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white, width: 1.0),
                              color: mute
                                  ? Theme.of(context).colorScheme.secondary
                                  : Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              //This keeps the splash effect within the circle
                              borderRadius: BorderRadius.circular(
                                  1000.0), //Something large to ensure a circle
                              child: const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.mic_off,
                                  size: 40.0,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                log("mute!");
                                TwilioVoice.instance.call
                                    .toggleMute(!mute)
                                    .then((value) {
                                  _updateMuteState();
                                });
                                // setState(() {
                                //   mute = !mute;
                                // });
                              },
                            ),
                          ),
                        )
                      ]),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: isHolding
                          ? Theme.of(context).primaryColor
                          : Colors.white24,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: const BorderSide(color: Colors.white)),
                    ),
                    onPressed: () {
                      log("Holding call? $isHolding");
                      TwilioVoice.instance.call.holdCall().then((value) {
                        _updateHoldState();
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isHolding)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.pause,
                              color: Colors.white,
                            ),
                          ),
                        Text(
                          isHolding ? "Call on hold" : "Hold call",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  RawMaterialButton(
                    elevation: 2.0,
                    fillColor: Colors.red,
                    child: const Icon(
                      Icons.call_end,
                      size: 40.0,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(20.0),
                    shape: const CircleBorder(),
                    onPressed: () async {
                      final isOnCall =
                          await TwilioVoice.instance.call.isOnCall();
                      if (isOnCall) {
                        TwilioVoice.instance.call.hangUp();
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
