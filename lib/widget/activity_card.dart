import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/pages/activity_photo_page.dart';
import 'package:iterasi1/pages/add_activities/add_activities.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/app_helper.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class ActivityCard extends StatelessWidget {
  final Activity data;
  final int selectedDayIndex;
  final int activityIndex;
  final void Function() onDismiss;
  final void Function() onUndo;
  final ScaffoldMessengerState snackbarHandler;
  const ActivityCard({
    super.key,
    required this.data,
    required this.selectedDayIndex,
    required this.activityIndex,
    required this.onDismiss,
    required this.onUndo,
    required this.snackbarHandler,
  });

  @override
  Widget build(BuildContext context) {
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

    final currentActivity = data.copy();

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
      key: Key(data.hashCode.toString()),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              log("removed images" + data.removedImages.toString());
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AddActivities(
                      initialActivity: data,
                      onSubmit: (newActivity) {
                        context.read<ItineraryProvider>().updateActivity(
                            updatedDayIndex: selectedDayIndex,
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
                color: CustomColor.primaryColor50,
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
                            Icon(
                              const IconData(
                                0xe055,
                                fontFamily: 'MaterialIcons',
                              ),
                              color: CustomColor.subtitleTextColor,
                              size: 15,
                            ),
                            const SizedBox(
                              width: 9,
                            ),
                            Expanded(
                              child: Text(
                                data.lokasi,
                                textAlign: TextAlign.left,
                                style: primaryTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: semibold,
                                  color: CustomColor.subtitleTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          data.activityName,
                          textAlign: TextAlign.left,
                          style: primaryTextStyle.copyWith(
                            fontSize: 20,
                            fontWeight: semibold,
                            color: CustomColor.primaryColor900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'START',
                                  style: primaryTextStyle.copyWith(
                                    fontWeight: regular,
                                    fontSize: 12,
                                    color: CustomColor.subtitleTextColor,
                                  ),
                                ),
                                Text(
                                  data.startActivityTime,
                                  style: primaryTextStyle.copyWith(
                                    fontWeight: regular,
                                    fontSize: 16,
                                    color: CustomColor.subtitleTextColor,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: CustomColor.primaryColor300,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(50.0),
                                ),
                              ),
                              child: Text(
                                '${AppHelper.calculateDurationInMinutes(data.startActivityTime, data.endActivityTime)} Mins',
                                style: primaryTextStyle.copyWith(
                                  fontWeight: semibold,
                                  color: CustomColor.whiteColor,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'END',
                                  style: primaryTextStyle.copyWith(
                                    fontWeight: regular,
                                    fontSize: 12,
                                    color: CustomColor.subtitleTextColor,
                                  ),
                                ),
                                Text(
                                  data.endActivityTime,
                                  style: primaryTextStyle.copyWith(
                                    fontWeight: regular,
                                    fontSize: 16,
                                    color: CustomColor.subtitleTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
