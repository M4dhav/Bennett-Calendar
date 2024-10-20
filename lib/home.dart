import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:bennett_cal/calendar_controller.dart';
import 'package:dio/dio.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:sizer/sizer.dart';
import 'package:oktoast/oktoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double progValue = 0.0;
  List<Map<String, String>> eventData = [];
  final SingleSelectController<String?> splController =
      SingleSelectController("Please Select a Specialisation");
  final SingleSelectController<String?> electiveController =
      SingleSelectController("Please Select an Elective");
  String? splElective;
  List<String> list = [
    "Please Select a Specialisation",
    'AI',
    "Data Science",
    "Cybersecurity",
    "DevOps",
    "Cloud Computing",
    "Full Stack",
    "Core",
    "Blockchain",
    "Gaming",
    "IoT And Robotics",
    "Quantum Computing",
    "AR/VR",
    "Product Design Technology",
  ];
  List<String> electiveList = [
    "Please Select an Elective",
    'Soft Computing',
    "Compiler Construction",
    "Engineering Optimization",
    "Software Project Management",
  ];
  List<List<String>> splElectives = [
    ["Please Select a Specialisation Elective"],
    [
      "Image And Video Processing",
      "Natural Language Processing",
    ],
    [
      "Time Series Analysis",
      "Big Data Analytics And Buisness Intelligence",
    ],
    [
      "Penetraion Testing, Auditing and Ethical Testing",
    ],
    [
      "Build And Release Managment in DevOps",
    ],
    ["Cloud Infrastructure and Services"],
    ["Front-End Web UI Frameworks and Tools: Bootstrap"],
    ["Blockchain Technologies: Platforms & Applications"],
    ["Augmented Reality"],
    ["IoT Analytics"],
    ["Quantum Computing for Data Analysis"],
    ["Augmented Reality and ARCore"],
    ['Design and Manufacturing for Digital Products']
  ];
  Future<void> uploadFile() async {
    if (splController.value == "Please Select a Specialisation" ||
        electiveController.value == "Please Select an Elective" ||
        splElective == null) {
      showToast("Please select all the fields");

      return;
    }
    // Pick the file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'xls',
        'xlsx'
      ], // Add other allowed extensions if needed
    );
    final dio = Dio();
    if (result != null) {
      PlatformFile file = result.files.single;
      final formData = FormData.fromMap({
        'files': MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        ),
        'spl': splController.value,
        'spl_elective': splElective,
        "elective": electiveController.value,
      });
      final response = await dio.post(
        'https://bennett-calendar-backend.onrender.com/upload',
        data: formData,
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        eventData.clear();
        for (var event in jsonData['class']) {
          Map<String, String> eventMap = Map.from(event);
          eventData.add(eventMap);
        }
        setState(() {});
        print(eventData);
      } else {
        print('Upload failed: ${response.statusCode}');
      }
    } else {
      // User canceled the picker
      print('No file selected.');
    }
  }

  Future<void> googleSignInFunc() async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      clientId:
          '547194397495-acus6c61hpgu76gtnin58j9tafoit5gm.apps.googleusercontent.com',
      scopes: [
        'https://www.googleapis.com/auth/calendar',
      ],
    );
    try {
      await googleSignIn.signIn();
      final client = await googleSignIn.authenticatedClient();
      if (client != null) {
        CalendarClient.calendar = cal.CalendarApi(client);
        log('Signed in');
      }
    } on PlatformException catch (e) {
      debugPrint(e.message);
    }
  }

  Future<void> updateProgress() async {
    setState(() {
      progValue += 100 / eventData.length;
    });
  }

  Future<void> addEvents() async {
    CalendarClient client = CalendarClient();
    final String calId = await client.createCalendar();
    for (Map<String, String> event in eventData) {
      await client.insert(
          title: event['name']!,
          description: event['course']!,
          location: event['room']!,
          startTime: DateTime(
              2024, 8, int.parse(event['day']!), int.parse(event['time']!), 30),
          endTime: DateTime(2024, 8, int.parse(event['day']!),
              int.parse(event['time']!) + 1, 30),
          calendarId: calId);
      await updateProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bennett Calendar', style: TextStyle(fontSize: 16)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropDownWidget(
                list: electiveList,
                splController: electiveController,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              DropDownWidget(
                list: list,
                splController: splController,
                onChanged: (value) {
                  setState(() {
                    splElective = list[list.indexOf(splController.value!)][0];
                  });
                },
              ),
              if (splController.value != "Please Select a Specialisation")
                SizedBox(
                  width: 50.w,
                  child: CustomDropdown<String>(
                    decoration: CustomDropdownDecoration(),
                    hintText: 'Please Select a Specialisation',
                    items: splElectives[list.indexOf(splController.value!)],
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        splElective = value;
                      });
                    },
                    initialItem:
                        splElectives[list.indexOf(splController.value!)][0],
                  ),
                ),
              ElevatedButton(
                onPressed: () async {
                  await uploadFile();
                  await googleSignInFunc();
                  await addEvents();
                  showToast('Events added to calendar');
                },
                child: const Text('Upload File'),
              ),
              SizedBox(
                width: 70.w,
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 5.h,
                  value: progValue,
                  color: Colors.blue,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DropDownWidget extends StatelessWidget {
  const DropDownWidget({
    super.key,
    required this.list,
    required this.splController,
    required this.onChanged,
  });

  final List<String> list;
  final SingleSelectController<String?> splController;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50.w,
      child: CustomDropdown<String>(
        decoration: CustomDropdownDecoration(),
        hintText: 'Please Select a Specialisation',
        items: list,
        onChanged: onChanged,
        controller: splController,
      ),
    );
  }
}
