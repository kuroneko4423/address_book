import 'dart:convert';
import 'package:http/http.dart' as http;

class PostalCodeService {
  static const String _baseUrl = 'https://zipcloud.ibsnet.co.jp/api/search';

  /// 郵便番号から住所を検索する
  /// zipcode: ハイフンなしの7桁郵便番号（例: "1000001"）
  static Future<PostalCodeResult?> searchByPostalCode(String zipcode) async {
    try {
      // ハイフンを除去して7桁の数字のみにする
      final cleanZipcode = zipcode.replaceAll('-', '').replaceAll(' ', '');
      
      if (cleanZipcode.length != 7 || !RegExp(r'^\d{7}$').hasMatch(cleanZipcode)) {
        return null;
      }

      final url = Uri.parse('$_baseUrl?zipcode=$cleanZipcode');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 200 && data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          return PostalCodeResult(
            zipcode: result['zipcode'],
            prefecture: result['address1'],
            city: result['address2'],
            town: result['address3'],
          );
        }
      }
    } catch (e) {
      print('郵便番号検索エラー: $e');
    }
    
    return null;
  }

  /// 郵便番号を表示用にフォーマットする（例: "1000001" -> "100-0001"）
  static String formatPostalCode(String zipcode) {
    final cleanZipcode = zipcode.replaceAll('-', '').replaceAll(' ', '');
    if (cleanZipcode.length == 7) {
      return '${cleanZipcode.substring(0, 3)}-${cleanZipcode.substring(3)}';
    }
    return zipcode;
  }

  /// 郵便番号の入力値を検証する
  static bool isValidPostalCode(String zipcode) {
    final cleanZipcode = zipcode.replaceAll('-', '').replaceAll(' ', '');
    return cleanZipcode.length == 7 && RegExp(r'^\d{7}$').hasMatch(cleanZipcode);
  }
}

class PostalCodeResult {
  final String zipcode;
  final String prefecture;
  final String city;
  final String town;

  PostalCodeResult({
    required this.zipcode,
    required this.prefecture,
    required this.city,
    required this.town,
  });

  /// 完全な住所を取得する
  String get fullAddress => '$prefecture$city$town';

  @override
  String toString() {
    return 'PostalCodeResult{zipcode: $zipcode, prefecture: $prefecture, city: $city, town: $town}';
  }
}