import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'company_names.dart';
import 'company_profile.dart';
import 'stock_search.dart';
import 'stock_profile_pg.dart';

// https://finnhub.io/api/v1/stock/profile2?symbol=AAPL&token=c9gvchqad3iblo2foslg # Search for company details
// https://finnhub.io/api/v1/search?q=apple&token=c9gvchqad3iblo2foslg # Search for companies with query

StreamController<String> streamController = StreamController<String>();
List<String> foundCompanies = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Watch',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Stock', stream: streamController.stream),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Stateful Widget to represent the homepage of the application
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.stream})
      : super(key: key);

  final String title;
  final Stream<String> stream;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    widget.stream.listen((symbol) {
      mySetState(symbol);
    });
  }

  void mySetState(String symbol) {
    if (symbol[0] == 'a') {
      setState(() {
        favorites.add(symbol.substring(1));
        foundCompanies.add(symbol.substring(1));
      });
    } else {
      setState(() {
        favorites.remove(symbol.substring(1));
        foundCompanies.remove(symbol.substring(1));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                showSearch(context: context, delegate: StockSearch());
              },
              icon: const Icon(Icons.search),
            )
          ],
          backgroundColor: Colors.purple,
        ),
        body: Column(children: <Widget>[
          const HomeHeading(), // Heading components for homepage
          Expanded(
              child: Favorites(
            favoriteList: favorites,
          )), // Expanded list of favorites to fill rest of column
        ]));
  }
}

// Stateful Widget to present the heading of Stock Watch homepage
class HomeHeading extends StatefulWidget {
  const HomeHeading({Key? key}) : super(key: key);

  @override
  State<HomeHeading> createState() => _HomeHeadingState();
}

class _HomeHeadingState extends State<HomeHeading> {
  @override
  Widget build(BuildContext context) {
    String today = DateFormat("MMMMd").format(DateTime.now());

    // Make a column that contains 4 parts
    return Column(
      children: <Widget>[
        // Stock Watch
        Container(
          color: Colors.black,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.fromLTRB(0, 6, 12, 0),
          child: const Text(
            "STOCK WATCH",
            textScaleFactor: 2,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        // Date (MONDAY-DAY)
        Container(
          color: Colors.black,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.fromLTRB(0, 0, 12, 6),
          child: Text(
            today,
            textScaleFactor: 1.9,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        // Favorites
        Container(
          color: Colors.black,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
          child: const Text(
            "Favorites",
            textScaleFactor: 1.4,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// Stateful Widget to represent the List of Stocks on Favorite List
class Favorites extends StatefulWidget {
  const Favorites({Key? key, required this.favoriteList}) : super(key: key);

  final List<String> favoriteList;

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  @override
  Widget build(BuildContext context) {
    if (widget.favoriteList.isEmpty) {
      return buildUnsuccessful();
    } else {
      return Container(
        color: Colors.black,
        child: ListView.builder(
          itemCount: widget.favoriteList.length,
          itemBuilder: (context, index) {
            final item = widget.favoriteList[index];
            return Dismissible(
              background: Container(
                color: Colors.red,
                child: const Icon(Icons.restore_from_trash, size: 30),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              ),
              key: Key(item),
              direction: DismissDirection.endToStart,
              confirmDismiss: (DismissDirection dismissDirection) async {
                return await showAlertDialog(context, index, item);
              },
              child: FutureBuilder<CompanyInfo>(
                  future: fetchCompanyProfile(query: item),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Center(child: CircularProgressIndicator());
                      default:
                        return buildSuccessful(snapshot.data!);
                    }
                  }),
            );
          },
        ),
      );
    }
  }

  Future<bool>? showAlertDialog(BuildContext context, int index, String item) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );
    Widget deleteButton = TextButton(
      child: const Text("Delete"),
      onPressed: () {
        setState(() {
          widget.favoriteList.removeAt(index);
        });
        foundCompanies.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$item was removed from watchlist'),
          duration: const Duration(seconds: 2),
        ));
        Navigator.pop(context, true);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete Confirmation"),
      content: const Text("Are you sure you want to delete this item?"),
      actions: [
        deleteButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget buildSuccessful(CompanyInfo companyInfo) {
    final ticker = companyInfo.ticker;
    final name = companyInfo.name;

    return Column(children: [
      const Divider(
        color: Colors.white,
        thickness: 2,
        indent: 12,
        endIndent: 12,
      ),
      ListTile(
          title: Text('$ticker\n$name'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return StockProfilePage(
                query: ticker,
              );
            }));
          }),
    ]);
  }

  Widget buildUnsuccessful() => Container(
        child: Column(
          children: [
            const Divider(
              color: Colors.white,
              thickness: 2,
              indent: 12,
              endIndent: 12,
            ),
            Container(
              child: const Text(
                'Empty',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              padding: const EdgeInsets.all(10),
            )
          ],
        ),
        color: Colors.black,
        width: double.infinity,
      );
}
