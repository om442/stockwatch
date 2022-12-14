import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_watch/main.dart';
import 'package:url_launcher/link.dart';
import 'company_price.dart';
import 'company_profile.dart';
import 'package:favorite_button/favorite_button.dart';

// Stateful Widget to represent the stock profile page of the application
class StockProfilePage extends StatefulWidget {
  const StockProfilePage({Key? key, required this.query}) : super(key: key);

  final String query;

  @override
  State<StockProfilePage> createState() => _StockProfilePageState();
}

class _StockProfilePageState extends State<StockProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        centerTitle: true,
        actions: [
          FavoriteStockButton(query: widget.query),
        ],
        backgroundColor: Colors.grey[900],
      ),
      body: buildStockProfile(context, widget.query),
    );
  }

  Widget buildStockProfile(BuildContext context, String query) => FutureBuilder(
        future: Future.wait([
          fetchCompanyPrice(query: query),
          fetchCompanyProfile(query: query),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {
                return Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: const Text(
                    'Failed to fetch stock data',
                    style: TextStyle(fontSize: 28, color: Colors.white),
                  ),
                );
              } else {
                return buildResultSuccess(snapshot.data![0], snapshot.data![1]);
              }
          }
        },
      );

  Widget buildResultSuccess(
      CompanyPrice companyPrice, CompanyInfo companyInfo) {
    final ticker = companyInfo.ticker;
    final name = companyInfo.name;

    final current_price = companyPrice.c;
    final daily_change = companyPrice.d;
    final open_price = companyPrice.o;
    final high_price = companyPrice.h;
    final low_price = companyPrice.l;
    final prev_price = companyPrice.pc;

    final start_date = companyInfo.ipo;
    final String formatted_date = DateFormat('yyyy-MM-dd').format(start_date);
    final industry = companyInfo.finnhubIndustry;
    final website = companyInfo.weburl;
    final exchange = companyInfo.exchange;
    final market_cap = companyInfo.marketCapitalization;

    return Container(
      child: Column(
        children: [
          // Ticker and name
          Container(
            child: Row(
              children: [
                Text(
                  ticker,
                  style: const TextStyle(fontSize: 25),
                ),
                Container(
                  child: Text(
                    name,
                    style: TextStyle(
                        fontSize: 25, color: Colors.white.withOpacity(0.6)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                ),
              ],
            ),
            margin: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          ),
          // Price and change
          Container(
            child: Row(
              children: [
                Text(
                  current_price.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 25),
                ),
                Container(
                  child: Text(
                    daily_change.toStringAsFixed(2),
                    style: TextStyle(
                        fontSize: 25,
                        color: daily_change >= 0 ? Colors.green : Colors.red),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                ),
              ],
            ),
            margin: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          ),
          // Stats
          Container(
            child: Column(
              children: [
                const Text(
                  'Stats',
                  style: TextStyle(fontSize: 25),
                ),
                Row(
                  children: [
                    Container(
                      child: const Text('Open', style: TextStyle(fontSize: 20)),
                      padding: const EdgeInsets.fromLTRB(10, 5, 20, 0),
                    ),
                    Container(
                      child: Text(open_price.toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.6))),
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                    ),
                    Container(
                      child: const Text('High', style: TextStyle(fontSize: 20)),
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                    ),
                    Container(
                      child: Text(high_price.toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.6))),
                      padding: const EdgeInsets.fromLTRB(20, 5, 0, 0),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      child: const Text('Low', style: TextStyle(fontSize: 20)),
                      padding: const EdgeInsets.fromLTRB(17, 5, 20, 0),
                    ),
                    Container(
                      child: Text(low_price.toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.6))),
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                    ),
                    Container(
                      child: const Text('Prev', style: TextStyle(fontSize: 20)),
                      padding: const EdgeInsets.fromLTRB(23, 5, 20, 0),
                    ),
                    Container(
                      child: Text(prev_price.toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.6))),
                      padding: const EdgeInsets.fromLTRB(20, 5, 0, 0),
                    ),
                  ],
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            margin: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          ),
          // About
          Container(
            child: Column(
              children: [
                Container(
                  child: const Text('About', style: TextStyle(fontSize: 25)),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                ),
                Row(
                  children: [
                    Container(
                      child: const Text('Start date',
                          style: TextStyle(fontSize: 14)),
                      padding: const EdgeInsets.fromLTRB(5, 5, 20, 0),
                      width: 100,
                    ),
                    Container(
                      child: Text(formatted_date,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6))),
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      child: const Text('Industry',
                          style: TextStyle(fontSize: 14)),
                      padding: const EdgeInsets.fromLTRB(5, 5, 20, 0),
                      width: 100,
                    ),
                    Container(
                      child: Text(industry,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6))),
                      padding: const EdgeInsets.fromLTRB(10, 2, 0, 0),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      child:
                          const Text('Website', style: TextStyle(fontSize: 14)),
                      padding: const EdgeInsets.fromLTRB(5, 5, 20, 0),
                      width: 100,
                    ),
                    Container(
                      child: Link(
                          uri: Uri.parse(website),
                          builder: (context, followLink) => GestureDetector(
                              onTap: followLink,
                              child: Text(
                                website,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.blue[900]),
                              ))),
                      padding: const EdgeInsets.fromLTRB(10, 2, 0, 0),
                    ),
                    // Container(
                    //   child: Text(website,
                    //       style: TextStyle(
                    //           fontSize: 14,
                    //           color: Colors.white.withOpacity(0.6))),
                    //   padding: const EdgeInsets.fromLTRB(10, 2, 0, 0),
                    // ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      child: const Text('Exchange',
                          style: TextStyle(fontSize: 14)),
                      padding: const EdgeInsets.fromLTRB(5, 5, 20, 0),
                      width: 100,
                    ),
                    Container(
                      child: Text(exchange,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6))),
                      padding: const EdgeInsets.fromLTRB(10, 2, 0, 0),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      child: const Text('Market Cap',
                          style: TextStyle(fontSize: 14)),
                      padding: const EdgeInsets.fromLTRB(5, 5, 20, 0),
                      width: 100,
                    ),
                    Container(
                      child: Text(market_cap.toString(),
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6))),
                      padding: const EdgeInsets.fromLTRB(10, 2, 0, 0),
                    ),
                  ],
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            margin: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          ),
        ],
      ),
      color: Colors.black,
    );
  }
}

// Stateful Widget to represent the stock profile page of the application
class FavoriteStockButton extends StatefulWidget {
  const FavoriteStockButton({Key? key, required this.query}) : super(key: key);

  final String query;

  @override
  State<FavoriteStockButton> createState() => _FavoriteStockButtonState();
}

class _FavoriteStockButtonState extends State<FavoriteStockButton> {
  @override
  Widget build(BuildContext context) {
    return StarButton(
      isStarred: foundCompanies.contains(widget.query) ? true : false,
      iconSize: 40,
      valueChanged: (_isStarred) {
        if (_isStarred) {
          streamController.add('a${widget.query}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${widget.query} was added to watchlist'),
            duration: const Duration(seconds: 2),
          ));
        } else {
          streamController.add('r${widget.query}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${widget.query} was removed from watchlist'),
            duration: const Duration(seconds: 2),
          ));
        }
      },
    );
  }
}
