// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_wrapper/flutter_webrtc_wrapper.dart';
import 'package:webrtcvideocallapp/model/meeting_details_model.dart';
import 'package:webrtcvideocallapp/pages/home_screen.dart';
import 'package:webrtcvideocallapp/utils/user.utils.dart';
import 'package:webrtcvideocallapp/widgets/control_panel.dart';
import 'package:webrtcvideocallapp/widgets/remote_connection.dart';

class MeetingScreen extends StatefulWidget {
  final String? meetingId;
  final String? name;
  final MeetingDetailsModel meetingDetailsModel;
  const MeetingScreen({
    Key? key,
    this.meetingId,
    this.name,
    required this.meetingDetailsModel,
  }) : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final localRenderer = RTCVideoRenderer();
  final Map<String, dynamic> mediaConstraints = {"audio": true, "video": true};
  bool isConnectionFailed = false;
  WebRTCMeetingHelper? meetingHelper;

  void startMeeting() async {
    final String userId = await loadUserId();
    meetingHelper = WebRTCMeetingHelper(
      url: "http://10.1.18.71:4000",
      meetingId: widget.meetingDetailsModel.id,
      userId: userId,
      name: widget.name,
    );

    MediaStream? localStream;
    try {
      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    } catch (err) {
      log(err.toString());
    }

    localRenderer.srcObject = localStream;
    meetingHelper!.stream = localStream;
    // ignore: use_build_context_synchronously
    meetingHelper!.on("open", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    // ignore: use_build_context_synchronously
    meetingHelper!.on("connection", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    // ignore: use_build_context_synchronously
    meetingHelper!.on("user-left", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    // ignore: use_build_context_synchronously
    meetingHelper!.on("video-toggle", context, (ev, context) {
      setState(() {});
    });
    // ignore: use_build_context_synchronously
    meetingHelper!.on("audio-toggle", context, (ev, context) {
      setState(() {});
    });
    // ignore: use_build_context_synchronously
    meetingHelper!.on("meeting-ended", context, (ev, context) {
      setState(() {
        onMeetingEnd();
      });
    });
    // ignore: use_build_context_synchronously
    meetingHelper!.on("connection-setting-changed", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });

    // ignore: use_build_context_synchronously
    meetingHelper!.on("stream-changed", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });

    setState(() {});
  }

  initRenders() async {
    await localRenderer.initialize();
  }

  @override
  void initState() {
    super.initState();
    initRenders();
    startMeeting();
  }

  @override
  void deactivate() {
    localRenderer.dispose();
    if (meetingHelper != null) {
      meetingHelper!.destroy();
      meetingHelper = null;
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: buildMeetingRoom(),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        videoEnabled: isVideoEnabled(),
        audioEnabled: isAudioEnabled(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconnect,
        onMeetingEnd: onMeetingEnd,
      ),
    );
  }

  buildMeetingRoom() {
    return Stack(
      children: [
        meetingHelper != null && meetingHelper!.connections.isNotEmpty
            ? GridView.count(
                crossAxisCount: meetingHelper!.connections.length < 3 ? 1 : 2,
                children:
                    List.generate(meetingHelper!.connections.length, (index) {
                  return Padding(
                      padding: const EdgeInsets.all(1),
                      child: RemoteConnection(
                          renderer: meetingHelper!.connections[index].renderer,
                          connection: meetingHelper!.connections[index]));
                }),
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Waiting for participants to join the meeting",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
        Positioned(
            bottom: 10,
            right: 0,
            child: SizedBox(
              width: 150,
              height: 200,
              child: RTCVideoView(localRenderer),
            ))
      ],
    );
  }

  void onAudioToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleAudio();
      });
    }
  }

  void onVideoToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleVideo();
      });
    }
  }

  void onMeetingEnd() {
    if (meetingHelper != null) {
      meetingHelper!.endMeeting();
      meetingHelper = null;
      goToHomeScreen();
    }
  }

  void handleReconnect() {
    if (meetingHelper != null) {
      meetingHelper!.reconnect();
    }
  }

  bool isAudioEnabled() {
    return meetingHelper != null ? meetingHelper!.audioEnabled! : false;
  }

  bool isVideoEnabled() {
    return meetingHelper != null ? meetingHelper!.videoEnabled! : false;
  }

  void goToHomeScreen() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
}
