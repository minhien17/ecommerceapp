import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants.dart';
import '../../../services/firestore_file_access/firestore_file_access_service.dart';
import '../../../size_config.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(screenPadding),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: getProportionateScreenHeight(10)),
                Text(
                  "About Developer",
                  style: headingStyle,
                ),
                SizedBox(height: getProportionateScreenHeight(50)),
                // InkWell(
                //   onTap: () async {
                //     // const String linkedInUrl =
                //     //     "https://www.linkedin.com/in/imrb7here";
                //     // await launchUrl(linkedInUrl);
                //   },
                //   child: buildDeveloperAvatar(),
                // ),
                Text(
                  "Minh Hiển",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Mobile Developer",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(30)),
                Text(
                  "Giang Linh",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Game Developer",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(30)),
                Text(
                  "Việt Anh",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Data Engineer",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(30)),
                // Row(
                //   children: [
                //     Spacer(),
                //     IconButton(
                //       icon: SvgPicture.asset(
                //         "assets/icons/github_icon.svg",
                //         color: kTextColor.withOpacity(0.75),
                //       ),
                //       color: kTextColor.withOpacity(0.75),
                //       iconSize: 40,
                //       padding: EdgeInsets.all(16),
                //       onPressed: () async {
                //         const String githubUrl = "https://github.com/minhien17";
                //         await launchUrlString(githubUrl);
                //       },
                //     ),
                //     IconButton(
                //       icon: SvgPicture.asset(
                //         "assets/icons/linkedin_icon.svg",
                //         color: kTextColor.withOpacity(0.75),
                //       ),
                //       iconSize: 40,
                //       padding: EdgeInsets.all(16),
                //       onPressed: () async {
                //         const String linkedInUrl =
                //             "https://www.linkedin.com/in/imrb7here";
                //         await launchUrlString(linkedInUrl);
                //       },
                //     ),
                //     IconButton(
                //       icon: SvgPicture.asset("assets/icons/instagram_icon.svg",
                //           color: kTextColor.withOpacity(0.75)),
                //       iconSize: 40,
                //       padding: EdgeInsets.all(16),
                //       onPressed: () async {
                //         const String instaUrl =
                //             "https://www.instagram.com/_rahul.badgujar_";
                //         await launchUrlString(instaUrl);
                //       },
                //     ),
                //     Spacer(),
                //   ],
                // ),
                SizedBox(height: getProportionateScreenHeight(50)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.thumb_up),
                      color: kTextColor.withOpacity(0.75),
                      iconSize: 50,
                      padding: EdgeInsets.all(16),
                      onPressed: () {
                        // submitAppReview(context, liked: true);
                      },
                    ),
                    Text(
                      "Liked the app?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.thumb_down),
                      padding: EdgeInsets.all(16),
                      color: kTextColor.withOpacity(0.75),
                      iconSize: 50,
                      onPressed: () {
                        // submitAppReview(context, liked: false);
                      },
                    ),
                    Spacer(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDeveloperAvatar() {
    return FutureBuilder<String>(
        future: FirestoreFilesAccess().getDeveloperImage(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final url = snapshot.data;
            return CircleAvatar(
              radius: SizeConfig.screenWidth * 0.3,
              backgroundColor: kTextColor.withOpacity(0.75),
              backgroundImage: NetworkImage(url!),
            );
          } else if (snapshot.hasError) {
            final error = snapshot.error.toString();
            Logger().e(error);
          }
          return CircleAvatar(
            radius: SizeConfig.screenWidth * 0.3,
            backgroundColor: kTextColor.withOpacity(0.75),
          );
        });
  }

  // Future<void> launchUrlString(String url) async {
  //   final Uri uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
  Future<void> launchUrlString(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // dùng trình duyệt ngoài
      );
      if (!launched) throw 'Could not launch $url';
    } else {
      throw 'Could not launch $url';
    }
  }

//   Future<void> submitAppReview(BuildContext context,
//       {bool liked = true}) async {
//     AppReview prevReview;
//     try {
//       prevReview = await AppReviewDatabaseHelper().getAppReviewOfCurrentUser();
//     } on FirebaseException catch (e) {
//       Logger().w("Firebase Exception: $e");
//     } catch (e) {
//       Logger().w("Unknown Exception: $e");
//     } finally {
//       if (prevReview == null) {
//         prevReview = AppReview(
//           AuthentificationService().currentUser.uid,
//           liked: liked,
//           feedback: "",
//         );
//       }
//     }

//     final AppReview result = await showDialog(
//       context: context,
//       builder: (context) {
//         return AppReviewDialog(
//           appReview: prevReview,
//         );
//       },
//     );
//     if (result != null) {
//       result.liked = liked;
//       bool reviewAdded = false;
//       String snackbarMessage = '';
//       try {
//         reviewAdded = await AppReviewDatabaseHelper().editAppReview(result);
//         if (reviewAdded == true) {
//           snackbarMessage = "Feedback submitted successfully";
//         } else {
//           throw "Coulnd't add feeback due to unknown reason";
//         }
//       } on FirebaseException catch (e) {
//         Logger().w("Firebase Exception: $e");
//         snackbarMessage = e.toString();
//       } catch (e) {
//         Logger().w("Unknown Exception: $e");
//         snackbarMessage = e.toString();
//       } finally {
//         Logger().i(snackbarMessage);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(snackbarMessage),
//           ),
//         );
//       }
//     }
//   }
}
