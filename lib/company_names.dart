import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = 'PUT API KEY HERE';

class Information {
  final int count;
  final List<Result> result;

  const Information({
    required this.count,
    required this.result,
  });

  factory Information.fromJson(Map<String, dynamic> json) {
    final result_list = json['result'] as List<dynamic>?;
    final results = result_list != null
        // map each review to a Review object
        ? result_list
            .map((x) => Result.fromJson(x))
            // map() returns an Iterable so we convert it to a List
            .toList()
        // use an empty list as fallback value
        : <Result>[];
    return Information(
      count: json['count'],
      result: results,
    );
  }
}

class Result {
  String description;
  String displaySymbol;
  String symbol;
  String type;

  Result({
    required this.description,
    required this.displaySymbol,
    required this.symbol,
    required this.type,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        description: json["description"],
        displaySymbol: json["displaySymbol"],
        symbol: json["symbol"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "displaySymbol": displaySymbol,
        "symbol": symbol,
        "type": type,
      };
}

Future<List<Result>> fetchCompanyNames({required String query}) async {
  final response = await http.get(
      Uri.parse('https://finnhub.io/api/v1/search?q=$query&token=$apiKey'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Information temp = Information.fromJson(jsonDecode(response.body));
    return temp.result;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Information');
  }
}
