import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import '../common/location_picker_view.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/vendor_model.dart';
import '../../services/storage_service.dart';

class EditBusinessView extends StatefulWidget {
  const EditBusinessView({super.key});

  @override
  State<EditBusinessView> createState() => _EditBusinessViewState();
}

class _EditBusinessViewState extends State<EditBusinessView> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _storageService = StorageService();
  
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _contactController;
  
  String? _selectedType;
  String? _logoUrl;
  List<ProductModel> _products = [];
  LatLng _selectedLatLng = const LatLng(10.8505, 76.2711);
  bool _isUploading = false;

  final List<String> _serviceTypes = [
    'Convention Center', 'Food', 'Decoration', 'Vehicle', 'Catering', 'Photography', 'Music/DJ'
  ];

  @override
  void initState() {
    super.initState();
    final vendor = Provider.of<VendorProvider>(context, listen: false).vendorModel;
    _nameController = TextEditingController(text: vendor?.businessName ?? '');
    _locationController = TextEditingController(text: vendor?.location ?? '');
    _priceController = TextEditingController(text: vendor?.priceRange ?? '');
    _descriptionController = TextEditingController(text: vendor?.description ?? '');
    _contactController = TextEditingController(text: vendor?.contactNumber ?? '');
    _logoUrl = vendor?.logoUrl;
    _products = List.from(vendor?.products ?? []);
    
    if (vendor?.serviceType != null && _serviceTypes.contains(vendor!.serviceType)) {
      _selectedType = vendor.serviceType;
    }
  }

  Future<void> _pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isUploading = true);
      String? url = await _storageService.uploadImage('logos', File(image.path));
      if (url != null) {
        setState(() => _logoUrl = url);
      }
      setState(() => _isUploading = false);
    }
  }

  void _addProduct() {
    String name = '';
    String price = '';
    String? imageUrl;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Product/Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setDialogState(() => _isUploading = true);
                    String? url = await _storageService.uploadImage('products', File(image.path));
                    setDialogState(() {
                      imageUrl = url;
                      _isUploading = false;
                    });
                  }
                },
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                  child: imageUrl != null 
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(imageUrl!, fit: BoxFit.cover))
                    : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Item Name'),
                onChanged: (v) => name = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Price'),
                onChanged: (v) => price = v,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: imageUrl != null && name.isNotEmpty ? () {
                setState(() {
                  _products.add(ProductModel(imageUrl: imageUrl!, price: price, name: name));
                });
                Navigator.pop(context);
              } : null,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<AuthProvider>(context, listen: false).userModel;
      final vendorProvider = Provider.of<VendorProvider>(context, listen: false);

      final vendor = VendorModel(
        vendorId: user!.uid,
        businessName: _nameController.text.trim(),
        serviceType: _selectedType ?? '',
        location: _locationController.text.trim(),
        priceRange: _priceController.text.trim(),
        description: _descriptionController.text.trim(),
        contactNumber: _contactController.text.trim(),
        images: _logoUrl != null ? [_logoUrl!] : [],
        logoUrl: _logoUrl ?? '',
        products: _products,
        status: user.status,
      );

      await vendorProvider.updateProfile(vendor);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: const Text('Business Registry', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickLogo,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: _logoUrl != null ? NetworkImage(_logoUrl!) : null,
                        child: _logoUrl == null 
                          ? const Icon(Icons.add_business_rounded, size: 40, color: Color(0xFF904CC1))
                          : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Company Logo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const Text('General Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _buildCard([
                _buildTextField(_nameController, 'Business Name', Icons.business),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: _inputDecoration('Service Category', Icons.category),
                  items: _serviceTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _selectedType = v),
                ),
                const SizedBox(height: 16),
                _buildTextField(_contactController, 'Contact Number', Icons.phone, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  readOnly: true,
                  onTap: () async {
                    final result = await Navigator.push<LocationResult>(
                      context, MaterialPageRoute(builder: (context) => const LocationPickerView())
                    );
                    if (result != null) {
                      setState(() {
                        _selectedLatLng = result.latLng;
                        _locationController.text = result.address;
                      });
                    }
                  },
                  decoration: _inputDecoration('Business Location', Icons.map),
                ),
              ]),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Products & Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  TextButton.icon(onPressed: _addProduct, icon: const Icon(Icons.add), label: const Text('Add New')),
                ],
              ),
              const SizedBox(height: 16),
              if (_products.isEmpty)
                const Center(child: Text('No products added yet', style: TextStyle(color: Colors.grey)))
              else
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final p = _products[index];
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.network(p.imageUrl, fit: BoxFit.cover, width: double.infinity))),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            Text('₹${p.price}', style: const TextStyle(color: Color(0xFF904CC1), fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              
              const SizedBox(height: 40),
              _isUploading 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF904CC1),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Update Profile', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
    child: Column(children: children),
  );

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: _inputDecoration(label, icon),
  );

  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon, color: Colors.grey),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    filled: true, fillColor: const Color(0xFFF1F4F8),
  );
}
