import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeEditPage extends StatefulWidget {
  const HomeEditPage({super.key});

  @override
  State<HomeEditPage> createState() => _HomeEditPageState();
}

class _HomeEditPageState extends State<HomeEditPage> {
  final _schoolNameController = TextEditingController();
  final _visionController = TextEditingController();
  final _missionController = TextEditingController();
  
  List<Map<String, String>> announcements = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return;
    }
    _loadDataFromFirestore();
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _visionController.dispose();
    _missionController.dispose();
    super.dispose();
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

  // Load current data from Firestore
  Future<void> _loadDataFromFirestore() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('school_info')
          .doc('main')
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _schoolNameController.text = data['schoolName'] ?? "Ku Wellawa Central College";
          _visionController.text = data['vision'] ?? "Empowering education through technology";
          _missionController.text = data['mission'] ?? "To provide efficient school management solutions";
          
          // Load announcements
          if (data['announcements'] != null) {
            announcements = List<Map<String, String>>.from(
              (data['announcements'] as List).map((item) => {
                'title': item['title']?.toString() ?? '',
                'link': item['link']?.toString() ?? '',
              })
            );
          }
        });
      } else {
        // Set default values if document doesn't exist
        setState(() {
          _schoolNameController.text = "Ku Wellawa Central College";
          _visionController.text = "Empowering education through technology";
          _missionController.text = "To provide efficient school management solutions";
          announcements = [
            {
              'title': 'Welcome to the new academic year!',
              'link': 'https://drive.google.com/file/example1'
            },
            {
              'title': 'Sports Day 2025 Registration',
              'link': 'https://drive.google.com/file/example2'
            },
          ];
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _addAnnouncement() {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        final linkController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Add New Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Announcement Title',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: 'Google Drive Link (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'https://drive.google.com/...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  setState(() {
                    announcements.add({
                      'title': titleController.text.trim(),
                      'link': linkController.text.trim(),
                    });
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter announcement title'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editAnnouncement(int index) {
    final titleController = TextEditingController(text: announcements[index]['title']);
    final linkController = TextEditingController(text: announcements[index]['link']);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Announcement Title',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: 'Google Drive Link (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'https://drive.google.com/...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  setState(() {
                    announcements[index] = {
                      'title': titleController.text.trim(),
                      'link': linkController.text.trim(),
                    };
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter announcement title'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _removeAnnouncement(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Announcement'),
          content: Text('Are you sure you want to remove "${announcements[index]['title']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  announcements.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Announcement removed'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  // Save data to Firestore
  Future<void> _saveToFirestore() async {
    // Validate required fields
    if (_schoolNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('School name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_visionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vision cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_missionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mission cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare data for Firestore
      Map<String, dynamic> data = {
        'schoolName': _schoolNameController.text.trim(),
        'vision': _visionController.text.trim(),
        'mission': _missionController.text.trim(),
        'announcements': announcements.map((announcement) => {
          'title': announcement['title']!.trim(),
          'link': announcement['link']!.trim(),
        }).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'Unknown',
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('school_info')
          .doc('main')
          .set(data, SetOptions(merge: true));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Changes saved successfully to Firestore!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Wait a moment for the user to see the success message
      await Future.delayed(const Duration(seconds: 1));

      // Go back to previous page
      Navigator.pop(context);

    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error saving changes: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      print('Error saving to Firestore: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Home Page',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF667eea),
                            ),
                          ),
                          Text(
                            'Modify school information & announcements',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Main Content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(30),
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // School Name Section
                          const Row(
                            children: [
                              Icon(Icons.school, color: Color(0xFF667eea)),
                              SizedBox(width: 10),
                              Text(
                                'School Name',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667eea),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _schoolNameController,
                            decoration: InputDecoration(
                              hintText: 'Enter school name',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.business),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Vision Section
                          const Row(
                            children: [
                              Icon(Icons.visibility, color: Color(0xFF667eea)),
                              SizedBox(width: 10),
                              Text(
                                'Vision',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667eea),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _visionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Enter school vision',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.remove_red_eye),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Mission Section
                          const Row(
                            children: [
                              Icon(Icons.flag, color: Color(0xFF667eea)),
                              SizedBox(width: 10),
                              Text(
                                'Mission',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667eea),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _missionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Enter school mission',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.track_changes),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Announcements Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.campaign, color: Color(0xFF667eea)),
                                  SizedBox(width: 10),
                                  Text(
                                    'Announcements',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF667eea),
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: _addAnnouncement,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Add New'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Announcements List
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 150),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: announcements.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(40),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.announcement,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'No announcements yet',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Click "Add New" to create your first announcement',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: announcements.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.all(8),
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Icon(
                                                announcements[index]['link']!.isNotEmpty 
                                                    ? Icons.link 
                                                    : Icons.announcement,
                                                color: Colors.blue,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    announcements[index]['title']!,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (announcements[index]['link']!.isNotEmpty)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 5),
                                                      child: InkWell(
                                                        onTap: () => _openUrl(announcements[index]['link']!),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.link,
                                                              size: 12,
                                                              color: Colors.blue,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Expanded(
                                                              child: Text(
                                                                announcements[index]['link']!,
                                                                style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors.blue,
                                                                  decoration: TextDecoration.underline,
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                            const Icon(
                                                              Icons.open_in_new,
                                                              size: 12,
                                                              color: Colors.blue,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () => _editAnnouncement(index),
                                                  icon: const Icon(Icons.edit),
                                                  color: Colors.blue,
                                                  tooltip: 'Edit',
                                                ),
                                                IconButton(
                                                  onPressed: () => _removeAnnouncement(index),
                                                  icon: const Icon(Icons.delete),
                                                  color: Colors.red,
                                                  tooltip: 'Delete',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          const SizedBox(height: 30),

                          // Save Button
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _saveToFirestore,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF667eea),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: _isLoading 
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.cloud_upload),
                                label: Text(
                                  _isLoading ? 'SAVING TO FIRESTORE...' : 'SAVE TO FIRESTORE',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Info text
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Changes will be saved to Firestore and automatically appear on the home page.',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}