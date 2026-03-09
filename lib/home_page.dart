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

  int dayDurationHours = 12;

  bool isChecking = false;
  bool showPackage = false;

  String availabilityMessage = "";
  String durationText = "";
  String totalAmountText = "";

  /// PACKAGE DATA
  final Map<int, Map<String, String>> packages = {
    1: {
      "name": "Staycation",
      "price": "10000",
      "image": "assets/images/stay.jpg"
    },
    2: {
      "name": "Premium",
      "price": "20000",
      "image": "assets/images/hero.jpg"
    },
    3: {
      "name": "Party Venue",
      "price": "13000",
      "image": "assets/images/partyy.jpg"
    }
  };

  /// PACKAGE CAPACITY
  final Map<int, int> packageCapacity = {
    1: 25,
    2: 50,
    3: 50,
  };

  String getPackageName(int? id) {
    return packages[id]?["name"] ?? "";
  }

  /// RESET FORM
  void resetForm() {
    checkIn = null;
    checkOut = null;
    durationText = "";
    availabilityMessage = "";
    totalAmountText = "";
    showPackage = false;
  }

  /// DATE PICKER
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
        if (!overnight) {
          checkOut = date;
        }
      } else {
        checkOut = date;
      }

      showPackage = false;
      availabilityMessage = "";
      durationText = "";
      totalAmountText = "";
    });
  }

  /// CALCULATE DURATION
  int calculateDays() {
    if (!overnight) return 1;
    if (checkIn == null || checkOut == null) return 1;

    int days = checkOut!.difference(checkIn!).inDays;
    if (days == 0) days = 1;
    return days;
  }

  void calculateDuration() {
    if (checkIn == null) return;

    if (!overnight) {
      durationText = "Duration: $dayDurationHours Hours";
    } else {
      int days = calculateDays();
      int hours = days * 24;
      durationText = "Duration: $days Day(s) ($hours hrs)";
    }
  }

  /// CALCULATE TOTAL AMOUNT
  void calculateTotalAmount() {
    if (selectedPackage == null) return;

    int packagePrice = int.parse(packages[selectedPackage]!["price"]!);

    int days = 1;

    if (!overnight) {
      // 12hrs or 24hrs per day
      if (dayDurationHours == 12) {
        totalAmountText = "Total Amount: ₱${(packagePrice / 2).toInt()}";
        return;
      } else {
        totalAmountText = "Total Amount: ₱$packagePrice";
        return;
      }
    } else {
      // Overnight / per day booking
      days = calculateDays();
      int total = packagePrice * days;
      totalAmountText = "Total Amount: ₱$total";
    }
  }

  /// CHECK AVAILABILITY
  Future<void> checkAvailability() async {
    if (selectedPackage == null || checkIn == null || checkOut == null) {
      setState(() {
        availabilityMessage = "Please select package and dates.";
        showPackage = false;
        totalAmountText = "";
      });
      return;
    }

    calculateDuration();
    calculateTotalAmount();

    setState(() {
      isChecking = true;
      availabilityMessage = "";
      showPackage = false;
    });

    try {
      String packageName = getPackageName(selectedPackage);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('package', isEqualTo: packageName)
          .where('status', isEqualTo: 'Approved')
          .get();

      bool available = true;

      for (var doc in snapshot.docs) {
        DateTime bookedStart = (doc['startDate'] as Timestamp).toDate();
        DateTime bookedEnd = (doc['endDate'] as Timestamp).toDate();

        bool overlap =
            checkIn!.isBefore(bookedEnd) && checkOut!.isAfter(bookedStart);

        if (overlap) {
          available = false;
          break;
        }
      }

      setState(() {
        if (available) {
          availabilityMessage = "✅ Package Available!";
          showPackage = true;
        } else {
          availabilityMessage = "❌ Package Not Available";
          showPackage = false;
          totalAmountText = "";
        }
      });
    } catch (e) {
      setState(() {
        availabilityMessage = "Error checking availability";
        totalAmountText = "";
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
                  MaterialPageRoute(builder: (context) => const LoginCustomerPage()),
                );
              },
              child: const Text(
                "Login Customer",
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
            const SizedBox(height: 20),
            if (durationText.isNotEmpty)
              Text(
                durationText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 10),
            if (availabilityMessage.isNotEmpty)
              Text(
                availabilityMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 10),
            if (totalAmountText.isNotEmpty)
              Text(
                totalAmountText,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            const SizedBox(height: 30),
            if (showPackage && selectedPackage != null) _packageResultCard()
          ],
        ),
      ),
    );
  }

  /// SEARCH FORM
  Widget _searchCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _tab('For a Couple of Days', overnight, () {
                setState(() {
                  overnight = true;
                  resetForm();
                });
              }),
              const SizedBox(width: 10),
              _tab('For a Day', !overnight, () {
                setState(() {
                  overnight = false;
                  resetForm();
                });
              }),
            ],
          ),
          const SizedBox(height: 15),
          if (!overnight)
            DropdownButtonFormField<int>(
              value: dayDurationHours,
              decoration: const InputDecoration(labelText: "Select Duration"),
              items: const [
                DropdownMenuItem(value: 12, child: Text("12 Hours")),
                DropdownMenuItem(value: 24, child: Text("24 Hours")),
              ],
              onChanged: (val) {
                setState(() {
                  dayDurationHours = val!;
                  resetForm();
                });
              },
            ),
          const SizedBox(height: 15),
          DropdownButtonFormField<int>(
            value: selectedPackage,
            hint: const Text('Select Package'),
            items: const [
              DropdownMenuItem(value: 1, child: Text("Staycation")),
              DropdownMenuItem(value: 2, child: Text("Premium")),
              DropdownMenuItem(value: 3, child: Text("Party Venue")),
            ],
            onChanged: (val) {
              setState(() {
                selectedPackage = val;
                resetForm();
              });
            },
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _dateField("Check In", checkIn, () => pickDate(true))),
              const SizedBox(width: 15),
              Expanded(child: _dateField("Check Out", checkOut, overnight ? () => pickDate(false) : null)),
            ],
          ),
          const SizedBox(height: 15),
          if (selectedPackage != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "PAX: ${packageCapacity[selectedPackage]!}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: checkAvailability,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: isChecking
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("CHECK AVAILABILITY", style: TextStyle(fontSize: 18)),
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
        child: Text(value == null ? "Select Date" : DateFormat('yyyy-MM-dd').format(value)),
      ),
    );
  }

  Widget _packageResultCard() {
    var data = packages[selectedPackage]!;

    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          Image.asset(data["image"]!, height: 180, fit: BoxFit.cover),
          const SizedBox(height: 10),
          Text(data["name"]!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("₱${data["price"]!}", style: const TextStyle(fontSize: 18, color: Colors.green)),
          const SizedBox(height: 10),
          Text("PAX: ${packageCapacity[selectedPackage]!}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            onPressed: () {
              if (selectedPackage == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StaycationDetailsPage()));
              }
              if (selectedPackage == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumDetailsPage()));
              }
              if (selectedPackage == 3) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyDetailsPage()));
              }
            },
            child: const Text("View Details"),
          )
        ],
      ),
    );
  }
}