import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GymProgramPage extends StatelessWidget {
  final String goal;

  GymProgramPage({required this.goal});

  final List<Map<String, dynamic>> gainMuscleProgram = [
    {
      'day': 'Monday - Push',
      'exercises': [
        {
          'name': 'Barbell Bench Press',
          'reps': '4x10',
          'videoUrl': 'https://www.youtube.com/watch?v=gRVjAtPip0Y',
        },
        {
          'name': 'Overhead Press',
          'reps': '4x10',
          'videoUrl': 'https://www.youtube.com/watch?v=qEwKCR5JCog',
        },
        {
          'name': 'Dumbbell Chest Fly',
          'reps': '3x12',
          'videoUrl': 'https://www.youtube.com/watch?v=eozdVDA78K0',
        },
        {
          'name': 'Triceps Extension',
          'reps': '3x12',
          'videoUrl': 'https://www.youtube.com/watch?v=nRiJVZDpdL0',
        },
      ],
    },
    {
      'day': 'Tuesday - Pull',
      'exercises': [
        {
          'name': 'Seated Row',
          'reps': '4x10',
          'videoUrl': 'https://www.youtube.com/watch?v=GZbfZ033f74',
        },
        {
          'name': 'Assisted Pull-ups',
          'reps': '3x8',
          'videoUrl': 'https://www.youtube.com/watch?v=0ZkivYwS5zM',
        },
        {
          'name': 'Bicep Curls',
          'reps': '3x12',
          'videoUrl': 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo',
        },
      ],
    },
    {
      'day': 'Wednesday - Legs',
      'exercises': [
        {
          'name': 'Barbell Squats',
          'reps': '4x12',
          'videoUrl': 'https://www.youtube.com/watch?v=Dy28eq2PjcM',
        },
        {
          'name': 'Walking Lunges',
          'reps': '3x10',
          'videoUrl': 'https://www.youtube.com/watch?v=wrwwXE_x-pQ',
        },
        {
          'name': 'Romanian Deadlift',
          'reps': '3x10',
          'videoUrl': 'https://www.youtube.com/watch?v=2SHsk9AzdjA',
        },
        {
          'name': 'Calf Raises',
          'reps': '3x20',
          'videoUrl': 'https://www.youtube.com/watch?v=-M4-G8p8fmc',
        },
      ],
    },
    {
      'day': 'Thursday',
      'exercises': [],
    },
    {
      'day': 'Friday - Push',
      'exercises': [
        {
          'name': 'Incline Dumbbell Press',
          'reps': '4x10',
          'videoUrl': 'https://www.youtube.com/watch?v=8iPEnn-ltC8',
        },
        {
          'name': 'Dips',
          'reps': '3x8',
          'videoUrl': 'https://www.youtube.com/watch?v=2z8JmcrW-As',
        },
        {
          'name': 'Lateral Raises',
          'reps': '3x12',
          'videoUrl': 'https://www.youtube.com/watch?v=kDqklk1ZESo',
        },
      ],
    },
    {
      'day': 'Saturday - Pull',
      'exercises': [
        {
          'name': 'Barbell Row',
          'reps': '4x10',
          'videoUrl': 'https://www.youtube.com/watch?v=vT2GjY_Umpw',
        },
        {
          'name': 'Face Pulls',
          'reps': '3x12',
          'videoUrl': 'https://www.youtube.com/watch?v=rep-qVOkqgk',
        },
        {
          'name': 'Hammer Curls',
          'reps': '3x12',
          'videoUrl': 'https://www.youtube.com/watch?v=zC3nLlEvin4',
        },
      ],
    },
    {
      'day': 'Sunday - Legs/Optional',
      'exercises': [
        {
          'name': 'Leg Press',
          'reps': '4x10',
          'videoUrl': 'https://www.youtube.com/watch?v=IZxyjW7MPJQ',
        },
        {
          'name': 'Leg Curl Machine',
          'reps': '3x12',
          'videoUrl': 'https://www.youtube.com/watch?v=1Tq3QdYUuHs',
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> loseWeightProgram = [
    {
      'day': 'Monday - Push',
      'exercises': [
        {
          'name': 'Push-ups',
          'reps': '4x20',
          'videoUrl': 'https://www.youtube.com/watch?v=IODxDxX7oi4',
        },
        {
          'name': 'Bench Dips',
          'reps': '3x15',
          'videoUrl': 'https://www.youtube.com/watch?v=0326dy_-CzM',
        },
        {
          'name': 'Dumbbell Shoulder Press',
          'reps': '3x15',
          'videoUrl': 'https://www.youtube.com/watch?v=B-aVuyhvLHU',
        },
      ],
    },
    {
      'day': 'Tuesday - Pull',
      'exercises': [
        {
          'name': 'Cable Row',
          'reps': '3x15',
          'videoUrl': 'https://www.youtube.com/watch?v=HJSVR_67OlM',
        },
        {
          'name': 'Bicep Curls',
          'reps': '3x20',
          'videoUrl': 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo',
        },
        {
          'name': 'Plank',
          'reps': '3x1 min',
          'videoUrl': 'https://www.youtube.com/watch?v=pSHjTRCQxIw',
        },
      ],
    },
    {
      'day': 'Wednesday - Legs',
      'exercises': [
        {
          'name': 'Bodyweight Squats',
          'reps': '4x20',
          'videoUrl': 'https://www.youtube.com/watch?v=aclHkVaku9U',
        },
        {
          'name': 'Walking Lunges',
          'reps': '3x12',
          'videoUrl': 'https://www.youtube.com/watch?v=wrwwXE_x-pQ',
        },
        {
          'name': 'Jump Squats',
          'reps': '3x15',
          'videoUrl': 'https://www.youtube.com/watch?v=U4s4mEQ5VqU',
        },
      ],
    },
    {
      'day': 'Thursday',
      'exercises': [],
    },
    {
      'day': 'Friday - Push',
      'exercises': [
        {
          'name': 'Incline Push-ups',
          'reps': '4x20',
          'videoUrl': 'https://www.youtube.com/watch?v=EDG7Yg6tzKY',
        },
        {
          'name': 'Lateral Raises',
          'reps': '3x15',
          'videoUrl': 'https://www.youtube.com/watch?v=kDqklk1ZESo',
        },
        {
          'name': 'Triceps Dips',
          'reps': '3x12',
          'videoUrl': 'https://www.youtube.com/watch?v=0326dy_-CzM',
        },
      ],
    },
    {
      'day': 'Saturday - Pull',
      'exercises': [
        {
          'name': 'Lat Pulldown',
          'reps': '3x15',
          'videoUrl': 'https://www.youtube.com/watch?v=CAwf7n6Luuc',
        },
        {
          'name': 'Resistance Band Row',
          'reps': '3x20',
          'videoUrl': 'https://www.youtube.com/watch?v=sP_4vybjVJs',
        },
        {
          'name': 'Side Plank',
          'reps': '3x45 sec',
          'videoUrl': 'https://www.youtube.com/watch?v=K2VljzCC16g',
        },
      ],
    },
    {
      'day': 'Sunday - Cardio + Stretch',
      'exercises': [
        {
          'name': 'Light cardio (walk/cycle)',
          'reps': '30-40 min',
          'videoUrl': 'https://www.youtube.com/watch?v=ml6cT4AZdqI',
        },
        {
          'name': 'Full-body Stretching',
          'reps': '15 min',
          'videoUrl': 'https://www.youtube.com/watch?v=qULTwquOuT4',
        },
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
                        'Rest Day',
                        style: TextStyle(color: Colors.white70),
                      )
                    : Table(
                        columnWidths: {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(1),
                        },
                        children: exercises
                            .map<TableRow>(
                              (ex) => TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ex['name'],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                      if (ex['videoUrl'] != null)
                                        GestureDetector(
                                          onTap: () => _launchUrl(
                                              Uri.parse(ex['videoUrl'])),
                                          child: Text(
                                            '▶ Watch Video',
                                            style: TextStyle(
                                              color: Colors.lightBlueAccent,
                                              fontSize: 14,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    ex['reps'],
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 16),
                                  ),
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

  void _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
