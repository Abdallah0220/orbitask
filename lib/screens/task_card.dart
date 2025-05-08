import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'add_task.dart';

class TaskCard extends StatelessWidget {
  final Map<String, String> task;
  final VoidCallback onDelete;
  final Function(
    String title,
    String description,
    String date,
    String status,
    String priority,
  )
  onEdit;
  final VoidCallback onComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onEdit,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 6,
            offset: Offset(0, 2),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height: 1.40,
                    ),
                  ),
                ),
                _getPriorityIcon(task['priority'] ?? 'Medium'),
                PopupMenuButton(
                  color: Colors.white,
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.screwdriverWrench,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                          onTap: () => _showEditDialog(context),
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.circleXmark,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                          onTap: onDelete,
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.check, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Mark as Complete'),
                            ],
                          ),
                          onTap: onComplete,
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task['description'] ?? '',
              style: const TextStyle(
                color: Color(0xFFB9B9B9),
                fontSize: 11,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                height: 1.40,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  task['date'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF5F33E1),
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 1.40,
                  ),
                ),
                const Spacer(),
                Text(
                  task['status'] ?? '',
                  style: TextStyle(
                    color: _getStatusColor(task['status'] ?? ''),
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 1.40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPriorityIcon(String priority) {
    switch (priority) {
      case 'High':
        return const Icon(FontAwesomeIcons.robot, color: Colors.red);
      case 'Medium':
        return const Icon(FontAwesomeIcons.robot, color: Colors.orange);
      case 'Low':
        return const Icon(FontAwesomeIcons.robot, color: Colors.green);
      default:
        return const Icon(FontAwesomeIcons.robot, color: Colors.grey);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return const Color(0xFF5F33E1);
      case 'Complete':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showEditDialog(BuildContext context) {
    String newTitle = task['title']!;
    String newDescription = task['description']!;
    String newDate = task['date']!;
    String newPriority = task['priority']!;

    showDialog(
      context: context,
      builder: (context) {
        return AddTaskDialog(
          selectedDate: DateTime.parse(newDate),
          initialTitle: newTitle,
          initialDescription: newDescription,
          initialPriority: newPriority,
          onAddTask: (title, description, date, status, priority) {
            onEdit(title, description, date, task['status']!, priority);
          },
          isEditing: true,
        );
      },
    );
  }
}
