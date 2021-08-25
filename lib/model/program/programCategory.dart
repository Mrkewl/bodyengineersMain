import '../../helper/tools_helper.dart';

class ProgramCategory {
  String? categoryId;
  String? categoryName;
  String? categoryParentId;
  String? categoryImg;
  bool showSubCategory = false;
  bool isSelected = false;
  ProgramCategory.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      categoryId = json['program_category_id'];
      categoryName = json['program_category_name'];
      categoryParentId = json['program_category_parent_id'];
      categoryImg = Tools.urlConverter(json['program_category_img']);
      if (json['showSubCategory'] == '1') {
        showSubCategory = true;
      }
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  @override
  String toString() => 'Category { categoryName: $categoryName }';
}
