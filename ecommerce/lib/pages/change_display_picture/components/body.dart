import 'dart:io';
import 'package:ecommerce/api/api_end_point.dart';
import 'package:ecommerce/api/api_util.dart';
import 'package:ecommerce/common/loading.dart';
import 'package:ecommerce/common/widgets/flutter_toast.dart';
import 'package:ecommerce/shared_preference.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../components/default_button.dart';
import '../../../constants.dart';
import '../../../exceptions/local_files/local_file_handling.dart';
import '../../../services/database/user_database_helper.dart';
import '../../../services/firestore_file_access/firestore_file_access_service.dart';
import '../../../services/local_files_access/image_picking_exception.dart';
import '../../../services/local_files_access/local_files_access.dart';
import '../../../size_config.dart';
import '../provider_models/body_model.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

class Body extends StatefulWidget {
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChosenImage(),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(screenPadding)),
            child: SizedBox(
              width: double.infinity,
              child: Consumer<ChosenImage>(
                builder: (context, bodyState, child) {
                  return Column(
                    children: [
                      Text(
                        "Change Avatar",
                        style: headingStyle,
                      ),
                      SizedBox(height: getProportionateScreenHeight(40)),
                      GestureDetector(
                        child: buildDisplayPictureAvatar(context, bodyState),
                        onTap: () {
                          getImageFromUser(context, bodyState);
                        },
                      ),
                      SizedBox(height: getProportionateScreenHeight(80)),
                      buildChosePictureButton(context, bodyState),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      buildUploadPictureButton(context, bodyState),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      // buildRemovePictureButton(context, bodyState),
                      // SizedBox(height: getProportionateScreenHeight(80)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDisplayPictureAvatar(
      BuildContext context, ChosenImage bodyState) {
    return FutureBuilder(
      future: SharedPreferenceUtil.getImage(), //
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;
          Logger().w(error.toString());
        }
        ImageProvider? backImage;
        if (bodyState.isImageSelected) {
          // nếu đường dẫn ảnh null
          backImage = MemoryImage(bodyState.chosenImage.readAsBytesSync());
        } else if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data != null) backImage = NetworkImage(snapshot.data!);
        }
        return CircleAvatar(
          radius: SizeConfig.screenWidth * 0.3,
          backgroundColor: kTextColor.withOpacity(0.5),
          backgroundImage: backImage,
        );
      },
    );
  }

  void getImageFromUser(BuildContext context, ChosenImage bodyState) async {
    String path = '';
    String snackbarMessage = '';
    try {
      path = await choseImageFromLocalFiles(context);
      if (path == '') {
        throw LocalImagePickingUnknownReasonFailureException();
      }
    } on LocalFileHandlingException catch (e) {
      Logger().i("LocalFileHandlingException: $e");
      snackbarMessage = e.toString();
    } catch (e) {
      Logger().i("LocalFileHandlingException: $e");
      snackbarMessage = e.toString();
    } finally {
      if (snackbarMessage != '') {
        Logger().i(snackbarMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackbarMessage),
          ),
        );
      }
    }
    if (path == '') {
      return;
    }
    bodyState.setChosenImage = File(path);
  }

  Widget buildChosePictureButton(BuildContext context, ChosenImage bodyState) {
    return DefaultButton(
      text: "Choose Picture",
      press: () {
        getImageFromUser(context, bodyState);
      },
    );
  }

  Widget buildUploadPictureButton(BuildContext context, ChosenImage bodyState) {
    return DefaultButton(
      text: "Upload Picture",
      press: () {
        final Future uploadFuture = uploadImageToSupabase(context, bodyState);
        showDialog(
          context: context,
          builder: (context) {
            return FutureProgressDialog(
              uploadFuture,
              message: Text("Updating Display Picture"),
            );
          },
        );
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text("Display Picture updated")));
      },
    );
  }

  Future<void> uploadImageToSupabase(
      BuildContext context, ChosenImage bodyState) async {
    final supabase = Supabase.instance.client;
    const bucketName = 'ecommerce';
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    String snackbarMessage = '';
    try {
      String email = await SharedPreferenceUtil.getEmail();

      final path = 'user/display_picture/$timestamp.jpg';

      final response = await supabase.storage.from('ecommerce').upload(
            path, // thay đổi từ path
            bodyState.chosenImage, // sử dụng chosenImage từ bodyState
            fileOptions: const FileOptions(upsert: true),
          );

      if (response.isNotEmpty) {
        final publicUrl = supabase.storage.from(bucketName).getPublicUrl(path);

        await postURL(publicUrl);
        Logger().i("Image URL: $publicUrl");
      } else {
        throw Exception('Upload failed: empty response');
      }

      snackbarMessage = "Display picture updated successfully";
    } catch (e) {
      Logger().w("Upload Error: $e");
      snackbarMessage = "Something went wrong during upload";
    } finally {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackbarMessage)),
      );
    }
  }

  Widget buildRemovePictureButton(BuildContext context, ChosenImage bodyState) {
    return DefaultButton(
      text: "Remove Picture",
      press: () async {
        final Future uploadFuture =
            removeImageFromFirestore(context, bodyState);
        await showDialog(
          context: context,
          builder: (context) {
            return FutureProgressDialog(
              uploadFuture,
              message: Text("Deleting Display Picture"),
            );
          },
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Display Picture removed")));
        Navigator.pop(context);
      },
    );
  }

  Future<void> removeImageFromFirestore(
      BuildContext context, ChosenImage bodyState) async {
    bool status = false;
  }

  Future<void> postURL(String url) async {
    await SharedPreferenceUtil.saveImage(url);

    ApiUtil.getInstance()!.post(
        url: ApiEndpoint.updateUser,
        body: {
          "picture": url, // Cập nhật URL ảnh đại diện
        },
        onSuccess: (response) {},
        onError: (error) {
          Logger().e("Error updating display picture: $error");
          toastInfo(msg: "failed to update display picture");
        });
  }
}
