class TranscribedWord {

  late int currentStartTime;
  late int currentEndTime;
  final int order;
  final int startTime;
  final int endTime;
  final String text;
  final String projectDirectory;

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

  TranscribedWord.fromJson(Map<String, dynamic> json)
      : currentStartTime = json['currentStartTime'],
        currentEndTime = json['currentEndTime'],
        order = json['order'],
        startTime = json['startTime'],
        endTime = json['endTime'],
        text = json['text'],
        projectDirectory = json['projectDirectory'];

  Map<String, dynamic> toJson() => {
    'currentStartTime' : currentStartTime,
    'currentEndTime' : currentEndTime,
    'order' : order,
    'startTime' : startTime,
    'endTime' : endTime,
    'text' : text,
    'projectDirectory' : projectDirectory,
  };
}
