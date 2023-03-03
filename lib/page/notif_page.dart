import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttersocial/model/Member.dart';
import 'package:fluttersocial/model/inside_notif.dart';
import 'package:fluttersocial/tile/notif_tile.dart';
import 'package:fluttersocial/util/firebase_handler.dart';

class NotifPage extends StatefulWidget {
  Member member;

  NotifPage({required this.member});

  @override
  State<StatefulWidget> createState() => NotifState();

}

class NotifState extends State<NotifPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseHandler().fire_notif.doc(FirebaseHandler().authInstance.currentUser!.uid).collection("InsideNotif").snapshots(),
        builder: (context, snapshots) {
          if (snapshots.hasData) {
            final datas = snapshots.data!.docs;
            return ListView.separated(
                itemBuilder: (ctx, index) {
                  return NotifTile(notif: InsideNotif(datas[index]));
                },
                separatorBuilder: (ctx, index) {
                  return Divider();
                },
                itemCount: datas.length
            );
          } else {
            return Center(child: Text("Aucune notif"),);
          }
        });
  }
}