import 'dart:developer';

import 'package:flutter/material.dart';
// import 'package:iterasi1/navigation/side_navbar.dart';
import 'package:flutter/services.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/pages/datepicker/select_date.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/date_time_formatter.dart';
import 'package:iterasi1/widget/itinerary_card.dart';
import 'package:provider/provider.dart';

import '../model/itinerary.dart';
import '../widget/text_dialog.dart';

class ItineraryList extends StatefulWidget {
  static const route = "/ItineraryListRoute";

  ItineraryList({Key? key}) : super(key: key);

  @override
  State<ItineraryList> createState() => _ItineraryListState();
}

class _ItineraryListState extends State<ItineraryList> {
  late ScaffoldMessengerState snackbarHandler;
  String searchKeyword = '';

  TextEditingController searchController = TextEditingController();

  final time = DateTime.now();

  late DatabaseProvider dbProvider;

  @override
  Widget build(BuildContext context) {
    // String searchKeyword = '';
    // TextEditingController searchController = TextEditingController(text: '');
    snackbarHandler = ScaffoldMessenger.of(context);

    dbProvider = Provider.of(context, listen: true);

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    // String _prefixtext = "Search";

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF1F2F6),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        key: _scaffoldKey,
        floatingActionButton: FloatingActionButton(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          backgroundColor: const Color(0xFFC58940),
          onPressed: () {
            getItineraryTitle(context);
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        backgroundColor: CustomColor.whiteColor,
        // drawer: NavDrawer(),
        appBar: AppBar(
          centerTitle: false,
          // automaticallyImplyLeading: false,
          backgroundColor: CustomColor.primary,
          elevation: 0,

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip Planner',
                style: TextStyle(
                  fontFamily: 'poppins_bold',
                  color: CustomColor.whiteColor,
                  fontWeight: bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10,
                ),
                color: CustomColor.whiteColor,
                child: Text(
                  'TRIP SERU, PLANNING GAMPANG',
                  style: primaryTextStyle.copyWith(
                    color: CustomColor.primary,
                    fontWeight: semibold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                color: CustomColor.primaryColor500,
                child: TextFormField(
                  controller: searchController,
                  // selectionHeightStyle: BoxHeightStyle.tight,
                  style: primaryTextStyle.copyWith(),
                  cursorColor: CustomColor.primaryColor500,
                  onChanged: (value) {
                    log('message ${searchController.text}');
                  },
                  decoration: InputDecoration(
                    fillColor: CustomColor.whiteColor,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(),
                    hintText: 'Cari Trip Anda',
                    hintStyle: primaryTextStyle.copyWith(
                      color: CustomColor.subtitleTextColor,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                      borderSide: BorderSide(
                        color: CustomColor.disabledColor,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                      borderSide: BorderSide(
                        color: CustomColor.primary,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      maxHeight: 22,
                    ),
                    prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8),
                        child: Icon(Icons.search)),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  children: [
                    FutureBuilder<List<Itinerary>>(
                      future: dbProvider.itineraryDatas,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Jika masih dalam proses memuat data, tampilkan indikator kemajuan
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          // Jika terjadi kesalahan, tampilkan pesan kesalahan
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (snapshot.hasData) {
                          // Jika data sudah tersedia, tampilkan daftar itineraries
                          final itineraries = snapshot.data!;

                          return Column(
                            children: [
                              ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                scrollDirection: Axis.vertical,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  ...itineraries.map(
                                    (e) {
                                      return ItineraryCard(
                                        snackbarHandler: snackbarHandler,
                                        itinerary: e,
                                        dbProvider: dbProvider,
                                      );
                                    },
                                  ).where(
                                    (item) => item.itinerary.title
                                        .toLowerCase()
                                        .contains(
                                          searchController.text.toLowerCase(),
                                        ),
                                  )
                                ],
                              )
                            ],
                          );
                        } else {
                          // Jika tidak ada data, tampilkan widget kosong
                          return Container(); // atau bisa juga return null
                        }
                      },
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

  Future<void> getItineraryTitle(BuildContext context) async {
    final itineraryTitle = await showTextDialog(
      context,
      title: "JUDUL ITINERARY",
      value: "",
    );

    if (itineraryTitle != null && context.mounted) {
      if (itineraryTitle.isNotEmpty) {
        final today = DateTime.now();

        Provider.of<ItineraryProvider>(context, listen: false).initItinerary(
            Itinerary(
                title: itineraryTitle,
                dateModified: DateTimeFormatter.toDMY(today)));

        snackbarHandler.removeCurrentSnackBar();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return SelectDate(
                isNewItinerary: true,
              );
            },
          ),
        );
      }
    }
  }
}
