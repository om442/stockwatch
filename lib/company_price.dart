import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = 'PUT API KEY HERE';

class CompanyPrice {
  CompanyPrice({
    required this.c,
    required this.d,
    required this.dp,
    required this.h,
    required this.l,
    required this.o,
    required this.pc,
    required this.t,
  });

  double c;
  double d;
  double dp;
  double h;
  double l;
  double o;
  double pc;
  int t;

  factory CompanyPrice.fromJson(Map<String, dynamic> json) => CompanyPrice(
        c: json["c"].toDouble(),
        d: json["d"].toDouble(),
        dp: json["dp"].toDouble(),
        h: json["h"].toDouble(),
        l: json["l"].toDouble(),
        o: json["o"].toDouble(),
        pc: json["pc"].toDouble(),
        t: json["t"],
      );

  Map<String, dynamic> toJson() => {
        "c": c,
        "d": d,
        "dp": dp,
        "h": h,
        "l": l,
        "o": o,
        "pc": pc,
        "t": t,
      };
}

Future<CompanyPrice> fetchCompanyPrice({required String query}) async {
  query = query.toUpperCase();

  final response = await http.get(
      Uri.parse('https://finnhub.io/api/v1/quote?symbol=$query&token=$apiKey'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    if (response.body ==
        '{"c":0,"d":null,"dp":null,"h":0,"l":0,"o":0,"pc":0,"t":0}') {
      return Future.error('Incorrect Query');
    } else {
      return CompanyPrice.fromJson(jsonDecode(response.body));
    }
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    return Future.error('Incorrect Query');
  }
}
