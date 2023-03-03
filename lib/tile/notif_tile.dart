import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttersocial/custom_widget/profile_image.dart';
import 'package:fluttersocial/model/Member.dart';
import 'package:fluttersocial/model/color_theme.dart';
import 'package:fluttersocial/model/inside_notif.dart';
import 'package:fluttersocial/model/post.dart';
import 'package:fluttersocial/page/detail_page.dart';
import 'package:fluttersocial/page/profile_page.dart';
import 'package:fluttersocial/util/constants.dart';
import 'package:fluttersocial/util/firebase_handler.dart';

class NotifTile extends StatelessWidget {

  InsideNotif notif;

  NotifTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    print(notif.userId);
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseHandler().fire_user.doc(notif.userId).snapshots(),
        builder: (context, snap) {
      if (snap.hasData) {
        Member member = Member(snap.data!);
       return  InkWell(
          onTap: () {
            FirebaseHandler().seenNotif(notif);
            if (notif.type == follow) {
              Navigator.push(context, MaterialPageRoute(builder: (build) {
                return Scaffold(body: ProfilePage(member: member));
              }));
            } else {
              notif.aboutRef.get().then((value) {
                Post post = Post(value);
                Navigator.push(context, MaterialPageRoute(builder: (build) {
                  return DetailPage(post: post, member: member);
                }));
              });
            }
          },
          child: Container(
            color: (notif.seen) ? ColorTheme().base(): ColorTheme().accent(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        ProfileImage(urlString: member.imageUrl  ?? "", onPressed: (() {})),
                        Text("${member.surname} ${member.name}")
                      ],
                    ),
                    Text(notif.date)
                  ],
                ),
                Center(child: Text(notif.text),)
              ],
            ),
          )
        );
      } else {
        return Center(child:  Text("Aucune données"));
      }
    });
  }
}