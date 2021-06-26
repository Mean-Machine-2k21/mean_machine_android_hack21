import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:frontend/bloc/mural_bloc/mural_state.dart';
import 'package:frontend/screens/create_mural_screen.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/widget/toggle_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../global.dart';
import '../services/api_handling.dart';

class EditProfile extends StatefulWidget {
  static const routeName = '/editProfile';
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  void getUrl(String bioUrl) {
    this.bioUrl = bioUrl;
    print("*******-> ${bioUrl}");
  }

  ApiHandling apiHandling = ApiHandling();
  ImagePicker _imagePicker = ImagePicker();
  String avatarUrl = "";
  String bioUrl = "";
  File? image;
  bool loading = false;

  String currentProfile = "";
  String currentBio = "";

  @override
  Future<void> didChangeDependencies() async {
    setState(() {
      loading = true;
    });
    currentProfile = await localRead('avatar_url');
    currentBio = await localRead('bio_url');

    setState(() {
      loading = false;
    });
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  Future<void> uploadImage() async {
    final pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      image = File(pickedFile!.path);
    });
    await uploadImageToFirebase(context);
  }

  Future uploadImageToFirebase(BuildContext context) async {
    setState(() {
      loading = true;
    });

    String username = await localRead('username');
    //String fileName = basename(_image.path);
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('uploads/profileImages/${username}');
    final uploadTask = firebaseStorageRef.putFile(image!);
    await uploadTask.whenComplete(() => print('File Uploaded'));
    firebaseStorageRef.getDownloadURL().then((fileURL) {
      setState(() {
        // _uploadedFileURL = fileURL;
        // //imageURLs.add(_uploadedFileURL);
        // widget.product.imageUrls.add(_uploadedFileURL);
        print(fileURL + "-------");
        avatarUrl = fileURL;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image Uploaded'),
          ),
        );
      });
      // StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      // taskSnapshot.ref.getDownloadURL().then(
      //       (value) => print("Done: $value"),
      //     );
    });

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Edit Your Profile !',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () async {
                    await apiHandling.editProfile(
                      avatarUrl: avatarUrl,
                      bioUrl: bioUrl,
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => Profile(
                          key: widget.key,
                        ),
                      ),
                    );
                  },
                  child: loading
                      ? SizedBox(
                          height: 50,
                          width: 50,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Icon(
                          Icons.save,
                          color: Colors.red,
                        ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Profile Pictue',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: color.contrast),
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    uploadImage().then(
                      (value) => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Profile Photo Updated'),
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit,color: Colors.red,)
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     Container(
              //       height: 95,
              //       width: 95,
              //       decoration: BoxDecoration(
              //         border: Border.all(color: Colors.red, width: 2),
              //         shape: BoxShape.circle,
              //         color: Colors.blue,
              //         image: DecorationImage(
              //           image: NetworkImage(currentProfile),
              //           fit: BoxFit.cover,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  image != null
                      ? Container(
                          height: 95,
                          width: 95,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                            border: Border.all(color: Colors.red, width: 2),
                            image: DecorationImage(
                              image: FileImage(image!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          height: 95,
                          width: 95,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                            shape: BoxShape.circle,
                            color: Colors.blue,
                            image: DecorationImage(
                              image: NetworkImage(currentProfile),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Change Your Bio',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: color.contrast),
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateMuralScreen(
                          'normal',
                          editProfile: getUrl,
                        ),
                      ),
                    );

                    setState(() {
                      loading = false;
                    });

                    print('################ ${bioUrl}');
                    localWrite('bio_url', bioUrl);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            height: 173,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
              color: Colors.red,
              image: DecorationImage(
                image: NetworkImage(bioUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Toggle Color Mode',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color:   color.contrast),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Toggle(
                    value: color.isDarkMode,
                    onToggle: (value) {
                      if (value) {
                        // color.themeModeSwitch(colorMode: ColorMode.dark);
                      } else {
                        // color.themeModeSwitch(colorMode: ColorMode.light);
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
