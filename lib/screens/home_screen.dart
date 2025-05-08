import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'task_card.dart';
import 'add_task.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> tasks = [];
  DateTime selectedDate = DateTime.now();
  int activeSwitchIndex = 0;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeTimeZones();
    _initializeNotifications();
    _requestNotificationPermission();
    _loadTasks();
  }

  Future<void> _initializeTimeZones() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_channel',
      'Tasks Notifications',
      importance: Importance.high,
      description: 'Channel for task reminders',
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestNotificationPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  void _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? taskData = prefs.getString('tasks');
    if (taskData != null) {
      List<dynamic> taskList = jsonDecode(taskData);
      setState(() {
        tasks = taskList.map((task) => Map<String, String>.from(task)).toList();
      });
    }
    _scheduleAllNotifications();
  }

  void _scheduleAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();

    final now = DateTime.now();
    for (var task in tasks) {
      final taskDate = DateTime.parse(task['date']!);

      if (taskDate.isAfter(now.subtract(const Duration(days: 1)))) {
        _scheduleNotification(task);
      }
    }
  }

  Future<void> _scheduleNotification(Map<String, String> task) async {
    final taskDate = DateTime.parse(task['date']!);
    final scheduledDate = tz.TZDateTime.from(taskDate, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      tasks.indexOf(task),
      task['title'],
      task['description'],
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Tasks Notifications',
          importance: Importance.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  void _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String taskData = jsonEncode(tasks);
    prefs.setString('tasks', taskData);
  }

  void _addTask(
    String title,
    String description,
    String date,
    String status,
    String priority,
  ) {
    setState(() {
      tasks.add({
        'title': title,
        'description': description,
        'date': date,
        'status': status,
        'priority': priority,
      });
    });
    _saveTasks();
    _scheduleNotification(tasks.last);
  }

  void _removeTask(int index) async {
    await flutterLocalNotificationsPlugin.cancel(index);
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _editTask(
    int index,
    String title,
    String description,
    String date,
    String status,
    String priority,
  ) {
    flutterLocalNotificationsPlugin.cancel(index);
    setState(() {
      tasks[index] = {
        'title': title,
        'description': description,
        'date': date,
        'status': status,
        'priority': priority,
      };
    });
    _saveTasks();
    _scheduleNotification(tasks[index]);
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTaskDialog(selectedDate: selectedDate, onAddTask: _addTask);
      },
    );
  }

  void _resetToToday() {
    setState(() {
      selectedDate = DateTime.now();
      _focusedDay = DateTime.now();
    });
  }

  List<Map<String, String>> _getFilteredTasks() {
    return tasks.where((task) {
      final taskDate = DateTime.parse(task['date']!);
      final isSameDay =
          taskDate.year == selectedDate.year &&
          taskDate.month == selectedDate.month &&
          taskDate.day == selectedDate.day;

      if (!isSameDay) return false;

      if (activeSwitchIndex == 0) return true;
      if (activeSwitchIndex == 1) return task['status'] == 'In Progress';
      if (activeSwitchIndex == 2) return task['status'] == 'Complete';

      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          title: Image.asset(
            'assets/images/logo1.png',
            height: 100,
            width: 120,
            fit: BoxFit.contain,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenWidth * 0.01),
              _buildChooseDateWithReload(),
              SizedBox(height: screenWidth * 0.02),
              _buildCalendar(),
              SizedBox(height: screenWidth * 0.05),
              _buildSwitch(screenWidth),
              SizedBox(height: screenWidth * 0.05),
              _buildTaskList(filteredTasks),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(
          FontAwesomeIcons.spider,
          color: Color(0xFF5F33E1),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildChooseDateWithReload() {
    return Row(
      children: [
        const Text(
          'Choose date',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            height: 1.40,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF5F33E1)),
          onPressed: _resetToToday,
          tooltip: 'Reset to today',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          iconSize: 20,
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          selectedDate = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) => setState(() => _calendarFormat = format),
      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
      calendarStyle: const CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Color(0xFF5F33E1),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Color(0xFFEDE8FF),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildSwitch(double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE8FF),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: activeSwitchIndex * (screenWidth * 0.9 / 3),
            child: Container(
              width: (screenWidth * 0.9 / 3),
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF5F33E1),
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => activeSwitchIndex = 0),
                  child: Center(
                    child: Text(
                      'All tasks',
                      style: TextStyle(
                        color:
                            activeSwitchIndex == 0
                                ? Colors.white
                                : const Color(0xFF5F33E1),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 1.40,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => activeSwitchIndex = 1),
                  child: Center(
                    child: Text(
                      'In progress',
                      style: TextStyle(
                        color:
                            activeSwitchIndex == 1
                                ? Colors.white
                                : const Color(0xFF5F33E1),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 1.40,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => activeSwitchIndex = 2),
                  child: Center(
                    child: Text(
                      'Complete',
                      style: TextStyle(
                        color:
                            activeSwitchIndex == 2
                                ? Colors.white
                                : const Color(0xFF5F33E1),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 1.40,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, String>> tasksToShow) {
    return Column(
      children:
          tasksToShow.map((task) {
            return TaskCard(
              task: task,
              onDelete: () => _removeTask(tasks.indexOf(task)),
              onEdit:
                  (title, description, date, status, priority) => _editTask(
                    tasks.indexOf(task),
                    title,
                    description,
                    date,
                    status,
                    priority,
                  ),
              onComplete:
                  () => _editTask(
                    tasks.indexOf(task),
                    task['title']!,
                    task['description']!,
                    task['date']!,
                    'Complete',
                    task['priority']!,
                  ),
            );
          }).toList(),
    );
  }
}
