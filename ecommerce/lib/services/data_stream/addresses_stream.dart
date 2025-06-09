// import 'package:ecommerce/services/data_stream/data_stream.dart';

// import '../database/user_database_helper.dart';

// class AddressesStream extends DataStream<List<String>> {
//   @override
//   void reload() {
//     final addressesList = UserDatabaseHelper().addressesList;
//     addressesList.then((list) {
//       addData(list);
//     }).catchError((e) {
//       addError(e);
//     });
//   }
// }
