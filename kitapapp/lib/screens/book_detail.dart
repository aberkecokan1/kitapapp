import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kitapapp/models/redux_model.dart';
import 'package:kitapapp/services/repository.dart';
import 'package:kitapapp/services/services_imp/repo_services_impl.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BookDetailScreen extends StatefulWidget {
  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  List<Map<String, dynamic>> villainDetails = [];
  bool isLoading = false;
  String errorMessage = '';
  IBookRepository bookRepository = BookRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVillainData();
    });
  }

  Future<void> _loadVillainData() async {
    final state = StoreProvider.of<ReduxModel>(context).state;
    final books = state.apiModel.books ?? [];
    final index = state.apiModel.index ?? 0;

    if (books.isNotEmpty && index < books.length) {
      final book = books[index];

      final List<dynamic> villains;
      if (book['villains'] is List) {
        villains = book['villains'] as List<dynamic>;
      } else {
        villains = <dynamic>[];
      }

      final fetchedVillains = await bookRepository.fetchVillainDetails(villains);

      setState(() {
        villainDetails = fetchedVillains;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<ReduxModel, ReduxModel>(
      builder: (context, state) {
        var books = state.apiModel.books ?? [];
        var index = state.apiModel.index ?? 0;

        if (books.isEmpty || index >= books.length) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text("Kitap bilgisi bulunamadı")),
          );
        }

        var book = books[index];

        return Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['Title'].toString(),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  // Kitap bilgileri
                  infoRow("${AppLocalizations.of(context)?.id}", book['id']),
                  infoRow("${AppLocalizations.of(context)?.bookYear}", book['Year']),
                  infoRow("${AppLocalizations.of(context)?.publisher}", book['Publisher']),
                  infoRow("ISBN", book['ISBN']),
                  infoRow("${AppLocalizations.of(context)?.pages}", book['Pages']),
                  if (book['Notes'] != null)
                    infoRow("${AppLocalizations.of(context)?.notes}", book['Notes'].toString()),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${AppLocalizations.of(context)?.villains}",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (isLoading)
                        SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  SizedBox(height: 10),

                  if (errorMessage.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.red.shade100,
                      child: Text(errorMessage, style: TextStyle(color: Colors.red)),
                    ),

                  if (!isLoading && villainDetails.isEmpty)
                    Center(
                      child: CircularProgressIndicator(),
                    ),

                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: villainDetails.length,
                    itemBuilder: (context, index) {
                      var villain = villainDetails[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                villain['name'].toString(),
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${AppLocalizations.of(context)?.status}: ${villain['status'] ?? 'Unknown'}",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${AppLocalizations.of(context)?.gender}: ${villain['gender'] ?? 'Unknown'}",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              if (villain['notes'] != null &&
                                  villain['notes'].toString().isNotEmpty)
                                ExpansionTile(
                                  title: Text("${AppLocalizations.of(context)?.notes}"),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: List<Widget>.from(villain['notes']
                                            .toString()
                                            .split(',')
                                            .map((note) => Chip(
                                                  label: Text(note),
                                                  backgroundColor: Colors.blue.shade50,
                                                ))),
                                      ),
                                    )
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      converter: (store) => store.state,
    );
  }

  Widget infoRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? "Bilinmiyor",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
