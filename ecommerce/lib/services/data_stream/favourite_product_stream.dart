// import 'package:ecommerce/services/data_stream/data_stream.dart';
// import 'package:ecommerce/services/database/user_database_helper.dart';

// class FavouriteProductsStream extends DataStream<List<String>> {
//   @override
//   void reload() {
//     final favProductsFuture = UserDatabaseHelper().usersFavouriteProductsList;
//     favProductsFuture.then((favProducts) {
//       addData(favProducts.cast<String>());
//     }).catchError((e) {
//       addError(e);
//     });
//   }
// }
