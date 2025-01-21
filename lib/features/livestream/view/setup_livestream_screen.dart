import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:socieaty/app_theme.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/livestream/viewmodel/live_screen_view_model.dart';
import 'package:socieaty/features/livestream/viewstate/setup_livestream_form_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

class SetupLiveStreamScreen extends ConsumerStatefulWidget {
  const SetupLiveStreamScreen({super.key});

  @override
  ConsumerState<SetupLiveStreamScreen> createState() => _SetupLiveStreamViewState();
}

class _SetupLiveStreamViewState extends ConsumerState<SetupLiveStreamScreen> {
  SetupLivestreamFormState formState = SetupLivestreamFormState();
  final _formKey = GlobalKey<FormState>();
  LocalVideoTrack? localVideoTrack;
  LocalAudioTrack? localAudioTrack;
  CameraPosition cameraPosition = CameraPosition.front;

  @override
  void initState() {
    super.initState();
    _checkPremissions();
    _initializeCamera();
    _initializeAudio();
  }

  @override
  void dispose() {
    localVideoTrack?.stop();
    localVideoTrack?.dispose();
    localAudioTrack?.stop();
    localAudioTrack?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (localVideoTrack != null) {
      debugPrint("Stopping video track");
      await localVideoTrack?.stop();
      await localVideoTrack?.dispose();
      localVideoTrack = null;
    }
    localVideoTrack = await LocalVideoTrack.createCameraTrack(
      CameraCaptureOptions(
        cameraPosition: cameraPosition,
        params: VideoParameters(
          dimensions: VideoDimensions(1280, 720),
        ),
      ),
    );
    await localVideoTrack?.start();
    setState(() {});
  }

  Future<void> _initializeAudio() async {
    localAudioTrack = await LocalAudioTrack.create(const AudioCaptureOptions(
      noiseSuppression: true,
      echoCancellation: true,
    ));
    await localAudioTrack?.start();
    setState(() {});
  }

  Future<void> _checkPremissions() async {
    await Permission.camera.onDeniedCallback(() {
      showSnackbar(context, "Kamera diperlukan untuk memulai livestream");
    }).onPermanentlyDeniedCallback(() {
      showSnackbar(context, "Permission kamera dapat diaktifkan di pengaturan");
    }).request();

    await Permission.microphone.onDeniedCallback(() {
      showSnackbar(context, "Mikrofon diperlukan untuk memulai livestream");
    }).onPermanentlyDeniedCallback(() {
      showSnackbar(context, "Permission mikrofon dapat diaktifkan di pengaturan");
    }).request();
  }

  Future<void> _toggleCameraPosition() async {
    cameraPosition = cameraPosition == CameraPosition.front ? CameraPosition.back : CameraPosition.front;
    _initializeCamera();
    setState(() {});
  }

  _startLiveStream() {
    final room = Room();
    // room.connect(
    //   "",
    //   "token",
    //   connectOptions: ConnectOptions(),
    //   fastConnectOptions: FastConnectOptions(
    //     camera: TrackOption(track: localVideoTrack),
    //     microphone: TrackOption(track: localAudioTrack),
    //   )
    // );
    ref.read(liveScreenViewModelProvider.notifier).setRoom(room);
    context.push('/customer/livestream/live');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: localVideoTrack != null
                ? VideoTrackRenderer(
                    localVideoTrack!,
                    fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : LoadingIndicator(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: Icon(
                    Icons.close,
                    color: AppPallete.neutralColor.shade50,
                  ),
                ),
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: AppPallete.neutralColor.shade700.withAlpha(128),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 22.5,
                            backgroundImage: AssetImage("assets/images/person_dummy.jpg"),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: TextFormField(
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration.collapsed(
                                hintText: "Your title here...",
                                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppPallete.neutralColor.shade400),
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Title is required";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                formState = formState.copyWith(title: value ?? "");
                              },
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          IconButton(
                            onPressed: () {
                              _toggleCameraPosition();
                            },
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.cameraswitch_outlined,
                              color: AppPallete.neutralColor.shade50,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    SizedBox(
                      width: screenWidth * 0.3,
                      height: 45,
                      child: FilledButton(
                        onPressed: () {
                          _startLiveStream();
                        },
                        child: Text("Go Live"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
