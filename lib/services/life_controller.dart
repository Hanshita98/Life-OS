import 'dart:math';

import 'package:flutter/material.dart';

import '../models/life_models.dart';
import 'life_repository.dart';

class LifeController extends ChangeNotifier {
  final LifeRepository _repository = LifeRepository.instance;

  List<RoutineTask> routine = [];
  List<Habit> habits = [];
  List<StudyEntry> studyEntries = [];
  List<Goal> goals = [];

  SpiritualEntry spiritualEntry = SpiritualEntry(date: DateTime.now());
  HealthEntry healthEntry = HealthEntry(date: DateTime.now());
  final List<DistractionLimit> distractionLimits = [
    DistractionLimit(appName: 'Instagram', limitMinutes: 30, usedMinutes: 40),
    DistractionLimit(appName: 'YouTube', limitMinutes: 45, usedMinutes: 20),
    DistractionLimit(appName: 'X', limitMinutes: 20, usedMinutes: 25),
  ];

  String morningChecklist = '';
  String nightReflection = '';
  String weeklyReview = '';

  final List<String> quotes = [
    'Discipline is choosing between what you want now and what you want most.',
    'Small daily improvements lead to stunning long-term results.',
    'Your future is built by what you do today, not tomorrow.',
  ];

  Future<void> load() async {
    routine = await _repository.fetchRoutine();
    habits = await _repository.fetchHabits();
    studyEntries = await _repository.fetchStudy();
    goals = await _repository.fetchGoals();
    notifyListeners();
  }

  Future<void> toggleRoutine(RoutineTask task, bool value) async {
    task.completed = value;
    await _repository.updateRoutineTask(task);
    notifyListeners();
  }

  Future<void> toggleHabit(Habit habit, bool value) async {
    habit.completedToday = value;
    habit.streak = max(0, habit.streak + (value ? 1 : -1));
    await _repository.updateHabit(habit);
    notifyListeners();
  }

  Future<void> addStudyRecord(String subject, double hours) async {
    final entry = StudyEntry(subject: subject, hours: hours, date: DateTime.now());
    await _repository.addStudy(entry);
    studyEntries = await _repository.fetchStudy();
    notifyListeners();
  }

  Future<void> setGoalProgress(Goal goal, int value) async {
    goal.progress = value;
    await _repository.updateGoal(goal);
    notifyListeners();
  }

  double get dailyRoutineProgress {
    if (routine.isEmpty) return 0;
    return routine.where((t) => t.completed).length / routine.length;
  }

  double get habitCompletion {
    if (habits.isEmpty) return 0;
    return habits.where((h) => h.completedToday).length / habits.length;
  }

  double get todayStudyHours {
    final now = DateTime.now();
    return studyEntries
        .where((entry) => entry.date.year == now.year && entry.date.month == now.month && entry.date.day == now.day)
        .fold(0.0, (sum, e) => sum + e.hours);
  }

  double get weeklyStudyHours {
    final weekStart = DateTime.now().subtract(const Duration(days: 7));
    return studyEntries.where((entry) => entry.date.isAfter(weekStart)).fold(0.0, (sum, e) => sum + e.hours);
  }

  int get dailyScore {
    final routineScore = (dailyRoutineProgress * 25).round();
    final habitScore = (habitCompletion * 25).round();
    final spiritualScore = ((spiritualEntry.score / 3) * 20).round();
    final healthScore = (((healthEntry.steps / 8000) + (healthEntry.waterGlasses / 8) + (healthEntry.exerciseMinutes / 45)) / 3 * 15)
        .clamp(0, 15)
        .round();
    final studyScore = ((todayStudyHours / 4) * 15).clamp(0, 15).round();
    return routineScore + habitScore + spiritualScore + healthScore + studyScore;
  }

  Map<LifeArea, int> get lifeAreaScores => {
        LifeArea.health: (((healthEntry.steps / 8000) + (healthEntry.waterGlasses / 8)) / 2 * 100).clamp(0, 100).round(),
        LifeArea.study: ((weeklyStudyHours / 20) * 100).clamp(0, 100).round(),
        LifeArea.spirituality: ((spiritualEntry.score / 3) * 100).clamp(0, 100).round(),
        LifeArea.money: 55,
      };

  String get quoteOfTheDay => quotes[DateTime.now().day % quotes.length];
}
