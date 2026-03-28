import 'package:flutter/material.dart';
import '../models/student.dart';
import '../widgets/stat_card.dart';

class AttendanceListScreen extends StatelessWidget {
  final List<Student> attendanceList;
  final Function(Student) onMarkPresent;
  final Function(String) onMarkAbsent;

  const AttendanceListScreen({
    super.key,
    required this.attendanceList,
    required this.onMarkPresent,
    required this.onMarkAbsent,
  });

  @override
  Widget build(BuildContext context) {
    final presentCount = attendanceList.where((s) => s.isPresent).length;
    final absentCount = attendanceList.where((s) => s.isAbsent).length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatCard(
                title: "Present",
                count: presentCount,
                color: Colors.green,
                icon: Icons.check_circle,
              ),
              StatCard(
                title: "Absent",
                count: absentCount,
                color: Colors.red,
                icon: Icons.cancel,
              ),
              StatCard(
                title: "Total",
                count: attendanceList.length,
                color: Colors.blue,
                icon: Icons.people,
              ),
            ],
          ),
        ),

        Expanded(
          child: attendanceList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No students marked yet",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Scan QR codes or add manually",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: attendanceList.length,
                  itemBuilder: (context, index) {
                    final student = attendanceList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: student.isPresent
                              ? Colors.green
                              : Colors.red,
                          radius: 24,
                          child: Text(
                            student.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ID: ${student.id}"),
                            const SizedBox(height: 4),
                            Text(
                              "${student.formattedTime} • ${student.formattedDate}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: student.isPresent
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Present",
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                onPressed: () => onMarkPresent(student),
                                tooltip: "Mark Present",
                              ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
