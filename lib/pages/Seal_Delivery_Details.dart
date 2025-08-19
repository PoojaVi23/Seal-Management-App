import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SealApp/constants.dart';
import 'package:SealApp/app_classes/My_Drawer.dart';
import 'package:SealApp/app_classes/My_Application_Bar.dart';
import 'package:SealApp/pages/Login_Page.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class SealDeliveryDetails extends StatefulWidget {
  @override
  _SealDeliveryDetailsState createState() => _SealDeliveryDetailsState();
}

class _SealDeliveryDetailsState extends State<SealDeliveryDetails> {
  final searchStrController = TextEditingController();
  List<dynamic> deliveryData = [];
  TextEditingController numberOfBagsController = TextEditingController();

  DateTime? _selectedDate;

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


  String getStatusText(String status) {
    return status == '0' ? 'Pending...' : (status == '1' ? 'Reached' : 'Unknown');
  }

  Color getStatusColor(String status) {
    return status == '0' ? Colors.yellow.shade800 : (status == '1' ? Colors.green : Colors.black);
  }


  @override
  void initState() {
    super.initState();
    _getUserDetails();
    get_seal_delivery_data(); // Call the method to fetch data when the page initializes.
    // updateDeliveryData(bagsReceivedDate: null, numberOfBags: '', sealDeliveryNoteId: '');
  }

  void _showAddDialog(String sealDeliveryNoteId) async {
    TextEditingController dateController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                width: MediaQuery.of(context).size.width * 0.10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        'Enter Delivery Details',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      readOnly: true,
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: 'Bags Received Date',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2101),
                            );

                            if (pickedDate != null && pickedDate != selectedDate) {
                              setState(() {
                                selectedDate = pickedDate;
                                dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: numberOfBagsController,
                      decoration: InputDecoration(labelText: 'Number of Bags'),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? bagsReceivedDate = selectedDate;
                            String numberOfBags = numberOfBagsController.text;

                            // Call the API to update delivery data
                            await updateDeliveryData(
                              sealDeliveryNoteId: sealDeliveryNoteId,
                              bagsReceivedDate: bagsReceivedDate,
                              numberOfBags: numberOfBags,
                            );

                            // Update local deliveryData list
                            // Perform API call to fetch updated data
                            await get_seal_delivery_data();

                            // Call setState to trigger UI rebuild
                            setState(() {
                              // Optionally, you can update any other state variables here
                            });

                            // Close the dialog
                            Navigator.of(context).pop();
                          },
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }




  // Function to update delivery data
  Future<void> updateDeliveryData({
    required DateTime? bagsReceivedDate,
    required String numberOfBags,
    required String sealDeliveryNoteId,
  }) async {
    try {
      //print(sealDeliveryNoteId);

      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/update_delivery_data'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
          'seal_delivery_note_id': sealDeliveryNoteId,
          'receive_date': bagsReceivedDate != null ? DateFormat('yyyy-MM-dd').format(bagsReceivedDate) : '',

          // bagsReceivedDate?.toIso8601String() ?? '',
          // 'bags_received_date': '2023-11-24',
          'receive_bags': numberOfBags,
          // 'number_of_bags': '5',
        },
      );

      if (response.statusCode == 200)
      {
        final data = json.decode(response.body);
        print("Response data: $data");
      }

    } catch (e) {
      // Handle network or other errors
      print('Error: $e');
    }
  }




  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    searchStrController.dispose();
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

  Future<void> get_seal_delivery_data() async {
    try {
      await _getUserDetails();
      final response = await http.post(
        Uri.parse('$API_URL/Mobile_flutter_api/get_seal_delivery_data'),
        headers: {"Accept": "application/json"},
        body: {
          'uuid': _uuid,
          'user_id': _username,
          'password': _password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);


        setState(() {
          deliveryData = data['user_data'];
        });

      }
    } catch (e) {
      print('Error: $e');
    }
  }


  void _showFileViewDialog(String fileValue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: PhotoView(
            backgroundDecoration: BoxDecoration(
              color: Colors.transparent,
            ),
            imageProvider: NetworkImage(fileValue),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            enableRotation: true,
          ),
        );
      },
    );
  }


  Widget buildDeliveryNotes() {
    if (deliveryData.isEmpty) {
      return Center(
        child: Text('No delivery notes available.'),
      );
    }

    return ListView.builder(
      itemCount: deliveryData.length,
      itemBuilder: (context, index) {
        final deliveryNote = deliveryData[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2.0,
              // margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.yellow, width: 2.0),
                borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
              ),
              child: ListTile(
                // title: Text('ID: ${deliveryNote['seal_delivery_note_id']}'),
                title: Text(''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8.0),
                      color: Colors.grey.shade300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location: ${deliveryNote['location_name']}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black),
                                ),
                                Text(
                                  '${getStatusText(deliveryNote['status'])}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: getStatusColor(deliveryNote['status']),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.black,
                            onPressed: () => _showAddDialog(deliveryNote['seal_delivery_note_id']),
                          ),
                        ],
                      ),

                    ),
                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Send on : ',style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold,color: Colors.black),),
                        Text('${deliveryNote['send_date']}',style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sender\n Name : ',style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold,color: Colors.black)),
                        Text('${deliveryNote['sender_name']}',style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('No. of Bags : ',style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold,color: Colors.black)),
                        Text('${deliveryNote['no_bags']}',style: TextStyle(color: Colors.black),),

                      ],
                    ),
                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('No. of Seals : ',style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold,color: Colors.black)),
                        Text('${deliveryNote['no_seals']}',style: TextStyle(color: Colors.black),),
                      ],
                    ),

                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Seal Start : ',style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold,color: Colors.black)),
                        Text('${deliveryNote['seal_start']}',style: TextStyle(color: Colors.black),)
                      ],
                    ),
                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Seal End : ',style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold,color: Colors.black)),
                        Text('${deliveryNote['seal_end']}',style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Send via : ',style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold,color: Colors.black)),
                        Text('${deliveryNote['mode_of_transport']}',style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Transporter\n Name : ',style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold,color: Colors.black)),
                        Text('${deliveryNote['transport_name']}',style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ref No. : ',style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold,color: Colors.black)),
                        Text('${deliveryNote['ref_no']}',style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Received Date : ',style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold,color: Colors.black)),
                        Text('${deliveryNote['receive_date']}',style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Received Bags : ',style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold,color: Colors.black)),
                        Text('${deliveryNote['receive_bags']}',style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Received By : ',style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold,color: Colors.black)),
                        Text('${deliveryNote['receive_by']}',style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('File :',style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold,color: Colors.black)),
                        ElevatedButton(

                          onPressed: () {
                            _showFileViewDialog(deliveryNote['scan_copy']);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: Text('View File'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0,),
                    // ...

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Bags Difference :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                        // Text('${deliveryNote['difference_bags']}',
                        //   style: TextStyle(color: deliveryNote['difference_bags'] == '0' ? Colors.green : Colors.red,),),
                        if (deliveryNote['difference_bags'] != '0')
                          Text(
                            '${deliveryNote['difference_bags']}  ''Missing Bags',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (deliveryNote['difference_bags'] == '0')
                          Text(
                            'No missing bags',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16.0,),
                    // Add more details as needed
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
      drawer: MyDrawer(_full_name, _email, _isloggedin, userImageUrl, _id, _user_type,_password,_uuid),
      appBar: MyApplicationBar(title: const Text('SEAL MANAGEMENT')),
      body: Column(
        children: [
          Card(
            elevation: 12,
            margin: EdgeInsets.all(16),
            child: Container(
              height: 50,
              margin: EdgeInsets.only(left: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'View Delivery Notes',
                    style: TextStyle(
                      fontSize: 20,
                      // fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: buildDeliveryNotes(),
          ),
        ],
      ),
    );
  }
}
