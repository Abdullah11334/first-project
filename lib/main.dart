import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskPage(),
    );
  }
}

class Task {
  String name;
  bool received;

  Task({required this.name, this.received = false});
}

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedTasks = prefs.getStringList('tasks');
    if (savedTasks != null) {
      setState(() {
        tasks = savedTasks.map<Task>((task) => Task(name: task)).toList();
      });
    }
  }

  void saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskNames = tasks.map((task) => task.name).toList();
    await prefs.setStringList('tasks', taskNames);
  }

  void addTask(String task) {
    setState(() {
      tasks.add(Task(name: task));
      saveTasks();
    });
  }

  void deleteAllTasks() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تحذير!'),
          content: Text('هل ترغب في حذف جميع الطلبات؟'),
          actions: [
            TextButton(
              child: Text('نعم'),
              onPressed: () {
                setState(() {
                  tasks.clear();
                  saveTasks();
                });
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('لا'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void editTask(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String updatedTask = tasks[index].name;
        return AlertDialog(
          title: Text('تعديل الطلب'),
          content: TextField(
            onChanged: (value) {
              updatedTask = value;
            },
            controller: TextEditingController(text: updatedTask),
          ),
          actions: [
            TextButton(
              child: Text('حفظ'),
              onPressed: () {
                setState(() {
                  tasks[index].name = updatedTask;
                  saveTasks();
                });
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void toggleReceived(int index) {
    setState(() {
      tasks[index].received = !tasks[index].received;
      saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 245, 226),
      appBar: AppBar(
        title: Center(
          child: Text(
            'الطلبات',
            style: TextStyle(fontSize: 24.0),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  tasks[index].name,
                  textAlign: TextAlign.right, // توجيه النص إلى اليمين
                  style: TextStyle(
                    decoration: tasks[index].received
                        ? TextDecoration
                            .lineThrough // إضافة خط على النص عند التأشير
                        : TextDecoration.none, // إزالة الخط عند عدم التأشير
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    editTask(index);
                  },
                ),
              ],
            ),
            trailing: Checkbox(
              value: tasks[index].received,
              onChanged: (value) {
                toggleReceived(index);
              },
            ),
            onTap: () {
              editTask(index);
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.delete),
            onPressed: () {
              deleteAllTasks();
            },
          ),
          SizedBox(height: 16.0),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String newTask = '';
                  return AlertDialog(
                    title: Text('إضافة طلب جديد'),
                    content: TextField(
                      onChanged: (value) {
                        newTask = value;
                      },
                    ),
                    actions: [
                      TextButton(
                        child: Text('إضافة'),
                        onPressed: () {
                          if (newTask.isNotEmpty) {
                            addTask(newTask);
                          }
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text('إلغاء'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
