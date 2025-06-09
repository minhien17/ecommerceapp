import 'dart:async';

import 'package:ecommerce/models/address_model.dart';
import 'package:ecommerce/pages/manage_addresses/components/address_short_details_card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../common/widgets/flutter_toast.dart';
import '../../../components/default_button.dart';
import '../../../components/nothingtoshow.dart';
import '../../../constants.dart';
import '../../../size_config.dart';
import '../../edit_address/edit_address_screen.dart';
import '../components/address_box.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late Future<List<AddressModel>> _listAddresses;
  @override
  void initState() {
    super.initState();
    _listAddresses = getAddressList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<AddressModel>> getAddressList() async {
    final completer = Completer<List<AddressModel>>();

    ApiUtil.getInstance()!.get(
      url: ApiEndpoint.adress, // Endpoint lấy danh sách địa chỉ
      onSuccess: (response) {
        List<AddressModel> addresses = (response.data['data'] as List)
            .map((json) => AddressModel.fromJson(json))
            .toList();
        completer.complete(addresses);
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Request timed out");
        } else {
          toastInfo(msg: error.toString());
        }
        completer.complete([]);
      },
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(screenPadding)),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: getProportionateScreenHeight(10)),
                  Text(
                    "Manage Addresses",
                    style: headingStyle,
                  ),
                  Text(
                    "Swipe LEFT to Edit, Swipe RIGHT to Delete",
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  DefaultButton(
                    text: "Add New Address",
                    press: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditAddressScreen(address: AddressModel()),
                        ),
                      );
                      await refreshPage();
                    },
                  ),
                  SizedBox(height: getProportionateScreenHeight(30)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.7,
                    child: FutureBuilder<List<AddressModel>>(
                      future: _listAddresses,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final addresses = snapshot.data;
                          if (addresses!.length == 0) {
                            return Center(
                              child: NothingToShowContainer(
                                iconPath: "assets/icons/add_location.svg",
                                secondaryMessage: "Add your first Address",
                              ),
                            );
                          }
                          return ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: addresses.length,
                              itemBuilder: (context, index) {
                                return buildAddressItemCard(addresses[index]);
                              });
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          final error = snapshot.error;
                          Logger().w(error.toString());
                        }
                        return Center(
                          child: NothingToShowContainer(
                            iconPath: "assets/icons/network_error.svg",
                            primaryMessage: "Something went wrong",
                            secondaryMessage: "Unable to connect to Database",
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(50)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    return Future<void>.value();
  }

  Future<bool> deleteButtonCallback(
      BuildContext context, String addressId) async {
    final confirmDeletion = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to delete this Address ?"),
          actions: [
            ElevatedButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            ElevatedButton(
              child: Text("No"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );

    if (confirmDeletion) {
      bool status = false;
      String snackbarMessage = '';
      try {
        // status =
        //     await UserDatabaseHelper().deleteAddressForCurrentUser(addressId);
        if (status == true) {
          snackbarMessage = "Address deleted successfully";
        } else {
          throw "Coulnd't delete address due to unknown reason";
        }
      } on FirebaseException catch (e) {
        Logger().w("Firebase Exception: $e");
        snackbarMessage = "Something went wrong";
      } catch (e) {
        Logger().w("Unknown Exception: $e");
        snackbarMessage = e.toString();
      } finally {
        Logger().i(snackbarMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackbarMessage),
          ),
        );
      }
      await refreshPage();
      return status;
    }
    return false;
  }

  Future<bool> editButtonCallback(
      BuildContext context, AddressModel address) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditAddressScreen(address: address)));
    await refreshPage();
    return false;
  }

  Future<void> addressItemTapCallback(AddressModel address) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.transparent,
          title: AddressBox(
            address: address,
          ),
          titlePadding: EdgeInsets.zero,
        );
      },
    );
    await refreshPage();
  }

  Widget buildAddressItemCard(AddressModel address) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Dismissible(
        key: Key(address.addressId),
        direction: DismissDirection.horizontal,
        background: buildDismissibleSecondaryBackground(),
        secondaryBackground: buildDismissiblePrimaryBackground(),
        dismissThresholds: {
          DismissDirection.endToStart: 0.65,
          DismissDirection.startToEnd: 0.65,
        },
        child: AddressShortDetailsCard(
          address: address,
          onTap: () async {
            await addressItemTapCallback(address);
          },
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            final status =
                await deleteButtonCallback(context, address.addressId);
            return status;
          } else if (direction == DismissDirection.endToStart) {
            final status = await editButtonCallback(context, address);
            return status;
          }
          return false;
        },
        onDismissed: (direction) async {
          await refreshPage();
        },
      ),
    );
  }

  Widget buildDismissiblePrimaryBackground() {
    return Container(
      padding: EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.edit,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            "Edit",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDismissibleSecondaryBackground() {
    return Container(
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
