import 'package:flutter/material.dart';

import 'models/life_models.dart';
import 'services/life_controller.dart';

void main() {
  runApp(const LifeOsApp());
}

class LifeOsApp extends StatelessWidget {
  const LifeOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeOS',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const LifeHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LifeHomePage extends StatefulWidget {
  const LifeHomePage({super.key});

  @override
  State<LifeHomePage> createState() => _LifeHomePageState();
}

class _LifeHomePageState extends State<LifeHomePage> {
  final controller = LifeController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    controller.load();
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['Dashboard', 'Routine', 'Habits', 'Study', 'Life'];
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Scaffold(
          appBar: AppBar(title: Text('LifeOS • ${titles[currentIndex]}')),
          body: IndexedStack(
            index: currentIndex,
            children: [
              DashboardTab(controller: controller),
              RoutineTab(controller: controller),
              HabitsTab(controller: controller),
              StudyTab(controller: controller),
              LifeTab(controller: controller),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (value) => setState(() => currentIndex = value),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.checklist), label: 'Routine'),
              NavigationDestination(icon: Icon(Icons.repeat), label: 'Habits'),
              NavigationDestination(icon: Icon(Icons.menu_book), label: 'Study'),
              NavigationDestination(icon: Icon(Icons.spa), label: 'Life'),
            ],
          ),
        );
      },
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key, required this.controller});
  final LifeController controller;

  @override
  Widget build(BuildContext context) {
    final score = controller.dailyScore;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Daily Discipline Score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: score / 100),
              const SizedBox(height: 8),
              Text('$score / 100'),
            ]),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('Motivation'),
            subtitle: Text(controller.quoteOfTheDay),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Life Areas Score', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...controller.lifeAreaScores.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${entry.key.name[0].toUpperCase()}${entry.key.name.substring(1)} • ${entry.value}%'),
                      LinearProgressIndicator(value: entry.value / 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RoutineTab extends StatelessWidget {
  const RoutineTab({super.key, required this.controller});
  final LifeController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Completion: ${(controller.dailyRoutineProgress * 100).round()}%'),
        const SizedBox(height: 8),
        ...controller.routine.map(
          (task) => CheckboxListTile(
            title: Text(task.name),
            subtitle: Text(task.timeLabel),
            value: task.completed,
            onChanged: (v) => controller.toggleRoutine(task, v ?? false),
          ),
        ),
        const Divider(),
        const Text('Morning routine checklist'),
        TextField(
          decoration: const InputDecoration(hintText: 'Write your morning checklist...'),
          onChanged: (v) => controller.morningChecklist = v,
        ),
      ],
    );
  }
}

class HabitsTab extends StatelessWidget {
  const HabitsTab({super.key, required this.controller});
  final LifeController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: controller.habits
          .map(
            (habit) => Card(
              child: ListTile(
                title: Text(habit.name),
                subtitle: Text('Streak: ${habit.streak} days • Consistency ${(habit.consistency * 100).round()}%'),
                trailing: Switch(
                  value: habit.completedToday,
                  onChanged: (value) => controller.toggleHabit(habit, value),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class StudyTab extends StatelessWidget {
  const StudyTab({super.key, required this.controller});
  final LifeController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: Text('Today: ${controller.todayStudyHours.toStringAsFixed(1)}h'),
            subtitle: Text('Weekly: ${controller.weeklyStudyHours.toStringAsFixed(1)}h'),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => controller.addStudyRecord('Self Study', 1.0),
          icon: const Icon(Icons.add),
          label: const Text('Log +1 hour'),
        ),
        ...controller.studyEntries.map((entry) => ListTile(
              title: Text(entry.subject),
              subtitle: Text('${entry.hours}h • ${entry.date.toLocal()}'),
            )),
      ],
    );
  }
}

class LifeTab extends StatelessWidget {
  const LifeTab({super.key, required this.controller});
  final LifeController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Spiritual routine', style: TextStyle(fontWeight: FontWeight.bold)),
        SwitchListTile(
          value: controller.spiritualEntry.prayerDone,
          title: const Text('Prayer'),
          onChanged: (v) {
            controller.spiritualEntry.prayerDone = v;
            controller.notifyListeners();
          },
        ),
        SwitchListTile(
          value: controller.spiritualEntry.meditationDone,
          title: const Text('Meditation'),
          onChanged: (v) {
            controller.spiritualEntry.meditationDone = v;
            controller.notifyListeners();
          },
        ),
        SwitchListTile(
          value: controller.spiritualEntry.gratitudeDone,
          title: const Text('Gratitude Journal'),
          onChanged: (v) {
            controller.spiritualEntry.gratitudeDone = v;
            controller.notifyListeners();
          },
        ),
        const Divider(),
        const Text('Health section', style: TextStyle(fontWeight: FontWeight.bold)),
        _StepperTile(
          label: 'Steps',
          value: controller.healthEntry.steps,
          onChanged: (v) {
            controller.healthEntry.steps = v;
            controller.notifyListeners();
          },
          step: 500,
        ),
        _StepperTile(
          label: 'Water glasses',
          value: controller.healthEntry.waterGlasses,
          onChanged: (v) {
            controller.healthEntry.waterGlasses = v;
            controller.notifyListeners();
          },
        ),
        _StepperTile(
          label: 'Exercise minutes',
          value: controller.healthEntry.exerciseMinutes,
          onChanged: (v) {
            controller.healthEntry.exerciseMinutes = v;
            controller.notifyListeners();
          },
          step: 5,
        ),
        const Divider(),
        const Text('Goals', style: TextStyle(fontWeight: FontWeight.bold)),
        ...controller.goals.map(
          (goal) => ListTile(
            title: Text('${goal.type}: ${goal.title}'),
            subtitle: Slider(
              value: goal.progress.toDouble(),
              min: 0,
              max: 100,
              label: '${goal.progress}%',
              onChanged: (v) => controller.setGoalProgress(goal, v.round()),
            ),
          ),
        ),
        const Divider(),
        const Text('Distraction control', style: TextStyle(fontWeight: FontWeight.bold)),
        ...controller.distractionLimits.map(
          (limit) => ListTile(
            leading: Icon(limit.exceeded ? Icons.warning_amber : Icons.check_circle, color: limit.exceeded ? Colors.red : Colors.green),
            title: Text(limit.appName),
            subtitle: Text('${limit.usedMinutes} / ${limit.limitMinutes} min'),
          ),
        ),
        const Divider(),
        const Text('Night reflection journal'),
        TextField(
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'What went well today? What can improve?'),
          onChanged: (v) => controller.nightReflection = v,
        ),
        const SizedBox(height: 8),
        const Text('Weekly review'),
        TextField(
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Weekly wins, misses, and action plan'),
          onChanged: (v) => controller.weeklyReview = v,
        ),
      ],
    );
  }
}

class _StepperTile extends StatelessWidget {
  const _StepperTile({required this.label, required this.value, required this.onChanged, this.step = 1});

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int step;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text('$value'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: () => onChanged((value - step).clamp(0, 100000)), icon: const Icon(Icons.remove_circle_outline)),
          IconButton(onPressed: () => onChanged(value + step), icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }
}
