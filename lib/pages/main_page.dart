import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../components/td_app_bar.dart';
import '../components/td_zoom_drawer.dart';
import '../constants/app_constant.dart';
import '../resources/app_color.dart';
import '../shared_prefs.dart';
import 'main/drawer_page.dart';
import 'main/home_page.dart';
import 'profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final zoomDrawerController = ZoomDrawerController();

  @override
  void initState() {
    super.initState();
  }

  toggleDrawer() {
    zoomDrawerController.toggle?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.bgColor,
        appBar: TdAppBar(
          leftPressed: toggleDrawer,
          rightPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const ProfilePage(),
          )),
          title: widget.title,
          avatar:
              '${AppConstant.endPointBaseImage}/${SharedPrefs.user?.avatar ?? ''}',
        ),
        body: TdZoomDrawer(
          controller: zoomDrawerController,
          menuScreen: const DrawerPage(),
          screen: const HomePage(title: 'Tasks'),
        ),
      ),
    );
  }
}
