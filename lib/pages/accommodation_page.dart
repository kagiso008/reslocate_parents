import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SVG images
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:convert';
import 'package:reslocate/pages/binterest_form_page.dart';

class AccommodationPage extends StatefulWidget {
  const AccommodationPage({super.key});

  @override
  _AccommodationPageState createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  List<dynamic> houseListings = [];
  bool isLoading = true;
  bool showAll = false; // This controls whether all accommodations are shown

  @override
  void initState() {
    super.initState();
    fetchAccommodations();
  }

  Future<void> fetchAccommodations() async {
    try {
      final SupabaseClient supabaseClient = Supabase.instance.client;

      final response = await supabaseClient
          .from('HouseListing')
          .select('name, location, amenities, price, image_url, description');

      // ignore: unnecessary_null_comparison
      if (response != null && response.isNotEmpty) {
        setState(() {
          houseListings = response;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("No data found or response is empty.");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show either all accommodations or only the first one depending on "showAll"
    final displayList =
        showAll ? houseListings : houseListings.take(1).toList();

    return Scaffold(
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STUDENT ACCOMMODATION',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'The students accommodation',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            height: 1.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF0D47A1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : houseListings.isEmpty
              ? const Center(child: Text('No accommodations found'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Title and logo section added here
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              children: [
                                // Logo (responsive size)

                                SizedBox(height: 10),
                                // Title
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            16.0), // Add padding as needed
                                    child: Text(
                                      'Discover your perfect ideal home away from home!',
                                      textAlign: TextAlign
                                          .center, // Center text alignment
                                      style: TextStyle(
                                        fontSize: 20, // Dynamic font size
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D47A1),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),

                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final house = displayList[index];
                              return buildSingleAccommodation(
                                  house, constraints);
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D47A1),
                                padding: EdgeInsets.symmetric(
                                  horizontal: constraints.maxWidth * 0.2,
                                  vertical: constraints.maxHeight * 0.02,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  showAll =
                                      !showAll; // Toggle between showing all or one
                                });
                              },
                              child: Text(showAll ? 'View Less' : 'View All'),
                            ),
                          ),
                          // Add the back arrow button at the bottom
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget buildSingleAccommodation(dynamic house, BoxConstraints constraints) {
    List<String> imageUrls = house['image_url'] != null
        ? List<String>.from(json.decode(house['image_url']))
        : [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageUrls.isNotEmpty
                  ? CarouselSlider(
                      options: CarouselOptions(
                        height: constraints.maxHeight *
                            0.3, // Prominent height for image slider
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false,
                        autoPlay: false,
                      ),
                      items: imageUrls.map((url) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenGallery(
                                  imageUrls: imageUrls,
                                  initialIndex: imageUrls.indexOf(url),
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : const Icon(Icons.home, size: 100),
              const SizedBox(height: 10),
              Text(
                house['name'] ?? 'Unknown Name',
                style: TextStyle(
                  fontSize: constraints.maxWidth * 0.05, // Dynamic font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                house['location'] ?? 'Unknown Location',
                style: TextStyle(
                  fontSize: constraints.maxWidth * 0.04, // Dynamic font size
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'R ${house['price'] ?? 'N/A'} pm',
                style: TextStyle(
                  fontSize: constraints.maxWidth * 0.045, // Dynamic font size
                  color: const Color(0xFF0D47A1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                house['description'] ?? 'No description available',
                style: TextStyle(
                  fontSize: constraints.maxWidth * 0.035, // Dynamic font size
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InterestFormPage(
                          house: house,
                          houseName: house['name'] ?? 'Unnamed House',
                          houseId: house['id'] ?? '0',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.2,
                      vertical: constraints.maxHeight * 0.02,
                    ),
                  ),
                  child: Text(
                    'Are You Interested?',
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenGallery extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenGallery(
      {super.key, required this.imageUrls, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the accommodation details
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: PhotoViewGallery.builder(
        itemCount: imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}
