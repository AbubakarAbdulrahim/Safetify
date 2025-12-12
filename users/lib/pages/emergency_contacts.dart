import 'package:flutter/material.dart';
import 'package:safetify/services/firestore_service.dart';
import 'package:safetify/services/location_service.dart';
import 'package:share_plus/share_plus.dart';
import '../constants.dart';
import '../services/url_launcher_service.dart';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestore = FirestoreService();
  final LocationService _locationService = LocationService();
  List<Map<String, dynamic>> _personalContacts = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _officialContacts = const [
    {
      'name': 'General Emergency Hotline',
      'phone': '112',
      'icon': Icons.emergency_rounded,
      'color': Colors.red
    },
    {
      'name': 'Police Emergency',
      'phone': '08032419754',
      'icon': Icons.local_police_rounded,
      'color': Colors.blueGrey
    },
    {
      'name': 'Fire Service',
      'phone': '08107888878',
      'icon': Icons.local_fire_department_rounded,
      'color': Colors.deepOrange
    },
    {
      'name': 'Ambulance Service',
      'phone': '09039422777',
      'icon': Icons.local_hospital_rounded,
      'color': AppColors.successGreen
    },
    {
      'name': 'Road Safety (FRSC)',
      'phone': '08077690012',
      'icon': Icons.traffic_rounded,
      'color': Colors.orange
    },
    {
      'name': 'NEMA (Disaster Response)',
      'phone': '080022556362',
      'icon': Icons.warning_amber_rounded,
      'color': AppColors.safetyBlue
    },
    {
      'name': 'REMASAB',
      'phone': '07042338576',
      'icon': Icons.delete_rounded,
      'color': Color.fromARGB(255, 223, 167, 0)
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadPersonalContacts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonalContacts() async {
    setState(() => _isLoading = true);
    final contacts = await _firestore.getEmergencyContacts();
    if (mounted) {
      setState(() {
        _personalContacts = contacts;
        _isLoading = false;
      });
    }
  }

  Future<void> _addContact(String name, String phone) async {
    await _firestore.addEmergencyContact(name, phone);
    _loadPersonalContacts();
  }

  Future<void> _removeContact(Map<String, dynamic> contact) async {
    await _firestore.removeEmergencyContact(contact);
    _loadPersonalContacts();
  }

  Future<void> _makeCall(String number) async {
    await UrlLauncherService.makePhoneCall(number);
  }

  Future<void> _shareLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      final link = _locationService.getGoogleMapsLink(position.latitude, position.longitude);
      final message = "I need help! Here is my current location: $link";
      
      
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to get current location")),
        );
      }
    }
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Emergency Contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name", prefixIcon: Icon(Icons.person)),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                _addContact(nameController.text.trim(), phoneController.text.trim());
                Navigator.pop(context);

                // Switch to Personal Contacts tab
                _tabController.animateTo(1);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.safetyBlue),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).iconTheme.color,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.safetyBlue,
          labelColor: AppColors.safetyBlue,
          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
          tabs: const [
            Tab(text: "Official Helplines"),
            Tab(text: "Personal Contacts"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOfficialContacts(),
          _buildPersonalContacts(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        backgroundColor: AppColors.safetyBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOfficialContacts() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _officialContacts.length,
      itemBuilder: (context, index) {
        final c = _officialContacts[index];
        return _buildContactCard(
          name: c['name'],
          phone: c['phone'],
          icon: c['icon'],
          color: c['color'],
          isPersonal: false,
        );
      },
    );
  }

  Widget _buildPersonalContacts() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_personalContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_disabled, size: 64, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              "No personal contacts yet",
              style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 8),
            const Text("Add family or friends for quick access"),
            const SizedBox(height: 24),

            // My Location Share Button
            _buildShareLocationButton(),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildShareLocationButton(),
        const SizedBox(height: 16),
        const Text(
          "My Trusted Contacts",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._personalContacts.map((c) => _buildContactCard(
          name: c['name'],
          phone: c['phone'],
          icon: Icons.person,
          color: AppColors.safetyBlue,
          isPersonal: true,
          contactData: c,
        )),
      ],
    );
  }

  Widget _buildShareLocationButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
            final position = await _locationService.getCurrentLocation();
            if (position != null) {
                final link = _locationService.getGoogleMapsLink(position.latitude, position.longitude);

                // share plus 
                 _shareLocationWithSharePlus(link);
            }
        },
        icon: const Icon(Icons.share_location, color: Colors.white),
        label: const Text("Share Live Location", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successGreen,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
  
  Future<void> _shareLocationWithSharePlus(String link) async {
      Share.share("I'm in an emergency! Track my location here: $link");
  }

  Widget _buildContactCard({
    required String name,
    required String phone,
    required IconData icon,
    required Color color,
    required bool isPersonal,
    Map<String, dynamic>? contactData,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 14),
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          phone,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.call_rounded, color: AppColors.safetyBlue),
              onPressed: () => _makeCall(phone),
            ),
            if (isPersonal && contactData != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(contactData),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Contact?"),
        content: Text("Are you sure you want to remove ${contact['name']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _removeContact(contact);
              Navigator.pop(context);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
