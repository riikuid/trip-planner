import 'package:flutter/material.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:provider/provider.dart';

class ItineraryCard extends StatelessWidget {
  final DatabaseProvider dbProvider;
  final ScaffoldMessengerState snackbarHandler;
  final Itinerary itinerary;
  const ItineraryCard(
      {super.key,
      required this.dbProvider,
      required this.snackbarHandler,
      required this.itinerary});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () {
        final itineraryProvider =
            Provider.of<ItineraryProvider>(context, listen: false);
        itineraryProvider.initItinerary(itinerary);

        snackbarHandler.removeCurrentSnackBar();
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const AddDays();
        }));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(12.0),
          ),
          boxShadow: [
            const BoxShadow(
              color: Color(0x19000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          color: CustomColor.greyBackgroundColor,
          // border: Border.all(
          //   width: 0.5,
          //   color: CustomColor.primary,
          // ),
        ),
        // height: 0,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  snackbarHandler.removeCurrentSnackBar();
                  final itineraryCopy = itinerary.copy();
                  dbProvider.deleteItinerary(itinerary: itinerary).whenComplete(
                    () {
                      snackbarHandler.showSnackBar(
                        SnackBar(
                          content: const Text("Item dihapus!"),
                          action: SnackBarAction(
                            label: "Undo",
                            onPressed: () {
                              dbProvider.insertItinerary(
                                  itinerary: itineraryCopy);
                              snackbarHandler.removeCurrentSnackBar();
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.cancel,
                  size: 18,
                  color: CustomColor.primaryColor500,
                  weight: 50,
                ),
              ),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${itinerary.days.length} Days Trip',
                      style: primaryTextStyle.copyWith(
                        fontWeight: semibold,
                        fontSize: 10,
                        color: CustomColor.subtitleTextColor,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      itinerary.title,
                      style: primaryTextStyle.copyWith(
                        fontWeight: semibold,
                        color: CustomColor.blackColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CustomColor.primaryColor200,
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            itinerary.days.first.date,
                            style: primaryTextStyle.copyWith(
                              fontWeight: semibold,
                              color: CustomColor.subtitleTextColor,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          child: Text(
                            '-',
                            style: primaryTextStyle.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CustomColor.primaryColor200,
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            itinerary.days.last.date,
                            style: primaryTextStyle.copyWith(
                              fontWeight: semibold,
                              color: CustomColor.subtitleTextColor,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
