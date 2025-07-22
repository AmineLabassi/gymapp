import 'package:flutter/material.dart';

class GymProgramPage extends StatelessWidget {
  final String goal;

  GymProgramPage({required this.goal});

final List<Map<String, dynamic>> gainMuscleProgram = [
  {
    'day': 'Monday - Push',
    'exercises': [
      {'name': 'Barbell Bench Press', 'reps': '4x10'},
      {'name': 'Overhead Press', 'reps': '4x10'},
      {'name': 'Dumbbell Chest Fly', 'reps': '3x12'},
      {'name': 'Triceps Extension', 'reps': '3x12'},
    ],
  },
  {
    'day': 'Tuesday - Pull',
    'exercises': [
      {'name': 'Seated Row', 'reps': '4x10'},
      {'name': 'Assisted Pull-ups', 'reps': '3x8'},
      {'name': 'Bicep Curls', 'reps': '3x12'},
    ],
  },
  {
    'day': 'Wednesday - Legs',
    'exercises': [
      {'name': 'Barbell Squats', 'reps': '4x12'},
      {'name': 'Walking Lunges', 'reps': '3x10'},
      {'name': 'Romanian Deadlift', 'reps': '3x10'},
      {'name': 'Calf Raises', 'reps': '3x20'},
    ],
  },
  {
    'day': 'Thursday',
    'exercises': [],
  },
  {
    'day': 'Friday - Push',
    'exercises': [
      {'name': 'Incline Dumbbell Press', 'reps': '4x10'},
      {'name': 'Dips', 'reps': '3x8'},
      {'name': 'Lateral Raises', 'reps': '3x12'},
    ],
  },
  {
    'day': 'Saturday - Pull',
    'exercises': [
      {'name': 'Barbell Row', 'reps': '4x10'},
      {'name': 'Face Pulls', 'reps': '3x12'},
      {'name': 'Hammer Curls', 'reps': '3x12'},
    ],
  },
  {
    'day': 'Sunday - Legs/Optional',
    'exercises': [
      {'name': 'Leg Press', 'reps': '4x10'},
      {'name': 'Leg Curl Machine', 'reps': '3x12'},
    ],
  },
];

final List<Map<String, dynamic>> loseWeightProgram = [
  {
    'day': 'Monday - Push',
    'exercises': [
      {'name': 'Push-ups', 'reps': '4x20'},
      {'name': 'Bench Dips', 'reps': '3x15'},
      {'name': 'Dumbbell Shoulder Press', 'reps': '3x15'},
    ],
  },
  {
    'day': 'Tuesday - Pull',
    'exercises': [
      {'name': 'Cable Row', 'reps': '3x15'},
      {'name': 'Bicep Curls', 'reps': '3x20'},
      {'name': 'Plank', 'reps': '3x1 min'},
    ],
  },
  {
    'day': 'Wednesday - Legs',
    'exercises': [
      {'name': 'Bodyweight Squats', 'reps': '4x20'},
      {'name': 'Walking Lunges', 'reps': '3x12'},
      {'name': 'Jump Squats', 'reps': '3x15'},
    ],
  },
  {
    'day': 'Thursday',
    'exercises': [],
  },
  {
    'day': 'Friday - Push',
    'exercises': [
      {'name': 'Incline Push-ups', 'reps': '4x20'},
      {'name': 'Lateral Raises', 'reps': '3x15'},
      {'name': 'Triceps Dips', 'reps': '3x12'},
    ],
  },
  {
    'day': 'Saturday - Pull',
    'exercises': [
      {'name': 'Lat Pulldown', 'reps': '3x15'},
      {'name': 'Resistance Band Row', 'reps': '3x20'},
      {'name': 'Side Plank', 'reps': '3x45 sec'},
    ],
  },
  {
    'day': 'Sunday - Cardio + Stretch',
    'exercises': [
      {'name': 'Light cardio (walk/cycle)', 'reps': '30-40 min'},
      {'name': 'Full-body Stretching', 'reps': '15 min'},
    ],
  },
];

  @override
  Widget build(BuildContext context) {
    final program = goal.toLowerCase() == 'gain muscle'
        ? gainMuscleProgram
        : loseWeightProgram;

    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      appBar: AppBar(
        title: Text('Gym Programme'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: program.length,
          itemBuilder: (context, index) {
            final day = program[index];
            final exercises = day['exercises'] as List;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day['day'],
                  style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                exercises.isEmpty
                    ? Text(
                        day['day'] == 'Mercredi' || day['day'] == 'Dimanche'
                            ? 'Repos'
                            : 'Libre',
                        style: TextStyle(color: Colors.white70),
                      )
                    : Table(
                        columnWidths: {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                        },
                        children: exercises
                            .map<TableRow>(
                              (ex) => TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(ex['name'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(ex['reps'],
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 16)),
                                ),
                              ]),
                            )
                            .toList(),
                      ),
                Divider(color: Colors.white24, height: 30),
              ],
            );
          },
        ),
      ),
    );
  }
}
