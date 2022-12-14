import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = 'c9gvchqad3iblo2foslg';

class CompanyInfo {
  CompanyInfo({
    required this.country,
    required this.currency,
    required this.exchange,
    required this.finnhubIndustry,
    required this.ipo,
    required this.logo,
    required this.marketCapitalization,
    required this.name,
    required this.phone,
    required this.shareOutstanding,
    required this.ticker,
    required this.weburl,
  });

  String country;
  String currency;
  String exchange;
  String finnhubIndustry;
  DateTime ipo;
  String logo;
  double marketCapitalization;
  String name;
  String phone;
  double shareOutstanding;
  String ticker;
  String weburl;

  factory CompanyInfo.fromJson(Map<String, dynamic> json) => CompanyInfo(
        country: json["country"],
        currency: json["currency"],
        exchange: json["exchange"],
        finnhubIndustry: json["finnhubIndustry"],
        ipo: DateTime.parse(json["ipo"]),
        logo: json["logo"],
        marketCapitalization: json["marketCapitalization"].toDouble(),
        name: json["name"],
        phone: json["phone"],
        shareOutstanding: json["shareOutstanding"].toDouble(),
        ticker: json["ticker"],
        weburl: json["weburl"],
      );

  Map<String, dynamic> toJson() => {
        "country": country,
        "currency": currency,
        "exchange": exchange,
        "finnhubIndustry": finnhubIndustry,
        "ipo":
            "${ipo.year.toString().padLeft(4, '0')}-${ipo.month.toString().padLeft(2, '0')}-${ipo.day.toString().padLeft(2, '0')}",
        "logo": logo,
        "marketCapitalization": marketCapitalization,
        "name": name,
        "phone": phone,
        "shareOutstanding": shareOutstanding,
        "ticker": ticker,
        "weburl": weburl,
      };
}

Future<CompanyInfo> fetchCompanyProfile({required String query}) async {
  query = query.toUpperCase();

  final response = await http.get(Uri.parse(
      'https://finnhub.io/api/v1/stock/profile2?symbol=$query&token=$apiKey'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    if (response.body == '{}') {
      return Future.error('Incorrect Query');
    } else {
      return CompanyInfo.fromJson(jsonDecode(response.body));
    }
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    return Future.error('Incorrect Query');
  }
}
