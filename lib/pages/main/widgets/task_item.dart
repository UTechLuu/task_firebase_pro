import 'package:flutter/material.dart';
import '../../../models/task_model.dart';
import '../../../resources/app_color.dart';

class TaskItem extends StatelessWidget {
  const TaskItem(
    this.task, {
    super.key,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // onLongPress: onLongTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.6)
            .copyWith(left: 14.0, right: 8.0),
        decoration: BoxDecoration(
          color: AppColor.white,
          border: const Border(
              left: BorderSide(width: 8, color: Colors.orangeAccent)),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: AppColor.shadow,
              offset: Offset(0.0, 3.0),
              blurRadius: 6.0,
            ),
          ],
        ),
        foregroundDecoration: BoxDecoration(
          border: const Border(left: BorderSide(width: 4, color: Colors.pink)),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Icon(
              () {
                if (task.isDone == true) {
                  return Icons.check_box_outlined;
                }
                return Icons.check_box_outline_blank;
              }(),
              size: 16.8,
              color: AppColor.blue,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.6, right: 4.6),
                child: Text(
                  task.text ?? '-:-',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    decoration: task.isDone == true
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            InkWell(
              onTap: onEdit,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(4.6),
                child: CircleAvatar(
                  backgroundColor: AppColor.green.withOpacity(0.68),
                  radius: 12.0,
                  child:
                      const Icon(Icons.edit, size: 14.0, color: AppColor.white),
                ),
              ),
            ),
            InkWell(
              onTap: onDelete,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: const Padding(
                padding: EdgeInsets.all(4.6),
                child: CircleAvatar(
                  backgroundColor: AppColor.orange,
                  radius: 12.0,
                  child: Icon(Icons.delete, size: 14.0, color: AppColor.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
