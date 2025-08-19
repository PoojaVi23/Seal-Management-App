import 'package:location/location.dart';

class LocationDataHolder {
  static LocationData? _locationData;

  static LocationData? get locationData => _locationData;

  static void setLocationData(LocationData data) {
    _locationData = data;
  }
}
