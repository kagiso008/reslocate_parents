import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reslocate/pages/parent_pages/parent_homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:reslocate/pages/binterest_form_page.dart';
import 'dart:convert';
import 'package:reslocate/widgets/loadingAnimation.dart';

class ParentHousingListingsPage extends StatefulWidget {
  const ParentHousingListingsPage({super.key});

  @override
  State<ParentHousingListingsPage> createState() =>
      _ParentHousingListingsPageState();
}

class _ParentHousingListingsPageState extends State<ParentHousingListingsPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> houseListings = [];
  int _loadedItemsCount = 4;
  static const int _itemsPerPage = 4;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchHousings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    if (_loadedItemsCount < houseListings.length) {
      setState(() {
        _loadedItemsCount += _itemsPerPage;
      });
    }
  }

  Future<void> fetchHousings() async {
    try {
      final response = await _supabaseClient.from('HouseListing').select(
            'id, name, location, amenities, price, image_url, description',
          );

      setState(() {
        houseListings = List<Map<String, dynamic>>.from(response);
        isLoading = false;
        isError = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching housing listings: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: BouncingImageLoader())
          : isError
              ? const Center(
                  child: Text(
                    "Failed to load housing listings. Please try again later.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFF4444),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : houseListings.isEmpty
                  ? const Center(
                      child: Text(
                        "No housing listings available at the moment.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFF4444),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _buildListings(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 100,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ParentHomepage()),
          );
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
                'Student Housing',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              Text(
                'Housing Preferences',
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
              colors: [Color(0xFF0D47A1), Color(0xFF00E4BA)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListings(BuildContext context) {
    final visibleListings = houseListings.take(_loadedItemsCount).toList();

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: visibleListings.length,
            itemBuilder: (context, index) {
              final house = visibleListings[index];
              return buildSingleAccommodation(
                  house, MediaQuery.of(context).size.height);
            },
          ),
          if (_loadedItemsCount < houseListings.length)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 12,
                  ),
                ),
                onPressed: _loadMoreItems,
                child: const Text(
                  'View More',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSingleAccommodation(
      Map<String, dynamic> house, double maxHeight) {
    List<String> imageUrls = house['image_url'] != null
        ? List<String>.from(json.decode(house['image_url']))
        : [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        color: const Color(0xFFE3F2FA),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              imageUrls.isNotEmpty
                  ? CarouselSlider(
                      options: CarouselOptions(
                        height: maxHeight * 0.3,
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
                              placeholder: (context, url) =>
                                  const Center(child: BouncingImageLoader()),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : const Icon(Icons.home, size: 100),
              const SizedBox(height: 20),
              Text(
                house['name'] ?? 'Unknown Name',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                house['location'] ?? 'Unknown Location',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'R ${house['price'] ?? 'N/A'} pm',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF0D47A1),
                  fontWeight: FontWeight.bold,
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
                          houseId: house['id'].toString(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 1,
                    backgroundColor: const Color(0xFFE3F2FA),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    side: const BorderSide(color: Colors.black, width: 2),
                  ),
                  child: const Text(
                    'I\'m Interested!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
