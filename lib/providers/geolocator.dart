import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Location {
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<Placemark>> getPosData(double lat, double lng) async {
    try {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      return placemark;
    } catch (e) {
      // Si hay un error, devolver una lista de Placemark con los datos de ubicación predeterminados
      List<Placemark> defaultPlacemark = [
        Placemark(
          locality: "Tuxtla Gutiérrez",
        )
      ];
      return defaultPlacemark;
    }
  }
}
