import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';

class ImageViewer extends StatefulWidget {
  final List<String> imgUrls;

  const ImageViewer({Key? key, required this.imgUrls}) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page?.round() ?? 0; // Handle potential null value
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uniqueImgUrls = widget.imgUrls.toSet().toList(); // Remove duplicates

    return Scaffold(
      appBar: AppBar(title: const Text('Images')),
      body: Stack(
        children: [
          if (uniqueImgUrls.isEmpty)
            const Center(child: Text('No images found'))
          else
            PageView.builder(
              controller: _pageController,
              itemCount: uniqueImgUrls.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    uniqueImgUrls[index],
                    fit: BoxFit.contain,
                    height: 200.0,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                    },
                  ),
                );
              },
            ),
          if (uniqueImgUrls.isNotEmpty)
            Positioned(
              bottom: 16.0,
              left: 0,
              right: 0,
              child: DotsIndicator(
                dotsCount: uniqueImgUrls.length,
                position: currentPage.toDouble(),
                decorator: DotsDecorator(
                  size: const Size.square(8.0),
                  activeSize: const Size(20.0, 8.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
