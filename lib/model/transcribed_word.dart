class TranscribedWord {
  TranscribedWord({
    required this.text,
    required this.startTime,
    required this.endTime,
    required this.order,
    required this.projectDirectory
  }) {
    currentStartTime = startTime;
    currentEndTime = endTime;
  }

  late int currentStartTime;
  late int currentEndTime;
  final int order;
  final int startTime;
  final int endTime;
  final String text;
  final String projectDirectory;
}
