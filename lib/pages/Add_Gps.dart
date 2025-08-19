import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SealApp/app_classes/My_Drawer.dart';
import 'package:SealApp/app_classes/My_Application_Bar.dart';
import 'package:SealApp/pages/Login_Page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:multiple_images_picker/multiple_images_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';


class AddGps extends StatefulWidget {
  const AddGps({Key? key}) : super(key: key);

  @override
  _AddGpsState createState() => _AddGpsState();
}

class _AddGpsState extends State<AddGps> {

  //Controller
  TextEditingController vehiclenoController = TextEditingController();
  TextEditingController driverController = TextEditingController();
  TextEditingController drivermobController = TextEditingController();
  TextEditingController dlnoController = TextEditingController();
  TextEditingController gpsController = TextEditingController();
  TextEditingController transporterController = TextEditingController();
  TextEditingController remarksController = TextEditingController();

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

  bool _isLoading = false;


  // List to store selected photos
  List<File> _image = [];

  // File? _image;

  // List to store location names & plant names
  List<String> locations = [];
  List<String> materials = [];
  List<String> issuereason = [];

  // List to storelocation_id & material_id
  List<String> locationIds = [];
  List<String> materialIds = [];
  List<String> issuereasonIds = [];

  //Variables for user selected values
  String sealDate = DateFormat('yyyy-MM-dd').format(
      DateTime.now()); // Current date
  String sealTime = DateFormat('HH:mm:ss').format(DateTime.now());
  String? selectedLocation;
  String? selectedMaterial;
  String? selectedissuereason;


  bool _isSubmitButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    fetchdropdownData();
    gps_transaction_data_by_id();
    _requestPermissions();
  }

  // @override
  void dispose() {
    vehiclenoController.dispose();
    driverController.dispose();
    drivermobController.dispose();
    dlnoController.dispose();
    gpsController.dispose();
    transporterController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  // Function to check if all required fields are filled
  bool isVehicleNumberValid(String vehicleNumber) {
    RegExp regExp = RegExp(r'^[a-zA-Z0-9]{10}$');
    return regExp.hasMatch(vehicleNumber);
  }

  // Function to check if driver name contains only letters and spaces
  bool isDriverNameValid(String driverName) {
    RegExp regExp = RegExp(r'^[a-zA-Z]$');
    return regExp.hasMatch(driverName);
  }

  // Function to check if driver mobile number is numeric and 10 digits long
  bool isDriverMobileValid(String driverMobile) {
    RegExp regExp = RegExp(r'^[0-9]{10}$');
    return regExp.hasMatch(driverMobile);
  }


  // Function to check if all required fields are filled
  // bool areRequiredFieldsFilled() {
  //   return vehiclenoController.text.isNotEmpty &&
  //       driverController.text.isNotEmpty &&
  //       drivermobController.text.isNotEmpty &&
  //       dlnoController.text.isNotEmpty &&
  //       gpsController.text.isNotEmpty &&
  //       transporterController.text.isNotEmpty &&
  //       selectedLocation != null &&
  //       selectedLocation != "All Location" &&
  //       selectedMaterial != null &&
  //       selectedMaterial != "Select Material" &&
  //       selectedissuereason != null &&
  //       selectedissuereason != "Select" &&
  //       _image.isNotEmpty;
  // }

  bool areRequiredFieldsFilled() {
    // Check if all required fields are filled
    if (vehiclenoController.text.isNotEmpty &&
        driverController.text.isNotEmpty &&
        drivermobController.text.isNotEmpty &&
        dlnoController.text.isNotEmpty &&
        gpsController.text.isNotEmpty &&
        transporterController.text.isNotEmpty &&
        selectedLocation != null &&
        selectedLocation != "All Location" &&
        selectedMaterial != null &&
        selectedMaterial != "Select Material" &&
        selectedissuereason != null &&
        selectedissuereason != "Select" &&
        _image.isNotEmpty) {
      return true;
    }
    return false;
  }


  void _updateSubmitButtonState() {
    setState(() {
      _isSubmitButtonEnabled = areRequiredFieldsFilled() && _image.isNotEmpty;
    });
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

  //Fetching API for Dropdown
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

        //Fetching API for location
        if (data["status"] == "1") {
          if (data.containsKey("location")) {
            updateLocationData(data["location"]);
          } else {
            print('No "location" data found in the response');
          }

          //Fetching API for plant
          if (data.containsKey("material")) {
            updatematerialData(data["material"]);
          } else {
            print('No "material" data found in the response');
          }

          setState(() {
            selectedLocation = "All Location";
            selectedMaterial = "Select Material";
          });
        } else {
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

  void updateLocationData(List<dynamic> locationDataList) {
    locations.clear();
    locationIds.clear();
    locations.add("All Location");

    for (var locationData in locationDataList) {
      String locationName = locationData["location_name"].toString();
      String locationId = locationData["location_id"].toString();

      locations.add(locationName);
      locationIds.add(locationId);
    }
  }

  void updatematerialData(List<dynamic> materialDataList) {
    materials.clear();
    materialIds.clear();
    materials.add("Select Material");

    for (var materialData in materialDataList) {
      String materialName = materialData["material_name"].toString();
      String materialId = materialData["material_id"].toString();

      materials.add(materialName);
      materialIds.add(materialId);
    }
  }

  // Define a function to get the location_id for the selected location name
  String? getSelectedLocationId() {
    if (selectedLocation != null &&
        selectedLocation != "All Location") {
      int selectedIndex = locations.sublist(
          locations.indexOf("All Location") + 1).indexOf(
          selectedLocation!);
      if (selectedIndex != -1 && selectedIndex < locationIds.length) {
        return locationIds[selectedIndex];
      }
    }
    return null;
  }

  // Define a function to get the material_id for the selected material name
  String? getSelectedMaterialId() {
    if (selectedMaterial != null &&
        selectedMaterial != "Select Material") {
      int selectedIndex = materials.sublist(
          materials.indexOf("Select Material") + 1).indexOf(
          selectedMaterial!);
      if (selectedIndex != -1 && selectedIndex < materialIds.length) {
        return materialIds[selectedIndex];
      }
    }
    return null;
  }

  //Fetching API for gps
  Future<void> gps_transaction_data_by_id() async {
    await _getUserDetails();
    try {
      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/get_gps_transaction_data_by_id'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
          'id': _id,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null) {
          if (data["status"] == "1") {
            if (data.containsKey("gps_issue_reasons")) {
              updategpsIssueReasonsData(data["gps_issue_reasons"]);
            } else {
              print('No "gps_issue_reasons" data found in the response');
            }

            setState(() {
              selectedissuereason = "Select";
            });
          } else {
            print('API request was not successful. Status: ${response
                .statusCode}');
          }
        } else {
          print('No data received in the response');
        }
      } else {
        print('Failed to fetch GPS transaction data. Status code: ${response
            .statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updategpsIssueReasonsData(List<dynamic> issuereasonsDataList) {
    issuereason.clear();
    issuereasonIds.clear();
    issuereason.add("Select");

    for (var issuereasonData in issuereasonsDataList) {
      String issuereasonDataName = issuereasonData["reason"].toString();
      String issuereasonId = issuereasonData["gps_issue_reasons_id"].toString();

      issuereason.add(issuereasonDataName);
      issuereasonIds.add(issuereasonId);
    }
  }

  // Define a function to get the issuereason_id for the selected issue name
  String? getSelectedissuereasonId() {
    if (selectedissuereason != null &&
        selectedissuereason != "Select") {
      int selectedIndex = issuereason.sublist(
          issuereason.indexOf("Select") + 1).indexOf(
          selectedissuereason!);
      if (selectedIndex != -1 && selectedIndex < issuereasonIds.length) {
        return issuereasonIds[selectedIndex];
      }
    }
    return null;
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.camera,
      Permission.storage,
    ].request();
  }

  Future<String> add_edit_gps_data({
    String? locationId,
    String? materialId,
    DateTime? transactionDateTime,
    String? issuereasonId,
    List<File>? image,
  }) async {
    try {
      // Prepare your request parameters here
      var request = http.MultipartRequest(
          'POST', Uri.parse('$API_URL/Mobile_flutter_api/add_edit_gps_data'));

      String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
          transactionDateTime ?? DateTime.now());

      // Add text fields
      request.fields['uuid'] = _uuid;
      request.fields['user_id'] = _username;
      request.fields['password'] = _password;
      request.fields['location_id'] = locationId!;
      request.fields['driver_name'] = driverController.text!;
      request.fields['material_id'] = materialId!;
      request.fields['tra_datetime'] = formattedDateTime.toString();
      request.fields['vehicle_no'] = vehiclenoController.text!;
      request.fields['driver_mobile_no'] = drivermobController.text!;
      request.fields['driver_driving_license'] = dlnoController.text!;
      request.fields['gps_number'] = gpsController.text!;
      request.fields['transporter_name'] = transporterController.text!;
      request.fields['gps_remarks'] = remarksController.text!;
      request.fields['gps_issue_reasons_id'] = issuereasonId!;
      request.fields['dataOp'] = 'Add';

      // Add image file
      if (image != null) {
        for (var image in image) {
          request.files.add(
              await http.MultipartFile.fromPath('pics[]', image.path));
        }
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        // Decode the response
        var responseData = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseData);

        // Check if status is 1
        if (jsonResponse['status'] == "1") {
          // Return the message from the API
          return jsonResponse['msg'];
        } else {
          throw Exception('Error: ${jsonResponse['msg']}');
        }
      } else {
        throw Exception('Error: Status code ${response.statusCode}');
      }
    } catch (e) {
      // Exception during API call
      print('Exception during API call: $e');
      throw Exception('Error occurred during API call');
    }
  }



  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Data submitted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

// Call this function after successful data submission
  void _handleSuccess(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    setState(() {
      // Clear form fields and reset state
      vehiclenoController.clear();
      driverController.clear();
      drivermobController.clear();
      dlnoController.clear();
      gpsController.clear();
      transporterController.clear();
      remarksController.clear();
      selectedLocation = "All Location";
      selectedMaterial = "Select Material";
      selectedissuereason = "Select";
      _image.clear(); // Clear the selected images
      _isLoading = false; // Hide circular progress indicator
    });
  }





  Widget _buildBorderedInput({
    required TextEditingController controller,
    required String hintText,
    double width = 0.0,
    double height = 0.0,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Set default values for width and height if not provided
    width = (width != 0.0) ? width : screenWidth * 0.6;
    height = (height != 0.0) ? height : 40.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
          hintText: hintText,
          border: InputBorder.none,
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

  Widget _buildElevatedButton(String label, void Function() onPressed) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  // Function to pick images from the gallery _pickImageFromCamera
  Future<void> _pickImageFromCamera() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image.add(File(pickedImage.path));
        _updateSubmitButtonState();
      });
    }
  }


  // Function to pick image from camera
  Future<void> _pickImagesFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image.add(File(pickedImage.path));
        _updateSubmitButtonState();
      });
    }
  }


  Widget buildDropdown(
      String hint,
      List<String> items,
      String? selectedItem,
      void Function(String?) onChanged,
      ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Column(
        children: [
          Container(
            height: 41,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(
                color: Colors.grey.shade600,
                width: 1.0,
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              child: DropdownButtonFormField<String>(
                value: selectedItem,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    bool exit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: MyDrawer(_full_name,_email,_isloggedin,userImageUrl,_id,_user_type,_password,_uuid),
      appBar: MyApplicationBar(title: const Text('SEAL MANAGEMENT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
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
                      Icons.location_on,
                      color: Colors.blue.shade900,
                      size: 23,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Add GPS',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                createRichText('Location'),
                // Spacer(),
                buildDropdown(
                  "Select Location",
                  locations,
                  selectedLocation,
                      (value) {
                    setState(() {
                      selectedLocation = value!;
                      _updateSubmitButtonState();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                createRichText('Material'),
                // Spacer(),
                buildDropdown(
                    "Select Material",
                    materials,
                    selectedMaterial,
                        (value) {
                      setState(() {
                        selectedMaterial = value!;
                        _updateSubmitButtonState();

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
                    'Transaction \nDate',
                    style: TextStyle(fontSize: 18.0)),
                SizedBox(width: 3.0),
                Text(
                  sealDate,
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction \nTime',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(width: 7.0),
                Text(
                  sealTime,
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                createRichText('Vehicle No'),
                // Spacer(),
                SizedBox(width: 20,),
                Flexible(
                  child: _buildBorderedInput(
                    controller: vehiclenoController,
                    hintText: 'Enter Vehicle No',
                  ),
                ),
              ],

            ),
            Text(isVehicleNumberValid(vehiclenoController.text)
                ? ''
                : 'Vehicle Number must be 10 char',
              style: TextStyle(color: Colors.red, fontSize: 12),),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                createRichText('Driver Name'),
                SizedBox(width: 7),
                Flexible(
                  child: _buildBorderedInput(
                    controller: driverController,
                    hintText: 'Enter Driver Name',
                  ),
                ),
              ],
            ),
            // Text(isDriverNameValid(driverController.text)
            //     ? ''
            //     : 'Please Fill name correctly',
            //   style: TextStyle(color: Colors.red, fontSize: 12),),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                createRichText('Driver Mobile'),
                SizedBox(width: 3),
                Flexible(
                  child: _buildBorderedInput(
                    controller: drivermobController,
                    hintText: 'Mobile',
                  ),
                ),
              ],
            ),
            Text(isDriverMobileValid(drivermobController.text)
                ? ''
                : 'Mobile Number must be 10 digits',
              style: TextStyle(color: Colors.red, fontSize: 12),),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                createRichText('DL Number'),
                SizedBox(width: 17),
                Flexible(
                  child: _buildBorderedInput(
                    controller: dlnoController,
                    hintText: 'Enter DL No',
                  ),
                ),
              ],
            ),
            Text('Driving Licence No',
              style: TextStyle(color: Colors.red, fontSize: 12),),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                createRichText('GPS/IMEI No'),
                SizedBox(width: 3),
                Flexible(
                  child: _buildBorderedInput(
                    controller: gpsController,
                    hintText: 'Enter GPS/IMEI No',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                createRichText('Transporter'),
                // Spacer(),
                SizedBox(width: 17,),
                Flexible(
                  child: _buildBorderedInput(
                    controller: transporterController,
                    hintText: 'Transporter Name',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                createRichText('Issue \nReasons'),
                // Spacer(),
                buildDropdown(
                  "Select",
                  issuereason,
                  selectedissuereason,
                      (value) {
                    setState(() {
                      selectedissuereason = value!;
                      _updateSubmitButtonState();

                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Remark',
                        style: TextStyle(fontSize: 18.0,color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 50),
                Flexible(
                  child: _buildBorderedInput(
                    controller: remarksController,
                    hintText: 'Remark',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _pickImagesFromGallery,
                child: Text('ADD PHOTOS FROM GALLERY'),
              ),
            ),
            Center(child: Text('Please Attach File Before Submitting',style: TextStyle(color: Colors.red,fontSize: 12),)),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _pickImageFromCamera,
                child: Text('ADD PHOTOS USING CAMERA'),
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
                            _updateSubmitButtonState();
                          });
                        },
                        icon: Icon(Icons.delete_forever, color: Colors.red),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              child: Builder(
                builder: (BuildContext context) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: areRequiredFieldsFilled()
                            ? () async {
                          // Check if required fields are filled
                          if (areRequiredFieldsFilled()) {
                            // Show circular progress indicator
                            setState(() {
                              _isLoading = true;
                            });

                            // Call API function
                            add_edit_gps_data(
                              locationId: getSelectedLocationId(),
                              materialId: getSelectedMaterialId(),
                              issuereasonId: getSelectedissuereasonId(),
                              image: _image,
                            ).then((message) {
                              // Handle success
                              _handleSuccess(message); // Pass message directly
                            }).catchError((error) {
                              // Handle error
                              print('Error during API call: $error');
                              setState(() {
                                _isLoading = false; // Hide circular progress indicator
                              });
                            });
                          } else {
                            // Show error message if required fields are not filled
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill in all required fields.'),
                              ),
                            );
                          }
                        }: null,
                        child: Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50.0), // Increase the height
                          padding: EdgeInsets.symmetric(vertical: 16.0), // Adjust vertical padding
                        ),
                      ),
                      if (_isLoading)
                        CircularProgressIndicator( // Show circular progress indicator if loading
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}