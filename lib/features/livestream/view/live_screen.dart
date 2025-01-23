import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/shared/widgets/custom_circle_avatar.dart';
import 'package:socieaty/shared/widgets/loading_indicator.dart';

class LiveScreenArgs {
  final String accessToken;
  final CameraPosition cameraPosition;
  const LiveScreenArgs({
    required this.accessToken,
    required this.cameraPosition,
  });
}

class LiveScreen extends ConsumerStatefulWidget {
  final LiveScreenArgs args;
  const LiveScreen({
    super.key,
    required this.args,
  });

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  late EventsListener _roomListener;
  LocalVideoTrack? _localVideoTrack;
  LocalAudioTrack? _localAudioTrack;
  bool _isVideoTrackLoading = false;
  CameraPosition? _cameraPosition;
  Room? _room;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isVideoTrackLoading = true;
    });

    _cameraPosition = widget.args.cameraPosition;
    _createRoom();
  }

  @override
  void dispose() {
    (() async {
      await _roomListener.dispose();
      await _room?.disconnect();
      await _room?.dispose();
    })();
    super.dispose();
  }

  _createRoom() async {
    _room = Room(
      roomOptions: RoomOptions(
        dynacast: true,
        adaptiveStream: true,
      ),
    );
    final url = AppConstants.livestreamServerUrl;
    await _room!.connect(
      url,
      widget.args.accessToken,
    );
    // if (mounted) {
    //   showSnackbar(context, "${_room!.metadata}");
    //   debugPrint("metadata: ${_room!.metadata}");
    // }
    _setupListener();
    _publishMedia();
  }

  _setupListener() {
    _roomListener = _room!.createListener();

    _roomListener.on<RoomDisconnectedEvent>((event) async {
      if (event.reason != null) {
        context.pop();
        showSnackbar(context, "Room disconected because of ${event.reason}");
      }
    });
  }

  _publishMedia() async {
    _publishCamera();
    try {
      await _room!.localParticipant?.setMicrophoneEnabled(true);
      _localAudioTrack = _room!.localParticipant?.audioTrackPublications.firstOrNull?.track;
    } catch (error) {
      if (mounted) {
        showSnackbar(context, "error: $error");
      }
    }
    setState(() {});
  }

  _publishCamera() async {
    setState(() {
      _isVideoTrackLoading = true;
    });
    try {
      await _room!.localParticipant?.setCameraEnabled(true);
      _localVideoTrack = _room!.localParticipant?.videoTrackPublications.firstOrNull?.track;
      debugPrint("_localVideoTrack: ${_localVideoTrack == null}");
      await _localVideoTrack?.setCameraPosition(_cameraPosition!);
    } catch (error) {
      if (mounted) {
        showSnackbar(context, "error: $error");
      }
    } finally {
      _isVideoTrackLoading = false;
      setState(() {});
    }
  }

  _unpublishCamera() async {
    setState(() {
      _isVideoTrackLoading = true;
    });
    try {
      await _room!.localParticipant?.setCameraEnabled(false);
      _localVideoTrack = null;
    } catch (error) {
      if (mounted) {
        showSnackbar(context, "error: $error");
      }
    } finally {
      _isVideoTrackLoading = false;
      setState(() {});
    }
  }

  _toggleCameraEnabledState() async {
    if (_localVideoTrack != null) {
      await _unpublishCamera();
    } else {
      await _publishCamera();
    }
  }

  _toggleCameraPosition() async {
    _cameraPosition = _cameraPosition == CameraPosition.front ? CameraPosition.back : CameraPosition.front;
    await _localVideoTrack?.setCameraPosition(_cameraPosition!);
    setState(() {});
  }

  _toggleMic() async {
    if (_localAudioTrack!.muted) {
      await _localAudioTrack?.unmute();
    } else {
      await _localAudioTrack?.mute();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _isVideoTrackLoading
                ? LoadingIndicator()
                : _localVideoTrack == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.videocam_off_outlined, size: 48, color: Colors.white),
                            Text(
                              'Camera is disabled',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : VideoTrackRenderer(
                        _localVideoTrack!,
                        fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    IconButton.filled(
                      onPressed: () {
                        context.pop();
                      },
                      icon: Icon(Icons.close),
                      color: Colors.black.withAlpha(128),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Live",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.podcasts, color: Colors.red),
                          SizedBox(width: 4),
                          Icon(Icons.person, color: Colors.white),
                          SizedBox(width: 2),
                          Text("0", style: Theme.of(context).textTheme.bodyMedium),
                          SizedBox(width: 4),
                          Icon(Icons.favorite, color: Colors.white),
                          SizedBox(width: 2),
                          Text("0", style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        _toggleCameraEnabledState();
                      },
                      icon: Icon(
                        _localVideoTrack != null && !_isVideoTrackLoading ? Icons.videocam_off_outlined : Icons.videocam,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _toggleCameraPosition();
                      },
                      icon: Icon(
                        Icons.flip_camera_android,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _toggleMic();
                      },
                      icon: Icon(
                        _localAudioTrack?.muted == true ? Icons.mic_off : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: screenHeight * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(8),
                    Colors.black.withAlpha(255),
                  ],
                ),
              ),
              child: ShaderMask(
                shaderCallback: (Rect rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: ListView.builder(
                    itemCount: 10,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomCircleAvatar(radius: 20, imageUrl: 'assets/images/person_dummy.jpg'),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Vithunchan",
                                      // widget.postComment.userName,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Hallo test comment hehehehhehehe",
                                      // widget.postComment.text,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
