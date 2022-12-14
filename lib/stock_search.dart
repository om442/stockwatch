import 'package:flutter/material.dart';
import 'company_names.dart';
import 'stock_profile_pg.dart';

class StockSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (query.isEmpty) {
              close(context, "");
            } else {
              query = "";
              showSuggestions(context);
            }
          },
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ""),
      );

  @override
  Widget buildResults(BuildContext context) => Container(
      color: Colors.black,
      child: FutureBuilder<List<Result>>(
          future: fetchCompanyNames(query: query),
          builder: (context, snapshot) {
            if (query.isEmpty) return buildNoSuggestions();

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return buildNoSuggestions();
                } else {
                  return buildSuggestionSuccess(
                      snapshot.data!); // Build SUggestion Success
                }
            }
          }));

  @override
  Widget buildSuggestions(BuildContext context) => Container(
      color: Colors.black,
      child: FutureBuilder<List<Result>>(
          future: fetchCompanyNames(query: query),
          builder: (context, snapshot) {
            if (query.isEmpty) return buildNoSuggestions();

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return buildNoSuggestions();
                } else {
                  return buildSuggestionSuccess(
                      snapshot.data!); // Build SUggestion Success
                }
            }
          }));

  Widget buildNoSuggestions() => const Center(
        child: Text(
          'No suggestions!',
          style: TextStyle(fontSize: 28, color: Colors.white),
        ),
      );

  Widget buildSuggestionSuccess(List<Result> suggestions) => ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          final displaySymbol = suggestion.displaySymbol;
          final description = suggestion.description;

          return ListTile(
            onTap: () {
              query = suggestion.symbol;
              // showResults(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return StockProfilePage(
                  query: query,
                );
              }));
            },
            title: Text(
              "$displaySymbol | $description",
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
}
