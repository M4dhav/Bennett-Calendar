import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sizer/sizer.dart';
import 'package:oktoast/oktoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      // print(response.data);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.data);

        print(jsonData['rooms']);
      } else {
        print('Upload failed: ${response.statusCode}');
      }
    } else {
      // User canceled the picker
      print('No file selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bennett Calendar', style: TextStyle(fontSize: 16)),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final GoogleSignInAccount? account =
                    await GoogleSignIn().signIn();
                if (account != null) {
                  print('Signed in as ${account.email}');
                } else {
                  print('Sign-in cancelled');
                }
              },
              child: const Text('Sign in with Google'),
            ),
          ],
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
                },
                child: const Text('Upload File'),
              ),
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
