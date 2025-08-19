import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:SealApp/pages/View_Seal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SealApp/app_classes/My_Drawer.dart';
import 'package:SealApp/app_classes/My_Application_Bar.dart';
import 'package:SealApp/pages/Login_Page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
// import 'package:multiple_images_picker/multiple_images_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as Img;

class AddSealData extends StatefulWidget {
  @override
  _AddSealDataState createState() => _AddSealDataState();
}

class _AddSealDataState extends State<AddSealData>
{
  bool _isLoading = false; // State variable to manage loading state

  bool _uploading = false; // For gallery
  bool uploading =false; //For camera

  List<DataRow> rows = [];
  List<TextEditingController> rejectedSeals = [];
  List<TextEditingController> newSeals = [];
  List<bool> rowAdded = [];

  // text: '30.860'
  // text: '10.220'
  // text: '20.220'

  // text: 'A254850'
  // text: 'A254851'
  // text: '20'

  //Controller for saving the details
  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  TextEditingController vehiclenoController = TextEditingController();
  TextEditingController netweightController = TextEditingController();
  TextEditingController startsealController = TextEditingController();
  TextEditingController endsealController = TextEditingController();
  TextEditingController noOfSealsController = TextEditingController();
  TextEditingController deviceIDController = TextEditingController();
  TextEditingController firstWeightController = TextEditingController();
  TextEditingController secondWeightController = TextEditingController();
  TextEditingController extraSealController = TextEditingController();
  TextEditingController extraEndSealController = TextEditingController();
  TextEditingController extranoofseals = TextEditingController();
  TextEditingController otherSealController = TextEditingController();
  TextEditingController gpsSealController = TextEditingController();
  TextEditingController tarpaulinConditionController = TextEditingController(text: 'Intact');
  TextEditingController senderRemarksController = TextEditingController();
  TextEditingController sealColorController = TextEditingController();
  TextEditingController ReachedDateController = TextEditingController();
  TextEditingController ReachedTimeController = TextEditingController();
  TextEditingController allowSlipController = TextEditingController();

  //Variables for Dropdown
  String? selectedLocation;
  String? selectedPlantName;
  String? selectedMaterial;
  String? selectedreceiverremarks;
  String? selectedVessel;
  String? selectedsealColor;
  String? selectedreceivedBy;
  String? selectedreceiverRemarks;
  String? selectedemployee;

  // List to store location names,plant names & material name
  List<String> locations = [];
  List<String> plants = [];
  List<String> materials = [];
  List<String> vessel = [];
  List<String> sealcolor = [];
  List<String> receivedby = [];
  List<String> receiverremarks = [];
  List<String> employees = [];

  // List to store plant_id,location_id $ material_id
  List<String> vesselIds = [];
  List<String> locationIds = [];
  List<String> plantIds = [];
  List<String> sealcolorIds = [];
  List<String> materialIds = [];
  List<String> reasonIds = [];
  List<String> employeeIds = [];
  List<String> receivedbyIds = [];
  List<String> receiverremarksIds = [];

  // List to store selected photos
  List<File> _image = [];

  bool _isSubmitButtonEnabled = true;


  //Variables for Date
  String sealDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Current date
  String sealTime = DateFormat('HH:mm:ss').format(DateTime.now()); // Current time

  //Variables for user details
  bool _isloggedin = true;
  String _id = '';
  String _username = '';
  String _full_name = '';
  String _email = '';
  String userImageUrl = '';
  String _user_type = '';
  String _password = '';
  String _uuid = '';

  DateTime? Date;
  DateTime? reachedTime;

  List<TableRow> tableRows = [];

  @override
  void dispose() {
    otherSealController.dispose();
    gpsSealController.dispose();
    extranoofseals.dispose();
    tarpaulinConditionController.dispose();
    senderRemarksController.dispose();
    vehiclenoController.dispose();
    netweightController.dispose();
    startsealController.dispose();
    endsealController.dispose();
    deviceIDController.dispose();
    noOfSealsController.dispose();
    extraSealController.dispose();
    extraEndSealController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    fetchdropdownData();
    fetch_add_seal_data();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.camera,
      Permission.storage,
    ].request();
  }

  // Function to check if all required fields are filled
  bool areRequiredFieldsFilled() {
    // Check if all required fields are filled
    if (vehiclenoController.text.isNotEmpty &&
        vehiclenoController.text.isNotEmpty &&
        netweightController.text.isNotEmpty &&
        startsealController.text.isNotEmpty &&
        endsealController.text.isNotEmpty &&
        noOfSealsController.text.isNotEmpty &&
        noOfSealsController.text.isNotEmpty &&
        selectedLocation != null &&
        selectedLocation != "--- All Location ---" &&
        selectedMaterial != null &&
        selectedMaterial != "--- Select Material ---" &&
        selectedPlantName != null &&
        selectedPlantName != "--- Select Plant ---"
    //&& _image.isNotEmpty
    ) { // Check if images are selected
      return true;
    }
    return false;
  }



  void _updateSubmitButtonState() {
    setState(() {
      _isSubmitButtonEnabled = areRequiredFieldsFilled();
      //&& _image.isNotEmpty;
    });
  }

  void addRow() {
    setState(() {
      var rejectedSeal = TextEditingController();
      var newSeal = TextEditingController();

      rejectedSeals.add(rejectedSeal);
      newSeals.add(newSeal);

      UniqueKey rowKey = UniqueKey();

      rows.add(DataRow(
        key: rowKey, // Set the unique key for the row
        cells: [
          DataCell(IconCell(() => deleteRow(rowKey), isAdd: false, addColor: Colors.green)),
          DataCell(
            TextFormField(
              controller: rejectedSeal,
              decoration: InputDecoration(hintText: 'Enter rejected seal'),
            ),
          ),
          DataCell(
            TextFormField(
              controller: newSeal,
              decoration: InputDecoration(hintText: 'Enter new seal'),
            ),
          ),
        ],
      ));

      rowAdded.add(true);
    });
  }

  void deleteRow(Key key) {
    setState(() {
      int index = rows.indexWhere((row) => row.key == key);

      if (index != -1) {
        rejectedSeals.removeAt(index);
        newSeals.removeAt(index);
        rows.removeAt(index);
        rowAdded.removeAt(index);
      }
    });
  }

  void saveData() {
    for (int i = 0; i < rows.length; i++) {
      String rejected = rejectedSeals[i].text;
      String newSeal = newSeals[i].text;

      if (rejected.isNotEmpty && newSeal.isNotEmpty) {
        print('Saved Data Row $i: Rejected Seal: $rejected, New Seal: $newSeal');
      } else {
        print('Please enter both Rejected Seal and New Seal in Row $i before saving.');
      }
    }
  }


  //Fetching user details from sharedpreferences
  _getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isloggedin = prefs.getBool("loggedin")!;
      _id = prefs.getString('id')!;
      _username = prefs.getString('username')!;
      _full_name = prefs.getString('full_name')!;
      _email = prefs.getString('email')!;
      _user_type = prefs.getString('user_type') ?? '';
      _password = prefs.getString('password')??'';
      _uuid = prefs.getString('uuid')??'';
    });

    if (kDebugMode) {
      print(_user_type);
      //print("is logged in$_isloggedin");
    }
    if (_isloggedin == false) {
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  //Fetching API for Dropdown
  fetchdropdownData() async {
    await _getUserDetails();
    try {
      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/get_dropdown_data'),
        headers: {"Accept": "application/json"},
        body: {
          // 'uuid': "bd0029d5175022be",

          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        //Fetching API for location
        if (data["status"] == "1") {
          if (data.containsKey("location")) {
            updateLocationData(data["location"]);
          } else {
            print('No "location" data found in the response');
          }

          //Fetching API for plant
          if (data.containsKey("plant")) {
            updatePlantData(data["plant"]);
          }else {
            print('No "plant" data found in the response');
          }

          //Fetching API for plant
          if (data.containsKey("material")) {
            updatematerialData(data["material"]);
          }else {
            print('No "material" data found in the response');
          }

          //Fetching API for color
          if (data.containsKey("color")) {
            updatecolorData(data["color"]);
          }else {
            print('No "color" data found in the response');
          }

          //Fetching API for receiver remarks
          if (data.containsKey("reason")) {
            updatereasonData(data["reason"]);
          }else {
            print('No "reason" data found in the response');
          }

          //Fetching API for received by
          if (data.containsKey("users")) {
            updateuserData(data["users"]);
          } else {
            print('No "users" data found in the response');
          }

          // Update vessel data based on selected location
          String? selectedLocationId = getSelectedLocationId();
          if (selectedLocationId != null) {
            fetchVesselNames(data, selectedLocationId);
          } else {
            print('Selected location ID is null');
          }

          setState(() {
            selectedLocation;
            selectedPlantName;
            selectedMaterial;
            selectedsealColor;
            selectedreceiverRemarks;
            selectedemployee;

          });

        } else {
          print('Status is not 1 in the response');
        }
      } else {
        print('Failed to fetch Dropdown API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  fetchVesselNames(Map<String, dynamic> data,String selectedLocationId) {

    print("ASHOKKA:$selectedLocationId");

    // Check if data contains vessel information
    if (data.containsKey("vessel")) {
      // Assuming locationId is the desired location ID
      String locationId = selectedLocationId; // Example location ID

      // Check if vessel information is available for the specified location
      if (data["vessel"].containsKey(locationId)) {
        // Extract vessel names for the specified location
        List<dynamic> vessels = data["vessel"][locationId];
        List<String> vesselNames = vessels.map((vessel) => vessel["vessel_name"].toString()).toList();
        List<String> vesselIDS = vessels.map((vessel) => vessel["vessel_id"].toString()).toList();


        vessel.clear();
        vessel.add('---Select Vessel---');
        // vesselIds.add('0');
        vessel.addAll(vesselNames);
        vesselIds.addAll(vesselIDS);

        print( vessel);
        print( vesselIds);
        // You can use the vessel names as required, for example, update some state variables
        setState(() {
          // selectedVessel = vesselNames.isNotEmpty ? vesselNames[0] : null;
        });

      } else {
        print('No vessel data found for the specified location');
      }
    } else {
      print('No vessel data found in the response');
    }
  }


  // fetchVesselNames(Map<String, dynamic> data, String selectedLocationId) {
  //   print("DEMO:$selectedLocationId");
  //   // Check if data contains vessel information
  //   if (data.containsKey("vessel")) {
  //     // Check if vessel information is available for the specified location
  //     if (data["vessel"].containsKey(selectedLocationId)) {
  //       // Extract vessel names for the specified location
  //       List<dynamic> vessels = data["vessel"][selectedLocationId];
  //       List<String> vesselNames = vessels.map((vessel) => vessel["vessel_name"].toString()).toList();
  //
  //       print(vesselNames);
  //       // You can use the vessel names as required, for example, update some state variables
  //       setState(() {
  //         selectedVessel = vesselNames.isNotEmpty ? vesselNames[0] : null;
  //       });
  //
  //     } else {
  //       print('No vessel data found for the specified location');
  //     }
  //   } else {
  //     print('No vessel data found in the response');
  //   }
  // }

  void updateuserData(List<dynamic> userDataList) {
    employees.clear();
    employeeIds.clear();
    employees.add("--- Select Receiver ---");

    for (var userData in userDataList) {
      String employeeName = userData["full_name"].toString();
      String employeeId = userData["id"].toString();

      employees.add(employeeName);
      employeeIds.add(employeeId);
    }


  }

  void updateLocationData(List<dynamic> locationDataList) {
    locations.clear();
    locationIds.clear();
    locations.add("--- All Location ---");

    for (var locationData in locationDataList) {
      String locationName = locationData["location_name"].toString();
      String locationId = locationData["location_id"].toString();

      locations.add(locationName);
      locationIds.add(locationId);
    }
  }

  void updatereasonData(List<dynamic> reasonDataList) {
    receiverremarks.clear();
    reasonIds.clear();
    receiverremarks.add("Select Remarks");

    for (var reasonData in reasonDataList) {
      String reasonName = reasonData["reason"].toString();
      String reasonId = reasonData["id"].toString();

      receiverremarks.add(reasonName);
      reasonIds.add(reasonId);

    }
    print(receiverremarks);
    print(reasonIds);
  }

  void updatecolorData(List<dynamic> colorDataList) {
    sealcolor.clear();
    sealcolorIds.clear();
    sealcolor.add("--- Select Seal Color ---");

    for (var colorData in colorDataList) {
      String colorName = colorData["color_name"].toString();
      String sealcolorId = colorData["color_id"].toString();
      sealcolor.add(colorName);
      sealcolorIds.add(sealcolorId);
    }
  }

  void updatePlantData(List<dynamic> plantDataList) {
    plants.clear();
    plantIds.clear();
    plants.add("--- Select Plant ---");

    for (var plantData in plantDataList) {
      String plantName = plantData["plant_name"].toString();
      String plantId = plantData["plant_id"].toString();

      plants.add(plantName);
      plantIds.add(plantId);
    }
  }

  void updatematerialData(List<dynamic> materialDataList) {
    materials.clear();
    materialIds.clear();
    materials.add("--- Select Material ---");

    for (var materialData in materialDataList) {
      String materialName = materialData["material_name"].toString();
      String materialId = materialData["material_id"].toString();

      materials.add(materialName);
      materialIds.add(materialId);
    }
  }


  // Define a function to get the sealcolor_id for the selected plant name
  String? getSelectedSealcolorId() {
    if (selectedsealColor != null && selectedsealColor != "--- Select Seal Color ---") {
      int selectedIndex = sealcolor.sublist(sealcolor.indexOf("--- Select Seal Color ---") + 1).indexOf(selectedsealColor!);
      if (selectedIndex != -1 && selectedIndex < sealcolorIds.length) {
        return sealcolorIds[selectedIndex];
      }
    }
    return null;
  }

  // Define a function to get the plant_id for the selected plant name
  String? getSelectedPlantId() {
    if (selectedPlantName != null && selectedPlantName != "--- Select Plant ---") {
      int selectedIndex = plants.sublist(plants.indexOf("--- Select Plant ---") + 1).indexOf(selectedPlantName!);
      if (selectedIndex != -1 && selectedIndex < plantIds.length) {
        return plantIds[selectedIndex];
      }
    }
    return null;
  }

  String? getSelectedVesselId() {
    if (selectedVessel != null && selectedVessel != "---Select Vessel---") {
      int selectedIndex = vessel.sublist(vessel.indexOf("---Select Vessel---") + 1).indexOf(selectedVessel!);
      if (selectedIndex != -1 && selectedIndex < vesselIds.length) {
        return vesselIds[selectedIndex];
      }
    }
    return null;
  }

  String? getSelectedreceivedbyId() {
    if (selectedemployee != null && selectedemployee != "--- Select Receiver ---") {
      int selectedIndex = employees.sublist(employees.indexOf("--- Select Receiver ---") + 1).indexOf(selectedemployee!);
      if (selectedIndex != -1 && selectedIndex < employeeIds.length) {
        return employeeIds[selectedIndex];
      }
    }
    return null;
  }

  // Define a function to get the reason_id for the selected plant name
  String? getSelectedreasonId() {
    if (selectedreceiverRemarks != null && selectedreceiverRemarks != "Select Remarks") {
      int selectedIndex = receiverremarks.sublist(receiverremarks.indexOf("Select Remarks") + 1).indexOf(selectedreceiverRemarks!);
      if (selectedIndex != -1 && selectedIndex < reasonIds.length) {
        return reasonIds[selectedIndex];
      }
    }
    return null;
  }

  // Define a function to get the location_id for the selected location name
  String? getSelectedLocationId() {
    if (selectedLocation != null && selectedLocation != "--- All Location ---") {
      int selectedIndex = locations.sublist(locations.indexOf("--- All Location ---") + 1).indexOf(selectedLocation!);
      if (selectedIndex != -1 && selectedIndex < locationIds.length) {
        return locationIds[selectedIndex];
      }
    }
    return null;
  }

  // Define a function to get the material_id for the selected material name
  String? getSelectedMaterialId() {
    if (selectedMaterial != null && selectedMaterial != "--- Select Material ---") {
      int selectedIndex = materials.sublist(materials.indexOf("--- Select Material ---") + 1).indexOf(selectedMaterial!);
      if (selectedIndex != -1 && selectedIndex < materialIds.length) {
        return materialIds[selectedIndex];
      }
    }
    return null;
  }

  Future<String?> fetch_add_seal_data({
    String? locationId,
    String? materialId,
    String? plantId,
    String? reasonId,
    String? sealDate,
    String? sealTime,
    String? times,
    String? date,
    String? sealcolorID,
    String? received_by,
    List<File>? image,
    List<TextEditingController>? rejSeals, String? vesselId,
  }) async {
    try {

      print("Vessel ID:$vesselId");
      print("IMG:$times");
      print("RS:$rejSeals");
      var request = http.MultipartRequest('POST', Uri.parse('$API_URL/Mobile_flutter_api/add_edit_seal_data_test'));

      // Add text fields
      request.fields['uuid'] =_uuid;
      request.fields['user_id'] = _username;
      request.fields['password'] = _password;
      request.fields['from_location'] = locationId!;
      request.fields['to_location'] = plantId!;
      request.fields['material_id'] = materialId!;
      request.fields['seal_date'] = sealDate!;
      request.fields['start_time'] = sealTime!;
      request.fields['allow_slip_no'] = allowSlipController.text ?? '';
      request.fields['vehicle_no'] = vehiclenoController.text ?? '';
      request.fields['first_weight'] = firstWeightController.text ?? '';
      request.fields['second_weight'] = secondWeightController.text ?? '';
      request.fields['net_weight'] = netweightController.text ?? '';
      request.fields['tarpaulin_condition'] = tarpaulinConditionController.text ?? '';
      request.fields['seal_remarks'] = senderRemarksController.text ?? '';
      request.fields['start_seal_no'] = startsealController.text ?? '';
      request.fields['end_seal_no'] = endsealController.text ?? '';
      request.fields['no_of_seal'] =  noOfSealsController.text ?? '';
      request.fields['gps_seal_no'] = gpsSealController.text ?? '';
      request.fields['extra_start_seal_no'] = extraSealController.text??'';
      request.fields['extra_end_seal_no'] = extraEndSealController.text ?? '';
      request.fields['extra_no_of_seal'] = extranoofseals.text ?? '';
      request.fields['other_extra_seal'] = otherSealController.text ?? '';
      // request.fields['seal_color'] = selectedsealColor ?? '';
      // request.fields['seal_color'] = sealcolorID ?? '';

      request.fields['seal_color'] = selectedsealColor ?? '';

      request.fields['vessel_id'] = vesselId ?? '';

      request.fields['rejected[rejected_seal_no]'] = rejectedSeals.map((controller) => controller.text).toList().join(',');
      request.fields['rejected[new_seal_no]']= newSeals.map((controller) => controller.text).toList().join(',');

      // Add fields only if the values are not null
      if (received_by != null) {
        if (_user_type == 'S' || _user_type == 'A') {
          request.fields['receiver_admin_id'] = received_by;
        }
      }

      if (_user_type == 'S' || _user_type == 'A') {
        if (date != null) {
          request.fields['seal_unloading_date'] = date;
        }
        if (times != null) {
          request.fields['seal_unloading_time'] = times;
        }
        if (reasonId != null) {
          request.fields['receiver_remarks'] = reasonId;
        }
      }

      // Add image file
      if (image != null) {
        for (var image in image) {
          request.files.add(await http.MultipartFile.fromPath('pics[]', image.path));
        }
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        // Assuming the response message is received as text
        return await response.stream.bytesToString();
      } else {
        print('Error submitting seal data. Status code: ${response.statusCode}');
        return 'Error submitting seal data. Status code: ${response.statusCode}';
      }
    }
    catch (e) {
      print('Exception during API call: $e');
    }
  }


  Widget buildFieldWithDatePicker(String label,
      DateTime? selectedDate,
      void Function(DateTime?) onDateChanged,) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(width: 2.0),
        SizedBox(
          height: 40.0,
          width: MediaQuery.of(context).size.width*0.5,
          child: InkWell(
            onTap: () async {
              final newSelectedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (newSelectedDate != null) {
                onDateChanged(newSelectedDate);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              padding: EdgeInsets.all(12.0),
              child: Text(
                selectedDate != null
                    ? '${selectedDate.toLocal()}'.split(' ')[0]
                    : 'Select Date',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300), // Adjust font size as needed
              ),
            ),
          ),
        ),
      ],
    );
  }

  //Function for Time
  Widget buildFieldWithTimePicker(
      DateTime? selectedTime,
      void Function(DateTime?) onTimeChanged,
      BuildContext context,
      ) {
    return InkWell(
      onTap: () async {
        final newSelectedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime != null
              ? TimeOfDay(hour: selectedTime.hour, minute: selectedTime.minute)
              : TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );

        if (newSelectedTime != null) {
          final newDateTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            newSelectedTime.hour,
            newSelectedTime.minute,
          );
          onTimeChanged(newDateTime);
        }
      },
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(0.0),
        ),
        // padding: EdgeInsets.all(24.0),
        padding: EdgeInsets.all(12),
        child: Text(
          selectedTime != null
              ? '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}:${selectedTime.second.toString().padLeft(2, '0')}'
              : 'Select Time',
          style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300), // Adjust font size as needed
        ),
      ),
    );
  }

// Function to pick images from the gallery _pickImageFromCamera
  Future<void> _pickImageFromCamera() async {
    setState(() {
      uploading = true; // Start uploading, show progress indicator
    });
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      await _compressAndAddImage(pickedImage.path);
    }
    setState(() {
      uploading = false; // Upload finished, hide progress indicator
    });
  }


  // Function to pick images from the gallery
  Future<void> _pickImagesFromGallery() async {
    setState(() {
      _uploading = true; // Start uploading, show progress indicator
    });
    List<XFile>? pickedImages = await ImagePicker().pickMultiImage();

    if (pickedImages != null) {
      for (var pickedImage in pickedImages) {
        await _compressAndAddImage(pickedImage.path);
      }
    }
    setState(() {
      _uploading = false; // Upload finished, hide progress indicator
    });
  }



  Future<void> _compressAndAddImage(String imagePath) async {
    File imageFile = File(imagePath);

    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      Img.Image image = Img.decodeImage(Uint8List.fromList(imageBytes))!;
      Img.Image compressedImage = Img.copyResize(image, width: 1024);
      List<int> compressedImageBytes;
      String extension = imagePath.split('.').last.toLowerCase();
      if (extension == 'jpg' || extension == 'jpeg') {
        compressedImageBytes = Img.encodeJpg(compressedImage, quality: 70);
      } else if (extension == 'png') {
        compressedImageBytes = Img.encodePng(compressedImage);
      } else {
        throw UnsupportedError('Unsupported image format: $extension');
      }
      File compressedFile = File(imagePath.replaceAll(RegExp(r'\.\w+$'), '_compressed.$extension'));
      await compressedFile.writeAsBytes(compressedImageBytes);

      setState(() {
        _image.add(compressedFile);
      });
    } catch (e) {
      print('Error during image compression: $e');
    }
  }


  //Function for buildropdown
  Widget buildDropdown(
      String hint,
      List<String> items,
      String? selectedItem,
      void Function(String?) onChanged,
      ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(
            color: Colors.grey.shade600,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedItem,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 10.0),
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.black, fontSize: 14.0),
                  border: InputBorder.none,
                ),
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((String item) {
                    return Center(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList();
                },
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }


// Function to extract numeric part from a string
  double extractNumericPart(String input) {
    // Regular expression to match numeric part
    RegExp regex = RegExp(r"(\d+(?:\.\d+)?)");
    // Find first match
    Match? match = regex.firstMatch(input);
    // Extract numeric part if match found
    if (match != null) {
      return double.parse(match.group(0)!);
    }
    // Return 0 if no match found
    return 0;
  }



  // Function to create a bordered input field
  Widget _buildBorderedInputrichtext({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            createRichText(labelText),
            Container(
              height: 35,
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(0), // Border radius
              ),
              child: Padding(
                padding: EdgeInsets.all(0), // Adjust the horizontal padding as needed
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    hintText: hintText,
                    hintStyle: TextStyle(fontSize: 14.0),
                    border: InputBorder.none, // Remove the default border
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildBorderedInputWithLabel({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labelText,
              style: TextStyle(fontSize: 15.0,color: Colors.black),
            ),
            Container(
              height: 35,
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(0), // Border radius
              ),
              child: Padding(
                padding: EdgeInsets.all(0), // Adjust the horizontal padding as needed
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    hintText: hintText,
                    hintStyle: TextStyle(fontSize: 14.0),
                    border: InputBorder.none, // Remove the default border
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildBorderedInputnet_weight({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    bool performCalculation = false, // Add parameter to determine if calculation should be performed
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labelText,
              style: TextStyle(fontSize: 15.0, color: Colors.black),
            ),
            Container(
              height: 35,
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(0), // Border radius
              ),
              child: Padding(
                padding: EdgeInsets.all(0), // Adjust the horizontal padding as needed
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    hintText: hintText,
                    hintStyle: TextStyle(fontSize: 14.0),
                    border: InputBorder.none, // Remove the default border
                  ),
                  keyboardType: TextInputType.text, // Allow alphanumeric input
                  onChanged: (value) {
                    if (performCalculation) {
                      // Extract numeric part from input
                      // double startSealNo = extractNumericPart(startsealController.text);
                      // double endSealNo = extractNumericPart(endsealController.text);
                      double firstWeight = extractNumericPart(firstWeightController.text);
                      double secondWeight = extractNumericPart(secondWeightController.text);
                      // double extraStartSealNo = extractNumericPart(extraSealController.text);
                      // double extraEndSealNo = extractNumericPart(extraEndSealController.text);

                      // Debug output
                      // print('Extra Start Seal No: $extraStartSealNo');
                      // print('Extra End Seal No: $extraEndSealNo');

                      // Calculate number of seals based on start and end seal numbers
                      // int numberOfSeals = 0;
                      // if (startSealNo != 0 && endSealNo != 0) { // Check if both start and end seals are provided
                      //   numberOfSeals = (endSealNo - startSealNo).abs().toInt() + 1; // Adding 1 to include both start and end seals
                      // }

                      // Calculate net weight based on first and second weight
                      double netWeight = (secondWeight - firstWeight).abs();

                      // Calculate number of extra seals based on extra start and end seal numbers
                      // int numberOfExtraSeals = 0;
                      // if (extraStartSealNo != 0 && extraEndSealNo != 0) { // Check if both extra seals are provided
                      //   numberOfExtraSeals = (extraEndSealNo - extraStartSealNo).abs().toInt() + 1; // Adding 1 to include both start and end extra seals
                      // }

                      // Format net weight to display up to 3 digits after the decimal point
                      String formattedNetWeight = netWeight.toStringAsFixed(3);

                      // Update the text in the respective controllers
                      netweightController.text = formattedNetWeight;
                      // noOfSealsController.text = numberOfSeals.toString();
                      // extranoofseals.text = numberOfExtraSeals.toString();
                      //
                      // print('Number of Seals: $numberOfSeals');
                      // print('Number of Extra Seals: $numberOfExtraSeals');
                    }
                  },

                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBorderedInputno_of_seals({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    bool performCalculation = false, // Add parameter to determine if calculation should be performed
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labelText,
              style: TextStyle(fontSize: 15.0, color: Colors.black),
            ),
            Container(
              height: 35,
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(0), // Border radius
              ),
              child: Padding(
                padding: EdgeInsets.all(0), // Adjust the horizontal padding as needed
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    hintText: hintText,
                    hintStyle: TextStyle(fontSize: 14.0),
                    border: InputBorder.none, // Remove the default border
                  ),
                  keyboardType: TextInputType.text, // Allow alphanumeric input
                  onChanged: (value) {
                    if (performCalculation) {
                      // Extract numeric part from input
                      double startSealNo = extractNumericPart(startsealController.text);
                      double endSealNo = extractNumericPart(endsealController.text);


                      // Calculate number of seals based on start and end seal numbers
                      int numberOfSeals = 0;
                      if (startSealNo != 0 && endSealNo != 0) { // Check if both start and end seals are provided
                        numberOfSeals = (endSealNo - startSealNo).abs().toInt() + 1; // Adding 1 to include both start and end seals
                      }

                      noOfSealsController.text = numberOfSeals.toString();

                      // print('Number of Seals: $numberOfSeals');
                      // print('Number of Extra Seals: $numberOfExtraSeals');
                    }
                  },

                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBorderedInputextra_no_seal({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    bool performCalculation = false, // Add parameter to determine if calculation should be performed
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labelText,
              style: TextStyle(fontSize: 15.0, color: Colors.black),
            ),
            Container(
              height: 35,
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(0), // Border radius
              ),
              child: Padding(
                padding: EdgeInsets.all(0), // Adjust the horizontal padding as needed
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    hintText: hintText,
                    hintStyle: TextStyle(fontSize: 14.0),
                    border: InputBorder.none, // Remove the default border
                  ),
                  keyboardType: TextInputType.text, // Allow alphanumeric input
                  onChanged: (value) {
                    if (performCalculation) {


                      double extraStartSealNo = extractNumericPart(extraSealController.text);
                      double extraEndSealNo = extractNumericPart(extraEndSealController.text);

                      // Debug output
                      // print('Extra Start Seal No: $extraStartSealNo');
                      // print('Extra End Seal No: $extraEndSealNo');




                      // Calculate number of extra seals based on extra start and end seal numbers
                      int numberOfExtraSeals = 0;
                      if (extraStartSealNo != 0 && extraEndSealNo != 0) { // Check if both extra seals are provided
                        numberOfExtraSeals = (extraEndSealNo - extraStartSealNo).abs().toInt() + 1; // Adding 1 to include both start and end extra seals
                      }



                      extranoofseals.text = numberOfExtraSeals.toString();
                      // print('Number of Seals: $numberOfSeals');
                      // print('Number of Extra Seals: $numberOfExtraSeals');
                    }
                  },

                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget createRichText(String labelText) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: labelText,
            style: TextStyle(fontSize: 15.0,color: Colors.black),
          ),
          TextSpan(
            text: '*',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      drawer: MyDrawer(_full_name,_email,_isloggedin,userImageUrl,_id,_user_type,_password,_uuid),
      appBar: MyApplicationBar(title: const Text('SEAL MANAGEMENT')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5.0),
              Row(
                children: [
                  Icon(
                    Icons.lock,
                    color: Colors.blue.shade900,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Add Seal',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  createRichText('Location'),
                  buildDropdown(
                    "--- All Location ---",
                    locations,
                    selectedLocation,
                        (value) async {
                      setState(() {
                        selectedLocation = value;
                      });
                      await fetchdropdownData();

                    },
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  createRichText('Plant'),
                  buildDropdown(
                    "--- Select Plant Name ---",
                    plants,
                    selectedPlantName,
                        (value) {
                      setState(() {
                        selectedPlantName = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  createRichText('Material'),
                  buildDropdown(
                      "--- Select Material Name ---",
                      materials,
                      selectedMaterial,
                          (value) {
                        setState(() {
                          selectedMaterial = value;
                        });
                      }),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vessel',
                    style: TextStyle(fontSize: 15.0),
                  ),
                  // SizedBox(width: 21,),
                  buildDropdown(
                      "---Select Vessel---",
                      vessel,
                      selectedVessel,
                          (value) {
                        setState(() {
                          selectedVessel = value;
                        });
                      }
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Seal Date',
                    style: TextStyle(fontSize: 15.0,color: Colors.black),
                  ),
                  SizedBox(width: 40.0),
                  Text(
                    sealDate,
                    style: TextStyle(fontSize: 15.0),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Seal Time',
                    style: TextStyle(fontSize: 15.0,color: Colors.black),
                  ),
                  // SizedBox(width: 45.0),
                  Text(
                    sealTime,
                    style: TextStyle(fontSize: 15.0),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              _buildBorderedInputWithLabel(
                controller: allowSlipController,
                hintText: 'Enter Allow Slip No',
                labelText: 'Allow Slip No',
              ),
              SizedBox(height: 16.0),
              _buildBorderedInputrichtext(
                controller: vehiclenoController,
                hintText: 'Enter your vehicle number',
                labelText: 'Vehicle No',
              ),
              Text('Vehicle Number\n Must Be 10 Char',style: TextStyle(color: Colors.red,fontSize: 14)),
              SizedBox(height: 16.0),
              _buildBorderedInputnet_weight(
                controller: firstWeightController,
                hintText: 'Enter the first weight',
                labelText: 'First Weight',
                performCalculation: true, // Enable calculation for first weight
              ),
              SizedBox(height: 16.0),
              _buildBorderedInputnet_weight(
                controller: secondWeightController,
                hintText: 'Enter the second weight',
                labelText: 'Second Weight',
                performCalculation: true, // Enable calculation for second weight
              ),
              SizedBox(height: 16.0),
              _buildBorderedInputrichtext(
                controller: netweightController,
                hintText: '00.00',
                labelText: 'Net Weight',
              ),
              SizedBox(height: 16.0),
              _buildBorderedInputno_of_seals(
                controller: startsealController,
                hintText: 'Enter your start seal no',
                labelText: 'Start Seal No',
                performCalculation: true, // Enable calculation for start seal number
              ),
              SizedBox(height: 16.0),
              _buildBorderedInputno_of_seals(
                controller: endsealController,
                hintText: 'Enter your End Seal No',
                labelText: 'End Seal No',
                performCalculation: true, // Enable calculation for end seal number
              ),
              SizedBox(height: 16.0),
              _buildBorderedInputrichtext(
                controller: noOfSealsController,
                hintText: 'Enter the no of seals',
                labelText: 'No of Seals',
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Seal Color',
                    style: TextStyle(fontSize: 15.0,color: Colors.black),
                  ),
                  SizedBox(width: 16.0),
                  buildDropdown(
                      "---Select Seal Color---",
                      sealcolor,
                      selectedsealColor,
                          (value) {
                        setState(() {
                          selectedsealColor = value;
                        });
                      }),
                ],
              ),

              SizedBox(height: 16.0),
              _buildBorderedInputextra_no_seal(
                controller: extraSealController,
                hintText: 'Enter Extra Start Seal No',
                labelText: 'Extra Start \nSeal No',
                performCalculation: true, // Enable calculation for extra start seal number
              ),
              SizedBox(height: 16.0),
              _buildBorderedInputextra_no_seal(
                controller: extraEndSealController,
                hintText: 'Enter Extra End Seal No',
                labelText: 'Extra End \nSeal No',
                performCalculation: true, // Enable calculation for extra end seal number
              ),
              SizedBox(height: 16.0),
              _buildBorderedInputWithLabel(
                controller: extranoofseals,
                hintText: 'Extra No of Seals',
                labelText: 'Extra No \nof Seals',
              ),
              SizedBox(height: 16.0),
              _buildBorderedInputWithLabel(
                controller: otherSealController,
                hintText: 'Add other extra seal by comma(,) seprated',
                labelText: 'Other Extra Seal No',
              ),
              SizedBox(height: 16.0),
              _buildBorderedInputWithLabel(
                controller: gpsSealController,
                hintText: 'Enter GPS Seal No',
                labelText: 'GPS Seal No',
              ),
              SizedBox(height: 16.0),
              _buildBorderedInputWithLabel(
                controller: tarpaulinConditionController,
                hintText: 'Enter Tarpaulin condition',
                labelText: 'Tarpaulin \ncondition',
              ),
              SizedBox(height: 16.0),
              _buildBorderedInputWithLabel(
                controller: senderRemarksController,
                hintText: 'Enter Sender Remarks',
                labelText: 'Sender\nRemarks',
              ),
              SizedBox(height: 16.0),
              if (_user_type == 'S'||_user_type == 'A')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Received By',
                      style: TextStyle(fontSize: 15.0,color: Colors.black),
                    ),
                    buildDropdown(
                      "--- Select Receiver ---",
                      employees,
                      selectedemployee,
                          (value) {
                        setState(() {
                          selectedemployee = value;
                        });
                      },
                    ),
                  ],
                ),
              SizedBox(height: 16.0),
              if (_user_type == 'S'||_user_type == 'A')
                buildFieldWithDatePicker(
                  'Vehicle \nReached Date',
                  Date,
                      (selectedDate) {
                    setState(() {
                      Date = selectedDate;
                    });
                  },
                ),
              SizedBox(height: 16.0),
              if (_user_type == 'S'||_user_type == 'A')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Vehicle\nReached\nTime',style: TextStyle(fontSize: 15),),
                    SizedBox(width: 16.0),
                    buildFieldWithTimePicker(
                      reachedTime,
                          (newTime) {
                        setState(() {
                          reachedTime = newTime;
                        });
                      },
                      context,
                    ),
                  ],
                ),
              SizedBox(height: 16.0),
              if (_user_type == 'S'||_user_type == 'A')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Receiver\nRemarks',
                      style: TextStyle(fontSize: 15.0,color: Colors.black),
                    ),
                    buildDropdown(
                        "Select Remarks",
                        receiverremarks,
                        selectedreceiverRemarks,
                            (value) {
                          setState(() {
                            selectedreceiverRemarks = value;
                          });
                        }),
                  ],
                ),
              SizedBox(height: 16.0),
              Center(
                child: FittedBox(
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.grey.shade300),
                    border: TableBorder.all(color: Colors.grey, width: 1.0),
                    columns: [
                      DataColumn(label: IconCell(this.addRow, isAdd: true, addColor: Colors.green)),
                      DataColumn(label: Text('Rejected seal' , style: TextStyle(fontSize: 16 , color: Colors.red),)),
                      DataColumn(label: Text('New seal' , style: TextStyle(fontSize: 16 , color: Colors.blue),)),
                    ],
                    rows: rows,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _uploading ? null : _pickImagesFromGallery,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text('ADD PHOTOS FROM GALLERY'),
                      Visibility(
                        visible: _uploading,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: SizedBox(
                            width: 20,  // Adjust the size as needed
                            height: 20, // Adjust the size as needed
                            child: CircularProgressIndicator(
                              strokeWidth: 2, // Adjust the thickness as needed
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: uploading ? null : _pickImageFromCamera,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text('ADD PHOTOS USING CAMERA'),
                      Visibility(
                        visible: uploading,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: SizedBox(
                            width: 20,  // Adjust the size as needed
                            height: 20, // Adjust the size as needed
                            child: CircularProgressIndicator(
                              strokeWidth: 2, // Adjust the thickness as needed
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  for (var image in _image)
                    Row(
                      children: [
                        Image.file(
                          image,
                          height: 150.0,
                          width: 150.0,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _image.remove(image);
                              //_updateSubmitButtonState();

                            });
                          },
                          icon: Icon(Icons.delete_forever, color: Colors.red),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 16),
              // Center(
              //   child: Container(
              //     width: double.infinity,
              //     child: ElevatedButton(
              //       onPressed: areRequiredFieldsFilled()
              //           ? () async {
              //         saveData();
              //
              //         String formattedDate = DateFormat('y-M-d').format(Date!);
              //         String formattedTime = reachedTime != null
              //             ? DateFormat('H:m:s').format(DateTime(2023, 1, 1, reachedTime!.hour, reachedTime!.minute, DateTime.now().second))
              //             : '';
              //         var responseMessage = await fetch_add_seal_data(
              //           locationId: getSelectedLocationId(),
              //           materialId: getSelectedMaterialId(),
              //           plantId: getSelectedPlantId(),
              //           reasonId: getSelectedreasonId(),
              //           sealcolorID: getSelectedSealcolorId(),
              //           sealDate: sealDate,
              //           sealTime: sealTime,
              //           date: formattedDate,
              //           times: formattedTime,
              //           received_by: getSelectedreceivedbyId(),
              //           rejSeals: rejectedSeals,
              //           image: _image,
              //         );
              //
              //         // Parse the JSON response
              //         Map<String, dynamic> jsonResponse = json.decode(responseMessage ?? "{}");
              //
              //         // Access the "msg" part of the response
              //         String? message = jsonResponse['msg'];
              //
              //         // Show the response message in AlertDialog
              //         showDialog(
              //           context: context,
              //           builder: (BuildContext context) {
              //             return AlertDialog(
              //               content: Column(
              //                 mainAxisSize: MainAxisSize.min,
              //                 children: [
              //                   Text(message ?? 'Unknown error occurred.'),
              //                   ElevatedButton(
              //                     onPressed: () {
              //                       Navigator.of(context).pop();
              //                     },
              //                     child: Text('OK'),
              //                   ),
              //                 ],
              //               ),
              //             );
              //           },
              //         );
              //
              //
              //         // Simulate a 2-second delay (replace this with your actual logic)
              //         await Future.delayed(Duration(seconds: 2));
              //
              //         // Navigate to the next screen
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(builder: (context) => ViewSeal()),
              //         );
              //       }
              //           : null,
              //       child: Text('Submit'),
              //       style: ElevatedButton.styleFrom(
              //         minimumSize: Size(double.infinity, 50.0), // Increase the height
              //         padding: EdgeInsets.symmetric(vertical: 16.0), // Adjust vertical padding
              //       ),
              //     ),
              //   ),
              // ),
              Center(
                child: _isLoading
                    ? CircularProgressIndicator() // Show circular progress indicator when loading
                    : Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: areRequiredFieldsFilled()
                        ? () async {
                      setState(() {
                        _isLoading = true; // Set loading state to true
                      });

                      saveData();
                      // if (_user_type == 'S')
                      //   String formattedDate = DateFormat('y-M-d').format(Date!);
                      // if (_user_type == 'S')
                      //   String formattedTime = reachedTime != null ? DateFormat('H:m:s').format(DateTime(2023, 1, 1, reachedTime!.hour, reachedTime!.minute, DateTime.now().second)) : '';
                      //
                      // var responseMessage = await fetch_add_seal_data(
                      //   locationId: getSelectedLocationId(),
                      //   materialId: getSelectedMaterialId(),
                      //   plantId: getSelectedPlantId(),
                      //   reasonId: getSelectedreasonId(),
                      //   sealcolorID: getSelectedSealcolorId(),
                      //   sealDate: sealDate,
                      //   sealTime: sealTime,
                      //   date: formattedDate,
                      //   times: formattedTime,
                      //   received_by: getSelectedreceivedbyId(),
                      //   rejSeals: rejectedSeals,
                      //   image: _image,
                      // );

                      // Parse the JSON response

                      String? formattedDate;
                      String? formattedTime;


                      // if (_user_type == 'S' || _user_type == 'A') {
                      //   formattedDate = DateFormat('y-M-d').format(Date!);
                      //   formattedTime = reachedTime != null ? DateFormat('H:m:s').format(DateTime(2023, 1, 1, reachedTime!.hour, reachedTime!.minute, DateTime.now().second)) : '';
                      //
                      //   print(formattedTime);
                      //   print(formattedDate);
                      // }

                      if (_user_type == 'S' || _user_type == 'A') {
                        if (Date != null) {
                          formattedDate = DateFormat('y-M-d').format(Date!);
                        } else {
                          formattedDate = ''; // or provide a default value
                        }

                        if (reachedTime != null) {
                          formattedTime = reachedTime != null ? DateFormat('H:m:s').format(DateTime(2023, 1, 1, reachedTime!.hour, reachedTime!.minute, DateTime.now().second)) : '';
                        } else {
                          formattedTime = ''; // or provide a default value
                        }

                        print(formattedTime);
                        print(formattedDate);
                      }


                      var responseMessage = await fetch_add_seal_data(
                        vesselId:getSelectedVesselId(),
                        locationId: getSelectedLocationId(),
                        materialId: getSelectedMaterialId(),
                        plantId: getSelectedPlantId(),
                        // reasonId: getSelectedreasonId(),

                        reasonId: selectedreceiverRemarks,

                        // reasonId: getSelectedreasonId(),
                        sealcolorID: selectedsealColor,
                        // sealcolorID: getSelectedSealcolorId(),
                        sealDate: sealDate,
                        sealTime: sealTime,
                        date: formattedDate,
                        times: formattedTime,
                        received_by: getSelectedreceivedbyId(),
                        rejSeals: rejectedSeals,
                        image: _image,
                      );

                      Map<String, dynamic> jsonResponse = json.decode(responseMessage ?? "{}");

                      // Access the "msg" part of the response
                      String? message = jsonResponse['msg'];
                      String? status = jsonResponse['status'];

                      setState(() {
                        _isLoading = false; // Set loading state to false
                      });

                      // Show the response message in AlertDialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(message ?? 'Unknown error occurred.'),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    if (status == 'fail') {
                                      // Perform actions to handle failure, if needed
                                    } else {
                                      // Navigate to the next screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ViewSeal()),
                                      );
                                    }
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                        : null,
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.0), // Increase the height
                      padding: EdgeInsets.symmetric(vertical: 16.0), // Adjust vertical padding
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class IconCell extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isAdd;
  final Color addColor;

  IconCell(this.onPressed, {required this.isAdd, required this.addColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isAdd ? addColor : Colors.red, // Set background color based on isAdd
      child: IconButton(
        icon: Icon(isAdd ? Icons.add : Icons.remove),
        color: Colors.white, // Set icon color to white for better visibility
        onPressed: onPressed,
      ),
    );
  }
}