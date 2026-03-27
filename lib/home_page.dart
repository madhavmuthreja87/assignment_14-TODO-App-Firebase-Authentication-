import "dart:convert";
import "dart:developer";
import "dart:io";
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:crud_todo/signUp.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:crud_todo/task.dart";
import "package:image_picker/image_picker.dart";
import "package:shared_preferences/shared_preferences.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Task> tasks = List.empty(growable: true);
  void loadTasks() async {
    var snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("tasks")
        .get();
    setState(() {
      tasks = snapshot.docs.map((doc) {
        return Task(task: doc["task"], done: doc["done"], id: doc.id);
      }).toList();
    });
  }

  TextEditingController taskController = TextEditingController();
  File? pickedImage;
  DateTime time = DateTime.now();
  FocusNode ftask = FocusNode();
  int selectedIndex = -1;
  var mode = false; // 0 for light mode and 1 for dark mode

  late SharedPreferences sp;
  saveMode() async {
    await sp.setBool("darkMode", mode);
  }

  getSharedPreferences() async {
    sp = await SharedPreferences.getInstance();

    readFromSp();
  }

  saveIntoSp() {
    List<String> taskListString = tasks
        .map((task) => jsonEncode(task.toJson()))
        .toList();
    sp.setStringList('$uid-myData', taskListString);
  }

  readFromSp() {
    List<String>? taskListString = sp.getStringList('$uid-myData');
    setState(() {
      if (taskListString != null) {
        tasks = taskListString
            .map((task) => Task.fromJson(json.decode(task)))
            .toList();
      }
    });
    mode = sp.getBool("darkMode") ?? false;
  }

  @override
  void initState() {
    getSharedPreferences();
    loadTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mode == true
          ? const Color.fromARGB(255, 65, 64, 64)
          : const Color.fromARGB(237, 255, 255, 255),
      drawer: Drawer(
        backgroundColor: mode
            ? const Color.fromARGB(175, 0, 0, 0)
            : const Color.fromARGB(192, 255, 255, 255),
        width: 240,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color.fromARGB(228, 0, 0, 0),
                    width: 2,
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF209cff), Color(0xFF68e0cf)],
                ),
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: pickedImage != null
                                ? CircleAvatar(
                                    radius: 25,

                                    backgroundImage: FileImage(pickedImage!),
                                  )
                                : CircleAvatar(
                                    radius: 25,

                                    child: Icon(Icons.person_2_outlined),
                                  ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              FirebaseAuth.instance.currentUser?.displayName ??
                                  "User",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              FirebaseAuth.instance.currentUser?.email ??
                                  "Users",
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        "To do List\n${time.day}/${time.month}/${time.year}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 5,
              child: ListTile(
                tileColor: mode
                    ? const Color.fromARGB(83, 0, 0, 0)
                    : Colors.white,
                textColor: mode
                    ? const Color.fromARGB(216, 255, 255, 255)
                    : Colors.black,
                title: Text(
                  "Dark mode ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                trailing: CupertinoSwitch(
                  value: mode,

                  onChanged: (value) {
                    setState(() {
                      mode = value;
                    });
                    saveMode();
                  },
                ),
              ),
            ),
            Card(
              elevation: 5,

              child: ListTile(
                tileColor: mode
                    ? const Color.fromARGB(83, 0, 0, 0)
                    : Colors.white,
                textColor: mode
                    ? const Color.fromARGB(216, 255, 255, 255)
                    : Colors.black,
                title: Text(
                  "Clear all tasks",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
                trailing: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierColor: const Color.fromARGB(72, 50, 50, 50),
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: Text(
                            "Clear Tasks",
                            style: TextStyle(fontSize: 18),
                          ),
                          content: Text(
                            "Are you sure you want to delete?",
                            style: TextStyle(fontSize: 14.5),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                var snapshot = await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(uid)
                                    .collection("tasks")
                                    .get();
                                for (var doc in snapshot.docs) {
                                  doc.reference.delete();
                                }
                                setState(() {
                                  tasks = List.empty(growable: true);
                                });
                                sp.remove('$uid-myData');
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.transparent,

                    child: Icon(
                      Icons.delete_forever_rounded,
                      size: 26,
                      color: mode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Card(
              elevation: 5,

              child: ListTile(
                tileColor: mode
                    ? const Color.fromARGB(83, 0, 0, 0)
                    : Colors.white,
                textColor: mode
                    ? const Color.fromARGB(216, 255, 255, 255)
                    : Colors.black,
                title: Text(
                  "Log out",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
                trailing: InkWell(
                  onTap: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()),
                    );
                    await FirebaseAuth.instance.signOut();
                  },
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.transparent,

                    child: Icon(
                      Icons.logout_rounded,
                      size: 26,
                      color: mode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Card(
              elevation: 5,
              child: ListTile(
                tileColor: mode
                    ? const Color.fromARGB(83, 0, 0, 0)
                    : Colors.white,
                textColor: mode
                    ? const Color.fromARGB(216, 255, 255, 255)
                    : Colors.black,
                title: Text(
                  "Add profile image",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
                trailing: InkWell(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Pick image from"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                onTap: () async {
                                  await pickImage(ImageSource.camera);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  
                                },
                                leading: Icon(Icons.camera),
                                title: Text("Camera"),
                              ),
                              ListTile(
                                onTap: () async {
                                  await pickImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                leading: Icon(Icons.image),
                                title: Text("Gallery"),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.transparent,

                    child: Icon(
                      Icons.image_rounded,
                      size: 26,
                      color: mode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 70,
        width: 65,

        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 32, 155, 255), Color(0xFF68e0cf)],
          ),
        ),
        child: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: Colors.transparent,

          onPressed: () {
            ftask.requestFocus();
          },
          child: Icon(
            Icons.add,
            size: 27,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          "To Do List (${time.day}/${time.month}/${time.year})",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: mode ? const Color.fromARGB(182, 0, 0, 0) : Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(214, 32, 155, 255), Color(0xFF68e0cf)],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: taskController,
              focusNode: ftask,
              cursorColor: mode ? Colors.white : Colors.black,
              style: TextStyle(color: mode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Enter your task...",
                hintStyle: TextStyle(color: mode ? Colors.white : Colors.black),

                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF209cff), width: 3),
                  borderRadius: BorderRadius.circular(27),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 95, 149, 224),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  height: 40,
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 6,
                      backgroundColor: Color.fromARGB(214, 32, 155, 255),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () async {
                      String t = taskController.text.trim();
                      var docref = await FirebaseFirestore.instance
                          .collection("users")
                          .doc(uid)
                          .collection("tasks")
                          .add({"task": t, "done": false});
                      setState(() {
                        if (t.isNotEmpty) {
                          taskController.text = "";
                          tasks.add(Task(task: t, done: false, id: docref.id));

                          selectedIndex = -1;
                        }
                      });
                      saveIntoSp();
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: mode ? Colors.black : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 6,
                      backgroundColor: Color(0xFF68e0cf),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      setState(() {
                        tasks[selectedIndex].task = taskController.text;
                        taskController.text = "";
                        tasks[selectedIndex].done = false;
                      });
                      saveIntoSp();
                    },
                    child: Text(
                      "Update",
                      style: TextStyle(
                        color: mode ? Colors.black : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Expanded(
              child: tasks.isEmpty
                  ? Column(
                      children: [
                        SizedBox(height: 150),
                        Text(
                          "No task saved yet!!!",
                          style: TextStyle(
                            color: mode ? Colors.white : Colors.black,
                            fontSize: 23,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) => getRows(index, tasks),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  pickImage(ImageSource imageSource) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageSource);
      if (photo == null) return;

      final tempImage = File(photo.path);
      setState(() {
        pickedImage = tempImage;
      });
    } catch (ex) {
      log(ex.toString());
    }
  }

  getRows(int index, dynamic tasks) {
    return Card(
      elevation: 7,
      color: Colors.transparent,

      shadowColor: mode
          ? const Color.fromARGB(126, 255, 255, 255)
          : const Color.fromARGB(255, 0, 0, 0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
        textColor: mode
            ? const Color.fromARGB(217, 255, 255, 255)
            : Colors.black,
        tileColor: mode ? const Color.fromARGB(163, 0, 0, 0) : Colors.white,
        dense: true,
        leading: Checkbox(
          value: tasks[index].done,
          activeColor: const Color.fromARGB(255, 107, 203, 110),
          checkColor: const Color.fromARGB(255, 255, 255, 255),
          side: BorderSide(
            color: mode ? Colors.white : Colors.black,
            width: 1.8,
          ),
          onChanged: (value) {
            setState(() {
              tasks[index].done = value!;
            });
          },
        ),
        title: Text(
          tasks[index].task,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w500,
            decoration: tasks[index].done
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            decorationColor: mode ? Colors.white : Colors.black,
            color: mode
                ? tasks[index].done
                      ? Colors.grey
                      : Colors.white
                : tasks[index].done
                ? const Color.fromARGB(195, 158, 158, 158)
                : Colors.black,
          ),
        ),

        trailing: SizedBox(
          width: 55,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  taskController.text = tasks[index].task;
                  setState(() {
                    selectedIndex = index;
                  });
                  ftask.requestFocus();
                },
                child: Icon(
                  Icons.edit_rounded,
                  size: 19,
                  color: mode
                      ? const Color.fromARGB(207, 255, 255, 255)
                      : Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(uid)
                      .collection("tasks")
                      .doc(tasks[index].id)
                      .delete();
                  setState(() {
                    tasks.removeAt(index);
                  });

                  saveIntoSp();
                },
                child: Icon(
                  Icons.delete_forever_rounded,
                  size: 24,
                  color: mode
                      ? const Color.fromARGB(227, 255, 255, 255)
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
