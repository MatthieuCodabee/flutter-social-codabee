import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttersocial/custom_widget/profile_image.dart';
import 'package:fluttersocial/model/Member.dart';
import 'package:fluttersocial/model/color_theme.dart';
import 'package:fluttersocial/page/profile_page.dart';
import 'package:fluttersocial/util/firebase_handler.dart';
import 'package:fluttersocial/util/images.dart';

class MembersPage extends StatefulWidget {
  Member member;

  MembersPage({required this.member});

  @override
  State<StatefulWidget> createState() => MembersState();

}

class MembersState extends State<MembersPage> {

  @override
  Widget build(BuildContext context) {
    String myId = FirebaseHandler().authInstance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseHandler().fire_user.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool scrolled) {
                  return [
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 200,
                      backgroundColor: ColorTheme().pointer(),

                      flexibleSpace: FlexibleSpaceBar(
                        title: Text("Liste des utilisateurs"),
                        background: Image(image: AssetImage(eventsImage), fit: BoxFit.cover,),
                      ),
                    )
                  ];
                },
                body: ListView.separated(
                    itemBuilder: (BuildContext ctx, int index) {
                      final list = snapshot.data!.docs;
                      final memberMap = list[index];
                      final member = Member(memberMap);
                      return ListTile(
                        leading: ProfileImage(urlString: member?.imageUrl  ?? "", onPressed: (() {})),
                        title: Text("${member.surname} ${member.name}", style: TextStyle(color: ColorTheme().textColor()),),
                        trailing: TextButton(
                          onPressed: () {
                            FirebaseHandler().addOrRemoveFollow(member);
                          },
                          child: (myId == member.uid)
                          ? Container(width: 0,height: 0,)
                          : Text((member!.followers!.contains(myId) ? "Ne plus suivre" : "Suivre"))
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext ctx) {
                              return Scaffold( body:ProfilePage(member: member));
                            }));
                        },
                      );
                    },
                    separatorBuilder: (BuildContext ctx, int index) {
                      return Divider();
                    },
                    itemCount: snapshot.data!.docs.length
                )
            );
          } else {
            return Center(child: Text("Aucun utilisateur sur cette app"),);
          }
        }
    );
  }
}