import 'package:community/core/common/error_text.dart';
import 'package:community/core/common/loader.dart';
import 'package:community/core/common/post_card.dart';
import 'package:community/features/auth/controller/auth_controller.dart';
import 'package:community/features/community/controller/community_controller.dart';
import 'package:community/features/post/controller/post_contoller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return const Loader();
    }
    return ref.watch(userCommunitiesProvider(user.uid)).when(
          data: (communities) => ref.watch(userPostProvider(communities)).when(
                data: (data) {
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final post = data[index];
                      return PostCard(post: post);
                    },
                  );
                },
                error: (error, stackTrace) => ErrorText(
                  error: error.toString(),
                ),
                loading: () => const Loader(),
              ),
          error: (error, stackTrace) => ErrorText(
            error: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
