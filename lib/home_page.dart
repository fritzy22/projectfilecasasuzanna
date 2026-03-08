import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'styles.dart';
import 'staycation_details_page.dart';
import 'premium_details_page.dart';
import 'party_details_page.dart';
import 'logincustomer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool overnight = true;
  int? selectedPackage;

  DateTime? checkIn;
  DateTime? checkOut;

  int adults = 1;
  int children = 0;

  final TextEditingController childAgeController = TextEditingController();

  bool isChecking = false;
  String availabilityMessage = "";

  /// Convert package ID to Firebase package name
  String getPackageName(int? id) {
    switch (id) {
      case 1:
        return "Staycation";
      case 2:
        return "Premium";
      case 3:
        return "Party Venue";
      default:
        return "";
    }
  }

  Future<void> pickDate(bool isCheckIn) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (date == null) return;

    setState(() {
      if (isCheckIn) {
        checkIn = date;
        if (!overnight) checkOut = date;
      } else {
        checkOut = date;
      }
    });
  }

  /// CHECK AVAILABILITY FROM FIREBASE
  Future<void> checkAvailability() async {
    if (selectedPackage == null || checkIn == null || checkOut == null) {
      setState(() {
        availabilityMessage = "Please select package and dates.";
      });
      return;
    }

    setState(() {
      isChecking = true;
      availabilityMessage = "";
    });

    try {
      String packageName = getPackageName(selectedPackage);

      DateTime start = checkIn!;
      DateTime end = checkOut!;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('package', isEqualTo: packageName)
          .where('status', isEqualTo: 'Approved')
          .get();

      bool available = true;
      DateTime? nextAvailable;

      for (var doc in snapshot.docs) {
        DateTime bookedStart =
            (doc['startDate'] as Timestamp).toDate();

        DateTime bookedEnd =
            (doc['endDate'] as Timestamp).toDate();

        /// Prevent double booking
        bool overlap =
            start.isBefore(bookedEnd) && end.isAfter(bookedStart);

        if (overlap) {
          available = false;
          nextAvailable = bookedEnd;
          break;
        }
      }

      setState(() {
        if (available) {
          availabilityMessage = "✅ Package is AVAILABLE";
        } else {
          availabilityMessage =
              "❌ Package NOT AVAILABLE\nNext available: ${DateFormat('MMM dd yyyy').format(nextAvailable!)}";
        }
      });
    } catch (e) {
      setState(() {
        availabilityMessage = "Error checking availability";
      });
    }

    setState(() {
      isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text('CASA SUZANNA', style: AppText.logo),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginCustomerPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.grayDark,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Login Customer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _searchCard(),
            const SizedBox(height: 40),
            const Text(
              'CHOOSE WHAT PACKAGE TO AVAIL',
              style: AppText.sectionTitle,
            ),
            const SizedBox(height: 30),
            _packagesRow(),
          ],
        ),
      ),
    );
  }

  Widget _searchCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _tab('Overnight', overnight, () {
                setState(() => overnight = true);
              }),
              const SizedBox(width: 10),
              _tab('Day Use', !overnight, () {
                setState(() {
                  overnight = false;
                  checkOut = checkIn;
                });
              }),
            ],
          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<int>(
            initialValue: selectedPackage,
            hint: const Text('Select a Package'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Staycation')),
              DropdownMenuItem(value: 2, child: Text('Premium')),
              DropdownMenuItem(value: 3, child: Text('Party Venue')),
            ],
            onChanged: (val) {
              setState(() {
                selectedPackage = val;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _dateField('Check-in', checkIn, () => pickDate(true)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _dateField(
                  'Check-out',
                  checkOut,
                  overnight ? () => pickDate(false) : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: "1",
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Adults"),
                  onChanged: (val) {
                    adults = int.tryParse(val) ?? 1;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: "0",
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Children"),
                  onChanged: (val) {
                    setState(() {
                      children = int.tryParse(val) ?? 0;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (children > 0)
            TextField(
              controller: childAgeController,
              decoration: const InputDecoration(
                labelText: "Child Age",
                hintText: "Example: 5,8",
              ),
            ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: checkAvailability,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              minimumSize: const Size(double.infinity, 50),
              shape: const StadiumBorder(),
            ),
            child: isChecking
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'CHECK AVAILABILITY',
                    style: TextStyle(fontSize: 18),
                  ),
          ),

          const SizedBox(height: 15),

          Text(
            availabilityMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String text, bool active, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? AppColors.blue : Colors.transparent,
        side: const BorderSide(color: AppColors.blue),
        shape: const StadiumBorder(),
      ),
      child: Text(
        text,
        style: TextStyle(color: active ? Colors.white : AppColors.blue),
      ),
    );
  }

  Widget _dateField(String label, DateTime? value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          value == null
              ? 'Select date'
              : DateFormat('yyyy-MM-dd').format(value),
        ),
      ),
    );
  }

  Widget _packagesRow() {
    return SizedBox(
      height: 360,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _packageCard(1, 'Staycation', 'assets/images/stay.jpg', '₱10,000'),
          const SizedBox(width: 20),
          _packageCard(2, 'Premium', 'assets/images/hero.jpg', '₱20,000',
              featured: true),
          const SizedBox(width: 20),
          _packageCard(3, 'Party Venue', 'assets/images/partyy.jpg', '₱13,000'),
        ],
      ),
    );
  }

  Widget _packageCard(
    int id,
    String title,
    String img,
    String price, {
    bool featured = false,
  }) {
    if (selectedPackage != null && selectedPackage != id) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.packageCard(featured: featured),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          Image.asset(img, height: 150, fit: BoxFit.cover),
          const SizedBox(height: 10),
          Text(price, style: AppText.price),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              shape: const StadiumBorder(),
            ),
            onPressed: () {
              if (id == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StaycationDetailsPage(),
                  ),
                );
              } else if (id == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PremiumDetailsPage(),
                  ),
                );
              } else if (id == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PartyDetailsPage(),
                  ),
                );
              }
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }
}