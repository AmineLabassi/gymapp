import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GymProgramPage extends StatefulWidget {
  final String goal;

  const GymProgramPage({required this.goal});

  @override
  State<GymProgramPage> createState() => _GymProgramPageState();
}

class _GymProgramPageState extends State<GymProgramPage> {
  List<dynamic> program = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProgram();
  }

  Future<void> fetchProgram() async {
    try {
      final url = Uri.parse('http://192.168.1.4:5000/gym'); 
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final selected = data.firstWhere(
          (p) => p['goal'].toLowerCase() == widget.goal.toLowerCase(),
          orElse: () => {'program': []},
        );

        setState(() {
          program = selected['program'];
          loading = false;
        });
      } else {
        throw Exception('Failed to load program');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('Error fetching program: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      appBar: AppBar(
        title: Text('Gym Programme'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
                          fontWeight: FontWeight.bold,
                        ),
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
                                    (ex) => TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ex['name'],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if (ex['videoUrl'] != null && ex['videoUrl'].toString().isNotEmpty)
                                                GestureDetector(
                                                  onTap: () => _launchUrl(Uri.parse(ex['videoUrl'])),
                                                  child: Text(
                                                    '▶ Watch Video',
                                                    style: TextStyle(
                                                      color: Colors.lightBlueAccent,
                                                      fontSize: 14,
                                                      decoration: TextDecoration.underline,
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
                                            style: TextStyle(color: Colors.white70, fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
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
