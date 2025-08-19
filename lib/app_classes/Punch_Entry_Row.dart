import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

class PunchEntryRow extends StatefulWidget {
  final String title;
  final bool alternateColor;
  final VoidCallback onPressed;
  final bool punched;
  final String punchType; // Add punchType to identify different punch entry types

  PunchEntryRow({
    required this.title,
    required this.alternateColor,
    required this.onPressed,
    required this.punched,
    required this.punchType,
  });

  @override
  _PunchEntryRowState createState() => _PunchEntryRowState();
}

class _PunchEntryRowState extends State<PunchEntryRow> {
  bool buttonEnabled = false; // Initialize with a default value
  String punchTime = ''; // Initialize with an empty string

  @override
  void initState() {
    super.initState();
    // Load punch data from SharedPreferences
    loadPunchData();
  }

  void loadPunchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastPunchDate = prefs.getString('last_punch_date');

    if (lastPunchDate != getCurrentDate()) {
      setState(() {
        buttonEnabled = true;
      });
    } else {
      setState(() {
        // Use punchType to identify each punch entry type
        buttonEnabled = prefs.getBool('buttonEnabled_${widget.punchType}') ?? true;
      });
    }

    setState(() {
      punchTime = prefs.getString('punchTime_${widget.punchType}') ?? '';
    });
  }

  void updateAndSavePunchData() async {
    final now = DateTime.now();
    final formattedTime = "${now.hour}:${now.minute}:${now.second}";
    final formattedDate = getCurrentDate();
    final punchTimeText = "$formattedTime $formattedDate";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('punchTime_${widget.punchType}', punchTimeText);
    prefs.setBool('buttonEnabled_${widget.punchType}', false); // Disable the button
    prefs.setString('last_punch_date', formattedDate); // Update last punch date

    setState(() {
      punchTime = punchTimeText;
      buttonEnabled = false;
    });
  }

  String getCurrentDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final Color? backgroundColor =
    widget.alternateColor ? Colors.grey[200] : Colors.white;
    final Color punchButtonColor = Colors.blue;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.0), // Add some space between title and button
              ElevatedButton(
                onPressed: buttonEnabled
                    ? () {
                  widget.onPressed();
                  if (!widget.punched) {
                    updateAndSavePunchData();
                  }
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.punched ? Colors.green : punchButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  widget.punched ? 'Punched' : 'Punch',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              if (punchTime != null && punchTime!.contains(getCurrentDate()))
                Text(
                  punchTime!,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
        ),
        color: backgroundColor,
      ),
    );
  }
}
