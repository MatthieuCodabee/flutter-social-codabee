import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:fluttersocial/model/Member.dart';
import 'package:fluttersocial/model/inside_notif.dart';
import 'package:fluttersocial/model/post.dart';
import 'package:fluttersocial/util/constants.dart';

class FirebaseHandler {

  //Auth
  final authInstance = FirebaseAuth.instance;

  //Connexion
  Future<User?> signIn(String mail, String pwd) async {
    final userCredential = await authInstance.signInWithEmailAndPassword(
        email: mail,
        password: pwd
    );
    final User? user = userCredential.user;
    return user;
  }

  //Création user
  Future<User?> createUser(String mail, String pwd, String name, String surname) async {
    final userCredential = await authInstance.createUserWithEmailAndPassword(
        email: mail,
        password: pwd
    );
    final User? user = userCredential.user;
    Map<String, dynamic>memberMap = {
      nameKey: name,
      surnameKey: surname,
      imageUrlKey: "",
      followersKey: [user?.uid],
      followingKey: [],
      uidKey: user?.uid
    };
    //AddUser;
    addUserToFirebase(memberMap);
    return user;
  }

  logOut() {
    authInstance.signOut();
  }



  //Database
  static final firestoreInstance = FirebaseFirestore.instance;
  final fire_user = firestoreInstance.collection(memberRef);
  final fire_notif = firestoreInstance.collection("notification");

  //Storage
  static final storageRef = storage.FirebaseStorage.instance.ref();


  addUserToFirebase(Map<String, dynamic> map) {
    fire_user.doc(map[uidKey]).set(map);
  }

  addPostToFirebase(String memberId, String text, File file) async {
    int date = DateTime.now().millisecondsSinceEpoch.toInt();
    List<dynamic> likes = [];
    List<dynamic> comments = [];
    Map<String, dynamic> map = {
      uidKey: memberId,
      likeKey: likes,
      commentKey: comments,
      dateKey: date,
    };

    if (text != null && text != "") {
      map[textKey] = text;
    }
    if (file != null) {
      final ref = storageRef.child(memberId).child("post").child(date.toString());
      final urlString = await addImageToStorage(ref, file);
      map[imageUrlKey] = urlString;
      fire_user.doc(memberId).collection("post").doc().set(map);
    } else {
      fire_user.doc(memberId).collection("post").doc().set(map);
    }
  }

  Future<String> addImageToStorage(storage.Reference ref, File file) async {
    storage.UploadTask task = ref.putFile(file);
    storage.TaskSnapshot snapshot = await task.whenComplete(() => null);
    String urlString = await snapshot.ref.getDownloadURL();
    return urlString;
  }

  addOrRemoveLike(Post post, String memberId) {
    if (post.likes.contains(memberId)) {
      post.ref.update({likeKey: FieldValue.arrayRemove([memberId])});
    } else {
      post.ref.update({likeKey: FieldValue.arrayUnion([memberId])});
      //Ajouter notification a aime le post
      sendNotifTo(post.memberId, authInstance.currentUser!.uid, "A aimé votre post", post.ref, like);
    }
  }

  addOrRemoveFollow(Member member) {
    String myId = authInstance.currentUser!.uid;
    DocumentReference myRef = fire_user.doc(myId);
    print("Member ref= ${member.ref}");
    print("Me ref = ${myRef}");
    if (member != null) {
      if (member!.followers!.contains(myId)) {
        member!.ref!.update({followersKey: FieldValue.arrayRemove([myId])});
        myRef.update({followingKey: FieldValue.arrayRemove([member.uid])});
      } else {
        member!.ref!.update({followersKey: FieldValue.arrayUnion([myId])});
        myRef.update({followingKey: FieldValue.arrayUnion([member.uid])});
        //Notif
        sendNotifTo(member?.uid  ??"", authInstance.currentUser!.uid, "Vous suit désormais", fire_user.doc(authInstance.currentUser!.uid), follow);
      }
    }

  }

  addComment(Post post, String text) {
    Map<String, dynamic> map = {
      uidKey: authInstance.currentUser!.uid,
      dateKey: DateTime.now().millisecondsSinceEpoch,
      textKey: text
    };
    post.ref.update({commentKey: FieldValue.arrayUnion([map])});
    sendNotifTo(post.memberId, authInstance.currentUser!.uid, "A commenté votre post", post.ref, comment);
  }

  sendNotifTo(String to, String from, String text, DocumentReference ref, String type) {
    bool seen = false;
    int date = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> map = {
      seenKey: seen,
      dateKey: date,
      textKey: text,
      refKey: ref,
      typeKey: type,
      uidKey: from
    };
    fire_notif.doc(to).collection("InsideNotif").add(map);
  }

  seenNotif(InsideNotif notif) {
    notif.reference.update({seenKey: true});
  }

  Stream<QuerySnapshot> postFrom(String uid) {
    return fire_user.doc(uid).collection("post").snapshots();
  }

  modifyPicture(File file) {
    String uid = authInstance.currentUser!.uid;
    final ref = storageRef.child(uid);
    addImageToStorage(ref, file).then((value) {
      Map<String, dynamic> newMap = { imageUrlKey: value};
      modifyMember(newMap, uid);
    });
  }

  modifyMember(Map<String, dynamic> map, String uid) {
    fire_user.doc(uid).update(map);
  }
}