import 'package:flutter/material.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:provider/provider.dart';

class ItineraryTile extends StatelessWidget {
  final DatabaseProvider dbProvider;
  final ScaffoldMessengerState snackbarHandler;
  final Itinerary itinerary;

  const ItineraryTile({
    super.key,
    required this.dbProvider,
    required this.snackbarHandler,
    required this.itinerary,
  });

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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          color: CustomColor.greyBackgroundColor,
        ),
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
                  size: 16,
                  color: CustomColor.primaryColor500,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  itinerary.title,
                  style: primaryTextStyle.copyWith(
                    fontWeight: semibold,
                    color: CustomColor.blackColor,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${itinerary.days.length} Days Trip',
                  style: primaryTextStyle.copyWith(
                    fontWeight: semibold,
                    fontSize: 10,
                    color: CustomColor.subtitleTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                itinerary.days.isNotEmpty
                    ? Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: CustomColor.primaryColor200,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                itinerary.days.first.date,
                                style: primaryTextStyle.copyWith(
                                  fontWeight: semibold,
                                  color: CustomColor.subtitleTextColor,
                                  fontSize: 8,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '-',
                              style: primaryTextStyle.copyWith(
                                fontSize: 8,
                                color: CustomColor.subtitleTextColor,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: CustomColor.primaryColor200,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                itinerary.days.last.date,
                                style: primaryTextStyle.copyWith(
                                  fontWeight: semibold,
                                  color: CustomColor.subtitleTextColor,
                                  fontSize: 8,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'No dates set',
                        style: primaryTextStyle.copyWith(
                          fontWeight: semibold,
                          color: CustomColor.subtitleTextColor,
                          fontSize: 8,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
