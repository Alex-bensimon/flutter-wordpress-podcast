import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Comic {
  final String title;
  final String pdfPath;

  Comic({required this.title, required this.pdfPath});

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      title: json['title'] as String,
      pdfPath: json['pdf_path'] as String,
    );
  }
}

class ComicsScreen extends StatefulWidget {
  const ComicsScreen({Key? key}) : super(key: key);

  @override
  State<ComicsScreen> createState() => _ComicsScreenState();
}

class _ComicsScreenState extends State<ComicsScreen> {
  List<Comic> comics = [];

  @override
  void initState() {
    super.initState();
    loadComics();
  }

  Future<void> loadComics() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/bd.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    setState(() {
      comics = jsonList
          .map((json) => Comic.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  void _openPdf(BuildContext context, Comic comic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(comic.title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SfPdfViewer.asset(
            comic.pdfPath,
            pageLayoutMode: PdfPageLayoutMode.single,
            scrollDirection: PdfScrollDirection.horizontal,
            enableDoubleTapZooming: true,
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              print('Error loading PDF: ${details.error}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading PDF: ${details.error}')),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('BD'),
      ),
      body: comics.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: comics.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(comics[index].title),
                    onTap: () => _openPdf(context, comics[index]),
                  ),
                );
              },
            ),
    );
  }
}
