import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class AddTaskDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(String, String, String, String, String) onAddTask;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialPriority;
  final String? initialStatus;
  final bool isEditing;

  const AddTaskDialog({
    super.key,
    required this.selectedDate,
    required this.onAddTask,
    this.initialTitle,
    this.initialDescription,
    this.initialPriority,
    this.initialStatus,
    this.isEditing = false,
  });

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late String newTaskTitle;
  late String newTaskDescription;
  late String newTaskDate;
  late String newTaskPriority;
  late String newTaskStatus;
  final List<String> priorities = ['High', 'Medium', 'Low'];
  bool showPriorityList = false;

  @override
  void initState() {
    super.initState();
    newTaskTitle = widget.initialTitle ?? '';
    newTaskDescription = widget.initialDescription ?? '';
    newTaskDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    newTaskPriority = widget.initialPriority ?? 'Medium';
    newTaskStatus = widget.initialStatus ?? 'In Progress';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: screenWidth * 0.9,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                widget.isEditing ? 'Edit Task' : 'Add Task',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Task Name',
                value: newTaskTitle,
                onChanged: (val) => newTaskTitle = val,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Description',
                value: newTaskDescription,
                onChanged: (val) => newTaskDescription = val,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _buildDatePicker(context, screenWidth),
              const SizedBox(height: 16),

              // Priority Selector as a dropdown list
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showPriorityList = !showPriorityList;
                      });
                    },
                    child: Container(
                      width: screenWidth * 0.8,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          newTaskPriority,
                          style: TextStyle(
                            color: _getPriorityColor(newTaskPriority),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showPriorityList)
                    Container(
                      width: screenWidth * 0.8,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children:
                            priorities.map((priority) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    newTaskPriority = priority;
                                    showPriorityList = false;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      bottom:
                                          priority != priorities.last
                                              ? BorderSide(
                                                color: Colors.grey.shade200,
                                              )
                                              : BorderSide.none,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.robot,
                                        color: _getPriorityColor(priority),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        priority,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _getPriorityColor(priority),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    screenWidth,
                    label: 'Close',
                    color: Colors.grey.shade200,
                    textColor: Colors.black,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildActionButton(
                    screenWidth,
                    label: widget.isEditing ? 'Update' : 'Add',
                    color: const Color(0xFF5F33E1),
                    textColor: Colors.white,
                    onTap: () {
                      widget.onAddTask(
                        newTaskTitle,
                        newTaskDescription,
                        newTaskDate,
                        newTaskStatus,
                        newTaskPriority,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required void Function(String) onChanged,
    int maxLines = 1,
  }) {
    final controller = TextEditingController(text: value);
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    return TextField(
      maxLines: maxLines,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, double screenWidth) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: widget.selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF5F33E1),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          setState(() {
            newTaskDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
      child: Container(
        width: screenWidth * 0.8,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            newTaskDate,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

Widget _buildActionButton(
  double width, {
  required String label,
  required Color color,
  required Color textColor,
  required VoidCallback onTap,
}) {
  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: textColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: Size(width * 0.35, 40),
    ),
    child: Text(label),
  );
}

Color _getPriorityColor(String priority) {
  switch (priority) {
    case 'High':
      return Colors.red;
    case 'Medium':
      return Colors.orange;
    case 'Low':
      return Colors.green;
    default:
      return Colors.grey;
  }
}
