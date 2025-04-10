import 'package:community/core/common/loader.dart';
import 'package:community/core/common/sign_in_button.dart';
import 'package:community/core/constants/constants.dart';
import 'package:community/features/auth/controller/auth_controller.dart';
import 'package:community/responsive/responsive.dart';
import 'package:community/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInAsGuest(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).signInAsGuest(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          Constants.logoPath,
          height: 60,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => signInAsGuest(ref, context),
            child: Text(
              'Skip',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Pallete.blueColor,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Dive into anything",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    Constants.loginEmotePath,
                    height: 400,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Responsive(child: SignInButton()),
              ],
            ),
    );
  }
}
