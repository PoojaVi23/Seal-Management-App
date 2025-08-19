class Temperatures {
  final String status;
  final List<Plant> plant;
  final List<Location> location;
  final List<Material> material;
  final Map<String, List<Vessel>> vessel;
  final List<Color> color;
  final List<User> users;
  final List<Reason> reason;
  final List<VehicleChecklist> vehicleChecklist;

  Temperatures({
    required this.status,
    required this.plant,
    required this.location,
    required this.material,
    required this.vessel,
    required this.color,
    required this.users,
    required this.reason,
    required this.vehicleChecklist,
  });

  Temperatures copyWith({
    String? status,
    List<Plant>? plant,
    List<Location>? location,
    List<Material>? material,
    Map<String, List<Vessel>>? vessel,
    List<Color>? color,
    List<User>? users,
    List<Reason>? reason,
    List<VehicleChecklist>? vehicleChecklist,
  }) =>
      Temperatures(
        status: status ?? this.status,
        plant: plant ?? this.plant,
        location: location ?? this.location,
        material: material ?? this.material,
        vessel: vessel ?? this.vessel,
        color: color ?? this.color,
        users: users ?? this.users,
        reason: reason ?? this.reason,
        vehicleChecklist: vehicleChecklist ?? this.vehicleChecklist,
      );
}

class Color {
  final String colorName;

  Color({
    required this.colorName,
  });

  Color copyWith({
    String? colorName,
  }) =>
      Color(
        colorName: colorName ?? this.colorName,
      );
}

class Location {
  final String locationId;
  final String locationName;
  final String locationRemarks;
  final LocationUpdatedBy updatedBy;
  final bool isAvailableForSeal;
  final bool isAvailableForScrap;
  final bool isAvailableForGps;

  Location({
    required this.locationId,
    required this.locationName,
    required this.locationRemarks,
    required this.updatedBy,
    required this.isAvailableForSeal,
    required this.isAvailableForScrap,
    required this.isAvailableForGps,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      locationId: json['location_id'],
      locationName: json['location_name'],
      locationRemarks: json['location_remarks'],
      updatedBy: json['updated_by'],
      isAvailableForSeal: json['is_available_for_seal'] == '1',
      isAvailableForScrap: json['is_available_for_scrap'] == '1',
      isAvailableForGps: json['is_available_for_gps'] == '1',
    );
  }

// Location copyWith({
//   String? locationId,
//   String? locationName,
//   String? locationRemarks,
//   LocationUpdatedBy? updatedBy,
//   String? isAvailableForSeal,
//   String? isAvailableForScrap,
//   String? isAvailableForGps,
// }) =>
//     Location(
//       locationId: locationId ?? this.locationId,
//       locationName: locationName ?? this.locationName,
//       locationRemarks: locationRemarks ?? this.locationRemarks,
//       updatedBy: updatedBy ?? this.updatedBy,
//       isAvailableForSeal: isAvailableForSeal ?? this.isAvailableForSeal,
//       isAvailableForScrap: isAvailableForScrap ?? this.isAvailableForScrap,
//       isAvailableForGps: isAvailableForGps ?? this.isAvailableForGps,
//);
}

enum LocationUpdatedBy {
  BANTI,
  EMPTY,
  TEJAS
}

class Material {
  final String materialId;
  final String materialName;
  final String isAvailableForSeal;
  final String isAvailableForScrap;
  final String updatedOn;
  final MaterialUpdatedBy updatedBy;
  final String isAvailableForGps;

  Material({
    required this.materialId,
    required this.materialName,
    required this.isAvailableForSeal,
    required this.isAvailableForScrap,
    required this.updatedOn,
    required this.updatedBy,
    required this.isAvailableForGps,
  });

  Material copyWith({
    String? materialId,
    String? materialName,
    String? isAvailableForSeal,
    String? isAvailableForScrap,
    String? updatedOn,
    MaterialUpdatedBy? updatedBy,
    String? isAvailableForGps,
  }) =>
      Material(
        materialId: materialId ?? this.materialId,
        materialName: materialName ?? this.materialName,
        isAvailableForSeal: isAvailableForSeal ?? this.isAvailableForSeal,
        isAvailableForScrap: isAvailableForScrap ?? this.isAvailableForScrap,
        updatedOn: updatedOn ?? this.updatedOn,
        updatedBy: updatedBy ?? this.updatedBy,
        isAvailableForGps: isAvailableForGps ?? this.isAvailableForGps,
      );
}

enum MaterialUpdatedBy {
  ADMIN,
  BANTI,
  TEJAS
}

class Plant {
  final String plantName;
  final String plantId;
  final String isAvailableForScrap;
  final String isAvailableForSeal;

  Plant({
    required this.plantName,
    required this.plantId,
    required this.isAvailableForScrap,
    required this.isAvailableForSeal,
  });

  Plant copyWith({
    String? plantName,
    String? plantId,
    String? isAvailableForScrap,
    String? isAvailableForSeal,
  }) =>
      Plant(
        plantName: plantName ?? this.plantName,
        plantId: plantId ?? this.plantId,
        isAvailableForScrap: isAvailableForScrap ?? this.isAvailableForScrap,
        isAvailableForSeal: isAvailableForSeal ?? this.isAvailableForSeal,
      );
}

class Reason {
  final String reason;

  Reason({
    required this.reason,
  });

  Reason copyWith({
    String? reason,
  }) =>
      Reason(
        reason: reason ?? this.reason,
      );
}

class User {
  final String fullName;
  final String id;

  User({
    required this.fullName,
    required this.id,
  });

  User copyWith({
    String? fullName,
    String? id,
  }) =>
      User(
        fullName: fullName ?? this.fullName,
        id: id ?? this.id,
      );
}

class VehicleChecklist {
  final String id;
  final String vehicleCondition;
  final bool defaultValue;

  VehicleChecklist({
    required this.id,
    required this.vehicleCondition,
    required this.defaultValue,
  });

  VehicleChecklist copyWith({
    String? id,
    String? vehicleCondition,
    bool? defaultValue,
  }) =>
      VehicleChecklist(
        id: id ?? this.id,
        vehicleCondition: vehicleCondition ?? this.vehicleCondition,
        defaultValue: defaultValue ?? this.defaultValue,
      );
}

class Vessel {
  final String vesselId;
  final String vesselName;
  final VesselRemarks vesselRemarks;
  final DateTime vesselDate;
  final String vesselQty;
  final String locationId;
  final VesselUpdatedBy updatedBy;
  final String isActive;
  final String locationName;

  Vessel({
    required this.vesselId,
    required this.vesselName,
    required this.vesselRemarks,
    required this.vesselDate,
    required this.vesselQty,
    required this.locationId,
    required this.updatedBy,
    required this.isActive,
    required this.locationName,
  });

  Vessel copyWith({
    String? vesselId,
    String? vesselName,
    VesselRemarks? vesselRemarks,
    DateTime? vesselDate,
    String? vesselQty,
    String? locationId,
    VesselUpdatedBy? updatedBy,
    String? isActive,
    String? locationName,
  }) =>
      Vessel(
        vesselId: vesselId ?? this.vesselId,
        vesselName: vesselName ?? this.vesselName,
        vesselRemarks: vesselRemarks ?? this.vesselRemarks,
        vesselDate: vesselDate ?? this.vesselDate,
        vesselQty: vesselQty ?? this.vesselQty,
        locationId: locationId ?? this.locationId,
        updatedBy: updatedBy ?? this.updatedBy,
        isActive: isActive ?? this.isActive,
        locationName: locationName ?? this.locationName,
      );
}

enum VesselUpdatedBy {
  USER2
}

enum VesselRemarks {
  EMPTY,
  MCC_NON_FERROUS
}
