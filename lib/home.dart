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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SingleSelectController<String?> splController =
      SingleSelectController("Please Select a Specialisation");
  List<String> list = [
    "Please Select a Specialisation",
    'AI',
    "Data Science",
    "Cybersecurity",
    "DevOps",
    "Cloud Computing"
  ];
  Future<void> uploadFile() async {
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
        'spl': "AI",
        'spl_elective': "NLP",
        "elective": "Soft Computing",
      });
      final response = await dio.post(
        'http://localhost:5000/upload',
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
              SizedBox(
                width: 50.w,
                child: CustomDropdown<String>(
                  decoration: CustomDropdownDecoration(),
                  hintText: 'Select job role',
                  items: list,
                  onChanged: (value) {
                    log('value of controller $value');
                    print(splController.value);
                  },
                  controller: splController,
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
