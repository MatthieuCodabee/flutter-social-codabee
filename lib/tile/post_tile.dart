import 'package:flutter/material.dart';
import 'package:fluttersocial/custom_widget/padding_with.dart';
import 'package:fluttersocial/custom_widget/post_content.dart';
import 'package:fluttersocial/model/Member.dart';
import 'package:fluttersocial/model/alert_helper.dart';
import 'package:fluttersocial/model/color_theme.dart';
import 'package:fluttersocial/model/post.dart';
import 'package:fluttersocial/page/detail_page.dart';
import 'package:fluttersocial/util/constants.dart';
import 'package:fluttersocial/util/firebase_handler.dart';

class PostTile extends StatelessWidget {

  Post post;
  Member member;
  bool isDetail = false;

  PostTile({required this.post, required this.member, this.isDetail = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!isDetail) {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext ctx) {
            return DetailPage(post: post, member: member);
          }));
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 5),
        child: Card(
          color: ColorTheme().base(),
          shadowColor: ColorTheme().pointer(),
          elevation: 5,
          child: PaddingWith(
            child: Column(
              children: [
                PostContent(post: post, member: member),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        icon: (post.likes.contains(FirebaseHandler().authInstance.currentUser!.uid) ? likeIcon : unlikeIcon),
                        onPressed: () {
                          FirebaseHandler().addOrRemoveLike(post, FirebaseHandler().authInstance.currentUser!.uid);
                        }),
                    Text("${post.likes.length} likes"),
                    IconButton(icon: commentIcon, onPressed: () {
                      AlertHelper().writeAComment(context, post: post, commentController: TextEditingController(), member: member);
                    }),
                    Text("${post.comments.length} commentaires")
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}