import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/life_models.dart';

class LifeRepository {
  LifeRepository._();
  static final LifeRepository instance = LifeRepository._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'lifeos.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE routine (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            timeLabel TEXT,
            area TEXT,
            completed INTEGER
          )
        ''');
        await database.execute('''
          CREATE TABLE habits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            targetPerWeek INTEGER,
            completedToday INTEGER,
            streak INTEGER
          )
        ''');
        await database.execute('''
          CREATE TABLE study (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT,
            hours REAL,
            date TEXT
          )
        ''');
        await database.execute('''
          CREATE TABLE goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            type TEXT,
            progress INTEGER
          )
        ''');
        await _seed(database);
      },
    );
    return _db!;
  }

  Future<void> _seed(Database database) async {
    for (final task in [
      RoutineTask(name: 'Wake Up', timeLabel: '05:30 AM', area: LifeArea.health),
      RoutineTask(name: 'Prayer', timeLabel: '06:00 AM', area: LifeArea.spirituality),
      RoutineTask(name: 'Exercise', timeLabel: '06:30 AM', area: LifeArea.health),
      RoutineTask(name: 'Study Session', timeLabel: '08:00 AM', area: LifeArea.study),
      RoutineTask(name: 'Evening Walk', timeLabel: '06:00 PM', area: LifeArea.health),
      RoutineTask(name: 'Reading', timeLabel: '09:00 PM', area: LifeArea.productivity),
    ]) {
      await database.insert('routine', task.toMap());
    }

    for (final habit in [
      Habit(name: 'Meditation', targetPerWeek: 7),
      Habit(name: 'Journaling', targetPerWeek: 7),
      Habit(name: 'Drink Water', targetPerWeek: 7),
      Habit(name: 'Exercise', targetPerWeek: 5),
      Habit(name: 'Focused Study', targetPerWeek: 6),
    ]) {
      await database.insert('habits', habit.toMap());
    }

    await database.insert('study', StudyEntry(subject: 'Mathematics', hours: 2.0, date: DateTime.now()).toMap());
    await database.insert('study', StudyEntry(subject: 'Physics', hours: 1.5, date: DateTime.now().subtract(const Duration(days: 1))).toMap());

    await database.insert('goals', Goal(title: 'Clear certification exam', type: 'Long-term', progress: 20).toMap());
    await database.insert('goals', Goal(title: 'Read 2 books', type: 'Monthly', progress: 45).toMap());
    await database.insert('goals', Goal(title: 'Complete morning routine', type: 'Daily', progress: 80).toMap());
  }

  Future<List<RoutineTask>> fetchRoutine() async {
    final records = await (await db).query('routine');
    return records.map(RoutineTask.fromMap).toList();
  }

  Future<void> updateRoutineTask(RoutineTask task) async {
    await (await db).update('routine', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<List<Habit>> fetchHabits() async {
    final records = await (await db).query('habits');
    return records.map(Habit.fromMap).toList();
  }

  Future<void> updateHabit(Habit habit) async {
    await (await db).update('habits', habit.toMap(), where: 'id = ?', whereArgs: [habit.id]);
  }

  Future<List<StudyEntry>> fetchStudy() async {
    final records = await (await db).query('study', orderBy: 'date DESC');
    return records.map(StudyEntry.fromMap).toList();
  }

  Future<void> addStudy(StudyEntry entry) async {
    await (await db).insert('study', entry.toMap());
  }

  Future<List<Goal>> fetchGoals() async {
    final records = await (await db).query('goals');
    return records.map(Goal.fromMap).toList();
  }

  Future<void> updateGoal(Goal goal) async {
    await (await db).update('goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }
}
