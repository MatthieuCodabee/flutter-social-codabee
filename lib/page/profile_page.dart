import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttersocial/custom_widget/profile_image.dart';
import 'package:fluttersocial/delegate/header_delegate.dart';
import 'package:fluttersocial/model/Member.dart';
import 'package:fluttersocial/model/alert_helper.dart';
import 'package:fluttersocial/model/color_theme.dart';
import 'package:fluttersocial/model/post.dart';
import 'package:fluttersocial/tile/post_tile.dart';
import 'package:fluttersocial/util/constants.dart';
import 'package:fluttersocial/util/firebase_handler.dart';
import 'package:fluttersocial/util/images.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  Member member;

  ProfilePage({required this.member});

  @override
  State<StatefulWidget> createState() => ProfileState();

}

class ProfileState extends State<ProfilePage> {

  late TextEditingController _name;
  late TextEditingController _surname;
  late TextEditingController _desc;
  late ScrollController _controller;
  bool get scrolled {
    return _controller.hasClients && _controller.offset > 200 - kToolbarHeight;
  }
  late bool isMe;

  @override
  void initState() {
    final authId = FirebaseHandler().authInstance.currentUser!.uid;
    isMe = (authId == widget.member.uid);
    _controller = ScrollController()..addListener(() {
      setState(() {
      });
    });
    _name = TextEditingController();
    _surname = TextEditingController();
    _desc = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _name.dispose();
    _surname.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseHandler().postFrom(widget.member?.uid ?? ""),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
        print(widget.member.uid);
            if (snapshots.hasData) {
              return CustomScrollView(
                controller: _controller,
                slivers: [
                  appBar(),
                  persistent(),
                  list(snapshots.data!.docs)
                ],
              );
            } else {
              return Center(
                child: Text("Aucun post pour l'instant"),
              );
            }
        }
    );
  }

  SliverAppBar appBar() {
    return SliverAppBar(
      backgroundColor: ColorTheme().pointer(),
      pinned: true,
      expandedHeight: 200,
      actions: [
        IconButton(icon: Icon(Icons.settings), onPressed: (() =>AlertHelper().disconnect(context)))
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: (scrolled)
            ? Row(
          children: [
            ProfileImage(urlString: widget.member?.imageUrl  ?? "", onPressed: (() {}), imageSize: 20,),
            Text("${widget.member.surname} ${widget.member.name}")
          ],
        )
            : ProfileImage(urlString: widget.member?.imageUrl  ?? "", onPressed: (() => takePicture()), imageSize: 50,),
        background: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(profileImage),
              fit: BoxFit.cover
            )
          ),
        ),
      ),
    );
  }


  SliverPersistentHeader persistent() {
    return SliverPersistentHeader(
      pinned: true,
        delegate: HeaderDelegate(
            member: widget.member,
            callback: updateUser,
            scrolled: scrolled)
    );
  }

  updateUser() {
    if (isMe) {
      AlertHelper().changeUser(
          context,
          member: widget.member,
          name: _name,
          surname: _surname,
          desc: _desc);
    }
  }

  SliverList list(List<QueryDocumentSnapshot> snapshots) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, index) {
              if (index > snapshots.length) {
                return null;
              } else if (index == snapshots.length){
                return Text("Fin de liste");
              } else {
                return PostTile(post: Post(snapshots[index]), member: widget.member);
              }
            }
        )
    );
  }

  takePicture() {
    if (isMe) {
      showModalBottomSheet(context: context, builder: (BuildContext ctx) {
        return Container(
          color: Colors.transparent,
          child: Card(
            elevation: 7,
            margin: EdgeInsets.all(15),
            child: Container(
              color: ColorTheme().base(),
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Modification de la photo de profil"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(icon: cameraIcon, onPressed: (() => picker(ImageSource.camera))),
                      IconButton(icon: libraryIcon, onPressed: (() => picker(ImageSource.gallery)))
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      });
    }
  }

  picker(ImageSource source) async {
    final f = await ImagePicker().getImage(source: source, maxWidth: 500, maxHeight: 500);
    final File file = File(f!.path);
    FirebaseHandler().modifyPicture(file);
  }
}