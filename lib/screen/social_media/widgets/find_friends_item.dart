import '../../../model/user/user.dart';
import '../../../model/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:paulonia_cache_image/paulonia_cache_image.dart';
import 'package:provider/provider.dart';

import '../../../translations.dart';

// ignore: must_be_immutable
class FindFriendsItem extends StatelessWidget {
  UserObject? user;
  FindFriendsItem({this.user});
  UserObject? currentUser;
  @override
  Widget build(BuildContext context) {
    currentUser = Provider.of<UserModel>(context, listen: true).user;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        padding: EdgeInsets.only(right: 10, top: 5, bottom: 5),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/friend-profile',
                  arguments: {'uid': user!.uid}),
              child: Container(
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.16,
                      height: MediaQuery.of(context).size.height * 0.05,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: (user!.avatar != null
                                    ? PCacheImage(user!.avatar!,
                                        enableCache: true,
                                        enableInMemory: true,
                                        imageScale: 0.5,
                                        maxRetryDuration: Duration(seconds: 30),
                                        retryDuration: Duration(seconds: 10))
                                    : AssetImage(
                                        'assets/images/onboarding/opening1.png'))
                                as ImageProvider<Object>),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user!.fullname!.length < 18
                                ? user!.fullname!
                                : user!.fullname!.substring(0, 18) + '...',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (user!.uid != currentUser!.uid)
              ElevatedButton(
                onPressed: () {
                  if (currentUser!.friendList
                      .where((element) => element?.uid == user!.uid)
                      .isEmpty) {
                    // bulk edit //print('Follow');
                    // bulk edit //print(user.uid);
                    Provider.of<UserModel>(context, listen: false)
                        .followFriend(uid: user!.uid);
                  } else {
                    // bulk edit //print('unFollow');
                    // bulk edit //print(user.uid);
                    Provider.of<UserModel>(context, listen: false)
                        .unfollowFriend(uid: user!.uid);
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  currentUser!.friendList
                          .where((element) => element?.uid == user!.uid)
                          .isEmpty
                      ? allTranslations.text('follow')!
                      : allTranslations.text('unfollow')!,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
