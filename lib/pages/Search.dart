import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:SealApp/constants.dart';
import '../app_classes/Image_Viewer.dart';
import '../app_classes/My_Application_Bar.dart';
import '../app_classes/My_Drawer.dart';
import 'Login_Page.dart';
import 'package:http/http.dart' as http;
import 'package:SealApp/models/Seal_Data.dart';
import 'package:flutter/services.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

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


  final _vehicleNoFocusNode = FocusNode();

  //Variables for user selected values
  String? selectedLocation;
  String? selectedPlantName;
  String? selectedMaterial;
  String? selectedName;
  String? vehicleNumber;
  DateTime? fromDate;
  DateTime? toDate;

  // List to store location names,plant names & material name
  List<String> locations = [];
  List<String> plants = [];
  List<String> materials = [];

  // List to store plant_id,location_id & material_id
  List<String> locationIds = [];
  List<String> plantIds = [];
  List<String> materialIds = [];
  List<SealData> sealsData = [];

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    fetchdropdownData();
  }


  @override
  void dispose() {
    super.dispose();
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
      _password = prefs.getString('password') ?? '';
      _uuid = prefs.getString('uuid') ?? '';
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

  fetchdropdownData() async {
    await _getUserDetails();
    try {
      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/get_dropdown_data'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "1") {
          updateData(data, "location", locations, locationIds);
          updateData(data, "plant", plants, plantIds);
          updateData(data, "material", materials, materialIds);

          setState(() {
            selectedLocation;
            selectedPlantName;
            selectedMaterial;
          });
        }
        else {
          print('Status is not 1 in the response');
        }
      } else {
        print('Failed to fetch Dropdown API. Status code: ${response
            .statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updateData(Map<String, dynamic> data, String key, List<String> itemList,
      List<String> itemIdList) {
    itemList.clear();
    itemIdList.clear();

    if (data.containsKey(key)) {
      for (var itemData in data[key]) {
        String itemName = itemData["${key}_name"].toString();
        String itemId = itemData["${key}_id"].toString();

        itemList.add(itemName);
        itemIdList.add(itemId);
      }
    } else {
      print('No "$key" data found in the response');
    }
  }

  String? getSelectedId(String? selectedItem, List<String> itemList,
      List<String> itemIdList) {
    if (selectedItem != null) {
      int selectedIndex = itemList.indexOf(selectedItem);
      return (selectedIndex != -1 && selectedIndex < itemIdList.length)
          ? itemIdList[selectedIndex]
          : null;
    }
    return null;
  }

  // Define functions to get the plant_id, location_id, and material_id for the selected names
  String? getSelectedPlantId() =>
      getSelectedId(selectedPlantName, plants, plantIds);

  String? getSelectedLocationId() =>
      getSelectedId(selectedLocation, locations, locationIds);

  String? getSelectedMaterialId() =>
      getSelectedId(selectedMaterial, materials, materialIds);


  //Fetching API for Search Seal Data
  Future<void> fetch_search_seal_data(
      {String? plantId, String? locationId, String? materialId, String? vehicleNumber }) async {
    try {
      await _getUserDetails();
      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/search_seal_data'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
          'plant_id': plantId,
          'from_date': fromDate != null ? fromDate?.toLocal().toString() : '',
          // '2019-08-18',
          'material_id': materialId,
          'location_id': locationId,
          'vehicle_no': vehicleNumber,
          // 'RJ27GD5098',
          'to_date': toDate != null ? toDate?.toLocal().toString() : '',
          // '2019-08-18',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "1" && data["seal_data"] != null) {
          List<SealData> fetchedUsersData = [];

          for (var seal in data["seal_data"]) {
            SealData sealData = SealData(
              sr_no: seal["sr_no"].toString(),
              location_name: seal["location_name"],
              seal_transaction_id: seal["seal_transaction_id"],
              seal_date: seal["seal_date"],
              seal_unloading_date: seal["seal_unloading_date"],
              seal_unloading_time: seal["seal_unloading_time"],
              vehicle_no: seal["vehicle_no"],
              allow_slip_no: seal["allow_slip_no"],
              plant_name: seal["plant_name"],
              material_name: seal["material_name"],
              vessel_name: seal["vessel_name"],
              net_weight: seal["net_weight"],
              start_seal_no: seal["start_seal_no"],
              end_seal_no: seal["end_seal_no"],
              seal_color: seal["seal_color"],
              no_of_seal: seal["no_of_seal"],
              gps_seal_no: seal["gps_seal_no"],
              extra_start_seal_no: seal["extra_start_seal_no"],
              extra_no_of_seal: seal["extra_no_of_seal"],
              rejected_seal_no: seal["rejected_seal_no"],
              new_seal_no: seal["new_seal_no"],
              remarks: seal["remarks"],
              rev_remarks: seal["rev_remarks"],
              img_cnt: seal["img_cnt"],
              extra_end_seal_no: seal["extra_end_seal_no"],
              first_weight: seal["first_weight"],
              second_weight: seal["second_weight"],
              tarpaulin_condition: seal["tarpaulin_condition"],
              sender_remarks: seal["sender_remarks"],
              pics: List<String>.from(seal["pics"]),
            );

            fetchedUsersData.add(sealData);
          }

          setState(() {
            sealsData = fetchedUsersData;
          });
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<bool> _onWillPop() async {
    bool exit = await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
    );

    if (exit != null && exit) {
      SystemNavigator.pop(); // Exit the app
    }

    return exit ?? false;
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      drawer: MyDrawer(
          _full_name,
          _email,
          _isloggedin,
          userImageUrl,
          _id,
          _user_type,
          _password,
          _uuid),
      appBar: MyApplicationBar(title: const Text('SEAL MANAGEMENT')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15),

                // Search Bar with Container
                Text(
                  'Search Seals',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade400,
                  ),
                ),

                const SizedBox(height: 20),

                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDropdown("All Location", "Location", locations,
                        selectedLocation, (value) {
                          setState(() {
                            selectedLocation = value;
                          });
                        }),
                    const SizedBox(height: 25),
                    // Increased from 15 to 20

                    buildDropdown("Select Plant", "Plant Name", plants,
                        selectedPlantName, (value) {
                          setState(() {
                            selectedPlantName = value;
                          });
                        }),
                    const SizedBox(height: 25),

                    buildDropdown("Select Material", "Material", materials,
                        selectedMaterial, (value) {
                          setState(() {
                            selectedMaterial = value;
                          });
                        }),
                    const SizedBox(height: 25),

                    buildFieldWithDatePicker(
                        'From Date', fromDate, (selectedDate) {
                      setState(() {
                        fromDate = selectedDate;
                      });
                    }),
                    const SizedBox(height: 25),

                    buildFieldWithDatePicker(
                        'To Date', toDate, (selectedEndDate) {
                      setState(() {
                        toDate = selectedEndDate;
                      });
                    }),
                    const SizedBox(height: 25),

                    buildTextField("Vehicle No", vehicleNumber, (value) {
                      setState(() {
                        vehicleNumber = value;
                      });
                    }),
                    const SizedBox(height: 30),
                    // Increased from 25 to 30 for better spacing before button

                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          padding: EdgeInsets.symmetric(horizontal: 25,
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          fetch_search_seal_data(
                            plantId: getSelectedPlantId(),
                            locationId: getSelectedLocationId(),
                            materialId: getSelectedMaterialId(),
                            vehicleNumber: vehicleNumber,
                          );
                        },
                        child: Text(
                          'Get Data',
                          style: TextStyle(fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  void showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Image'),
                const SizedBox(width: 16.0),
                (imagePath != '0')
                    ? Image.network(
                  imagePath,
                  width: 200.0, // Adjust the width as needed
                  height: 200.0, // Adjust the height as needed
                )
                    : Text('No Image'),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildUserDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Table(
        columnWidths: {
          0: FixedColumnWidth(126),
        },
        children: [
          TableRow(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: value == 'N/A'
                    ? Text(value)
                    : (label == 'Image')
                    ? Container(
                  width: 100, // Adjust the width as needed
                  child: ElevatedButton(
                    onPressed: () {
                      showImageDialog(value);
                    },
                    child: Text('View Image'),
                  ),
                )
                    : Text(value),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget buildDropdown(String hint, String labelText, List<String> items,
      String? selectedItem, void Function(String?) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 20.0), // Shift Label Right
            child: Text(
              labelText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.0),
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
        ),
      ],
    );
  }


  Widget buildFieldWithDatePicker(String label, DateTime? selectedDate,
      void Function(DateTime?) onDateChanged) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 20.0), // Shift Label Right
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 15.0),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final newSelectedDate = await showDatePicker(
                      context: context, // Ensure context is available
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (newSelectedDate != null) {
                      onDateChanged(newSelectedDate);
                    }
                  },
                  child: Container(
                    height: 55.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey.shade200,
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDate != null
                              ? '${selectedDate.toLocal()}'.split(' ')[0]
                              : 'Select Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 24.0,
                          color: Colors.blue.shade900,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTextField(String labelText, String? text,
      void Function(String?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.0), // Shift Label Right
          child: Row(
            children: [
              Icon(
                Icons.directions_car,
                color: Colors.blue.shade900,
                size: 24.0,
              ),
              SizedBox(width: 10.0),
              Text(
                labelText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          width: 180,
          child: Container(
            height: 50.0,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextFormField(
              onChanged: onChanged,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter Vehicle No',
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 15.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ],
    );
  }
}