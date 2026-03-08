import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'logincustomer.dart';

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({super.key});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedPackage;
  String? selectedDuration;
  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = false;

  final String defaultPassword = "customer123";

  final List<String> packages = ["Staycation", "Premium", "Party Venue"];
  final Map<String, int> durations = {
    "24hrs": 24,
    "12hrs": 12,
    "5hrs": 5,
  };

  /// Submit Booking
  Future<void> submitBooking() async {
    if (!_formKey.currentState!.validate() ||
        startDate == null ||
        selectedPackage == null ||
        selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: defaultPassword,
      );

      final user = userCredential.user;
      if (user == null) throw Exception("User creation failed");

      endDate = startDate!
          .add(Duration(hours: durations[selectedDuration]!));

      final fullName =
          "${firstNameController.text.trim()} ${lastNameController.text.trim()}";

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "name": fullName,
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "role": "customer",
        "createdAt": FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection("bookings").add({
        "userId": user.uid,
        "name": fullName,
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "package": selectedPackage,
        "duration": selectedDuration,
        "startDate": Timestamp.fromDate(startDate!),
        "endDate": Timestamp.fromDate(endDate!),
        "status": "Pending",
        "paymentStatus": "Unpaid",
        "createdAt": FieldValue.serverTimestamp(),
      });

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Account Created"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Your account has been created."),
              const SizedBox(height: 10),
              Text(
                "Default Password: $defaultPassword",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 10),
              const Text("You can change it in Customer Portal."),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );

      await FirebaseAuth.instance.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginCustomerPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Auth Error")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Pick Start Date
  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;

        if (selectedDuration != null) {
          endDate =
              startDate!.add(Duration(hours: durations[selectedDuration]!));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
      appBar: AppBar(
        title: const Text("Book Now"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "Reservation Form",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),

                  // First Name
                  TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: "First Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter first name" : null,
                  ),
                  const SizedBox(height: 15),

                  // Last Name
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: "Last Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter last name" : null,
                  ),
                  const SizedBox(height: 15),

                  // Email
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email (Username)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter email" : null,
                  ),
                  const SizedBox(height: 15),

                  // Phone
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter phone number" : null,
                  ),
                  const SizedBox(height: 15),

                  // Package
                  DropdownButtonFormField<String>(
                    value: selectedPackage,
                    items: packages
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedPackage = val),
                    decoration: const InputDecoration(
                      labelText: "Select Package",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Duration
                  DropdownButtonFormField<String>(
                    value: selectedDuration,
                    items: durations.keys
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedDuration = val;
                        if (startDate != null) {
                          endDate = startDate!
                              .add(Duration(hours: durations[val]!));
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Select Duration",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Start Date
                  GestureDetector(
                    onTap: pickStartDate,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: double.infinity,
                      child: Text(
                        startDate == null
                            ? "Select Start Date"
                            : DateFormat('yyyy-MM-dd').format(startDate!),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (endDate != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "End Date: ${DateFormat('yyyy-MM-dd HH:mm').format(endDate!)}",
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : submitBooking,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text("Submit Booking"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
