enum LifeArea { health, study, spirituality, productivity, money }

class RoutineTask {
  RoutineTask({
    this.id,
    required this.name,
    required this.timeLabel,
    required this.area,
    this.completed = false,
  });

  int? id;
  final String name;
  final String timeLabel;
  final LifeArea area;
  bool completed;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'timeLabel': timeLabel,
        'area': area.name,
        'completed': completed ? 1 : 0,
      };

  static RoutineTask fromMap(Map<String, Object?> map) => RoutineTask(
        id: map['id'] as int?,
        name: map['name'] as String,
        timeLabel: map['timeLabel'] as String,
        area: LifeArea.values.firstWhere((a) => a.name == map['area']),
        completed: (map['completed'] as int) == 1,
      );
}

class Habit {
  Habit({
    this.id,
    required this.name,
    required this.targetPerWeek,
    this.completedToday = false,
    this.streak = 0,
  });

  int? id;
  final String name;
  final int targetPerWeek;
  bool completedToday;
  int streak;

  double get consistency => (streak / (targetPerWeek == 0 ? 1 : targetPerWeek)).clamp(0, 1).toDouble();

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'targetPerWeek': targetPerWeek,
        'completedToday': completedToday ? 1 : 0,
        'streak': streak,
      };

  static Habit fromMap(Map<String, Object?> map) => Habit(
        id: map['id'] as int?,
        name: map['name'] as String,
        targetPerWeek: map['targetPerWeek'] as int,
        completedToday: (map['completedToday'] as int) == 1,
        streak: map['streak'] as int,
      );
}

class StudyEntry {
  StudyEntry({
    this.id,
    required this.subject,
    required this.hours,
    required this.date,
  });

  int? id;
  final String subject;
  final double hours;
  final DateTime date;

  Map<String, Object?> toMap() => {
        'id': id,
        'subject': subject,
        'hours': hours,
        'date': date.toIso8601String(),
      };

  static StudyEntry fromMap(Map<String, Object?> map) => StudyEntry(
        id: map['id'] as int?,
        subject: map['subject'] as String,
        hours: map['hours'] as double,
        date: DateTime.parse(map['date'] as String),
      );
}

class SpiritualEntry {
  SpiritualEntry({
    this.id,
    this.prayerDone = false,
    this.meditationDone = false,
    this.gratitudeDone = false,
    required this.date,
  });

  int? id;
  bool prayerDone;
  bool meditationDone;
  bool gratitudeDone;
  DateTime date;

  int get score => [prayerDone, meditationDone, gratitudeDone].where((v) => v).length;

  Map<String, Object?> toMap() => {
        'id': id,
        'prayerDone': prayerDone ? 1 : 0,
        'meditationDone': meditationDone ? 1 : 0,
        'gratitudeDone': gratitudeDone ? 1 : 0,
        'date': date.toIso8601String(),
      };

  static SpiritualEntry fromMap(Map<String, Object?> map) => SpiritualEntry(
        id: map['id'] as int?,
        prayerDone: (map['prayerDone'] as int) == 1,
        meditationDone: (map['meditationDone'] as int) == 1,
        gratitudeDone: (map['gratitudeDone'] as int) == 1,
        date: DateTime.parse(map['date'] as String),
      );
}

class HealthEntry {
  HealthEntry({
    this.id,
    this.steps = 0,
    this.waterGlasses = 0,
    this.exerciseMinutes = 0,
    required this.date,
  });

  int? id;
  int steps;
  int waterGlasses;
  int exerciseMinutes;
  DateTime date;

  Map<String, Object?> toMap() => {
        'id': id,
        'steps': steps,
        'waterGlasses': waterGlasses,
        'exerciseMinutes': exerciseMinutes,
        'date': date.toIso8601String(),
      };

  static HealthEntry fromMap(Map<String, Object?> map) => HealthEntry(
        id: map['id'] as int?,
        steps: map['steps'] as int,
        waterGlasses: map['waterGlasses'] as int,
        exerciseMinutes: map['exerciseMinutes'] as int,
        date: DateTime.parse(map['date'] as String),
      );
}

class Goal {
  Goal({
    this.id,
    required this.title,
    required this.type,
    this.progress = 0,
  });

  int? id;
  final String title;
  final String type;
  int progress;

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'type': type,
        'progress': progress,
      };

  static Goal fromMap(Map<String, Object?> map) => Goal(
        id: map['id'] as int?,
        title: map['title'] as String,
        type: map['type'] as String,
        progress: map['progress'] as int,
      );
}

class DistractionLimit {
  DistractionLimit({required this.appName, required this.limitMinutes, this.usedMinutes = 0});

  final String appName;
  int limitMinutes;
  int usedMinutes;

  bool get exceeded => usedMinutes > limitMinutes;
}
