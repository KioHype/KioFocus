class BlockedApp {
  final String packageName;
  final String appName;
  final int timerMinutes;
  final int timerSeconds;

  BlockedApp({
    required this.packageName,
    required this.appName,
    this.timerMinutes = 3,
    this.timerSeconds = 0,
  });

  Map<String, dynamic> toJson() => {
    'packageName': packageName,
    'appName':     appName,
    'timerMinutes': timerMinutes,
    'timerSeconds': timerSeconds,
  };

  factory BlockedApp.fromJson(Map<String, dynamic> json) => BlockedApp(
    packageName:  json['packageName'],
    appName:      json['appName'],
    timerMinutes: json['timerMinutes'] ?? 3,
    timerSeconds: json['timerSeconds'] ?? 0,
  );

  BlockedApp copyWith({int? timerMinutes, int? timerSeconds}) => BlockedApp(
    packageName:  packageName,
    appName:      appName,
    timerMinutes: timerMinutes  ?? this.timerMinutes,
    timerSeconds: timerSeconds  ?? this.timerSeconds,
  );
}

class RecommendedApp {
  final String packageName;
  final String appName;

  RecommendedApp({required this.packageName, required this.appName});

  Map<String, dynamic> toJson() => {
    'packageName': packageName,
    'appName':     appName,
  };

  factory RecommendedApp.fromJson(Map<String, dynamic> json) => RecommendedApp(
    packageName: json['packageName'],
    appName:     json['appName'],
  );
}