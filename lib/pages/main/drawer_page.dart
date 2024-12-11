import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../components/app_dialog.dart';
import '../../gen/assets.gen.dart';
import '../../resources/app_color.dart';
import '../../shared_prefs.dart';
import '../auth/change_password_page.dart';
import '../auth/login_page.dart';
import '../profile/profile_page.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    const iconSize = 18.0;
    const iconColor = AppColor.orange;
    const spacer = 6.0;
    const textStyle = TextStyle(color: AppColor.brown, fontSize: 16.0);

    return Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Welcome',
              style: TextStyle(color: AppColor.red, fontSize: 20.0)),
          Text(
            SharedPrefs.user?.name ?? '',
            style: const TextStyle(
                color: AppColor.brown,
                fontSize: 16.8,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 18.0),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ProfilePage(),
            )),
            child: const Row(
              children: [
                Icon(Icons.person, size: iconSize, color: iconColor),
                SizedBox(width: spacer),
                Text('My Profile', style: textStyle),
              ],
            ),
          ),
          const SizedBox(height: 18.0),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ChangePasswordPage(),
            )),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, size: iconSize, color: iconColor),
                SizedBox(width: spacer),
                Text('Change Password', style: textStyle),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 16.0, right: 20.0),
            height: 1.2,
            color: AppColor.grey,
          ),
          const Spacer(flex: 1),
          Row(
            children: [
              const SizedBox(width: 12.0),
              Expanded(child: Image.asset(Assets.images.todoIconTwo.path)),
            ],
          ),
          const Spacer(flex: 2),
          InkWell(
            onTap: () => AppDialog.dialog(
              context,
              title: const Text('😍'),
              content: 'Do you want to logout?',
              action: () async {
                await FirebaseAuth.instance.signOut();
                await SharedPrefs.removeSeason();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: const Row(
              children: [
                Icon(Icons.logout, size: iconSize, color: iconColor),
                SizedBox(width: spacer),
                Text('Logout', style: textStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
