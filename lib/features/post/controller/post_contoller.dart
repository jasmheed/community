import 'dart:io';
import 'dart:typed_data';
import 'package:community/core/enums/enums.dart';
import 'package:community/core/providers/storage_repository_provider.dart';
import 'package:community/core/utils.dart';
import 'package:community/features/auth/controller/auth_controller.dart';
import 'package:community/features/post/repository/post_repository.dart';
import 'package:community/features/user_profile/controller/user_profile_controller.dart';
import 'package:community/models/comment_model.dart';
import 'package:community/models/community_model.dart';
import 'package:community/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postContollerProvider = StateNotifierProvider<PostContoller, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostContoller(
    postRepository: postRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final userPostProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postContoller = ref.watch(postContollerProvider.notifier);
  return postContoller.fetchUserPosts(communities);
});

final guestPostProvider = StreamProvider((ref) {
  final postContoller = ref.watch(postContollerProvider.notifier);
  return postContoller.fetchGuestPosts(ref);
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postContoller = ref.watch(postContollerProvider.notifier);
  return postContoller.getPostById(postId);
});

final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postContoller = ref.watch(postContollerProvider.notifier);
  return postContoller.fetchPostComments(postId);
});

class PostContoller extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostContoller({
    required PostRepository postRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String description,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      description: description,
    );

    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted Successfully!');
      Routemaster.of(context).pop();
    });
  }

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String link,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      link: link,
    );

    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted Successfully!');
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,
    required Uint8List? webFile,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageRes = await _storageRepository.storeFile(
      path: 'posts/${selectedCommunity.name}',
      id: postId,
      file: file,
      webFile: webFile,
    );

    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        link: r,
      );

      final res = await _postRepository.addPost(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Posted Successfully!');
        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  Stream<List<Post>> fetchGuestPosts(s) {
    return _postRepository.fetchGuestPosts();
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);
    res.fold((l) => null,
        (r) => showSnackBar(context, 'Post Deleted Successfully!'));
  }

  void upVotes(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upVotes(post, uid);
  }

  void downVotes(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downVotes(post, uid);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
  }) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    Comment comment = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: post.id,
      userName: user.name,
      profilePic: user.profilePic,
    );
    final res = await _postRepository.addComment(comment);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  void awardPost({
    required Post post,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;
    final res = await _postRepository.awardPost(post, award, user.uid);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        _ref
            .read(userProfileControllerProvider.notifier)
            .updateUserKarma(UserKarma.awardPost);
        _ref.read(userProvider.notifier).update((state) {
          state?.awards.remove(award);
          return state;
        });
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }
}
