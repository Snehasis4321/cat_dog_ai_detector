// ignore_for_file: unused_field

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  File? _image;
  List? _output;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _output = output!;
      _isLoading = false;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
  }

  @override
  void dispose() {
    super.dispose();
  }

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    detectImage(_image!);
  }

  pickformGallary() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    detectImage(_image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detection Zone ")),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text("Either click or select a photo and get your result."),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    pickImage();
                  },
                  child: const Text("Take A Photo")),
              const Spacer(),
              ElevatedButton(
                  onPressed: () {
                    pickformGallary();
                  },
                  child: const Text("Select a Photo")),
            ],
          ),
        ),
        Column(
          children: [
            SizedBox(
                height: 250,
                child: _image != null
                    ? Image.file(File(_image!.path))
                    : const FlutterLogo(
                        size: 200,
                      )),
            const SizedBox(
              height: 20,
            ),
            Text("${_output != null ? _output![0]['label'] : " "}"),
          ],
        ),
      ]),
    );
  }
}
