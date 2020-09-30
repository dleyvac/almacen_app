

import 'package:almacen/utils/api.dart';

class Header {
  static Map<String, String> headers = {"x-api-key": APIKey.apikey};
  static final Header head = Header._();
  Header._();

}