import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/features/map/model/MyLocationData.dart';
import 'package:uuid/uuid.dart';

const double cameraZoom = 16;
const double cameraTilt = 80;
const double cameraBearing = 30;

class SelectLocation extends StatefulWidget {
  const SelectLocation({super.key});

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  late LatLng myCurrentLocation = const LatLng(-6.200000, 106.816666);
  late String myCurrentLocationAddress = "";
  late String myCurrentLocationName = "";
  late GoogleMapController? _mapController;
  final _markers = <Marker>{};
  final SearchController _searchController = SearchController();
  final String sessionToken = Uuid().v4();
  CancelToken cancelToken = CancelToken();
  @override
  void initState() {
    super.initState();
    _handlePosition();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  _handlePosition() async {
    LocationData? locationData = await LocationHandler.getCurrentPosition();

    if (locationData != null && mounted) {
      setState(() {
        myCurrentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: myCurrentLocation, zoom: 15),
          ),
        );
      });
    }
  }

  Future<dynamic> _getSuggestion(String query) async {
    cancelToken.cancel();
    cancelToken = CancelToken();
    return await LocationHandler.getAutoComplete(query, sessionToken, cancelToken);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              if (mounted) {
                setState(() {
                  _mapController = controller;
                });
              }
            },
            onCameraIdle: () async {
              LatLng? newLocation = await _mapController?.getLatLng(
                ScreenCoordinate(
                  x: (screenWidth * pixelRatio * 0.5).toInt(),
                  y: (screenHeight * pixelRatio * 0.5).toInt(),
                ),
              );
              if (newLocation == null) return;
              var preciseLocation = await LocationHandler.getAddressFromLatLng(newLocation);
              if (preciseLocation == null || !mounted) return;
              debugPrint(preciseLocation.toString());
              String preciseLocationAddress =
                  "${preciseLocation.street}, ${preciseLocation.subLocality} ${preciseLocation.locality}, ${preciseLocation.administrativeArea}, ${preciseLocation.postalCode}, ${preciseLocation.country}";
              String preciseLocationName = "${preciseLocation.street}";
              if (mounted) {
                setState(() {
                  myCurrentLocation = newLocation;
                  myCurrentLocationName = preciseLocationName;
                  myCurrentLocationAddress = preciseLocationAddress;
                });
              }
            },
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            initialCameraPosition: CameraPosition(
              target: myCurrentLocation,
              zoom: 15,
            ),
          ),
          Positioned(
            top: 20,
            width: screenWidth,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchAnchor(
                  searchController: _searchController,
                  viewBackgroundColor: AppPallete.neutralColor.shade100,
                  builder: (context, controller) {
                    return SearchBar(
                      controller: _searchController,
                      backgroundColor: WidgetStateProperty.all(AppPallete.neutralColor.shade100),
                      leading: const Icon(Icons.location_on),
                      trailing: const [Icon(Icons.search)],
                      hintText: "Search your address here...",
                      onTap: () {
                        controller.openView();
                      },
                    );
                  },
                  suggestionsBuilder: (context, controller) async {
                    dynamic suggestedAddress = await _getSuggestion(controller.text);
                    return suggestedAddress.length > 0
                        ? List<Widget>.generate(
                            suggestedAddress.length,
                            (index) {
                              var item = suggestedAddress[index];
                              var placeId = item['place_id'];
                              return ListTile(
                                title: Text(item['description']),
                                leading: Icon(
                                  Icons.location_on,
                                  color: AppPallete.primaryColor.shade200,
                                ),
                                onTap: () {
                                  LocationHandler.getPlaceDetails(placeId).then((value) {
                                    setState(() {
                                      final geometry = value['geometry']['location'];
                                      myCurrentLocation = LatLng(geometry['lat'], geometry['lng']);
                                      myCurrentLocationName = value['name'];
                                      myCurrentLocationAddress = value['formatted_address'];
                                      _mapController?.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(target: myCurrentLocation, zoom: 17),
                                        ),
                                      );
                                    });
                                  });
                                  _searchController.closeView(item['description']);
                                },
                              );
                            },
                          )
                        : [];
                  },
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Icon(
                Icons.location_on,
                color: AppPallete.primaryColor,
                size: 30,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            width: screenWidth,
            child: Container(
              padding: EdgeInsets.all(24.0),
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
                color: AppPallete.neutralColor.shade50,
                boxShadow: [
                  BoxShadow(
                    color: AppPallete.neutralColor.shade300,
                    spreadRadius: 2,
                    blurRadius: 7,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Pilih lokasi",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        color: AppPallete.primaryColor,
                        size: 35.0,
                      ),
                      SizedBox(width: 16.0),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              myCurrentLocationName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              myCurrentLocationAddress,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: screenWidth,
                    child: FilledButton(
                      onPressed: () {
                        context.pop(MyLocationData(latlng: myCurrentLocation, address: myCurrentLocationAddress));
                      },
                      child: Text("Konfirmasi"),
                    ),
                  ),
                ],
              ),
            ),
          )
          // Align(
          //   child: FilledButton(
          //       onPressed: () {
          //         _handlePosition();
          //       },
          //       child: const Text("Current Position")),
          // )
        ],
      ),
    );
  }
}
