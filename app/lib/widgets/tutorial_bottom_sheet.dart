import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class TutorialBottomSheet extends StatefulWidget {
  const TutorialBottomSheet({super.key});

  @override
  _TutorialBottomSheetState createState() => _TutorialBottomSheetState();
}

class _TutorialBottomSheetState extends State<TutorialBottomSheet> {
  final CarouselController _carouselController = CarouselController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> shareLinkDirectly = [
    {
      'text': "Find the share button on the page you're browsing",
      'image': 'assets/tutorial/slide1.png',
    },
    {
      'text': 'Tap on the Clarify app from the share menu',
      'image': 'assets/tutorial/slide2.png',
    },
    {
      'text': 'See the clarified result',
      'image': 'assets/tutorial/slide3.png',
    },
  ];

  final List<Map<String, String>> shareYoutubeLinkDirectly = [
    {
      'text':
          'Tap on the three dots udnerneath the video you want to clarify and tap on the share button',
      'image': 'assets/tutorial/slide4.png',
    },
    {
      'text': 'Select more to open the native sharing menu',
      'image': 'assets/tutorial/slide5.png',
    },
    {
      'text': 'Tap on the Clarify app from the share menu',
      'image': 'assets/tutorial/slide6.png',
    },
    {
      'text': 'See the clarified result of the video',
      'image': 'assets/tutorial/slide7.png',
    },
  ];

  final List<Map<String, String>> shareShareInApp = [
    {
      'text': 'Copy a link/url to your clipboard',
      'image': 'assets/tutorial/slide8.jpg',
    },
    {
      'text': 'Tap on the link analysis button inside the Clarify app',
      'image': 'assets/tutorial/slide9.jpg',
    },
    {
      'text': 'See the clarified result',
      'image': 'assets/tutorial/slide10.jpg',
    },
  ];

  int _currentSlideIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Learn the different ways to use Clarify',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _buildCarouselSection(
                          'Sharing a link directly to Clarify',
                          shareLinkDirectly),
                      _buildCarouselSection(
                          'Sharing a YouTube Link directly to Clarify',
                          shareYoutubeLinkDirectly),
                      _buildCarouselSection(
                          'Pasting a link into the Clarify App',
                          shareShareInApp),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselSection(String title, List<Map<String, String>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 450.0,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            autoPlay: false,
            onPageChanged: (carouselIndex, reason) {
              setState(() {
                _currentSlideIndex = carouselIndex;
              });
            },
          ),
          items: data.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Column(
                  children: [
                    Text(
                      item['text']!,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Image.asset(
                        item['image']!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: data.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _carouselController.animateToPage(entry.key),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentSlideIndex == entry.key
                      ? Colors.deepPurple
                      : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
