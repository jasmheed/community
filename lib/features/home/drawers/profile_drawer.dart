import 'package:community/features/auth/controller/auth_controller.dart';

import 'package:community/theme/pallete.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({
    super.key,
  });

  Future<void> logOut(WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logOut();
  }

  void navigateToProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  void toggleTheme(WidgetRef ref) {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic),
              radius: 70,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'u/${user.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 0.09,
            ),
            ListTile(
              title: const Text('My Profile'),
              leading: const Icon(Icons.person),
              onTap: () {
                navigateToProfile(context, user.uid);
              },
            ),
            ListTile(
              title: const Text('Log Out'),
              leading: Icon(
                Icons.logout,
                color: Pallete.redColor,
              ),
              onTap: () => logOut(ref),
            ),
            Switch.adaptive(
              value: ref.watch(themeNotifierProvider.notifier).mode ==
                  ThemeMode.dark,
              onChanged: (val) {
                toggleTheme(ref);
              },
              thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                return Colors.white;
              }),
              trackOutlineColor:
                  WidgetStateProperty.resolveWith<Color>((states) {
                return Colors.transparent;
              }),
              activeTrackColor: Pallete.greenColor,
              inactiveTrackColor: Colors.grey.shade300,
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                return const Icon(
                  Icons.circle,
                  color: Colors.white,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
