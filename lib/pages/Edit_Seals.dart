import 'dart:convert';
import 'dart:math';
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
import '../models/Seal_Data.dart';
// import 'package:multiple_images_picker/multiple_images_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as Img;

class EditSeals extends StatefulWidget {
  final SealData seal;

  EditSeals({required this.seal});

  @override
  _EditSealsState createState() => _EditSealsState();
}


class _EditSealsState extends State<EditSeals>
{
  bool _uploading = false; // For gallery
  bool uploading =false; //For camera

  List<String> imgUrls = [];

  // List to store selected photos
  List<File> _image = [];

  List<DataRow> rows = [];

  List<TextEditingController> rejectedSeals = [];
  List<TextEditingController> newSeals = [];

  List<bool> rowAdded = []; // Track whether each row is added or not
  List<TableRow> tableRows = [];
  //-------------------------------
  //Controller for saving the details
  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  TextEditingController vehiclenoController = TextEditingController();
  TextEditingController netweightController = TextEditingController();
  TextEditingController startsealController = TextEditingController();
  TextEditingController endsealController = TextEditingController();
  TextEditingController noOfSealsController = TextEditingController();
  TextEditingController firstWeightController = TextEditingController();
  TextEditingController secondWeightController = TextEditingController();
  TextEditingController extraSealController = TextEditingController();
  TextEditingController extraEndSealController = TextEditingController();
  TextEditingController otherSealController = TextEditingController();
  TextEditingController gpsSealController = TextEditingController();
  TextEditingController tarpaulinConditionController = TextEditingController();
  TextEditingController senderRemarksController = TextEditingController();
  TextEditingController sealColorController = TextEditingController();
  TextEditingController ReachedDateController = TextEditingController();
  TextEditingController ReachedTimeController = TextEditingController();
  TextEditingController allowSlipController = TextEditingController();
  TextEditingController extranoofseals = TextEditingController();

  TextEditingController reachedTimeController = TextEditingController();

  TextEditingController rejectedSeal = TextEditingController();
  TextEditingController newSeal = TextEditingController();

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
  List<String> locationIds = [];
  List<String> plantIds = [];
  List<String> sealcolorIds = [];
  List<String> materialIds = [];
  List<String> reasonIds = [];
  List<String> employeeIds = [];
  List<String> vesselIds = [];


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

  String? tarpaulincondition;
  String? vehicleno;
  String? allow_slip_no;
  String? first_weight;
  String? second_weight;
  String? net_weight;
  String? start_seal_no;
  String? end_seal_no;
  String? no_of_seal;

  String? extra_start_seal_no;
  String? extra_end_seal_no;
  String? other_extra_seal;
  String? extra_no_of_seal;

  String? gps_seal_no;
  String? seal_remarks;

  DateTime? seal_unloading_date;
  DateTime? seal_unloading_time;

  String? seal_date;
  String? seal_start_time;

  bool _isSubmitButtonEnabled = true;

  String? sealTransactionId;

  @override
  void dispose()
  {
    extranoofseals.dispose();
    otherSealController.dispose();
    gpsSealController.dispose();
    tarpaulinConditionController.dispose();
    senderRemarksController.dispose();
    vehiclenoController.dispose();
    netweightController.dispose();
    startsealController.dispose();
    endsealController.dispose();
    noOfSealsController.dispose();
    extraSealController.dispose();
    extraEndSealController.dispose();
    super.dispose();
  }

  // void initState() {
  //   super.initState();
  //
  //   sealTransactionId = widget.seal.seal_transaction_id;
  //
  //   fetch_single_seal(sealTransactionId,
  //           (String? location, String? plant, String? material, String? color, String? receiverremarks,List<Map<String, dynamic>> rejectedSealsData) {
  //         setState(() {
  //           print("location:$location");
  //           print("plant:$plant");
  //           print("material:$material");
  //           print("color:$color");
  //           print("receiverremarks:$receiverremarks");
  //           selectedLocation = location;
  //           selectedPlantName = plant;
  //           selectedMaterial = material;
  //           selectedsealColor = color;
  //           selectedreceiverRemarks = receiverremarks;
  //           tarpaulinConditionController.text = tarpaulincondition!;
  //           vehiclenoController.text = vehicleno!;
  //           allowSlipController.text = allow_slip_no!;
  //           firstWeightController.text = first_weight!;
  //           secondWeightController.text = second_weight!;
  //           netweightController.text = net_weight!;
  //           startsealController.text = start_seal_no!;
  //           endsealController.text = end_seal_no!;
  //           noOfSealsController.text = no_of_seal!;
  //           extraSealController.text = extra_start_seal_no!;
  //           extraEndSealController.text = extra_end_seal_no!;
  //           extranoofseals.text = extra_no_of_seal!;
  //           otherSealController.text = other_extra_seal!;
  //           gpsSealController.text = gps_seal_no!;
  //           senderRemarksController.text = seal_remarks!;
  //
  //           // print(ReachedTimeController.text);
  //
  //
  //
  //           List<List<String>> sealNumber = prefillSealsData(rejectedSealsData);
  //
  //           print("Testing:$sealNumber");
  //
  //           List<List<String>> sealPairs = List.generate(sealNumber.first.length, (index) => []);
  //
  //           for (List<String> sealsList in sealNumber) {
  //             for (int i = 0; i < sealsList.length; i++) {
  //               sealPairs[i].add(sealsList[i]);
  //             }
  //           }
  //
  //           print("SealPairs: $sealPairs");
  //
  //
  //           if (sealPairs.isNotEmpty) {
  //             for (List<String> sealsLists in sealPairs) {
  //
  //               String rejectedSealData = sealsLists[0];
  //               String newSealData = sealsLists[1];
  //
  //
  //
  //               // Call the addRow function and pass the prefill data for rejected and new seals
  //               addRow(prefillRejectedSeal: rejectedSealData, prefillNewSeal: newSealData);
  //             }
  //
  //           }
  //
  //
  //
  //
  //
  //         });
  //       });
  //
  //   _getUserDetails();
  //   fetchdropdownData();
  //   // addRow();
  // }

  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {

    await fetchdropdownData();
    sealTransactionId = widget.seal.seal_transaction_id;

    fetch_single_seal(sealTransactionId, (String? location, String? plant, String? material, String? color, String? receiverremarks, List<Map<String, dynamic>> rejectedSealsData) {
      setState(() {
        // print("location:$location");
        // print("plant:$plant");
        // print("material:$material");
        print("color:$color");
        // print("receiverremarks:$receiverremarks");
        selectedLocation = location;
        selectedPlantName = plant;
        selectedMaterial = material;
        selectedsealColor = color;
        selectedreceiverRemarks = receiverremarks;
        tarpaulinConditionController.text = tarpaulincondition!;
        vehiclenoController.text = vehicleno!;
        allowSlipController.text = allow_slip_no!;
        firstWeightController.text = first_weight!;
        secondWeightController.text = second_weight!;
        netweightController.text = net_weight!;
        startsealController.text = start_seal_no!;
        endsealController.text = end_seal_no!;
        noOfSealsController.text = no_of_seal!;
        extraSealController.text = extra_start_seal_no!;
        extraEndSealController.text = extra_end_seal_no!;
        extranoofseals.text = extra_no_of_seal!;
        otherSealController.text = other_extra_seal!;
        gpsSealController.text = gps_seal_no!;
        senderRemarksController.text = seal_remarks!;

        // print(ReachedTimeController.text);



        List<List<String>> sealNumber = prefillSealsData(rejectedSealsData);

        // print("Testing:$sealNumber");

        List<List<String>> sealPairs = List.generate(sealNumber.first.length, (index) => []);

        for (List<String> sealsList in sealNumber) {
          for (int i = 0; i < sealsList.length; i++) {
            sealPairs[i].add(sealsList[i]);
          }
        }

        // print("SealPairs: $sealPairs");


        if (sealPairs.isNotEmpty) {
          for (List<String> sealsLists in sealPairs) {

            String rejectedSealData = sealsLists[0];
            String newSealData = sealsLists[1];



            // Call the addRow function and pass the prefill data for rejected and new seals
            addRow(prefillRejectedSeal: rejectedSealData, prefillNewSeal: newSealData);
          }

        }
      });
    });
    _getUserDetails();

  }

  void displaySealDetails(BuildContext context, String location, String plant, String material, String color, String rejectedSealRemarks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seal Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Location: $location'),
              Text('Plant: $plant'),
              Text('Material: $material'),
              Text('Color: $color'),
              Text('Rejected Seal Remarks: $rejectedSealRemarks'),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to check if all required fields are filled
  bool areRequiredFieldsFilled() {


    return vehiclenoController.text.isNotEmpty &&
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
        selectedPlantName != "--- Select Plant ---";

  }


  void _updateSubmitButtonState() {
    setState(() {
      _isSubmitButtonEnabled =areRequiredFieldsFilled();

      // _isSubmitButtonEnabled = (_image.isNotEmpty || imgUrls.isNotEmpty) && areRequiredFieldsFilled();
    });
  }

  // void _updateSubmitButtonState() {
  //   setState(() {
  //     _isSubmitButtonEnabled = areRequiredFieldsFilled() && _image.isNotEmpty;
  //   });
  // }

  List<List<String>> prefillSealsData(List<Map<String, dynamic>> rejectedSealsData) {
    List<String> rejectedSealNumbers = [];
    List<String> newSealNumbers = [];

    if (rejectedSealsData.isNotEmpty) {
      for (int i = 0; i < rejectedSealsData.length; i++) {
        var rejectedSealNumbersList = rejectedSealsData[i]['rejected_seal_no'].split(',');
        var newSealNumbersList = rejectedSealsData[i]['new_seal_no'].split(',');

        // Append the lists obtained from the data to the respective lists
        rejectedSealNumbers.addAll(rejectedSealNumbersList);
        newSealNumbers.addAll(newSealNumbersList);
      }
    }

    // Return the lists
    return [rejectedSealNumbers, newSealNumbers];
  }

  void addRow({String? prefillRejectedSeal, String? prefillNewSeal}) {
    setState(() {
      UniqueKey rowKey = UniqueKey(); // Generate a unique key for each row

      // Create controllers for each text field
      TextEditingController rejectedSealController = TextEditingController(text: prefillRejectedSeal);
      TextEditingController newSealController = TextEditingController(text: prefillNewSeal);

      rows.add(DataRow(
        key: rowKey, // Set the unique key for the row
        cells: [
          DataCell(IconCell(() => deleteRow(rowKey), isAdd: false, addColor: Colors.green)),
          DataCell(
            TextFormField(
              controller: rejectedSealController,
              decoration: InputDecoration(hintText: 'Enter rejected seal'),
            ),
          ),
          DataCell(
            TextFormField(
              controller: newSealController,
              decoration: InputDecoration(hintText: 'Enter new seal'),
            ),
          ),
        ],
      ));

      // Save the controllers to access the data later
      rejectedSeals.add(rejectedSealController);
      newSeals.add(newSealController);

      rowAdded.add(true); // Mark the row as added
    });
  }

  void deleteRow(Key key) {
    setState(() {
      int index = rows.indexWhere((row) => row.key == key); // Find the index of the row with the given key
      if (index != -1) {
        // Remove the controllers from the lists
        rejectedSeals.removeAt(index);
        newSeals.removeAt(index);

        // Remove the row at the found index
        rows.removeAt(index);

        // Remove the corresponding boolean from the rowAdded list
        rowAdded.removeAt(index);
      }
    });
  }

  void saveData() {
    // Check if the length of 'rows', 'rejectedSeals', and 'newSeals' is consistent
    if (rows.length == rejectedSeals.length && rows.length == newSeals.length) {
      for (int i = 0; i < rows.length; i++) {
        String rejected = rejectedSeals[i].text;
        String newSeal = newSeals[i].text;

        if (rejected.isNotEmpty && newSeal.isNotEmpty) {
          print('Saved Data Row $i: Rejected Seal: $rejected, New Seal: $newSeal');
        } else {
          print('Please enter both Rejected Seal and New Seal in Row $i before saving.');
        }
      }
    } else {
      print('Error: Length of lists is inconsistent.');
      // Handle the error appropriately
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
      _uuid= prefs.getString('uuid')??'';

    });

    if (kDebugMode) {
      //print("is logged in$_isloggedin");
    }
    if (_isloggedin == false) {
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }


  // Fetch single seal data from the API
  Future<void> fetch_single_seal(
      String? sealTransactionId,
      Function(String?, String?, String?, String?, String?,List<Map<String, dynamic>> rejectedSeals) callback) async {
    try {
      await _getUserDetails();
      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/fetch_single_seal'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          // 'uuid': "bd0029d5175022be",
          'user_id': _username,
          'password': _password,
          'id': sealTransactionId,
        },
      );

      if (response.statusCode == 200)
      {

        final data = json.decode(response.body);

        print(data);

        // Accessing location_id, plant_id, and material_id
        String locationId = data['seal_data']['location_id'] ?? '';

        // print("fetch location:$locationId");
        String plantId = data['seal_data']['plant_id'] ?? '';
        // print("fetch plant:$plantId");

        String materialId = data['seal_data']['material_id'] ?? '';
        // String sealcolor = data['seal_data']['seal_color'];
        String sealcolor = data['seal_data']['seal_color'] ?? '';
        if (sealcolor == null || sealcolor.isEmpty) {
          sealcolor = '---Select Seal Color---';
        }

        print("fetch color:$sealcolor");
        String receiverremarkID = data['seal_data']['receiver_remarks']??'';
        if (receiverremarkID == null || receiverremarkID.isEmpty) {
          receiverremarkID = 'Select Remarks';
        }
        String vesselID = data['seal_data']['vessel_id'] ?? '';
        print("DJ:$vesselID");

        if (vesselID == null || vesselID.isEmpty) {
          selectedVessel= '---Select Vessel---';
        }else{
          fetchVesselNames(data, locationId,vesselID);
          dropdownData(locationId,vesselID);
        }
        tarpaulincondition = data['seal_data']['tarpaulin_condition']??'';
        vehicleno = data['seal_data']['vehicle_no']??'';
        allow_slip_no = data['seal_data']['allow_slip_no']??'';
        first_weight = data['seal_data']['first_weight']??'';
        second_weight = data['seal_data']['second_weight']??'';
        net_weight = data['seal_data']['net_weight']??'';
        start_seal_no = data['seal_data']['start_seal_no']??'';
        end_seal_no = data['seal_data']['end_seal_no']??'';
        no_of_seal = data['seal_data']['no_of_seal']??'';
        extra_start_seal_no = data['seal_data']['extra_start_seal_no']??'';
        extra_end_seal_no = data['seal_data']['extra_end_seal_no']??'';
        extra_no_of_seal = data['seal_data']['extra_no_of_seal']??'';
        other_extra_seal = data['seal_data']['other_extra_seal']??'';
        gps_seal_no = data['seal_data']['gps_seal_no']??'';
        seal_remarks = data['seal_data']['seal_remarks']??'';
        seal_date = data['seal_data']['seal_date']??'';
        seal_start_time = data['seal_data']['seal_start_time']??'';

        // print(seal_date);
        // print(seal_start_time);
//------------------------------------------------------------------------------------------------
        // Default to today's date if 'seal_unloading_date' is not provided

        DateTime? sealUnloadingDate;
        String? formattedDate;

        if (data['seal_data'] != null &&
            data['seal_data']['seal_unloading_date'] != null &&
            data['seal_data']['seal_unloading_date'] != '') {
          seal_unloading_date = DateTime.parse(data['seal_data']['seal_unloading_date']);
          formattedDate = seal_unloading_date != null
              ? DateFormat('yyyy-MM-dd').format(seal_unloading_date!)
              : '';
        }
//------------------------------------------------------------------------------------------------

        DateTime? sealUnloadingTime;
        String? formattedTime;

        if (data['seal_data'] != null &&
            data['seal_data']['seal_unloading_time'] != null &&
            data['seal_data']['seal_unloading_time'] != '') {
          seal_unloading_time = DateTime.parse(data['seal_data']['seal_unloading_time']).toLocal();
          formattedTime = seal_unloading_time != null
              ? DateFormat('HH:mm:ss').format(seal_unloading_time!)
              : '';
        }
        // else {
        //   seal_unloading_time = DateTime.now();
        // }


//------------------------------------------------------------------------------------------------
//
//         // Extracting rejected seals
        List<Map<String, dynamic>> rejectedSeals = []; // Change to dynamic
        if (data.containsKey('rejected_seal')) {
          rejectedSeals = (data['rejected_seal'] as List<dynamic>).map((item) {
            // Cast each item to Map<String, dynamic>
            return {
              'rejected_seal_no': item['rejected_seal_no'],
              'new_seal_no': item['new_seal_no'],
            };
          }).toList();
          print('Rejected Seals: $rejectedSeals');

        }

        // Set the selectedLocation, selectedPlantName, and selectedMaterial using the callback function
        callback(
          getLocationNameById(locationId, locationIds, locations),
          getPlantNameById(plantId, plantIds, plants),
          getMaterialNameById(materialId, materialIds, materials),
          // getcolorNameById(sealcolorID, sealcolorIds, sealcolor),
          sealcolor,
          receiverremarkID,
          // getreceiverremaksNameById(receiverremarkID, reasonIds, receiverremarks),
          rejectedSeals,
        );

        List<Map<String, dynamic>> picsList =
        List<Map<String, dynamic>>.from(data['pics']);
        imgUrls = picsList.map((pic) => pic['img'].toString()).toList();

      }

    } catch (e) {
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: Text('Error'),
      //       content: Text('An error occurred: $e'),
      //       actions: <Widget>[
      //         ElevatedButton(
      //           child: Text('OK'),
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //         ),
      //       ],
      //     );
      //   },
      // );
    }
  }

  fetchVesselNames(Map<String, dynamic> data, String selectedLocationId, String vesselID) {

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
        List<String> vesselIDs = vessels.map((vessel) => vessel["vessel_id"].toString()).toList();

        // Clear vessel list and add default value
        vessel.clear();
        vessel.add('---Select Vessel---');
        vesselIds.add('0');

        // Add vessel names and IDs to the list
        vessel.addAll(vesselNames);
        vesselIds.addAll(vesselIDs);

        print(vessel);
        print(vesselIds);


        // Find the index of the selected vesselID
        int selectedIndex = vesselIDs.indexOf(vesselID)+1;

        // Prefill vessel name if vesselID is provided and found in the data
        if(selectedIndex != -1) {
          print(selectedIndex);
          setState(() {
            selectedVessel = vesselNames.isNotEmpty ? vessel[selectedIndex] : null;
          });
        } else {
          // Randomly select a vessel if vesselID is not provided or not found
          int randomIndex = Random().nextInt(vesselNames.length);
          setState(() {
            selectedVessel = vesselNames.isNotEmpty ? vessel[randomIndex] : null;
          });
        }

        print(vesselIds);
        print(vessel);

      } else {
        print('No vessel data found for the specified location');
      }
    } else {
      print('No vessel data found in the response');
    }
  }

  fetchVesselName(Map<String, dynamic> data,String selectedLocationId) {

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

  Future<String> delete_seal_images(
      String removedImageData,
      {String? sealTransactionId}
      ) async {
    try {
      await _getUserDetails();
      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/delete_seal_images'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          // 'uuid': "bd0029d5175022be",

          'user_id': _username,
          'password': _password,
          'seal_transaction_id': sealTransactionId ?? '',
          'image_data': removedImageData,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

        // Assuming 'msg' contains the API response message
        return data['msg'] ?? 'Unknown response';
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (error) {
      print("Error during fetch_single_seal: $error");
      return 'Error: $error';
    }
  }


  Future<void> fetch_add_seal_data({
    String? sealTransactionId,
    String? locationId,
    String? materialId,
    String? plantId,
    String? reasonId,
    String? sealDate,
    String? sealTime,
    String? times,
    String? date,
    String? sealcolorID,
    String? receive_by,
    List<File>? image,
    List<TextEditingController>? rejSeals,
    String? vesselId,
  }) async {
    // print('Number of images inside add_edit_gps_data: ${image?.length}');
    // print('Number of images inside add_edit_gps_data: ${imgUrls?.length}');
    print("String? sealTransactionId: $sealTransactionId");
    print("String? locationId: $vesselId");
    print("String? materialId: $materialId");
    print("String? plantId: $plantId");
    print("String? reasonId: $reasonId");
    print("String? sealDate: $sealDate");
    print("String? sealTime: $sealTime");
    print("String? times: $times");
    print("String? date: $date");
    print("String? sealcolorID: $sealcolorID");
    print("String? receive_by: $receive_by");
    try {
      // Prepare your request parameters here

      var request = http.MultipartRequest('POST', Uri.parse('$API_URL/Mobile_flutter_api/add_edit_seal_data_test'));


      // Add text fields
      request.fields['seal_transaction_id'] = sealTransactionId!;
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
      if (receive_by != null) {
        request.fields['receiver_admin_id'] = receive_by;
      }
      request.fields['start_seal_no'] = startsealController.text ?? '';
      request.fields['end_seal_no'] = endsealController.text ?? '';
      request.fields['no_of_seal'] =  noOfSealsController.text ?? '';
      request.fields['gps_seal_no'] = gpsSealController.text ?? '';
      request.fields['extra_start_seal_no'] = extraSealController.text??'';
      request.fields['extra_end_seal_no'] = extraEndSealController.text ?? '';
      request.fields['extra_no_of_seal'] = extranoofseals.text ?? '';
      request.fields['other_extra_seal'] = otherSealController.text ?? '';
      // request.fields['seal_color'] = sealcolorID ?? '';
      // request.fields['seal_color'] = selectedsealColor ?? '';

      request.fields['rejected[rejected_seal_no]'] = rejectedSeals.map((controller) => controller.text).toList().join(',');
      request.fields['rejected[new_seal_no]'] = newSeals.map((controller) => controller.text).toList().join(',');

      // 'rejected_seal_no': rejectedSeals.map((controller) => controller.text).toList().join(','),
      // 'new_seal_no':newSeals.map((controller) => controller.text).toList().join(','),

      // request.fields['seal_unloading_time'] = times ?? '';
      // request.fields['seal_unloading_date'] = date?? '';

      // request.fields['receiver_remarks'] = reasonId ?? '';

      request.fields['vessel_id'] = vesselId ?? '';

      if (selectedsealColor == null || selectedsealColor == '---Select Seal Color---') {
        request.fields['seal_color'] = '';

        // reasonId = '';
      } else {
        request.fields['seal_color'] = selectedsealColor ?? '';
      }


      if (selectedreceiverRemarks == null || selectedreceiverRemarks == 'Select Remarks') {
        request.fields['receiver_remarks'] = '';

        // reasonId = '';
      } else {
        request.fields['receiver_remarks'] = reasonId ?? '';
      }

      if (date != null) {
        print("12231:$date");
        request.fields['seal_unloading_date'] = date;
      }
      if (times != null) {
        print("4235:$times");
        request.fields['seal_unloading_time'] = times;
      }


      // Add image file
      if (image != null) {
        for (var image in image) {
          print("sachin:$image");

          request.files.add(await http.MultipartFile.fromPath('pics[]', image.path));
        }
      }

      var response = await request.send();

      if (response.statusCode == 200) {

      } else {
        // Error submitting GPS data
        print('Error submitting seal data. Status code: ${response.statusCode}');
      }
    }
    catch (e) {
      // Exception during API call
      print('Exception during API call: $e');
    }
  }

  //Fetching API for Dropdown
  dropdownData(String locationId, String vesselID) async {
    print("location:$locationId");
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

          // Update vessel data based on selected location
          fetchVesselNames(data, locationId,vesselID);




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
            fetchVesselName(data, selectedLocationId);
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
    locationIds.add("");

    for (var locationData in locationDataList) {
      String locationName = locationData["location_name"].toString();
      String locationId = locationData["location_id"].toString();

      locations.add(locationName);
      locationIds.add(locationId);
    }
    print("location Name:$locations");
    print("location IDS:$locationIds");
  }


  void updatereasonData(List<dynamic> reasonDataList) {
    receiverremarks.clear();
    reasonIds.clear();
    receiverremarks.add("Select Remarks");
    reasonIds.add("0");
    for (var reasonData in reasonDataList) {
      String reasonName = reasonData["reason"].toString();
      String reasonId = reasonData["id"].toString();

      receiverremarks.add(reasonName);
      reasonIds.add(reasonId);
      print("###############");
      print(receiverremarks);
      print(reasonIds);
    }
  }

  void updatecolorData(List<dynamic> colorDataList) {
    sealcolor.clear();
    sealcolorIds.clear();
    sealcolor.add("---Select Seal Color---");
    sealcolorIds.add("0");

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
    //plantIds.add("");

    for (var plantData in plantDataList) {
      String plantName = plantData["plant_name"].toString();
      String plantId = plantData["plant_id"].toString();

      plants.add(plantName);
      plantIds.add(plantId);


    }
    // print("Plant Name:$plants");
    // print("Plant IDS:$plantIds");
  }

  void updatematerialData(List<dynamic> materialDataList) {
    materials.clear();
    materialIds.clear();
    materials.add("--- Select Material ---");
    // materialIds.add("");


    for (var materialData in materialDataList) {
      String materialName = materialData["material_name"].toString();
      String materialId = materialData["material_id"].toString();

      materials.add(materialName);
      materialIds.add(materialId);
    }
    print("Material Name:$materials");
    print("Material IDS:$materialIds");
  }

  // Define a function to get the user_id for the selected user name
  String? getSelectedreceivebyId() {
    if (selectedemployee != null && selectedemployee != "--- Select Receiver ---") {
      int selectedIndex = employees.sublist(employees.indexOf("--- Select Receiver ---") + 1).indexOf(selectedemployee!);
      if (selectedIndex != -1 && selectedIndex < employeeIds.length) {
        return employeeIds[selectedIndex];
      }
    }
    return null;
  }


  String? getSelectedVesselId() {
    if (selectedVessel != null && selectedVessel != "---Select Vessel---") {
      int selectedIndex = vessel.sublist(vessel.indexOf("---Select Vessel---")).indexOf(selectedVessel!);
      if (selectedIndex != -1 && selectedIndex < vesselIds.length) {
        return vesselIds[selectedIndex];
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

  // Define a function to get the plant_id for the selected plant name
  String? getSelectedreasonId() {
    if (selectedreceiverRemarks != null && selectedreceiverRemarks != "Select Remarks") {
      int selectedIndex = receiverremarks.indexOf(selectedreceiverRemarks!);
      if (selectedIndex != -1 && selectedIndex < reasonIds.length) {
        return reasonIds[selectedIndex];
      }
    }
    return null;
  }


  // Define a function to get the location_id for the selected location name
  String? getSelectedLocationId() {
    if (selectedLocation != null && selectedLocation != "--- All Location ---") {
      int selectedIndex = locations.sublist(locations.indexOf("--- All Location ---")).indexOf(selectedLocation!);
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

  String? getreceiverremaksNameById(String? receiverremarkID, List<String> reasonIds, List<String> receiverremarks) {
    if (receiverremarkID == null || receiverremarkID.isEmpty) {
      return !receiverremarks.isEmpty ? receiverremarks[0] : null;
    } else {
      int index = reasonIds.indexOf(receiverremarkID);
      if (index != -1 && index < receiverremarks.length) {
        if (receiverremarks[index] != "Select Remarks") {
          return receiverremarks[index];
        }
      }
    }
    return null;
  }

  String? getcolorNameById(String? sealcolorID, List<String> sealcolorIds, List<String> receiverremarks) {
    print("Nimbu:$sealcolorID");
    if (sealcolorID == null || sealcolorID.isEmpty) {
      return !sealcolor.isEmpty ? sealcolor[0] : null;
    } else {
      int index = sealcolorIds.indexOf(sealcolorID);
      if (index != -1 && index < sealcolor.length) {
        if (sealcolor[index] != "--- Select Seal Color ---") {
          return sealcolor[index];
        }
      }
    }
    return null;
  }


  String? getLocationNameById(String? locationId, List<String> locationIds, List<String> locations) {
    if (locationId != null) {
      int index = locationIds.indexOf(locationId);
      if (index != -1 && index < locations.length) {
        if (locations[index] != "--- All Location ---") {
          return locations[index];
        }
      }
    }
    return null;
  }

  String? getPlantNameById(String? plantId, List<String> plantIds, List<String> plants) {
    if (plantId != null) {
      int index = plantIds.indexOf(plantId)+1;
      if (index != -1 && index < plants.length) {
        if (plants[index] != "--- Select Plant ---") {
          return plants[index];
        }
      }
    }
    return null;
  }

  String? getMaterialNameById(String? materialId, List<String> materialIds, List<String> materials) {
    if (materialId != null) {
      int index = materialIds.indexOf(materialId)+1;
      if (index != -1 && index < materials.length) {
        if (materials[index] != "--- Select Material ---") {
          return materials[index];
          print(materials[index]);
          print("vrindavan");
        }
      }
    }
    return null;
  }



  String? getSelectedSealcolorId() {
    if (selectedsealColor != null && selectedsealColor != "--- Select Seal Color ---") {
      int selectedIndex = sealcolor.indexOf(selectedsealColor!);
      if (selectedIndex != -1 && selectedIndex < sealcolorIds.length) {
        return sealcolorIds[selectedIndex];
      }
    }
    return null;
  }


  //Function for Date
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
                          fontSize: 14,
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



  String getImageData(String imageUrl) {
    return imageUrl;
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
      drawer: MyDrawer(_full_name, _email, _isloggedin, userImageUrl, _id, _user_type,_password,_uuid),
      appBar: MyApplicationBar(title: const Text('SEAL MANAGEMENT')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5.0),
              Card(
                elevation: 12,
                margin:EdgeInsets.all(16),
                child: Container(
                  height: 50,
                  margin:EdgeInsets.only(left: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit,
                        color: Colors.blue.shade900,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Edit Seal',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  createRichText('Location'),
                  // SizedBox(width: 19,),
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
                  // SizedBox(width: 16,),
                  buildDropdown(
                    "--- Select Plant Name ---",
                    plants,
                    selectedPlantName,
                        (value) {
                      setState(() {
                        selectedPlantName = value;
                        // _updateSubmitButtonState();

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
                  // SizedBox(width: 19,),
                  buildDropdown(
                      "--- Select Material Name ---",
                      materials,
                      selectedMaterial,
                          (value) {
                        setState(() {
                          selectedMaterial = value;
                          // _updateSubmitButtonState();

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
                    seal_date ?? 'Select Date', // Use null-aware operator (??) to handle null values
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
                    seal_start_time ?? 'Select Time',
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
              buildFieldWithDatePicker(
                'Vehicle \nReached Date',
                seal_unloading_date,
                    (selectedDate) {
                  setState(() {
                    seal_unloading_date = selectedDate;
                  });
                },
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Vehicle\nReached\nTime',style: TextStyle(fontSize: 15),),
                  SizedBox(width: 16.0),
                  buildFieldWithTimePicker(
                    seal_unloading_time,  // First argument: selectedTime
                        (newTime) {
                      setState(() {
                        seal_unloading_time = newTime;
                      });
                    },  // Second argument: onTimeChanged callback
                    context,  // Third argument: context
                  ),
                ],
              ),
              SizedBox(height: 16.0),
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
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: FittedBox(
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade300),
                      border: TableBorder.all(color: Colors.grey, width: 1.0),
                      columns: [
                        DataColumn(label: IconCell(this.addRow, isAdd: true, addColor: Colors.green)),
                        DataColumn(label: Text('Rejected seal' , style: TextStyle(fontSize: 16 , color: Colors.blue),)),
                        DataColumn(label: Text('New seal' , style: TextStyle(fontSize: 16 , color: Colors.red),)),
                      ],
                      rows: rows,
                    ),
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
                              strokeWidth: 2,
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
              Column(
                children: [
                  for (var image in imgUrls)
                    Row(
                      children: [
                        Image.network(
                          image,
                          height: 150.0,
                          width: 150.0,
                        ),
                        IconButton(
                          onPressed: () async {
                            bool deleteConfirmed = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirmation"),
                                  content: Text("Are you sure you want to delete this image?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false); // No
                                      },
                                      child: Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true); // Yes
                                      },
                                      child: Text("Yes"),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (deleteConfirmed == true) {
                              var removedImageData = getImageData(image);

                              setState(() {
                                imgUrls.remove(image);
                                //_updateSubmitButtonState();

                              });

                              String apiResponse = await delete_seal_images(
                                removedImageData,
                                sealTransactionId: sealTransactionId,
                              );

                              if (apiResponse != null) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("API Response"),
                                      content: Text(apiResponse),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close the alert
                                          },
                                          child: Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                // Handle the case where the API response is null
                                print('API response is null');
                              }
                            }
                          },
                          icon: Icon(Icons.delete_forever, color: Colors.red),
                        ),


                      ],
                    ),
                ],
              ),

              SizedBox(height: 16),
              Center(
                child: Container(
                  width: double.infinity,
                  child:ElevatedButton(
                    // Assuming this is your onPressed function
                    onPressed: _isSubmitButtonEnabled ? () {
                      // Null check before accessing variables
                      //  if (seal_unloading_date != null && seal_unloading_time != null) {
                      saveData();

                      // String formattedDate = DateFormat('y-M-d').format(seal_unloading_date!);
                      // String formattedTime = seal_unloading_time != null ? DateFormat('H:m:s').format(DateTime(2023, 1, 1, seal_unloading_time!.hour, seal_unloading_time!.minute, DateTime.now().second)) : '';

                      // String formattedDate = seal_unloading_date != null ? DateFormat('y-M-d').format(seal_unloading_date!) : '';
                      // String formattedTime = seal_unloading_time != null ? DateFormat('H:m:s').format(DateTime(2023, 1, 1, seal_unloading_time!.hour, seal_unloading_time!.minute, DateTime.now().second)) : '';

                      String? formattedDate;
                      String? formattedTime;

                      if (seal_unloading_date != null) {
                        formattedDate = DateFormat('y-M-d').format(seal_unloading_date!);
                      } else {
                        formattedDate = ''; // or provide a default value
                      }

                      if (seal_unloading_time != null) {

                        formattedTime = seal_unloading_time != null ? DateFormat('H:m:s').format(DateTime(2023, 1, 1, seal_unloading_time!.hour, seal_unloading_time!.minute, DateTime.now().second)) : '';

                      } else {
                        formattedTime = ''; // or provide a default value
                      }

                      print("1:$formattedDate");
                      print("2:$formattedTime");

                      fetch_add_seal_data(
                        sealTransactionId: sealTransactionId,
                        vesselId:getSelectedVesselId(),
                        locationId: getSelectedLocationId(),
                        materialId: getSelectedMaterialId(),
                        plantId: getSelectedPlantId(),
                        // reasonId: getSelectedreasonId(),
                        sealcolorID: selectedsealColor,
                        reasonId: selectedreceiverRemarks,

                        // sealcolorID: getSelectedSealcolorId(),

                        sealDate: seal_date,
                        sealTime: seal_start_time,
                        date: formattedDate,
                        times: formattedTime,
                        receive_by: getSelectedreceivebyId(),
                        image: _image,
                        rejSeals: rejectedSeals,

                      );

                      // Show the loading indicator immediately
                      showDialog(
                        context: context,
                        barrierDismissible: false, // Prevent user from dismissing the dialog
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16.0),
                                Text("Submitting..."),
                              ],
                            ),
                          );
                        },
                      );

                      // Simulate a 2-second delay (replace this with your actual logic)
                      Future.delayed(Duration(seconds: 2), () async {
                        // Remove the loading indicator
                        Navigator.pop(context);

                        // Navigate to the next screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewSeal()),
                        );
                      });
                      // }
                    } : null,

                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.0), // Increase the height
                      padding: EdgeInsets.symmetric(vertical: 16.0), // Adjust vertical padding
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildDropdowns(
    String hint,
    List<String> items,
    String? selectedItem,
    void Function(String?) onChanged,
    ) {
  return Container(
    width: 150,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(0),
      border: Border.all(
        color: Colors.grey.shade300,
        width: 2.0,
      ),
    ),
    child: PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return items.map((String item) {
          return PopupMenuItem<String>(
            value: item,
            child: ListTile(
              title: Text(item),
            ),
          );
        }).toList();
      },
      onSelected: onChanged,
      child: ListTile(
        title: Text(selectedItem ?? hint),
        trailing: Icon(Icons.arrow_drop_down),
      ),
    ),
  );
}

//Function for buildropdown
Widget buildDropdown(
    String hint,
    List<String> items,
    String? selectedItem,
    void Function(String?) onChanged,
    ) {
  return Container(
    width: 150,// Set your desired fixed width here,
    child: Container(
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(
          color: Colors.grey.shade600,
          width: 1.0,
        ),
      ),
      child: Center(
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
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration.collapsed(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.black),
          ),
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((String item) {
              return Center(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList();
          },
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.black),
        ),
      ),
    ),
  );
}
// Function to create a bordered input field
Widget _buildBorderedInput({required TextEditingController controller, required String hintText,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.grey, // Border color
        width: 1.0,         // Border width
      ),
      borderRadius: BorderRadius.circular(0.0), // Border radius
    ),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
        hintText: hintText,
        border: InputBorder.none, // Remove the default border
      ),
    ),
  );
}

// Function for Richtext
Widget createRichText(String labelText) {
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: labelText,
          style: TextStyle(fontSize: 18.0,color: Colors.black),
        ),
        TextSpan(
          text: '*',
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.red,
          ),
        ),
      ],
    ),
  );
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