import 'dart:io';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../components/button/td_elevated_button.dart';
import '../../components/snack_bar/td_snack_bar.dart';
import '../../components/snack_bar/top_snack_bar.dart';
import '../../components/text_field/td_text_field.dart';
import '../../constants/app_constant.dart';
import '../../gen/assets.gen.dart';
import '../../models/user_model.dart';
import '../../resources/app_color.dart';
import '../../shared_prefs.dart';
import '../../utils/post_image.dart';
import '../../utils/validator.dart';
import '../main_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  PostImage postImage = PostImage();
  final formKey = GlobalKey<FormState>();
  File? fileAvatar;
  bool isLoading = false;
  UserModel user = SharedPrefs.user ?? UserModel();

  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users'); // tham chieu

  Future<void> pickAvatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result == null) return;
    fileAvatar = File(result.files.single.path!);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    nameController.text = user.name ?? '';
    emailController.text = user.email ?? '';
    // setState(() {});
  }

  Future<void> _updateProfile(BuildContext context) async {
    if (formKey.currentState!.validate() == false) {
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));

    final body = UserModel()
      ..name = nameController.text.trim()
      ..email = emailController.text.trim()
      ..avatar = fileAvatar != null
          ? await postImage.post(image: fileAvatar!)
          : SharedPrefs.user?.avatar;

    userCollection.doc(user.email).update(body.toJson()).then((_) {
      SharedPrefs.user = body;

      if (!context.mounted) return;
      showTopSnackBar(
        context,
        const TDSnackBar.success(message: 'Profile has been saved 😍'),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainPage(title: 'Tasks'),
        ),
        (Route<dynamic> route) => false,
      );
    }).catchError((error) {
      dev.log("Failed to update Profile: $error");
      if (!context.mounted) return;
      showTopSnackBar(
        context,
        const TDSnackBar.error(message: 'Server error 😐'),
      );
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(
                top: MediaQuery.of(context).padding.top + 38.0, bottom: 16.0),
            children: [
              const Text(
                'My Profile',
                style: TextStyle(color: AppColor.red, fontSize: 24.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 38.0),
              Center(
                child: _buildAvatar(),
              ),
              const SizedBox(height: 42.0),
              TdTextField(
                controller: nameController,
                hintText: "Full Name",
                prefixIcon: const Icon(Icons.person, color: AppColor.orange),
                validator: Validator.required,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 18.0),
              TdTextField(
                controller: emailController,
                hintText: "Email",
                readOnly: true,
                prefixIcon: const Icon(Icons.email, color: AppColor.orange),
              ),
              const SizedBox(height: 72.0),
              TdElevatedButton(
                onPressed: () => _updateProfile(context),
                text: 'Save',
                isDisable: isLoading,
              ),
              const SizedBox(height: 20.0),
              TdElevatedButton.outline(
                onPressed: () => Navigator.pop(context),
                text: 'Back',
                isDisable: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    const radius = 34.0;
    return GestureDetector(
      onTap: isLoading ? null : pickAvatar,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: isLoading
                ? CircleAvatar(
                    radius: radius,
                    backgroundColor: Colors.orange.shade200,
                    child: const SizedBox.square(
                      dimension: 32.0,
                      child: CircularProgressIndicator(
                        color: AppColor.pink,
                        strokeWidth: 2.0,
                      ),
                    ),
                  )
                : fileAvatar != null
                    ? CircleAvatar(
                        radius: radius,
                        backgroundImage:
                            FileImage(File(fileAvatar?.path ?? '')),
                      )
                    : user.avatar != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(radius),
                            child: Image.network(
                              '${AppConstant.endPointBaseImage}/${user.avatar!}',
                              fit: BoxFit.cover,
                              width: radius * 2,
                              height: radius * 2,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: radius * 2,
                                  height: radius * 2,
                                  color: AppColor.orange,
                                  child: const Center(
                                    child: Icon(Icons.error_rounded,
                                        color: AppColor.white),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return const SizedBox.square(
                                  dimension: radius * 2,
                                  child: Center(
                                    child: SizedBox.square(
                                      dimension: 26.0,
                                      child: CircularProgressIndicator(
                                        color: AppColor.pink,
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : CircleAvatar(
                            radius: radius,
                            backgroundImage:
                                // Assets.images.defaultAvatar.provider()
                                AssetImage(Assets.images.defaultAvatar.path),
                          ),
          ),
          Positioned(
            right: 0.0,
            bottom: 0.0,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.pink)),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 14.6,
                color: Colors.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
