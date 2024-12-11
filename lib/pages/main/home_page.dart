import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../components/app_box_shadow.dart';
import '../../components/app_dialog.dart';
import '../../components/td_search_box.dart';
import '../../models/task_model.dart';
import '../../resources/app_color.dart';
import '../../shared_prefs.dart';
import 'widgets/task_item.dart';

// collection la mot tap hop chua cac document
// document bao gom id cua document va data
// data bao gom cac colection va cac field
// khi update cac field se day du lieu len theo dang map

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  final addController = TextEditingController();
  final addFocus = FocusNode();
  bool showAddBox = false;
  bool isLoading = false;
  List<TaskModel> tasks = [];
  List<TaskModel> searchList = [];

  // tao tham chieu den collection database
  CollectionReference taskCollection =
      FirebaseFirestore.instance.collection('tasks2');

  @override
  void initState() {
    super.initState();
    _getData();
    // searchController.addListener(() {
    //   setState(() {});
    // });
  }

  Future<void> _getData() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1600));

    taskCollection
        .orderBy('id', descending: false)
        .get()
        .then((data) {
          tasks = data.docs
              .map((e) => TaskModel.fromJson(e.data() as Map<String, dynamic>)
                ..docId = e.id)
              .where((e) => e.createBy == SharedPrefs.user?.email)
              .toList();
          searchList = [...tasks];
          setState(() {});
        })
        .catchError((onError) {})
        .whenComplete(() {
          setState(() => isLoading = false);
        });
  }

  void _search(String value) {
    value = value.toLowerCase();
    searchList = tasks
        .where((e) => (e.text ?? '').toLowerCase().contains(value))
        .toList();
    setState(() {});
  }

  void _addTask(TaskModel task) {
    taskCollection
        .add(task.toJson()) // id cua document se tu dong sinh ra
        .then((value) {
      tasks.add(task..docId = value.id);
      searchList = [...tasks];
      addController.clear();
      searchController.clear();
      showAddBox = false;
      setState(() {});
      addFocus.unfocus();
    }).catchError((error) {
      dev.log("Failed to add Task: $error");
    });
  }

  void _updateTask(TaskModel task) {
    taskCollection.doc(task.docId).update(task.toJson()).then((_) {
      tasks.singleWhere((e) => e.docId == task.docId)
        ..text = task.text
        ..isDone = task.isDone;
      setState(() {});
    }).catchError((error) {
      dev.log("Failed to update Task: $error");
    });
  }

  void _deleteTask(String docId) {
    taskCollection.doc(docId).delete().then((_) {
      tasks.removeWhere((e) => e.docId == docId);
      searchList.removeWhere((e) => e.docId == docId);
      setState(() {});
    }).catchError((error) {
      dev.log("Failed to delete Task: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 12.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TdSearchBox(
                    controller: searchController,
                    onChanged: _search,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Divider(
                  height: 1.2,
                  thickness: 1.2,
                  indent: 20.0,
                  endIndent: 20.0,
                  color: AppColor.orange,
                ),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColor.primary),
                        )
                      : searchList.isEmpty
                          ? Center(
                              child: Text(
                                searchController.text.isEmpty
                                    ? 'Tasks is empty'
                                    : 'There is no result',
                                style: const TextStyle(
                                  color: AppColor.brown,
                                  fontSize: 20.0,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0)
                                      .copyWith(top: 12.0, bottom: 92.0),
                              itemCount: searchList.length,
                              itemBuilder: (_, idx) {
                                TaskModel task =
                                    searchList.reversed.toList()[idx];
                                return TaskItem(
                                  task,
                                  onTap: () {
                                    task.isDone = !(task.isDone ?? false);
                                    _updateTask(task);
                                  },
                                  onEdit: () async {
                                    task = await AppDialog.editTask2(
                                        context, task);
                                    _updateTask(task);
                                  },
                                  onDelete: () {
                                    AppDialog.dialog(
                                      context,
                                      title: const Text('😐'),
                                      content: 'Do you want to delete task?',
                                      action: () =>
                                          _deleteTask(task.docId ?? ''),
                                    );
                                  },
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 18.0),
                            ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20.0,
            right: 20.0,
            bottom: 16.0,
            child: Row(
              children: [
                Expanded(
                  child: Visibility(
                    visible: showAddBox,
                    child: _addBox(
                      controller: addController,
                      focusNode: addFocus,
                    ),
                  ),
                ),
                const SizedBox(width: 18.0),
                _addButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTap: () {
        if (!showAddBox) {
          showAddBox = true;
          setState(() {});
          addFocus.requestFocus();
          return;
        }

        String text = addController.text.trim();
        if (text.isEmpty) {
          showAddBox = false;
          setState(() {});
          addFocus.unfocus();
          return;
        }

        final task = TaskModel()
          ..id = '${DateTime.now().millisecondsSinceEpoch}'
          ..text = addController.text.trim()
          ..isDone = false
          ..createBy = SharedPrefs.user?.email;
        _addTask(task);
      },
      child: Container(
        padding: const EdgeInsets.all(14.6),
        decoration: BoxDecoration(
          color: AppColor.blue,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: AppBoxShadow.boxShadow,
        ),
        child: const Icon(Icons.add, size: 32.0, color: AppColor.white),
      ),
    );
  }

  Widget _addBox({TextEditingController? controller, FocusNode? focusNode}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.6),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.blue),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: AppBoxShadow.boxShadow,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Add a new task',
          hintStyle: TextStyle(color: AppColor.grey),
        ),
      ),
    );
  }
}
