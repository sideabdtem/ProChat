import 'package:flutter/material.dart';

class AdminReportsFlagsPage extends StatefulWidget {
  const AdminReportsFlagsPage({super.key});

  @override
  State<AdminReportsFlagsPage> createState() => _AdminReportsFlagsPageState();
}

class _AdminReportsFlagsPageState extends State<AdminReportsFlagsPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Reports & Flags',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This feature will be implemented in the future',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}