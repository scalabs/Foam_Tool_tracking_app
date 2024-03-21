import 'dart:convert';

import 'package:crypto/crypto.dart';

//public_id=pexels-aliona-%26-pasha-3892172.jpg&timestamp=1611742448382&unique_filename=false
//public_id=pexels-aliona-%26-pasha-3892172.jpg&timestamp=1611742448382&unique_filename=false
class Credentials {
  final String apiKey;
  final String apiSecret;
  final String cloudName;
  final String baseUrl = "https://api.cloudinary.com/v1_1/";

  Credentials(this.apiKey, this.apiSecret, this.cloudName);
  final _forbidden = ['file', 'cloud_name', 'resource_type', 'api_key'];
  String getSignature(Map<String, String> fields) {
    var buffer = StringBuffer();

    var keys = fields.keys.toList();
    keys.sort((a, b) => a.compareTo(b));
    // ignore: unused_local_variable
    var sorted = Map.fromEntries(keys.map((k) => MapEntry(k, fields[k])));
    fields.forEach((k, v) {
      if (!_forbidden.contains(k)) {
        buffer.write('&$k=$v');
      }
    });

    buffer.write(apiSecret);
    var bytes =
        utf8.encode(buffer.toString().substring(1).trim()); // data being hashed

    return sha1.convert(bytes).toString();
  }
}
