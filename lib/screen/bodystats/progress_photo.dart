import '../../model/planner/planner_model.dart';
import '../../model/planner/progress_photo.dart';
import '../../screen/widget/calendar/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import 'package:intl/intl.dart' as intl;

class ProgressPhotoPage extends StatefulWidget {
  @override
  _ProgressPhotoPageState createState() => _ProgressPhotoPageState();
}

class _ProgressPhotoPageState extends State<ProgressPhotoPage>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  ImagePicker backPicker = ImagePicker();
  ImagePicker frontPicker = ImagePicker();
  ImagePicker sidePicker = ImagePicker();

  File? backImage;
  File? frontImage;
  File? sideImage;
  DateTime today = DateTime.now();
  late List<ProgressPhoto?> images;

  Future<File>? _imageFile;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  Widget imageCard({required imageFile}) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Image.file(
            File(imageFile['back']),
            width: 400,
            height: 400,
            fit: BoxFit.cover,
          ),
          Positioned(
            right: mediaQuery.size.width * 0.01,
            top: mediaQuery.size.width * 0.01,
            child: InkWell(
              child: Icon(
                Icons.remove_circle,
                size: mediaQuery.size.width * 0.06,
                color: Colors.red,
              ),
              onTap: () {
                // setState(() {
                //   images.replaceRange(index, index + 1, ['Add Image']);
                // });
              },
            ),
          ),
        ],
      ),
    );
  }

  saveImageData() async {
    ProgressPhoto progressPhoto = ProgressPhoto();
    progressPhoto.dateTime =
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    progressPhoto.back = backImage != null ? backImage!.path : '';
    progressPhoto.front = frontImage != null ? frontImage!.path : '';
    progressPhoto.side = sideImage != null ? sideImage!.path : '';

    await Provider.of<PlannerModel>(context, listen: false)
        .addProgressPhoto(progressPhoto: progressPhoto);

    backImage = null;
    frontImage = null;
    sideImage = null;
  }

  Widget buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.2,
      crossAxisSpacing: 10,
      // ignore: missing_return
      children: List.generate(3, (index) {
        switch (index) {
          case 0:
            if (backImage == null) {
              return GestureDetector(
                onTap: () async {
                  await getImageGallery(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 5, color: Color.fromRGBO(86, 177, 191, 1)),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                    Icons.add_circle,
                    color: Color.fromRGBO(86, 177, 191, 1),
                    size: 40,
                  ),
                ),
              );
            } else {
              return GridTile(
                child: Column(
                  children: [
                    Expanded(
                      child: Image.file(backImage!),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          today.day.toString() +
                              ' / ' +
                              today.month.toString() +
                              ' / ' +
                              today.year.toString(),
                          style: TextStyle(color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          case 1:
            if (frontImage == null) {
              return GestureDetector(
                onTap: () async {
                  await getImageGallery(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 5, color: Color.fromRGBO(86, 177, 191, 1)),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                    Icons.add_circle,
                    color: Color.fromRGBO(86, 177, 191, 1),
                    size: 40,
                  ),
                ),
              );
            } else {
              return GridTile(
                child: Column(
                  children: [
                    Expanded(
                      child: Image.file(frontImage!),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          today.day.toString() +
                              ' / ' +
                              today.month.toString() +
                              ' / ' +
                              today.year.toString(),
                          style: TextStyle(color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          case 2:
            if (sideImage == null) {
              return GestureDetector(
                onTap: () async {
                  await getImageGallery(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 5, color: Color.fromRGBO(86, 177, 191, 1)),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                    Icons.add_circle,
                    color: Color.fromRGBO(86, 177, 191, 1),
                    size: 40,
                  ),
                ),
              );
            } else {
              return GridTile(
                child: Column(
                  children: [
                    Expanded(
                      child: Image.file(sideImage!),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          today.day.toString() +
                              ' / ' +
                              today.month.toString() +
                              ' / ' +
                              today.year.toString(),
                          style: TextStyle(color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }   
          default:
            return Container();
        }
      }),
    );
  }

  backModal(BuildContext context, ProgressPhoto? progressPhoto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                  ),
                  onPressed: () async {
                    String? newPath = await editImage();
                    if (newPath != null) {
                      progressPhoto!.front = newPath;
                      await Provider.of<PlannerModel>(context, listen: false)
                          .addProgressPhoto(progressPhoto: progressPhoto);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Add Progress',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Color.fromRGBO(86, 177, 191, 1),
                  ),
                  onPressed: () async {
                    progressPhoto!.front = null;
                    await Provider.of<PlannerModel>(context, listen: false)
                        .addProgressPhoto(progressPhoto: progressPhoto);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Delete Progress',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  sideModal(BuildContext context, ProgressPhoto? progressPhoto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                  ),
                  onPressed: () async {
                    String? newPath = await editImage();
                    if (newPath != null) {
                      progressPhoto!.side = newPath;
                      await Provider.of<PlannerModel>(context, listen: false)
                          .addProgressPhoto(progressPhoto: progressPhoto);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Add Progress',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Color.fromRGBO(86, 177, 191, 1),
                  ),
                  onPressed: () async {
                    progressPhoto!.side = null;
                    await Provider.of<PlannerModel>(context, listen: false)
                        .addProgressPhoto(progressPhoto: progressPhoto);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Delete Progress',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  frontModal(BuildContext context, ProgressPhoto? progressPhoto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                  ),
                  onPressed: () async {
                    String? newPath = await editImage();
                    if (newPath != null) {
                      progressPhoto!.back = newPath;
                      await Provider.of<PlannerModel>(context, listen: false)
                          .addProgressPhoto(progressPhoto: progressPhoto);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Add Progress',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Color.fromRGBO(86, 177, 191, 1),
                  ),
                  onPressed: () async {
                    progressPhoto!.back = null;
                    await Provider.of<PlannerModel>(context, listen: false)
                        .addProgressPhoto(progressPhoto: progressPhoto);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Delete Progress',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ignore: missing_return
  Future<File?> getImageGallery(int index) async {
    final PickedFile? pickedFile =
        await (backPicker.getImage(source: ImageSource.gallery));

    if (pickedFile!.path != null) {
      final File file = File(pickedFile.path);

      late String path;

      await getApplicationDocumentsDirectory().then((value) {
        path = value.path;
      });
      String dateTime = DateTime.now().toString().replaceAll(' ', '_');
      final File newImage = await file
          .copy(path + '/' + dateTime + '_' + index.toString() + '.png');

      switch (index) {
        case 0:
          // using your method of getting an image

          setState(() {
            backImage = newImage;
          });

          break;
        case 1:
          setState(() {
            frontImage = File(pickedFile.path);
          });

          break;
        case 2:
          setState(() {
            sideImage = File(pickedFile.path);
          });

          break;
      }

      saveImageData();
    } else {
      // bulk edit //print('No image selected.');
    }
  }

  Future<String?> editImage() async {
    final PickedFile? pickedFile =
        await (backPicker.getImage(source: ImageSource.gallery));

    if (pickedFile!.path != null) {
      final File file = File(pickedFile.path);

      late String path;

      await getApplicationDocumentsDirectory().then((value) {
        path = value.path;
      });
      String dateTime = DateTime.now().toString().replaceAll(' ', '_');
      final File newImage =
          await file.copy(path + '/' + dateTime + '_' + '.png');

      return newImage.path;
    }
  }

////////////////////////Calendar Functions Starts///////////////////////////////

  // CalendarController _calendarControllerMonth;
  AnimationController? _animationController;
  DateTime? _selectedDay;
  List<DateTime> visibleDays = [];

  selectedDayCallback(DateTime daySelected) {
    setState(() {
      _selectedDay = daySelected;
    });
  }

  showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              contentPadding: EdgeInsets.all(5),
              content: Container(
                height: MediaQuery.of(context).size.height * 0.55,
                child: CalendarWidget(
                  selectedDay: _selectedDay,
                  selectedDayCallback: selectedDayCallback,
                  animationController: _animationController,
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    "Select",
                    style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTableCalendarWithBuildersSecond() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: TableCalendar(
        firstDay: DateTime(2000, 1, 1),
        lastDay: DateTime(2100, 1, 1),
        locale: 'en_EN',
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableGestures: AvailableGestures.all,
        availableCalendarFormats: const {
          CalendarFormat.month: '',
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle().copyWith(color: Colors.blue[800]),
          holidayTextStyle: TextStyle().copyWith(color: Colors.blue[800]),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
        ),
        focusedDay: _selectedDay!,
        selectedDayPredicate: (day) {
          // Use `selectedDayPredicate` to determine which day is currently selected.
          // If this returns true, then `day` will be marked as selected.

          // Using `isSameDay` is recommended to disregard
          // the time-part of compared DateTime objects.
          return isSameDay(_selectedDay, day);
        },
        calendarBuilders: CalendarBuilders(
          selectedBuilder: (context, date, _) {
            return FadeTransition(
              opacity:
                  Tween(begin: 0.0, end: 1.0).animate(_animationController!),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4.0),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(86, 177, 191, 0.6),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle().copyWith(fontSize: 16.0),
                ),
              ),
            );
          },
          todayBuilder: (context, date, _) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(4.0),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Color.fromRGBO(8, 112, 138, 0.2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            );
          },
          markerBuilder: (context, date, holidays) {
            final children = <Widget>[];

            // if (events.isNotEmpty) {
            //   children.add(
            //     Container(),
            //   );
            // }

            if (holidays.isNotEmpty) {
              children.add(
                Container(),
              );
            }

            return Column(
              children: children,
            );
          },
        ),
        onDaySelected: (date, _selectedDay) {
          _animationController!.forward(from: 0.0);
          setState(() {
            _selectedDay = date;
          });
        },
      ),
    );
  }

////////////////////////Calendar Functions Ends///////////////////////////////

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    images = Provider.of<PlannerModel>(context, listen: true).progressPhotoList;
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (_selectedDay == null) _selectedDay = args!['datetime'];

    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.chevron_left,
                          size: 30,
                        ),
                      ),
                    ),
                    Text(
                      'Progress Photo',
                      style: TextStyle(fontSize: 20),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/compare-photo');
                      },
                      child: Text(
                        'Compare',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                      backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),

                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                  onTap: () {
                    return showCalendarDialog(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 10),
                        Text(intl.DateFormat('yMd').format(_selectedDay!))
                      ],
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Front'),
                    Text('Side'),
                    Text('Back'),
                  ],
                ),
              ),
              Column(
                children: [
                  if (images
                      .where((element) =>
                          element!.dateTime!.day == _selectedDay!.day &&
                          element.dateTime!.month == _selectedDay!.month &&
                          element.dateTime!.year == _selectedDay!.year)
                      .isEmpty)
                    buildGridView(),
                ],
              ),
              if (images
                  .where((element) =>
                      element!.dateTime!.day == _selectedDay!.day &&
                      element.dateTime!.month == _selectedDay!.month &&
                      element.dateTime!.year == _selectedDay!.year)
                  .isNotEmpty)
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      if (images[index]!.dateTime!.day != _selectedDay!.day ||
                          images[index]!.dateTime!.month !=
                              _selectedDay!.month ||
                          images[index]!.dateTime!.year != _selectedDay!.year)
                        return Container();
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: 3,
                        itemBuilder: (context, gindex) {
                          return GestureDetector(
                            onTap: () {
                              gindex == 0
                                  ? frontModal(context, images[index])
                                  : gindex == 1
                                      ? backModal(context, images[index])
                                      : sideModal(context, images[index]);
                            },
                            child: GridTile(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: (gindex == 0
                                        ? images[index]!.back != null &&
                                                images[index]!.back != ''
                                            ? Image.file(
                                                File(images[index]!.back!))
                                            : Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                height: 200,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 5,
                                                        color: Color.fromRGBO(
                                                            86, 177, 191, 1)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: Icon(
                                                  Icons.add_circle,
                                                  color: Color.fromRGBO(
                                                      86, 177, 191, 1),
                                                  size: 40,
                                                ),
                                              )
                                        : (gindex == 1)
                                            ? images[index]!.front != null &&
                                                    images[index]!.front != ''
                                                ? Image.file(
                                                    File(images[index]!.front!))
                                                : Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 5,
                                                            color:
                                                                Color.fromRGBO(
                                                                    86,
                                                                    177,
                                                                    191,
                                                                    1)),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    child: Icon(
                                                      Icons.add_circle,
                                                      color: Color.fromRGBO(
                                                          86, 177, 191, 1),
                                                      size: 40,
                                                    ),
                                                  )
                                            : images[index]!.side != null &&
                                                    images[index]!.side != ''
                                                ? Image.file(
                                                    File(images[index]!.side!))
                                                : Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 5,
                                                            color:
                                                                Color.fromRGBO(
                                                                    86,
                                                                    177,
                                                                    191,
                                                                    1)),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    child: Icon(
                                                      Icons.add_circle,
                                                      color: Color.fromRGBO(
                                                          86, 177, 191, 1),
                                                      size: 40,
                                                    ),
                                                  )),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        intl.DateFormat.yMd()
                                            .format(images[index]!.dateTime!),
                                        style: TextStyle(color: Colors.black45),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
            ],
          ),
        ),
      ),
    );
  }
}
