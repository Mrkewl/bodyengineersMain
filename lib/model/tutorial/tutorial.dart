class Tutorial {
  String? tutorialId;
  String? tutorialTitle;
  String? tutorialUrl;
  String? tutorialHelperTitle;
  bool isFullScreen = false;
  bool isVisible = true;
  List<String?> tutorialHelperList = [];

  Tutorial.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      tutorialId = json['tutorial_id'];
      tutorialTitle = json['tutorial_title'];
      tutorialUrl = json['tutorial_url'];
      tutorialHelperTitle = json['tutorial_helper_title'];
      for (var item in json['tutorial_helper']) {
        tutorialHelperList.add(item['tutorial_helper']);
      }
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }
  // Map<String, dynamic> toBasicJson() {
  //   return {
  //     "user_uid": uid,
  //     "user_fullname": fullname,
  //     "user_avatar": avatar,
  //     "user_authmethod": authmethod,
  //   };
  // }

  // Tutorial.fromFirebase(Map<dynamic, dynamic> json) {
  //   try {
  //     id = json['id'];
  //     firstName = json['name'];
  //     lastName = json['last_name'];
  //     email = json['email'];
  //     if (json['profile_img'] != null) {
  //       profileAvatar = json['profile_img'];
  //     }
  //     if (json['address'] != null) {
  //       address = json['address'];
  //     }
  //   } catch (e) {
  //     // bulk edit //print(e.toString());
  //   }
  // }
  @override
  String toString() => 'Tutorial { Tutorialname: $tutorialTitle }';
}
