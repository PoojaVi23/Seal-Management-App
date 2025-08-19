class SealData {
  String? sr_no;
  String? location_name;
  String? seal_transaction_id;
  String? seal_date;
  String? seal_unloading_date;
  String? seal_unloading_time;
  String? vehicle_no;
  String? allow_slip_no;
  String? plant_name;
  String? material_name;
  String? vessel_name;
  String? first_weight;
  String? second_weight;
  String? net_weight;
  String? start_seal_no;
  String? end_seal_no;
  String? seal_color;
  String? no_of_seal;
  String? other_seal_no;
  String? sender_remarks;
  String? tarpaulin_condition;
  dynamic gps_seal_no; // Change to dynamic to handle null values
  String? extra_start_seal_no;
  String? extra_end_seal_no;
  dynamic extra_no_of_seal; // Change to dynamic to handle null values and integers
  String? rejected_seal_no;
  String? new_seal_no;
  String? remarks;
  String? rev_remarks;
  dynamic img_cnt; // Change to dynamic to handle null values and integers
  List<String> pics;


  SealData({
    required this.sr_no,
    required this.location_name,
    required this.seal_transaction_id,
    required this.seal_date,
    required this.seal_unloading_date,
    required this.seal_unloading_time,
    required this.vehicle_no,
    required this.allow_slip_no,
    required this.plant_name,
    required this.material_name,
    required this.vessel_name,
    required this.first_weight,
    required this.second_weight,
    required this.net_weight,
    required this.tarpaulin_condition,
    required this.sender_remarks,
    required this.start_seal_no,
    required this.end_seal_no,
    required this.seal_color,
    required this.no_of_seal,
    required this.gps_seal_no,
    required this.extra_start_seal_no,
    required this.extra_end_seal_no,
    required this.extra_no_of_seal,
    required this.rejected_seal_no,
    required this.new_seal_no,
    required this.remarks,
    required this.rev_remarks,
    required this.img_cnt,
    required this.pics,
  });

  // Factory method to create SealData from JSON
  factory SealData.fromJson(Map<String, dynamic> json) {
    return SealData(
      pics: json['pics'],
      sr_no: json['sr_no'],
      location_name: json['location_name'],
      seal_transaction_id: json['seal_transaction_id'],
      seal_date: json['seal_date'],
      seal_unloading_date: json['seal_unloading_date'],
      seal_unloading_time: json['seal_unloading_time'],
      vehicle_no: json['vehicle_no'],
      allow_slip_no: json['allow_slip_no'],
      plant_name: json['plant_name'],
      material_name: json['material_name'],
      vessel_name: json['vessel_name'],
      first_weight: json['first_weight'],
      second_weight:json['second_weight'],
      net_weight: json['net_weight'],
      sender_remarks: json['sender_remarks'],
      tarpaulin_condition: json['tarpaulin_condition'],
      start_seal_no: json['start_seal_no'],
      end_seal_no: json['end_seal_no'],
      seal_color: json['seal_color'],
      no_of_seal: json['no_of_seal'],
      gps_seal_no: json['gps_seal_no'],
      extra_start_seal_no: json['extra_start_seal_no'],
      extra_end_seal_no: json['extra_end_seal_no'],
      extra_no_of_seal: json['extra_no_of_seal'],
      rejected_seal_no: json['rejected_seal_no'],
      new_seal_no: json['new_seal_no'],
      remarks: json['remarks'],
      rev_remarks: json['rev_remarks'],
      img_cnt: json['img_cnt'],
    );
  }
}
