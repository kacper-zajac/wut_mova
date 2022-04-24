import 'package:flutter/material.dart';

// Strings
const String kAppTitle = 'MOVA - Voice Editor';
const String kWorkDirectoryName = '/project_files';
const String kThumbnailFileName = '/thumbnail.jpg';
const String kAudioFileName = '/out_audio.wav';
const String kVideoFileName = '/out_video.mp4';
const String kSaveFileName = '/save';
const String kVideoWordName = 'word';
const String kVideoBreakName = 'break';

// Colors
const kBoxColorTop = Color(0xFF282e50);
const kBoxColorBottom = Color(0xFF495079);
const kBackgroundColor = Color(0xFF0F1228);
const kAlertColor = Color(0xFF0F1228);

// Text styles
const kBoxTextStyle = TextStyle(color: Color(0xFFE2E4EB), fontSize: 28.0);
const kBoxBottomTextStyle = TextStyle(color: Color(0xFFE2E4EB), fontSize: 15.0);
const kTranscribedTextInactive = TextStyle(color: Color(0xFFE2E4EB), fontSize: 15.0);
const kTranscribedTextActive = TextStyle(color: Colors.lightBlueAccent, fontSize: 15.0);
const kLoginFormText = TextStyle(color: Color(0xFFE2E4EB), fontSize: 15.0);
const kLoginFormHintText = TextStyle(color: Color(0x50E2E4EB), fontSize: 15.0);
const kLoginFormButtonText = TextStyle(color: Color(0xFFE2E4EB), fontSize: 24.0);
final kLoginFormLabelText = TextStyle(
  color: const Color(0xFFE2E4EB),
  fontSize: 35.0,
  shadows: [
    Shadow(
      color: Colors.black.withOpacity(0.5),
      offset: const Offset(0, 3),
      blurRadius: 5, // changes position of shadow
    ),
  ],
);

// Values
const int kSpeechConstant = 150000;
const double kWordBoxHeight = 45.0;
const double kWordBoxWidth = 70.0;
