import 'dart:convert';
import 'package:SealApp/pages/view_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SealApp/app_classes/My_Drawer.dart';
import 'package:SealApp/app_classes/My_Application_Bar.dart';
import 'package:SealApp/pages/Login_page.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class AddUser extends StatefulWidget
{
  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {


  RegExp nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
  RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  //Dropdown variables
  String userType = 'Select User Type';

  // Define FocusNode instances
  final emailFocusNode = FocusNode();


  //Variables for toggle switch
  String? active;
  String? mobileLogin;
  String? accessSealData;
  String? sender;
  String? receiver;
  String? readOnlyUser;
  String? accessScrapData;
  String? accessGPS;

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

  bool _isSubmitButtonEnabled = false;

  List<String> materials = [];
  List<String> selectedMaterials = [];
  List<String> selectedMaterialName = [];
  List<String> selectedMaterialIds  = [];

  // Add the 'plants' and 'selectedPlants' variables to the _AddUserState class
  List<String> plants = [];
  List<String> selectedPlants = [];
  List<String> selectedPlantName = [];
  List<String> selectedPlantIds = [];

  //variable to show  yes/no option
  List<String> isactive = ['Yes','No'];
  List<String> ismobileLogin = ['Yes','No'];
  List<String> isaccessSealData = ['Yes','No'];
  List<String> issender = ['Yes','No'];
  List<String> isreceiver = ['Yes','No'];
  List<String> isreadOnlyUser = ['Yes','No'];
  List<String> isaccessScrapData = ['Yes','No'];
  List<String> isaccessGPS = ['Yes','No'];

  int mapYesNoToInteger(String? value)
  {
    return value == 'Yes' ? 1 : 0;
  }

  //Controller
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController deviceIDController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    userNameController.dispose();
    passwordController.dispose();
    deviceIDController.dispose();
    emailFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    fetchdropdownData();
    emailFocusNode.addListener(() {
      if (!emailFocusNode.hasFocus) {
        setState(() {
          // Trigger validation and update submit button state
          _updateSubmitButtonState();
        });
      }
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

  // Function to validate full name with regex
  bool validateFullName(String fullName) {
    return nameRegExp.hasMatch(fullName);
  }

  // Function to validate email with regex
  bool validateEmail(String email) {
    return emailRegExp.hasMatch(email);
  }

  // Function to check if all required fields are filled
  bool _isFormValid() {
    return userType != 'Select User Type' &&
        fullNameController.text.isNotEmpty &&
        validateFullName(fullNameController.text) &&
        emailController.text.isNotEmpty &&
        validateEmail(emailController.text) &&
        userNameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        selectedMaterials.isNotEmpty &&
        selectedPlantName.isNotEmpty;
  }

  // Function to enable or disable the Submit button
  void _updateSubmitButtonState() {
    setState(() {
      _isSubmitButtonEnabled = _isFormValid() &&
          mobileLogin != null &&
          active != null &&
          accessSealData != null &&
          sender != null &&
          receiver != null &&
          readOnlyUser != null &&
          accessScrapData != null &&
          accessGPS != null;
    });
  }

  //Fetching API for Dropdown
  Future<void> fetchdropdownData() async {
    await _getUserDetails();

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

      updateData(data, "material", materials, selectedMaterialIds);
      updateData(data, "plant", plants, selectedPlantIds);

      setState(() {
        selectedPlantName = selectedPlants;
        selectedMaterialName = selectedMaterials ;
      });
    } else {
      print('Status is not 1 in the response');
    }
  }

  //Function to add plant name,material name, plant id and material id
  void updateData(Map<String, dynamic> data, String key, List<String> itemList, List<String> itemIdList) {
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

  // Function to map user type to the corresponding character
  String mapUserTypeToCharacter(String userType) {
    switch (userType) {
      case 'Super Admin':
        return 'S';
      case 'Admin':
        return 'A';
      case 'User With Delete':
        return 'U';
      case 'User Without Delete':
        return 'I';
      default:
        return ''; // Return empty string for unknown user types
    }
  }

  //Function to get selected material id
  List<String> getSelectedMaterialIds(List<String> selectedMaterialNames, List<String> allMaterialNames, List<String> allMaterialIds) {
    List<String> selectedIds = [];
    for (int i = 0; i < selectedMaterialNames.length; i++) {
      int index = allMaterialNames.indexOf(selectedMaterialNames[i]);
      if (index != -1) {
        selectedIds.add(allMaterialIds[index]);
      }
    }
    return selectedIds;
  }

  //Function to get selected plant id
  List<String> getSelectedPlantIds(List<String> selectedPlantNames, List<String> allPlantNames, List<String> allPlantIds) {
    List<String> selectedIds = [];
    for (int i = 0; i < selectedPlantNames.length; i++) {
      int index = allPlantNames.indexOf(selectedPlantNames[i]);
      if (index != -1) {
        selectedIds.add(allPlantIds[index]);
      }
    }
    return selectedIds;
  }

  //Fetching for add & edit user
  fetch_add_edit_user_data() async {
    try {
      final userTypeCharacter = mapUserTypeToCharacter(userType);
      final Map<String, String> body = {
        // 'uuid': "bd0029d5175022be",
        'uuid': _uuid,
        'user_id': _username,
        'password': _password,
        'user_type': userTypeCharacter,
        'full_name': fullNameController.text,
        'email': emailController.text,
        'username': userNameController.text,
        'pass': passwordController.text,
        'active_user': mapYesNoToInteger(active).toString(),
        'allowed_mobile_login': mapYesNoToInteger(mobileLogin).toString(),
        'access_seal_data': mapYesNoToInteger(accessSealData).toString(),
        'sender': mapYesNoToInteger(sender).toString(),
        'receiver': mapYesNoToInteger(receiver).toString(),
        'readonly': mapYesNoToInteger(readOnlyUser).toString(),
        'access_scrap_data': mapYesNoToInteger(accessScrapData).toString(),
        'access_gps_module': mapYesNoToInteger(accessGPS).toString(),
        'material': getSelectedMaterialIds(selectedMaterialName, materials, selectedMaterialIds).join(','),
        'plant': getSelectedPlantIds(selectedPlantName, plants, selectedPlantIds).join(','),
        'mid': deviceIDController.text,
      };

      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/add_edit_user_data'),
        headers: {"Accept": "application/json"},
        body: body,
      );

      // print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
      }
    } catch (e) {
      print('Error: $e');
    }
  }



  //Richtext function
  Widget createRichText(String labelText) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: labelText,
            style: TextStyle(fontSize: 16.0,color: Colors.black),
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

  //Borderinput function
  Widget buildRichTextBorderedInput({
    required String labelText,
    required TextEditingController controller,
    required String hintText,
    FocusNode? focusNode, // Make focusNode nullable
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        createRichText(labelText),
        SizedBox(width: 18.0),
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode, // Assign focus node here
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 14.0), // Adjust the hint font size here
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }



  //Dropdown function
  Widget buildRichTextDropdown(
      String labelText,
      String hint,
      List<String> items,
      String? selectedItem,
      void Function(String?) onChanged,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        createRichText(labelText),
        Spacer(),
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedItem,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item,style: TextStyle(fontSize: 14.0),),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12.0),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.black,fontSize: 14.0),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
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
                        Icons.lock,
                        color: Colors.blue.shade900,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Add User',
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
                  createRichText('User Type'),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: userType,
                      onChanged: (String? newValue) {
                        setState(() {
                          userType = newValue!;
                        });
                        _updateSubmitButtonState();
                      },
                      items: <String>[
                        'Select User Type',
                        'Super Admin', 'Admin', 'User With Delete', 'User Without Delete',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(value, style: TextStyle(fontSize: 14.0)),
                            ),
                          ),
                        );
                      }).toList(),
                      underline: Container(),
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              buildRichTextBorderedInput(
                labelText: 'Full Name',
                controller: fullNameController,
                hintText: 'Enter your full name',
                focusNode: null,
              ),
              SizedBox(height: 16.0),
              buildRichTextBorderedInput(
                labelText: ' Email ID :',
                controller: emailController,
                hintText: 'Enter your email ID',
                focusNode: emailFocusNode,
              ),
              if (!emailFocusNode.hasFocus && emailController.text.isNotEmpty && !validateEmail(emailController.text))
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Please enter a valid email',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 16.0),
              buildRichTextBorderedInput(
                labelText: 'UserName',
                controller: userNameController,
                hintText: 'Enter your user name',
                focusNode: null,
              ),
              SizedBox(height: 16.0),
              buildRichTextBorderedInput(
                labelText: 'Password ',
                controller: passwordController,
                hintText: 'Enter your password',
                focusNode: null,
              ),
              SizedBox(height: 16.0),
              buildRichTextDropdown(
                'Active?',
                "Select Active",
                isactive,
                active,
                    (value) {
                  setState(() {
                    active = value;
                    _updateSubmitButtonState();
                  });
                },
              ),
              SizedBox(height: 16.0),
              buildRichTextDropdown(
                'Mobile Login?',
                "Select Mobile Login",
                ismobileLogin,
                mobileLogin,
                    (value) {
                  setState(() {
                    mobileLogin = value;
                    _updateSubmitButtonState();
                  });
                },
              ),
              SizedBox(height: 16.0),
              buildRichTextDropdown(
                'Access Seal \nData?',
                "Select",
                isaccessSealData,
                accessSealData,
                    (value) {
                  setState(() {
                    accessSealData = value;
                    _updateSubmitButtonState();
                  });
                },
              ),
              SizedBox(height: 16.0),
              buildRichTextDropdown(
                'Sender?',
                "Select Sender",
                issender,
                sender,
                    (value) {
                  setState(() {
                    sender = value;
                    _updateSubmitButtonState();
                  });
                },
              ),
              SizedBox(height: 16.0),
              buildRichTextDropdown(
                'Receiver?',
                "Select Receiver",
                isreceiver,
                receiver,
                    (value) {
                  setState(() {
                    receiver = value;
                    _updateSubmitButtonState();
                  });
                },
              ),
              SizedBox(height: 16.0),
              buildRichTextDropdown(
                'Read Only \nUser?',
                "Select",
                isreadOnlyUser,
                readOnlyUser,
                    (value) {
                  setState(() {
                    readOnlyUser = value;
                    _updateSubmitButtonState();
                  });
                },
              ),
              SizedBox(height: 16.0),
              buildRichTextDropdown(
                'Access Scrap \nData?',
                "Select",
                isaccessScrapData,
                accessScrapData,
                    (value) {
                  setState(() {
                    accessScrapData = value;
                    _updateSubmitButtonState();
                  });
                },
              ),
              SizedBox(height: 16.0),
              buildRichTextDropdown(
                'Access GPS?',
                "Select Access GPS",
                isaccessGPS,
                accessGPS,
                    (value) {
                  setState(() {
                    accessGPS = value;
                    _updateSubmitButtonState();
                  });
                },
              ),
              SizedBox(height: 16.0),
              // Updated Material and Plant selection sections
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  createRichText('Material'),
                  Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.52,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: materials.map((String materialOption) {
                              return ListTile(
                                leading: Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  value: selectedMaterials.contains(materialOption),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedMaterials.add(materialOption);
                                      } else {
                                        selectedMaterials.remove(materialOption);
                                      }
                                      _updateSubmitButtonState();
                                    });
                                  },
                                ),
                                title: Text(materialOption,style: TextStyle(fontSize: 15.0)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),


              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  createRichText('Plant'),
                  Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.52,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: plants.map((String plantOption) {
                              return ListTile(
                                leading: Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  value: selectedPlants.contains(plantOption),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedPlants.add(plantOption);
                                      } else {
                                        selectedPlants.remove(plantOption);
                                      }
                                      _updateSubmitButtonState();
                                    });
                                  },
                                ),
                                title: Text(
                                  plantOption,
                                  style: TextStyle(fontSize: 15.0), // Adjust the font size as needed
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Device ID:',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(width: 15.0),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5, // Adjust the width as needed
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    child: TextFormField(
                      controller: deviceIDController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                        hintText: 'Enter your Device ID',
                        hintStyle: TextStyle(fontSize: 14.0),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Center(
                child: Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitButtonEnabled
                          ? () {
                        //Function calling
                        fetch_add_edit_user_data();

                        // Show the loading indicator immediately
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context)
                          {
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
                        Future.delayed(Duration(seconds: 2), () async
                        {
                          // Remove the loading indicator
                          Navigator.pop(context);

                          // Navigate to the next screen
                          Navigator.push
                            (
                              context, MaterialPageRoute(builder: (context) => view_user())
                          );
                        }
                        );
                      } : null,

                      child: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50.0),
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

