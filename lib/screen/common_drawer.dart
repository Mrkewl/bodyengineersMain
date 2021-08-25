import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:paulonia_cache_image/paulonia_cache_image.dart';
import 'package:provider/provider.dart';

import '../be_theme.dart';
import '../model/user/user_model.dart';
import '../model/planner/planner_model.dart';
import '../model/achievement/achievement_model.dart';
import '../model/watch/watch_model.dart';
import '../model/goal/goal_model.dart';
import '../model/user/user.dart';
import '../translations.dart';

buildProfileDrawer(BuildContext context, UserObject? user) {
  MyTheme theme = MyTheme();

  return Drawer(
    child: ListView(
      physics: ClampingScrollPhysics(),
      children: [
        if (user != null)
          Consumer<UserModel>(
            builder: (context, value, child) => UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: theme.currentTheme() == ThemeMode.dark
                      ? Colors.grey[800]
                      : Colors.grey[50],
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: (value.user!.avatar != '' &&
                              value.user!.avatar != null
                          ? PCacheImage(value.user!.avatar!,
                              enableInMemory: true, enableCache: true)
                          : AssetImage('assets/images/onboarding/opening1.png'))
                      as ImageProvider<Object>?,
                ),
                accountEmail: Text(
                  value.user != null ? value.user!.email ?? '' : '',
                ),
                accountName: Text(
                  value.user != null ? value.user!.fullname ?? '' : '',
                )),
          ),
        ListTile(
            leading: Container(
              height: 30,
              width: 30,
              child: SvgPicture.asset(
                'assets/images/drawer/profile.svg',
                color: Color.fromRGBO(182, 182, 182, 1),
              ),
            ),
            title: Text(allTranslations.text('profile')!),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/profile',
                (Route route) => route.settings.name == '/navigation',
              );
            }),
        ListTile(
            leading: Container(
              height: 30,
              width: 30,
              child: SvgPicture.asset(
                'assets/images/drawer/settings.svg',
                color: Color.fromRGBO(182, 182, 182, 1),
              ),
            ),
            title: Text(allTranslations.text('settings')!),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/drawer_settings',
                (Route route) => route.settings.name == '/navigation',
              );
            }),
        ListTile(
          leading: Container(
            height: 30,
            width: 30,
            child: SvgPicture.asset(
              'assets/images/drawer/health_stats.svg',
              color: Color.fromRGBO(182, 182, 182, 1),
            ),
          ),
          title: Text(allTranslations.text('health_stats')!),
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/health_stats',
              (Route route) => route.settings.name == '/navigation',
            );
          },
        ),
        ListTile(
          leading: Container(
            height: 30,
            width: 30,
            child: SvgPicture.asset(
              'assets/images/drawer/exercise_stats.svg',
              color: Color.fromRGBO(182, 182, 182, 1),
            ),
          ),
          title: Text(allTranslations.text('exercise_stats')!),
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/exercise_stats',
              (Route route) => route.settings.name == '/navigation',
            );
          },
        ),
        ListTile(
          leading: Container(
            height: 30,
            width: 30,
            child: SvgPicture.asset(
              'assets/images/drawer/tutorial.svg',
              color: Color.fromRGBO(182, 182, 182, 1),
            ),
          ),
          title: Text(allTranslations.text('tutorial')!),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/video_tutorial',
              (Route route) => route.settings.name == '/navigation',
            );
          },
        ),
        // ListTile(
        //   leading: Container(
        //     height: 35,
        //     width: 35,
        //     child: SvgPicture.asset(
        //       'assets/images/drawer/achievements.svg',
        //       color: Color.fromRGBO(182, 182, 182, 1),
        //     ),
        //   ),
        //   title: Text(allTranslations.text('achievements')),
        //   onTap: () {
        //     Navigator.pop(context);

        //     Navigator.pushNamedAndRemoveUntil(
        //       context,
        //       '/achievements',
        //       (Route route) => route.settings.name == '/navigation',
        //     );
        //   },
        // ),
        ListTile(
          leading: Container(
            height: 30,
            width: 30,
            child: SvgPicture.asset(
              'assets/images/drawer/sync_devices.svg',
              color: Color.fromRGBO(182, 182, 182, 1),
            ),
          ),
          title: Text(allTranslations.text('sync_devices')!),
          onTap: () {
            Navigator.pop(context);

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/sync_devices',
              (Route route) => route.settings.name == '/navigation',
            );
          },
        ),
        ListTile(
          leading: Container(
            height: 30,
            width: 30,
            child: Icon(
              Icons.logout,
              color: Color.fromRGBO(182, 182, 182, 1),
            ),
          ),
          title: Text(allTranslations.text('logout')!),
          onTap: () async {
            await Provider.of<UserModel>(context, listen: false).logOut();
            await Provider.of<PlannerModel>(context, listen: false).logOut();
            await Provider.of<WatchModel>(context, listen: false).logOut();
            await Provider.of<GoalModel>(context, listen: false).logOut();
            await Provider.of<AchievementModel>(context, listen: false)
                .logOut();

            await Navigator.pushNamedAndRemoveUntil(
                context, '/welcome', (route) => false);
          },
        ),
      ],
    ),
  );
}
