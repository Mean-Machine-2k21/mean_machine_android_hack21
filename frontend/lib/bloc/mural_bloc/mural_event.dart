import 'package:frontend/models/mural_model.dart';

abstract class MuralEvent {}

class FetchAllMurals extends MuralEvent {
  int page;
  FetchAllMurals({required this.page});
} //pagination to be done

//This is for any profile read.
class FetchProfileMurals extends MuralEvent {
  String username;
  int page;
  FetchProfileMurals({required this.username,required this.page});
}

class CreateMural extends MuralEvent {
  //no state
  String content;
  Flipbook? flipbook;
  CreateMural({required this.content, this.flipbook});
}

class LikeMural extends MuralEvent {
  //no state
  String muralid;
  LikeMural({required this.muralid});
}

class FetchMuralLikeList extends MuralEvent {
  String muralid;
  FetchMuralLikeList({required this.muralid});
}

class FetchMuralCommentList extends MuralEvent {
  String muralid;
  FetchMuralCommentList({required this.muralid});
}

class CommentMural extends MuralEvent {
  //no state
  String parentMuralId;
  String content;
  Flipbook? flipbook;
  CommentMural(
      {required this.parentMuralId, required this.content, this.flipbook});
}
