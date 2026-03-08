import 'package:flutter/material.dart';
import 'bookingform_page.dart';


class StaycationDetailsPage extends StatelessWidget {
  const StaycationDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const offWhite = Color(0xffF5F5F5);

    return Scaffold(
      backgroundColor: offWhite,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Staycation Details",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

                /// ===============================
                /// TOP SECTION (HEADER IMAGE + DETAILS)
                /// ===============================
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// HEADER IMAGE
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                     child: Image.asset(
                      "assets/images/stay.jpg",
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// DETAILS TEXT
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [

                          Text(
                            "Enjoy a relaxing staycation experience",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: 15),

                          Text(
                            "Escape the busy city life and enjoy comfort, privacy, and luxury at Casa Suzanna.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),


              const SizedBox(height: 20),

              /// ===============================
              /// SCROLLABLE IMAGES
              /// ===============================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Gallery",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  TravelCard(image: "assets/images/bathroom.jpg"),
                  TravelCard(image: "assets/images/balconnyy.jpg"),
                  TravelCard(image: "assets/images/balcony.jpg"),
                ],
              ),
            ),


              const SizedBox(height: 40),

              /// ===============================
              /// FOOTER (BLACK + BOOK NOW)
              /// ===============================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(35),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [

                    const Text(
                      "Ready to book your stay?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Inside your ElevatedButton
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookingFormPage(), // <-- navigate here
                            ),
                          );
                        },
                        child: const Text(
                          "BOOK NOW",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// IMAGE CARD
/// ===============================
class TravelCard extends StatelessWidget {
  final String image;

  const TravelCard({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

