import 'dart:developer' as dev;
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../components/button/td_elevated_button.dart';
import '../../components/snack_bar/td_snack_bar.dart';
import '../../components/snack_bar/top_snack_bar.dart';
import '../../components/text_field/td_text_field.dart';
import '../../components/text_field/td_text_field_password.dart';
import '../../gen/assets.gen.dart';
import '../../models/user_model.dart';
import '../../resources/app_color.dart';
import '../../utils/post_image.dart';
import '../../utils/validator.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  PostImage postImage = PostImage();
  final formKey = GlobalKey<FormState>();
  File? fileAvatar;
  bool isLoading = false;
  final _auth = FirebaseAuth.instance;

  // tao tham chieu den collection task luu tru trong firebase
  // de add, update, delete
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

  Future<void> _onSubmit(BuildContext context) async {
    if (formKey.currentState!.validate() == false) {
      return;
    }

    setState(() => isLoading = true);

    _auth
        .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text)
        .then((value) async {
      UserModel user = UserModel()
        ..name = nameController.text.trim()
        ..email = emailController.text.trim()
        ..avatar = fileAvatar != null
            ? await postImage.post(image: fileAvatar!)
            : null;

      _addUser(user);

      if (!context.mounted) return;

      showTopSnackBar(
        context,
        const TDSnackBar.success(
            message: 'Register successfully, please login 😍'),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(email: emailController.text.trim()),
        ),
        (Route<dynamic> route) => false,
      );
    }).catchError((onError) {
      FirebaseAuthException a = onError as FirebaseAuthException;
      if (!context.mounted) return;
      showTopSnackBar(
        context,
        TDSnackBar.error(message: a.message ?? ''),
      );
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  void _addUser(UserModel user) {
    userCollection
        .doc(user.email)
        .set(user.toJson())
        .then((_) {})
        .catchError((error) {
      dev.log("Failed to add User: $error");
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
              const Center(
                child: Text(
                  'Register',
                  style: TextStyle(color: AppColor.red, fontSize: 26.0),
                ),
              ),
              const SizedBox(height: 30.0),
              Center(
                child: _buildAvatar(),
              ),
              const SizedBox(height: 40.0),
              TdTextField(
                controller: nameController,
                hintText: 'Full Name',
                prefixIcon: const Icon(Icons.person, color: AppColor.orange),
                textInputAction: TextInputAction.next,
                validator: Validator.required,
              ),
              const SizedBox(height: 20.0),
              TdTextField(
                controller: emailController,
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email, color: AppColor.orange),
                textInputAction: TextInputAction.next,
                validator: Validator.email,
              ),
              const SizedBox(height: 20.0),
              TdTextFieldPassword(
                controller: passwordController,
                hintText: 'Password',
                textInputAction: TextInputAction.next,
                validator: Validator.password,
              ),
              const SizedBox(height: 20.0),
              TdTextFieldPassword(
                controller: confirmPasswordController,
                onChanged: (_) => setState(() {}),
                hintText: 'Confirm Password',
                onFieldSubmitted: (_) => _onSubmit(context),
                textInputAction: TextInputAction.done,
                validator: Validator.confirmPassword(
                  passwordController.text,
                ),
              ),
              const SizedBox(height: 56.0),
              TdElevatedButton(
                onPressed: () => _onSubmit(context),
                text: 'Sign up',
                isDisable: isLoading,
              ),
              const SizedBox(height: 12.0),
              RichText(
                text: TextSpan(
                  text: 'Do you have an account? ',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: AppColor.grey,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Sign in',
                      style: TextStyle(color: AppColor.red.withOpacity(0.86)),
                      recognizer: TapGestureRecognizer()
                        ..onTap =
                            () => Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                  (Route<dynamic> route) => false,
                                ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector _buildAvatar() {
    return GestureDetector(
      onTap: isLoading == true ? null : pickAvatar,
      child: Stack(
        children: [
          isLoading == true
              ? CircleAvatar(
                  radius: 34.6,
                  backgroundColor: Colors.orange.shade200,
                  child: const SizedBox.square(
                    dimension: 36.0,
                    child: CircularProgressIndicator(
                      color: AppColor.pink,
                      strokeWidth: 2.6,
                    ),
                  ),
                )
              : Container(
                  // margin: const EdgeInsets.all(3.6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.orange),
                  ),
                  child: CircleAvatar(
                    radius: 34.6,
                    backgroundImage: fileAvatar == null
                        // ? Assets.images.defaultAvatar.provider()
                        // ? AssetImage(Assets.images.defaultAvatar.path)
                        //     as ImageProvider
                        ? Image.asset(Assets.images.defaultAvatar.path).image
                        : FileImage(
                            File(fileAvatar?.path ?? ''),
                          ),
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
                border: Border.all(color: Colors.pink),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 14.6,
                color: AppColor.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
