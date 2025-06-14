import 'dart:async';
import 'dart:io';
import 'package:ecommerce/components/default_button.dart';
import 'package:ecommerce/components/product_card.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/exceptions/local_files/local_file_handling.dart';
import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/pages/edit_product/provider_models/product_detail_model.dart';
import 'package:ecommerce/services/local_files_access/image_picking_exception.dart';
import 'package:ecommerce/services/local_files_access/local_files_access.dart';
import 'package:ecommerce/size_config.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';
import 'package:material_tag_editor/tag_editor.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../api/api_end_point.dart';
import '../../../api/api_util.dart';
import '../../../common/widgets/flutter_toast.dart';

class EditProductForm extends StatefulWidget {
  final ProductModel product;
  EditProductForm({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  _EditProductFormState createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _basicDetailsFormKey = GlobalKey<FormState>();
  final _describeProductFormKey = GlobalKey<FormState>();
  // final _tagStateKey = GlobalKey<TagsState>();

  final TextEditingController titleFieldController = TextEditingController();
  final TextEditingController variantFieldController = TextEditingController();
  final TextEditingController discountPriceFieldController =
      TextEditingController();
  final TextEditingController originalPriceFieldController =
      TextEditingController();
  final TextEditingController highlightsFieldController =
      TextEditingController();
  final TextEditingController desciptionFieldController =
      TextEditingController();
  final TextEditingController sellerFieldController = TextEditingController();

  bool newProduct = true;
  ProductModel product = ProductModel();

  @override
  void dispose() {
    titleFieldController.dispose();
    variantFieldController.dispose();
    discountPriceFieldController.dispose();
    originalPriceFieldController.dispose();
    highlightsFieldController.dispose();
    desciptionFieldController.dispose();
    sellerFieldController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.product.id == '') {
      newProduct = true;
    } else {
      product = widget.product;
      newProduct = false;
      final productDetails =
          Provider.of<ProductDetails>(context, listen: false);
      productDetails.initialSelectedImages = widget.product.images
          .map((e) => CustomImage(imgType: ImageType.network, path: e))
          .toList();
      productDetails.initialProductType = product.productType;
      productDetails.initSearchTags = product.searchTags;
    }
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      children: [
        buildBasicDetailsTile(context),
        SizedBox(height: getProportionateScreenHeight(10)),
        buildDescribeProductTile(context),
        SizedBox(height: getProportionateScreenHeight(10)),
        buildUploadImagesTile(context),
        SizedBox(height: getProportionateScreenHeight(20)),
        buildProductTypeDropdown(),
        SizedBox(height: getProportionateScreenHeight(20)),
        buildProductSearchTagsTile(),
        SizedBox(height: getProportionateScreenHeight(80)),
        DefaultButton(
            text: "Save Product",
            press: () {
              saveProductButtonCallback(context);
            }),
        SizedBox(height: getProportionateScreenHeight(10)),
      ],
    );
    if (newProduct == false) {
      titleFieldController.text = product.title;
      variantFieldController.text = product.variant;
      discountPriceFieldController.text = product.discountPrice.toString();
      originalPriceFieldController.text = product.originalPrice.toString();
      highlightsFieldController.text = product.highlights;
      desciptionFieldController.text = product.description;
      sellerFieldController.text = product.seller;
    }
    return column;
  }

  Widget buildProductSearchTags() {
    return Consumer<ProductDetails>(
      builder: (context, productDetails, child) {
        // return Tags(
        //   key: _tagStateKey,
        //   horizontalScroll: true,
        //   heightHorizontalScroll: getProportionateScreenHeight(80),
        //   textField: TagsTextField(
        //     lowerCase: true,
        //     width: getProportionateScreenWidth(120),
        //     constraintSuggestion: true,
        //     hintText: "Add search tag",
        //     keyboardType: TextInputType.name,
        //     onSubmitted: (String str) {
        //       productDetails.addSearchTag(str.toLowerCase());
        //     },
        //   ),
        //   itemCount: productDetails.searchTags.length,
        //   itemBuilder: (index) {
        //     final item = productDetails.searchTags[index];
        //     return ItemTags(
        //       index: index,
        //       title: item,
        //       active: true,
        //       activeColor: kPrimaryColor,
        //       padding: EdgeInsets.symmetric(
        //         horizontal: 12,
        //         vertical: 8,
        //       ),
        //       alignment: MainAxisAlignment.spaceBetween,
        //       removeButton: ItemTagsRemoveButton(
        //         backgroundColor: Colors.white,
        //         color: kTextColor,
        //         onRemoved: () {
        //           productDetails.removeSearchTag(index: index);
        //           return true;
        //         },
        //       ),
        //     );
        //   },
        // );
        return TagEditor(
          onTagChanged: (value) {},
          length: productDetails.searchTags.length,
          hasAddButton: true,
          inputDecoration: InputDecoration(
            hintText: "Add search tag",
          ),
          // Add tag when submitted
          onSubmitted: (String str) {
            setState(() {
              productDetails.addSearchTag(str.toLowerCase());
            });
          },
          // Build tags
          tagBuilder: (context, index) {
            final item = productDetails.searchTags[index];
            return Chip(
              label: Text(item),
              backgroundColor: kPrimaryColor,
              deleteIcon: Icon(Icons.close, color: kTextColor),
              onDeleted: () {
                // Remove the tag from the list
                setState(() {
                  productDetails.removeSearchTag(index: index);
                });
              },
            );
          },
        );
      },
    );
  }

  Widget buildBasicDetailsTile(BuildContext context) {
    return Form(
      key: _basicDetailsFormKey,
      child: ExpansionTile(
        maintainState: true,
        title: Text(
          "Basic Details",
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: Icon(
          Icons.shop,
        ),
        childrenPadding:
            EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
        children: [
          buildTitleField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildVariantField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildOriginalPriceField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildDiscountPriceField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildSellerField(),
          SizedBox(height: getProportionateScreenHeight(20)),
        ],
      ),
    );
  }

  bool validateBasicDetailsForm() {
    if (_basicDetailsFormKey.currentState!.validate()) {
      _basicDetailsFormKey.currentState!.save();
      product.title = titleFieldController.text;
      product.variant = variantFieldController.text;
      product.originalPrice = double.parse(originalPriceFieldController.text);
      product.discountPrice = double.parse(discountPriceFieldController.text);
      product.seller = sellerFieldController.text;
      return true;
    }
    return false;
  }

  Widget buildDescribeProductTile(BuildContext context) {
    return Form(
      key: _describeProductFormKey,
      child: ExpansionTile(
        maintainState: true,
        title: Text(
          "Describe Product",
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: Icon(
          Icons.description,
        ),
        childrenPadding:
            EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
        children: [
          buildHighlightsField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildDescriptionField(),
          SizedBox(height: getProportionateScreenHeight(20)),
        ],
      ),
    );
  }

  bool validateDescribeProductForm() {
    if (_describeProductFormKey.currentState!.validate()) {
      _describeProductFormKey.currentState!.save();
      product.highlights = highlightsFieldController.text;
      product.description = desciptionFieldController.text;
      return true;
    }
    return false;
  }

  Widget buildProductTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: kTextColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Consumer<ProductDetails>(
        builder: (context, productDetails, child) {
          return DropdownButton(
            value: productDetails.productType,
            items: ProductType.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      EnumToString.convertToString(e),
                    ),
                  ),
                )
                .toList(),
            hint: Text(
              "Chose Product Type",
            ),
            style: TextStyle(
              color: kTextColor,
              fontSize: 16,
            ),
            onChanged: (value) {
              productDetails.productType = value ?? ProductType.other;
            },
            elevation: 0,
            underline: SizedBox(width: 0, height: 0),
          );
        },
      ),
    );
  }

  Widget buildProductSearchTagsTile() {
    return ExpansionTile(
      title: Text(
        "Search Tags",
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(Icons.check_circle_sharp),
      childrenPadding:
          EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
      children: [
        Text("Your product will be searched for this Tags"),
        SizedBox(height: getProportionateScreenHeight(15)),
        buildProductSearchTags(),
      ],
    );
  }

  Widget buildUploadImagesTile(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "Upload Images",
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(Icons.image),
      childrenPadding:
          EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
              icon: Icon(
                Icons.add_a_photo,
              ),
              color: kTextColor,
              onPressed: () {
                addImageButtonCallback();
              }),
        ),
        Consumer<ProductDetails>(
          builder: (context, productDetails, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  productDetails.selectedImages.length,
                  (index) => SizedBox(
                    width: 80,
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          addImageButtonCallback(index: index);
                        },
                        child: productDetails.selectedImages[index].imgType ==
                                ImageType.local
                            ? Image.memory(
                                File(productDetails.selectedImages[index].path)
                                    .readAsBytesSync())
                            : Image.network(
                                productDetails.selectedImages[index].path),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildTitleField() {
    return TextFormField(
      controller: titleFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "e.g., Samsung Galaxy F41 Mobile",
        labelText: "Product Title",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (titleFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildVariantField() {
    return TextFormField(
      controller: variantFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "e.g., Fusion Green",
        labelText: "Variant",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (variantFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildHighlightsField() {
    return TextFormField(
      controller: highlightsFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText:
            "e.g., RAM: 4GB | Front Camera: 30MP | Rear Camera: Quad Camera Setup",
        labelText: "Highlights",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (highlightsFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  Widget buildDescriptionField() {
    return TextFormField(
      controller: desciptionFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText:
            "e.g., This a flagship phone under made in India, by Samsung. With this device, Samsung introduces its new F Series.",
        labelText: "Description",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (desciptionFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  Widget buildSellerField() {
    return TextFormField(
      controller: sellerFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "e.g., HighTech Traders",
        labelText: "Seller",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (sellerFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildOriginalPriceField() {
    return TextFormField(
      controller: originalPriceFieldController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "e.g., 5999.0",
        labelText: "Original Price (in INR)",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (originalPriceFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildDiscountPriceField() {
    return TextFormField(
      controller: discountPriceFieldController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "e.g., 2499.0",
        labelText: "Discount Price (in INR)",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (discountPriceFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Future<void> saveProductButtonCallback(BuildContext context) async {
    if (validateBasicDetailsForm() == false) {
      if (newProduct == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Errors in Basic Details Form"),
          ),
        );
        return;
      }
    }

    if (validateDescribeProductForm() == false) {
      if (newProduct == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Errors in Describe Product Form"),
          ),
        );
        return;
      }
    }

    final productDetails = Provider.of<ProductDetails>(context, listen: false);
    if (productDetails.selectedImages.length < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload atleast One Image of Product"),
        ),
      );
      return;
    }
    if (productDetails.productType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select Product Type"),
        ),
      );
      return;
    }
    if (productDetails.searchTags.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Add atleast 3 search tags"),
        ),
      );
      return;
    }
    String productId = product.id;
    String snackbarMessage = '';
    try {
      product.productType = productDetails.productType;
      product.searchTags = productDetails.searchTags;

      final productUploadFuture =
          newProduct ? addProduct(product) : updateProduct(product);
      productUploadFuture.then((value) {
        productId = value;
      });
      await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            productUploadFuture,
            message:
                Text(newProduct ? "Uploading Product" : "Updating Product"),
          );
        },
      );
      if (productId != '') {
        snackbarMessage = "Product Info updated successfully";
      } else {
        throw "Couldn't update product info due to some unknown issue";
      }
    } finally {
      Logger().i(snackbarMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
    if (productId == '') {
      Navigator.pop(context);
      return;
    }
    bool allImagesUploaded = false;
    try {
      allImagesUploaded = await uploadProductImages(productId);
      if (allImagesUploaded == true) {
        snackbarMessage = "All images uploaded successfully";
      } else {
        throw "Some images couldn't be uploaded, please try again";
      }
    } finally {
      Logger().i(snackbarMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
    List<String> downloadUrls = productDetails.selectedImages
        .where((e) => e.imgType == ImageType.network)
        .map((e) => e.path)
        .toList();
    bool productFinalizeUpdate = false;
    product = product.copyWith(id: productId, images: downloadUrls);
    try {
      final updateProductFuture = updateProduct(product);
      productFinalizeUpdate = await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            updateProductFuture,
            message: Text("Saving Product"),
          );
        },
      );
      if (productFinalizeUpdate == true) {
        snackbarMessage = "Product uploaded successfully";
      } else {
        throw "Couldn't upload product properly, please retry";
      }
    } finally {
      Logger().i(snackbarMessage);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(snackbarMessage),
      //   ),
      // );
      Navigator.pop(context);
    }
  }

  Future<bool> uploadProductImages(String productId) async {
    bool allImagesUpdated = true;
    final productDetails = Provider.of<ProductDetails>(context, listen: false);
    for (int i = 0; i < productDetails.selectedImages.length; i++) {
      if (productDetails.selectedImages[i].imgType == ImageType.local) {
        print("Image being uploaded: " + productDetails.selectedImages[i].path);
        String downloadUrl = '';
        try {
          final imgUploadFuture =
              uploadFileToPath(File(productDetails.selectedImages[i].path), '');
          downloadUrl = await showDialog(
            context: context,
            builder: (context) {
              return FutureProgressDialog(
                imgUploadFuture,
                message: Text(
                    "Uploading Images ${i + 1}/${productDetails.selectedImages.length}"),
              );
            },
          );
        } finally {
          if (downloadUrl != '') {
            productDetails.selectedImages[i] =
                CustomImage(imgType: ImageType.network, path: downloadUrl);
          } else {
            allImagesUpdated = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text("Couldn't upload image ${i + 1} due to some issue"),
              ),
            );
          }
        }
      }
    }
    return allImagesUpdated;
  }

  Future<void> addImageButtonCallback({int? index}) async {
    final productDetails = Provider.of<ProductDetails>(context, listen: false);
    if (index == null && productDetails.selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Max 3 images can be uploaded")));
      return;
    }
    String path = '';
    String snackbarMessage = '';
    try {
      path = await choseImageFromLocalFiles(context);
      if (path == null) {
        throw LocalImagePickingUnknownReasonFailureException();
      }
    } on LocalFileHandlingException catch (e) {
      Logger().i("Local File Handling Exception: $e");
      snackbarMessage = e.toString();
    } catch (e) {
      Logger().i("Unknown Exception: $e");
      snackbarMessage = e.toString();
    } finally {
      if (snackbarMessage != null) {
        Logger().i(snackbarMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackbarMessage),
          ),
        );
      }
    }
    if (path == null) {
      return;
    }
    if (index == null) {
      productDetails.addNewSelectedImage(
          CustomImage(imgType: ImageType.local, path: path));
    } else {
      productDetails.setSelectedImageAtIndex(
          CustomImage(imgType: ImageType.local, path: path), index);
    }
  }

  Future<String> updateProduct(ProductModel product) async {
    final completer = Completer<String>();

    ApiUtil.getInstance()!.post(
      url: "${ApiEndpoint.product}/${product.id}", // Endpoint được truyền vào
      body: product.toJson(),
      onSuccess: (response) {
        completer.complete(product.id);
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Request timed out");
        } else {
          toastInfo(msg: error.toString());
        }
        completer.complete(''); // Trả về danh sách rỗng nếu có lỗi
      },
    );

    return completer.future;
  }

  Future<String> addProduct(ProductModel product) async {
    final completer = Completer<String>();

    ApiUtil.getInstance()!.post(
      url: ApiEndpoint.upload, // Endpoint được truyền vào
      body: product.toJson(),
      onSuccess: (response) {
        String productId = response.data['data']['product_id'];
        completer.complete(productId);
      },
      onError: (error) {
        if (error is TimeoutException) {
          toastInfo(msg: "Request timed out");
        } else {
          toastInfo(msg: error.toString());
        }
        completer.complete(''); // Trả về danh sách rỗng nếu có lỗi
      },
    );

    return completer.future;
  }

  Future<String> uploadFileToPath(File file, String path) async {
    final supabaseCl = supabase.Supabase.instance.client;
    const bucketName = 'ecommerce';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'products/images/$timestamp.jpg';

    try {
      final response = await supabaseCl.storage.from(bucketName).upload(
            path, // thay đổi từ path
            file,
          );

      if (response.isNotEmpty) {
        final publicUrl =
            supabaseCl.storage.from(bucketName).getPublicUrl(path);
        return publicUrl;
      } else {
        throw Exception('Upload failed: empty response');
      }
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }
}
