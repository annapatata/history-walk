import '../../routes/models/stopmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';  

class MapController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var stops = <StopModel>[].obs;

  void fetchRouteData(String routeId) async {
    //1.fetch the stops sub-collection
    var snapshot = await _db
        .collection('routes')
        .doc(routeId)
        .collection('stops')
        .orderBy('order') //ensure they are in sequence
        .get();

     stops.value = snapshot.docs.map((doc){
        //convert firestore geopoint to mapbox LatLng
        GeoPoint pos = doc['location'];
        return StopModel(
          id: doc.id,
          name: doc['name'],
          location: Point(coordinates: Position(pos.longitude, pos.latitude)),
          imageUrls: List<String>.from(doc['imageUrls']),
          historyContent: doc['historyContent'],
          order: doc['order'],
        );
     }).toList();
  }
}