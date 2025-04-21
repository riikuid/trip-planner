// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:developer' as dev;
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iterasi1/model/alert_save_dialog_result.dart';
import 'package:iterasi1/model/day.dart';
import 'package:iterasi1/pages/activity_photo_page.dart';
import 'package:iterasi1/pages/add_activities/add_activities.dart';
import 'package:iterasi1/pages/add_days/app_bar_itinerary_title.dart';
import 'package:iterasi1/pages/add_days/search_field.dart';
import 'package:iterasi1/pages/datepicker/select_date.dart';
import 'package:iterasi1/pages/itinerary_list.dart';
import 'package:iterasi1/pages/pdf/preview_pdf_page.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/widget/activity_card.dart';
import 'package:loader_overlay/loader_overlay.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/activity.dart';
import '../../provider/itinerary_provider.dart';

class AddDays extends StatefulWidget {
  const AddDays({Key? key}) : super(key: key);

  @override
  State<AddDays> createState() => _AddDaysState();
}

class _AddDaysState extends State<AddDays> {
  // Provider
  late ItineraryProvider itineraryProvider;
  late DatabaseProvider databaseProvider;

  // State
  int selectedDayIndex = 0;
  bool isEditing = false;
  late Widget appBarTitle;
  late List<Widget> actionIcon;

  late ScaffoldMessengerState snackbarHandler;

  Future<void> openGoogleMaps(String placeName) async {
    // Encode nama tempat untuk URL
    String query = Uri.encodeComponent(placeName);
    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$query";

    final Uri url = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

// Fungsi untuk meminta permission galeri dan navigasi jika izin diberikan
  Future<void> requestGalleryPermission(Activity activity) async {
    var result = await PhotoManager
        .requestPermissionExtend(); // Langsung meminta permission dan mendapatkan hasilnya
    if (result.isAuth) {
      // Jika izin diberikan, navigasi ke ActivityPhotoPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActivityPhotoPage(
              dayIndex: selectedDayIndex,
              activity:
                  activity), // Pastikan class ActivityPhotoPage menerima parameter activity
        ),
      );
    } else {
      // Tampilkan dialog jika izin tidak diberikan
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Perizinan Ditolak"),
          content:
              const Text("Aplikasi memerlukan izin untuk mengakses galeri."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    snackbarHandler = ScaffoldMessenger.of(context);

    itineraryProvider = Provider.of(context, listen: true);
    databaseProvider = Provider.of(context, listen: true);

    if (isEditing) {
      appBarTitle = SearchField(
        initialText: itineraryProvider.itinerary.title,
        onSubmit: (String newTitle) {
          setState(
            () {
              itineraryProvider.setNewItineraryTitle(newTitle);
              isEditing = false;
            },
          );
        },
        onValueChange: (newTitle) {
          itineraryProvider.setNewItineraryTitle(newTitle);
        },
      );

      actionIcon = [];
    } else {
      appBarTitle =
          AppBarItineraryTitle(title: itineraryProvider.itinerary.title);

      actionIcon = [
        IconButton(
          icon: Icon(
            Icons.mode_edit_outlined,
            color: CustomColor.whiteColor,
          ),
          onPressed: () {
            setState(
              () {
                isEditing = true;
              },
            );
          },
        )
      ];
    }

    return LoaderOverlay(
      child: WillPopScope(
        onWillPop: handleBackBehaviour,
        child: Scaffold(
          backgroundColor: CustomColor.primary,
          appBar: AppBar(
            surfaceTintColor: CustomColor.transparentColor,
            title: appBarTitle,
            actions: actionIcon,
            centerTitle: true,
            // leading: IconButton(
            //   icon: Center(
            //     child: Icon(
            //       Icons.arrow_back_ios,
            //       color: CustomColor.whiteColor,
            //     ),
            //   ),
            //   onPressed: () {
            //     handleBackBehaviour().then(
            //       (shouldPop) {
            //         if (shouldPop) {
            //           Navigator.popUntil(
            //             context,
            //             ModalRoute.withName(ItineraryList.route),
            //           );
            //         }
            //       },
            //     );
            //   },
            leading: Padding(
              padding: const EdgeInsets.all(3.0),
              child: BackButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: CustomColor.whiteColor,
                ),
                onPressed: () {
                  handleBackBehaviour().then(
                    (shouldPop) {
                      if (shouldPop) {
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName(ItineraryList.route),
                        );
                      }
                    },
                  );
                },
              ),
            ),

            backgroundColor: CustomColor.primary,
            elevation: 0,
          ),
          body: Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                ),
                child: Container(
                  color: CustomColor.whiteColor,
                  // padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 65,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return KartuTanggal(
                                    index,
                                    itineraryProvider
                                        .itinerary.days[index].date);
                              },
                              itemCount:
                                  itineraryProvider.itinerary.days.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const SizedBox(
                                  // height: 24,
                                  width: 40,
                                );
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return SelectDate(
                                        isNewItinerary: false,
                                        initialDates: itineraryProvider
                                            .itinerary.days
                                            .map((e) => e.getDatetime())
                                            .toList(),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(1.0),
                                  child: Icon(Icons.add),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Divider(
                        height: 0,
                        color: CustomColor.subtitleTextColor,
                        thickness: 0.5,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 65),
                          child: FutureBuilder<List<Activity>>(
                            future: itineraryProvider.getSortedActivity(
                                itineraryProvider.itinerary
                                    .days[selectedDayIndex].activities),
                            builder: (context, snapshot) {
                              final data = snapshot.data;
                              if (data != null) {
                                return ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 24, 20, 0),
                                  scrollDirection: Axis.vertical,
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final currentActivity = data[index].copy();
                                    print(
                                        'activity card : ${data[index].startDateTime}');
                                    // print(
                                    //     'activity card : ${data[index].startActivityTime}');
                                    // return buildActivityCard(
                                    //   context,
                                    //   data[index],
                                    //   activityIndex: index,
                                    //   dayIndex: selectedDayIndex,
                                    //   onDismiss: () {
                                    //     itineraryProvider.removeActivity(
                                    //         activities: data,
                                    //         removedHashCode:
                                    //             data[index].hashCode);
                                    //   },
                                    //   onUndo: () {
                                    //     itineraryProvider.insertNewActivity(
                                    //         activities: data,
                                    //         newActivity: currentActivity);
                                    //   },
                                    // );
                                    return ActivityCard(
                                      snackbarHandler: snackbarHandler,
                                      data: data[index],
                                      selectedDayIndex: selectedDayIndex,
                                      activityIndex: index,
                                      onUndo: () {
                                        itineraryProvider.insertNewActivity(
                                            activities: data,
                                            newActivity: currentActivity);
                                      },
                                      onDismiss: () {
                                        itineraryProvider.removeActivity(
                                            activities: data,
                                            removedHashCode:
                                                data[index].hashCode);
                                      },
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const SizedBox(
                                      height: 24,
                                    );
                                  },
                                  itemCount: data.length,
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColor.whiteColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  print(itineraryProvider.itinerary
                                      .days[selectedDayIndex].activities);
                                  return AddActivities(
                                    onSubmit: (newActivity) {
                                      itineraryProvider.insertNewActivity(
                                          activities: itineraryProvider
                                              .itinerary
                                              .days[selectedDayIndex]
                                              .activities,
                                          newActivity: newActivity);
                                      dev.log(
                                          "${itineraryProvider.itinerary.days[selectedDayIndex].activities.length}");
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            height: 60,
                            width: 200,
                            decoration: BoxDecoration(
                              color: CustomColor.primaryColor500,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Tambah Aktivitas',
                              style: primaryTextStyle.copyWith(
                                fontWeight: semibold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            backgroundColor: MaterialStatePropertyAll(
                              CustomColor.primaryColor500,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (builder) => PdfPreviewPage(
                                    itinerary: itineraryProvider.itinerary),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.print,
                            color: CustomColor.surface,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            backgroundColor: MaterialStatePropertyAll(
                              CustomColor.primaryColor500,
                            ),
                          ),
                          onPressed: saveCurrentItinerary,
                          child: const Icon(
                            Icons.save,
                            color: CustomColor.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget KartuTanggal(int index, String tanggal) {
    // Split the date string into day, month, and year components
    List<String> dateComponents = tanggal.split('/');
    int day = int.parse(dateComponents[0]);
    int month = int.parse(dateComponents[1]);
    int year = int.parse(dateComponents[2]);

    // Construct a DateTime object from the components
    final parsedDate = DateTime(year, month, day);

    final formattedDate = DateFormat("dd MMM yyyy").format(parsedDate);

    return InkWell(
      onTap: () {
        setState(() {
          selectedDayIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: index == selectedDayIndex
              ? const Border(
                  bottom: BorderSide(
                    width: 3.0,
                    color: CustomColor.buttonColor,
                  ),
                )
              : null,
        ),
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                'Hari ${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins_bold',
                  color: index == selectedDayIndex
                      ? CustomColor.buttonColor
                      : CustomColor.disabledColor,
                ),
              ),
              Text(
                formattedDate, // Use the formatted date
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'poppins_regular',
                  color: index == selectedDayIndex
                      ? CustomColor.buttonColor
                      : CustomColor.disabledColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget addNewDayButton(BuildContext context) => InkWell(
        onTap: () async {
          final choosenDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2023),
              lastDate: DateTime(2100));

          if (choosenDate != null) {
            itineraryProvider.addDay(Day(date: formatDate(choosenDate)));
          }
        },
        child: SizedBox(
          height: 70,
          child: Container(
            padding: const EdgeInsets.fromLTRB(75, 5, 75, 5),
            child: const Card(
              color: Color(0xFFFFB252),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    child: Icon(Icons.add),
                  ),
                  Text(
                    "Tambah Aktivitas",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  String formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  String getMonthString(int intMonth) {
    switch (intMonth) {
      case 1:
        return "Januari";
      case 2:
        return "Februari";
      default:
        return "Desember";
    }
  }

  Widget buildActivityCard(
    BuildContext context,
    Activity activity, {
    required int dayIndex,
    required int activityIndex,
    required void Function() onDismiss,
    required void Function() onUndo,
  }) {
    return Dismissible(
      onDismissed: (DismissDirection direction) {
        snackbarHandler.removeCurrentSnackBar();
        onDismiss();

        snackbarHandler.showSnackBar(
          SnackBar(
            content: const Text("Item dihapus!"),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () {
                onUndo();
                snackbarHandler.removeCurrentSnackBar();
              },
            ),
          ),
        );
      },
      key: Key(activity.hashCode.toString()),
      child: InkWell(
        onTap: () {
          log(activity.latitude ?? 'kosong cak lat e');
          log("removed images" + activity.removedImages.toString());
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return AddActivities(
                  initialActivity: activity,
                  onSubmit: (newActivity) {
                    itineraryProvider.updateActivity(
                        updatedDayIndex: dayIndex,
                        updatedActivityIndex: activityIndex,
                        newActivity: newActivity);
                  },
                );
              },
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: CustomColor.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.activityName,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontFamily: 'poppins_bold',
                              fontSize: 24,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  print('activity:${activity.startDateTime}');
                                  print(
                                      'activity:${activity.startActivityTime}');
                                  requestGalleryPermission(
                                      activity); // Kirim activity sebagai argument
                                },
                                child: Transform.scale(
                                  scale: 1.8, // ukuran gambar
                                  child: const Image(
                                    width: 30,
                                    height: 30,
                                    color: CustomColor.surface,
                                    image: AssetImage(
                                      'assets/images/gallery-favorite.png',
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  openGoogleMaps(activity.lokasi);
                                },
                                child: Text(
                                  'Open on Maps',
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              IconData(0xe055, fontFamily: 'MaterialIcons'),
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(
                              width: 9,
                            ),
                            Expanded(
                              child: Text(
                                activity.lokasi,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontFamily: 'poppins_bold',
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_outlined,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(
                              width: 9,
                            ),
                            Text(
                              "${activity.startActivityTime} - ${activity.endActivityTime}",
                              style: const TextStyle(
                                fontFamily: 'poppins_bold',
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    Text(
                      activity.keterangan,
                      style: const TextStyle(
                        fontFamily: 'poppins_regular',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<AlertSaveDialogResult?> showAlertSaveDialog(BuildContext context) {
    return showDialog<AlertSaveDialogResult?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Ubah warna latar belakang
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Ubah bentuk border
          ),
          title: const Text(
            "Konfirmasi",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'poppins_bold',
              color: Color(0xFFC58940), // Ubah warna teks judul
              fontWeight: FontWeight.bold, // Teks judul menjadi tebal
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(AlertSaveDialogResult.saveWithoutQuit);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red, // Ubah warna latar belakang
                        borderRadius:
                            BorderRadius.circular(8), // Ubah bentuk border
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12), // Atur padding
                      child: const Text(
                        "Keluar Tanpa Simpan",
                        textAlign:
                            TextAlign.center, // Pusatkan teks dalam tombol
                        style: TextStyle(
                          fontFamily: 'poppins_bold',
                          color: Colors.white, // Ubah warna teks
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(AlertSaveDialogResult.saveAndQuit);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green, // Ubah warna latar belakang
                        borderRadius:
                            BorderRadius.circular(8), // Ubah bentuk border
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12), // Atur padding
                      child: const Text(
                        "Keluar dan Simpan",
                        textAlign:
                            TextAlign.center, // Pusatkan teks dalam tombol
                        style: TextStyle(
                          fontFamily: 'poppins_bold',
                          color: Colors.white, // Ubah warna teks
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> saveCurrentItinerary() {
    context.loaderOverlay.show();
    return databaseProvider
        .insertItinerary(itinerary: itineraryProvider.itinerary)
        .whenComplete(
      () {
        Navigator.popUntil(context, ModalRoute.withName(ItineraryList.route));
        context.loaderOverlay.hide();
      },
    );
  }

  Future<bool> handleBackBehaviour() async {
    if (itineraryProvider.isDataChanged) {
      final resultSaveDialog = await showAlertSaveDialog(context);

      late bool shouldPop;

      if (resultSaveDialog == AlertSaveDialogResult.saveWithoutQuit) {
        shouldPop = true;
      } else if (resultSaveDialog == AlertSaveDialogResult.saveAndQuit) {
        await saveCurrentItinerary();
        shouldPop = true;
      } else {
        shouldPop = false;
      }
      if (shouldPop) {
        snackbarHandler.removeCurrentSnackBar();
      }
      return shouldPop;
    } else {
      snackbarHandler.removeCurrentSnackBar();
      return true;
    }
  }
}
