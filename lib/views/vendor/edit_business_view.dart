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
import '../../core/utils/image_helper.dart';

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

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF904CC1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF904CC1), size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _pickLogo() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 25,
      maxWidth: 500,
      maxHeight: 500,
    );
    if (image != null) {
      setState(() => _isUploading = true);
      String? url = await _storageService.uploadImage('logos', File(image.path));
      if (url != null) {
        setState(() => _logoUrl = url);
      }
      setState(() => _isUploading = false);
    }
  }

  void _editProduct({ProductModel? product, int? index}) {
    String name = product?.name ?? '';
    String price = product?.price ?? '';
    String? imageUrl = product?.imageUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            top: 32,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product == null ? 'Add Product/Service' : 'Edit Product/Service',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final source = await _showImageSourceDialog();
                    if (source == null) return;

                    final XFile? image = await _picker.pickImage(
                      source: source,
                      imageQuality: 25,
                      maxWidth: 500,
                      maxHeight: 500,
                    );
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
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4F8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF904CC1).withOpacity(0.1)),
                    ),
                    child: Stack(
                      children: [
                        if (imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: ImageHelper.displayImage(imageUrl!, fit: BoxFit.cover, width: 140, height: 140),
                          )
                        else
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                Icon(Icons.add_a_photo_outlined, size: 32, color: Color(0xFF904CC1)),
                                SizedBox(height: 8),
                                Text('Add Photo', style: TextStyle(color: Color(0xFF904CC1), fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        if (_isUploading)
                          const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildTextFieldInPopup('Item Name', (v) => name = v, Icons.shopping_bag_outlined, initialValue: name),
                const SizedBox(height: 16),
              _buildTextFieldInPopup('Price (₹)', (v) => price = v, Icons.payments_outlined, keyboardType: TextInputType.number, initialValue: price),
                const SizedBox(height: 32),
              ElevatedButton(
                onPressed: imageUrl != null && name.isNotEmpty ? () {
                  setState(() {
                      if (product == null) {
                        _products.add(ProductModel(imageUrl: imageUrl!, price: price, name: name));
                      } else {
                        _products[index!] = ProductModel(imageUrl: imageUrl!, price: price, name: name);
                      }
                  });
                  Navigator.pop(context);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF904CC1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(product == null ? 'Add Product' : 'Update Product', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldInPopup(String label, Function(String) onChanged, IconData icon, {TextInputType keyboardType = TextInputType.text, String initialValue = ''}) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF1F4F8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        backgroundImage: _logoUrl != null ? ImageHelper.getImageProvider(_logoUrl!) : null,
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
                  TextButton.icon(onPressed: () => _editProduct(), icon: const Icon(Icons.add), label: const Text('Add New')),
                ],
              ),
              const SizedBox(height: 16),
              if (_products.isEmpty)
                const Center(child: Text('No products added yet', style: TextStyle(color: Colors.grey)))
              else
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final p = _products[index];
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), 
                                    child: ImageHelper.displayImage(p.imageUrl, fit: BoxFit.cover, width: double.infinity)
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _editProduct(product: p, index: index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                            child: const Icon(Icons.edit, size: 14, color: Color(0xFF904CC1)),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () => setState(() => _products.removeAt(index)),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                            child: const Icon(Icons.delete, size: 14, color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            Text('₹${p.price}', style: const TextStyle(color: Color(0xFF904CC1), fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
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
