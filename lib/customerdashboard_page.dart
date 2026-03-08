import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDashboardPage extends StatelessWidget {
  const CustomerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // If somehow user is null
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("User not logged in"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
      appBar: AppBar(
        title: const Text("Customer Portal"),
        backgroundColor: Colors.green,
        actions: [

          /// 🔐 RESET PASSWORD
          IconButton(
            icon: const Icon(Icons.lock_reset),
            onPressed: () async {
              await FirebaseAuth.instance
                  .sendPasswordResetEmail(email: user.email!);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password reset email sent."),
                ),
              );
            },
          ),

          /// 🚪 LOGOUT
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),

      /// 🔥 BOOKINGS STREAM
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("bookings")
            .where("userId", isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {

          /// Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// Error State
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          /// No Data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No bookings found."),
            );
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {

              final booking = bookings[index];
              final data = booking.data() as Map<String, dynamic>;

              final String status = data["status"] ?? "Pending";
              final String paymentStatus = data["paymentStatus"] ?? "Unpaid";

              // Safe price conversion
              double price = 0;
              if (data["price"] != null) {
                if (data["price"] is int) {
                  price = (data["price"] as int).toDouble();
                } else if (data["price"] is double) {
                  price = data["price"];
                }
              }

              final double downPayment = price * 0.5;

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Package Name
                      Text(
                        data["package"] ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text("Status: $status"),
                      Text("Price: ₱${price.toStringAsFixed(0)}"),
                      Text("Payment: $paymentStatus"),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          /// ❌ CANCEL BUTTON (Only if Pending)
                          if (status == "Pending")
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {

                                await FirebaseFirestore.instance
                                    .collection("bookings")
                                    .doc(booking.id)
                                    .update({
                                  "status": "Cancelled",
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Booking Cancelled"),
                                  ),
                                );
                              },
                              child: const Text("Cancel"),
                            ),

                          const SizedBox(width: 10),

                          /// 💰 PAY 50% (Only if Approved & Unpaid)
                          if (status == "Approved" &&
                              paymentStatus == "Unpaid")
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {

                                await FirebaseFirestore.instance
                                    .collection("bookings")
                                    .doc(booking.id)
                                    .update({
                                  "paymentStatus": "Downpayment Paid",
                                  "paidAmount": downPayment,
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "50% Payment (₱${downPayment.toStringAsFixed(0)}) Recorded",
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Pay 50% (₱${downPayment.toStringAsFixed(0)})",
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
