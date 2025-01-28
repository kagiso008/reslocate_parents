import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reslocate/widgets/loadingAnimation.dart';
import 'dart:io';

class EnglishGrade10IEBPage extends StatefulWidget {
  const EnglishGrade10IEBPage({super.key});

  @override
  _EnglishGrade10IEBPageState createState() => _EnglishGrade10IEBPageState();
}

class _EnglishGrade10IEBPageState extends State<EnglishGrade10IEBPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<FileObject> pdfFiles = [];

  List<FileObject> hlFiles = [];
  List<FileObject> falFiles = [];
  List<FileObject> salFiles = [];

  @override
  void initState() {
    super.initState();
    _fetchPDFFiles();
  }

  Future<void> _fetchPDFFiles() async {
    try {
      final List<FileObject> objects = await supabase.storage
          .from('pdfs')
          .list(path: 'grade_10/IEB/English');

      setState(() {
        pdfFiles = objects.where((file) => file.name.endsWith('.pdf')).toList();

        hlFiles = pdfFiles
            .where((file) => file.name.toLowerCase().contains('hl'))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        falFiles = pdfFiles
            .where((file) => file.name.toLowerCase().contains('fal'))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        salFiles = pdfFiles
            .where((file) => file.name.toLowerCase().contains('sal'))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      });
    } catch (e) {
      print('Error fetching files: $e');
    }
  }

  Future<File?> _downloadPDF(String fileName) async {
    try {
      final String path = 'grade_10/IEB/English/$fileName';
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

  Widget _buildPDFList(List<FileObject> files, String categoryTitle) {
    if (files.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            categoryTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
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
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'English',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  Text(
                    'IEB',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildPDFList(hlFiles, 'Home Language'),
            _buildPDFList(falFiles, 'First Additional Language'),
            _buildPDFList(salFiles, 'Second Additional Language'),
          ],
        ),
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
                          'English',
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
                  IconButton(
                    icon: const Icon(Icons.zoom_in, color: Colors.white),
                    onPressed: _zoomIn,
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_out, color: Colors.white),
                    onPressed: _zoomOut,
                  ),
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
