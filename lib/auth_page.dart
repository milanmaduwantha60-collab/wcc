import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = "";
  bool _isDataLoading = true;

  // Default data - will be loaded from Firestore
  String schoolName = "Ku Wellawa Central College";
  String vision = "Empowering education through technology";
  String mission = "To provide efficient school management solutions";
  List<Map<String, String>> announcements = [];

  @override
  void initState() {
    super.initState();
    _loadDataFromFirestore();
    // Also listen for auth state changes to reload data
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        _loadDataFromFirestore();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Load data from Firestore
  Future<void> _loadDataFromFirestore() async {
    try {
      // Try to load from Firestore first
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('school_info')
          .doc('main')
          .get();

      if (mounted) {
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            schoolName = data['schoolName'] ?? schoolName;
            vision = data['vision'] ?? vision;
            mission = data['mission'] ?? mission;
            
            // Convert announcements safely
            if (data['announcements'] != null) {
              announcements = [];
              for (var item in (data['announcements'] as List)) {
                if (item is Map) {
                  announcements.add({
                    'title': item['title']?.toString() ?? '',
                    'link': item['link']?.toString() ?? '',
                  });
                }
              }
            }
            _isDataLoading = false;
          });
        } else {
          // If no document exists, set default announcements
          _setDefaultData();
        }
      }
    } catch (e) {
      print('Error loading from Firestore: $e');
      // If Firestore fails, use default data
      _setDefaultData();
    }
  }

  // Set default data when Firestore is not available or fails
  void _setDefaultData() {
    if (mounted) {
      setState(() {
        announcements = [
          {
            'title': 'Welcome to the new academic year!',
            'link': 'https://drive.google.com/file/d/example1'
          },
          {
            'title': 'Sports Day 2025 Registration Open',
            'link': 'https://drive.google.com/file/d/example2'
          },
          {
            'title': 'Parent-Teacher Conference Schedule',
            'link': 'https://drive.google.com/file/d/example3'
          },
        ];
        _isDataLoading = false;
      });
    }
  }

  // Function to open URL
  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    
    try {
      // Ensure the URL has a protocol
      String finalUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        finalUrl = 'https://$url';
      }
      
      final Uri uri = Uri.parse(finalUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try to open in browser
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      print('Error opening URL: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() {
        _message = "Please enter both email and password";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = "";
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      setState(() {
        _message = "Login successful!";
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _message = "Login failed: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  void _navigateToDashboard() {
    // Dashboard can be accessed by anyone
    Navigator.pushNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF667eea),
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Left Side - Information Panel
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  'RC',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF667eea),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'SCHOOL MANAGEMENT\nSYSTEM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),

                        // Vision Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'VISION',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _isDataLoading
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      vision,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Mission Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'MISSION',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _isDataLoading
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      mission,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Announcements Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ANNOUNCEMENTS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _isDataLoading
                                  ? const CircularProgressIndicator()
                                  : announcements.isEmpty
                                      ? const Text(
                                          'No announcements yet',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : Column(
                                          children: announcements.map((announcement) {
                                            final title = announcement['title'] ?? '';
                                            final link = announcement['link'] ?? '';
                                            
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0),
                                              child: InkWell(
                                                onTap: link.isNotEmpty ? () => _openUrl(link) : null,
                                                child: Row(
                                                  children: [
                                                    if (link.isNotEmpty) ...[
                                                      const Icon(
                                                        Icons.link,
                                                        size: 16,
                                                        color: Colors.blue,
                                                      ),
                                                      const SizedBox(width: 5),
                                                    ],
                                                    Expanded(
                                                      child: Text(
                                                        title,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: link.isNotEmpty 
                                                              ? Colors.blue 
                                                              : Colors.black87,
                                                          decoration: link.isNotEmpty 
                                                              ? TextDecoration.underline 
                                                              : null,
                                                        ),
                                                      ),
                                                    ),
                                                    if (link.isNotEmpty)
                                                      const Icon(
                                                        Icons.open_in_new,
                                                        size: 14,
                                                        color: Colors.blue,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Dashboard Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _navigateToDashboard,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'DASHBOARD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Right Side - Login Panel
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // School Name
                        _isDataLoading
                            ? const CircularProgressIndicator()
                            : Text(
                                schoolName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667eea),
                                ),
                                textAlign: TextAlign.center,
                              ),
                        
                        const SizedBox(height: 40),

                        const Text(
                          'LOGIN TO YOUR ACCOUNT',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Email Field
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'USERNAME',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password Field
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'PASSWORD',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Error Message
                        if (_message.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _message.contains('failed') 
                                  ? Colors.red.shade100 
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _message,
                              style: TextStyle(
                                color: _message.contains('failed') 
                                    ? Colors.red.shade800 
                                    : Colors.green.shade800,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
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