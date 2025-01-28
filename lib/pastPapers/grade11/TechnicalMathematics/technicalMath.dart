import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reslocate/widgets/loadingAnimation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TechnicalMathsGrade11Page extends StatefulWidget {
  const TechnicalMathsGrade11Page({super.key});

  @override
  _TechnicalMathsGrade11PageState createState() =>
      _TechnicalMathsGrade11PageState();
}

class _TechnicalMathsGrade11PageState extends State<TechnicalMathsGrade11Page> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<FileObject> pdfFiles = [];

  @override
  void initState() {
    super.initState();
    _fetchPDFFiles();
  }

  Future<void> _fetchPDFFiles() async {
    try {
      final List<FileObject> objects = await supabase.storage
          .from('pdfs')
          .list(path: 'grade_11/TechnicalMathematics');

      setState(() {
        pdfFiles = objects.where((file) => file.name.endsWith('.pdf')).toList();
      });
    } catch (e) {
      print('Error fetching files: $e');
    }
  }

  Future<File?> _downloadPDF(String fileName) async {
    try {
      final String path = 'grade_11/TechnicalMathematics/$fileName';
      final response = await supabase.storage.from('pdfs').download(path);

      if (response.isNotEmpty) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response);
        return file;
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
    return null;
  }

  void _openPDF(String fileName) async {
    final File? file = await _downloadPDF(fileName);
    if (file != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewPage(file: file),
        ),
      );
    } else {
      print('Failed to open PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group PDFs by their subject and sort within each group
    final Map<String, List<FileObject>> groupedFiles = {};
    for (var file in pdfFiles) {
      final name = file.name;
      final subject = name.contains('P1')
          ? 'Paper 1'
          : name.contains('P2')
              ? 'Paper 2'
              : 'All Papers';

      if (!groupedFiles.containsKey(subject)) {
        groupedFiles[subject] = [];
      }
      groupedFiles[subject]!.add(file);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/reslocate_logo.svg',
              height: 50,
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Technical',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  Text(
                    'Mathematics',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            height: 1.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF00E4BA)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: pdfFiles.isEmpty
          ? const Center(child: BouncingImageLoader())
          : ListView(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              children: groupedFiles.entries.map((entry) {
                final subject = entry.key;
                final files = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        subject,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    ),
                    ...files.map((file) {
                      return GestureDetector(
                        onTap: () => _openPDF(file.name),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                          color: const Color(0xFFE3F2FA),
                          child: ListTile(
                            leading: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.black,
                              size: 40,
                            ),
                            title: Text(
                              file.name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
    );
  }
}

class PDFViewPage extends StatefulWidget {
  final File file;

  const PDFViewPage({super.key, required this.file});

  @override
  _PDFViewPageState createState() => _PDFViewPageState();
}

class _PDFViewPageState extends State<PDFViewPage> {
  bool _isReady = false;
  int _totalPages = 0;
  int _currentPage = 0;
  late PDFViewController _pdfViewController;
  bool _isFullScreen = false;
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale + 0.1).clamp(1.0, 3.0);
      _transformationController.value = Matrix4.identity()
        ..scale(_currentScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale - 0.1).clamp(1.0, 3.0);
      _transformationController.value = Matrix4.identity()
        ..scale(_currentScale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: _isFullScreen ? 0 : 100,
        leading: _isFullScreen
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
        title: !_isFullScreen
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/reslocate_logo.svg',
                    height: 50,
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PDF Viewer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        Text(
                          'Technical Mathematics',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : null,
        bottom: !_isFullScreen
            ? PreferredSize(
                preferredSize: const Size.fromHeight(1.5),
                child: Container(
                  height: 1.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF00E4BA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 1.0,
            maxScale: 3.0,
            child: PDFView(
              filePath: widget.file.path,
              autoSpacing: true,
              enableSwipe: true,
              swipeHorizontal: true,
              nightMode: true,
              onRender: (pages) {
                setState(() {
                  _totalPages = pages!;
                  _isReady = true;
                });
              },
              onViewCreated: (controller) {
                setState(() {
                  _pdfViewController = controller;
                });
              },
              onPageChanged: (page, total) {
                setState(() {
                  _currentPage = page!;
                });
              },
              onError: (error) {
                print(error.toString());
              },
            ),
          ),
          if (!_isReady)
            const Center(
              child: BouncingImageLoader(),
            ),
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      if (_currentPage > 0) {
                        _pdfViewController.setPage(_currentPage - 1);
                      }
                    },
                  ),
                  Text(
                    'Page ${_currentPage + 1} / $_totalPages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white),
                    onPressed: () {
                      if (_currentPage < _totalPages - 1) {
                        _pdfViewController.setPage(_currentPage + 1);
                      }
                    },
                  ),
                  // Zoom In Button
                  IconButton(
                    icon: const Icon(Icons.zoom_in, color: Colors.white),
                    onPressed: _zoomIn,
                  ),
                  // Zoom Out Button
                  IconButton(
                    icon: const Icon(Icons.zoom_out, color: Colors.white),
                    onPressed: _zoomOut,
                  ),
                  // Full Screen Button
                  IconButton(
                    icon: Icon(
                      _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFullScreen = !_isFullScreen;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
