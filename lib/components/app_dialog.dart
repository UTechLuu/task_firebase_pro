import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task_model.dart';
import '../resources/app_color.dart';
import 'button/td_elevated_button.dart';

class AppDialog {
  AppDialog._();

  static void dialog(
    BuildContext context, {
    Widget? title,
    required String content,
    Function()? action,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: title,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  content,
                  style: const TextStyle(color: Colors.brown, fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TdElevatedButton.smallOutline(
                  onPressed: () {
                    action?.call();
                    Navigator.pop(context);
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  text: 'Yes',
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: TdElevatedButton.smallOutline(
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    text: 'No',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Future<void> confirmExitApp(BuildContext context) async {
    bool? status = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('😍'),
        content: const Text(
          'Do you want to exit app?',
          style: TextStyle(color: Colors.brown, fontSize: 18.0),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TdElevatedButton.smallOutline(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                text: 'Yes',
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: TdElevatedButton.smallOutline(
                  onPressed: () => Navigator.pop(context, false),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  text: 'No',
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (status == true) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  static Future<TaskModel> editTask(BuildContext context, TaskModel task) {
    String text = task.text ?? '';
    TextEditingController editController = TextEditingController(text: text);
    bool textEmpty = text.isEmpty;
    bool isDone = task.isDone ?? false;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStatus) {
          return AlertDialog(
            title: Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.8),
                radius: 14.0,
                child: const Icon(Icons.edit, size: 16.0, color: Colors.white),
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: editController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                    ),
                    onChanged: (value) =>
                        setStatus(() => textEmpty = value.isEmpty),
                  ),
                  const SizedBox(height: 14.6),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setStatus(() => isDone = !isDone),
                        behavior: HitTestBehavior.translucent,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 4.0, right: 8.0, bottom: 5.6),
                          child: Icon(
                            isDone
                                ? Icons.check_box_outlined
                                : Icons.check_box_outline_blank,
                            size: 18.6,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const Text('Is Done', style: TextStyle(fontSize: 16.0)),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TdElevatedButton.smallOutline(
                    onPressed: textEmpty
                        ? null
                        : () {
                            Navigator.pop(context, true);
                          },
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    textColor: textEmpty
                        ? AppColor.orange.withOpacity(0.6)
                        : AppColor.red,
                    borderColor: textEmpty
                        ? AppColor.orange.withOpacity(0.6)
                        : AppColor.red,
                    text: 'Save',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: TdElevatedButton.smallOutline(
                      onPressed: () => Navigator.pop(context, false),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      text: 'Cancel',
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    ).then((value) {
      if (value == true) {
        return task
          ..text = editController.text.trim()
          ..isDone = isDone;
      }
      return task;
    });
  }

  static Future<TaskModel> editTask2(BuildContext context, TaskModel task) {
    String text = task.text ?? '';
    TextEditingController editController = TextEditingController(text: text);
    bool textEmpty = text.isEmpty;
    bool isDone = task.isDone ?? false;
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setStatus) {
          return FractionallySizedBox(
            heightFactor: 0.46,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CircleAvatar(
                        backgroundColor: Colors.orange.withOpacity(0.8),
                        radius: 14.0,
                        child: const Icon(Icons.edit,
                            size: 16.0, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: editController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                      ),
                      onChanged: (value) =>
                          setStatus(() => textEmpty = value.isEmpty),
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setStatus(() => isDone = true),
                          behavior: HitTestBehavior.translucent,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              padding: const EdgeInsets.all(2.6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: Colors.red, width: 1.2),
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                backgroundColor:
                                    isDone ? Colors.red : Colors.white,
                                radius: 6.4,
                              ),
                            ),
                          ),
                        ),
                        const Text('Is Done', style: TextStyle(fontSize: 16.0)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setStatus(() => isDone = false),
                          behavior: HitTestBehavior.translucent,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              padding: const EdgeInsets.all(2.6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: Colors.red, width: 1.2),
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                backgroundColor:
                                    isDone ? Colors.white : Colors.red,
                                radius: 6.4,
                              ),
                            ),
                          ),
                        ),
                        const Text('Not Is Done',
                            style: TextStyle(fontSize: 16.0)),
                      ],
                    ),
                    const SizedBox(height: 36.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TdElevatedButton.smallOutline(
                          onPressed: textEmpty
                              ? null
                              : () {
                                  Navigator.pop(context, true);
                                },
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          textColor: textEmpty
                              ? AppColor.orange.withOpacity(0.6)
                              : AppColor.red,
                          borderColor: textEmpty
                              ? AppColor.orange.withOpacity(0.6)
                              : AppColor.red,
                          text: 'Save',
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: TdElevatedButton.smallOutline(
                            onPressed: () => Navigator.pop(context, false),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            text: 'Cancel',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    ).then((value) {
      if (value == true) {
        return task
          ..text = editController.text.trim()
          ..isDone = isDone;
      }
      return task;
    });
  }
}
