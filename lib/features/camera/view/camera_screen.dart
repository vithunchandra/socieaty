// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class CameraScreen extends StatelessWidget {
//   const CameraScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CameraAwesomeBuilder.awesome(
//         saveConfig: SaveConfig.photoAndVideo(),
//         previewFit: CameraPreviewFit.contain,
//         previewAlignment: Alignment.center,
//         onMediaTap: (mediaCapture) {
//           mediaCapture.captureRequest.when(single: (single) {
//             if (single.file != null) {
//               final mimeType = single.file!.name.split('.')[1];

//               if (mimeType == "jpg" || mimeType == "png") {
//                 context.push('/camera/image/confirmation', extra: single.file);
//               } else {
//                 context.push('/camera/video/confirmation', extra: single.file);
//               }
//             }
//           });
//         },
//         onMediaCaptureEvent: (mediaCapture) {
//           mediaCapture.captureRequest.when(single: (single) {
//             if (single.file != null) {
//               final mimeType = single.file!.name.split('.')[1];

//               if (mimeType == "jpg" || mimeType == "png") {
//                 context.push('/camera/image/confirmation', extra: single.file);
//               } else {
//                 context.push('/camera/video/confirmation', extra: single.file);
//               }
//             }
//           });
//         },
//       ),
//     );
//   }
// }
