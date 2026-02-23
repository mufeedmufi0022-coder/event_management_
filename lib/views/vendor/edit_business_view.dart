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
import '../../core/utils/app_constants.dart';

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

  String? _logoUrl;
  List<ProductModel> _products = [];
  LatLng _selectedLatLng = const LatLng(10.8505, 76.2711);
  bool _isUploading = false;

  final List<String> _serviceTypes = AppConstants.serviceCategories;

  @override
  void initState() {
    super.initState();
    final vendor = Provider.of<VendorProvider>(
      context,
      listen: false,
    ).vendorModel;
    _nameController = TextEditingController(text: vendor?.businessName ?? '');
    _locationController = TextEditingController(text: vendor?.location ?? '');
    _priceController = TextEditingController(text: vendor?.priceRange ?? '');
    _descriptionController = TextEditingController(
      text: vendor?.description ?? '',
    );
    _contactController = TextEditingController(
      text: vendor?.contactNumber ?? '',
    );
    _logoUrl = vendor?.logoUrl;
    _products = List.from(vendor?.products ?? []);
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

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
      imageQuality: 10,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (image != null) {
      setState(() => _isUploading = true);
      String? url = await _storageService.uploadImage(
        'logos',
        File(image.path),
      );
      if (url != null) {
        setState(() => _logoUrl = url);
      }
      setState(() => _isUploading = false);
    }
  }

  void _editProduct({ProductModel? product, int? index}) {
    String name = product?.name ?? '';
    String price = product?.price ?? '';
    List<String> images = product?.images != null
        ? List.from(product!.images)
        : [];
    String? priceType = product?.priceType ?? 'fixed';
    String? categoryType = product?.categoryType;
    int? capacity = product?.capacity;
    String? mobileNumber = product?.mobileNumber;
    String? location = product?.location;
    String? subType = product?.subType;
    double? latitude = product?.latitude;
    double? longitude = product?.longitude;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product == null
                          ? 'Add Product/Service'
                          : 'Edit Product/Service',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Images (Select multiple)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length + 1,
                    itemBuilder: (context, idx) {
                      if (idx == images.length) {
                        return GestureDetector(
                          onTap: () async {
                            final source = await _showImageSourceDialog();
                            if (source == null) return;
                            final XFile? image = await _picker.pickImage(
                              source: source,
                              imageQuality: 10,
                              maxWidth: 300,
                              maxHeight: 300,
                            );
                            if (image != null) {
                              setDialogState(() => _isUploading = true);
                              String? url = await _storageService.uploadImage(
                                'products',
                                File(image.path),
                              );
                              setDialogState(() {
                                if (url != null) images.add(url);
                                _isUploading = false;
                              });
                            }
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F4F8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF904CC1).withOpacity(0.1),
                              ),
                            ),
                            child: const Icon(
                              Icons.add_a_photo_outlined,
                              color: Color(0xFF904CC1),
                            ),
                          ),
                        );
                      }
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image:
                                    ImageHelper.getImageProvider(images[idx]) ??
                                    const NetworkImage(
                                      'https://via.placeholder.com/150',
                                    ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 16,
                            child: GestureDetector(
                              onTap: () =>
                                  setDialogState(() => images.removeAt(idx)),
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (_isUploading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                const SizedBox(height: 24),
                _buildTextFieldInPopup(
                  'Item Name',
                  (v) => name = v,
                  Icons.shopping_bag_outlined,
                  initialValue: name,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: categoryType,
                  decoration: _inputDecoration(
                    'Service Category',
                    Icons.category,
                  ),
                  items: _serviceTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => categoryType = v),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFieldInPopup(
                        'Price (₹)',
                        (v) => price = v,
                        Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        initialValue: price,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: priceType,
                        decoration: _inputDecoration(
                          'Pricing Type',
                          Icons.sell_outlined,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'fixed',
                            child: Text('Fixed'),
                          ),
                          DropdownMenuItem(
                            value: 'per_person',
                            child: Text('Per Person'),
                          ),
                        ],
                        onChanged: (v) => setDialogState(() => priceType = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFieldInPopup(
                        'Capacity',
                        (v) => capacity = int.tryParse(v),
                        Icons.people_outline,
                        keyboardType: TextInputType.number,
                        initialValue: capacity?.toString() ?? '',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextFieldInPopup(
                        'Mobile',
                        (v) => mobileNumber = v,
                        Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        initialValue: mobileNumber ?? '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setFieldState) => _buildTextFieldInPopup(
                    'Specific Location',
                    (v) => location = v,
                    Icons.location_on_outlined,
                    initialValue: location ?? '',
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.map_outlined,
                        color: Color(0xFF904CC1),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationPickerView(
                              initialCenter:
                                  latitude != null && longitude != null
                                  ? LatLng(latitude!, longitude!)
                                  : const LatLng(10.8505, 76.2711),
                              initialAddress: location,
                            ),
                          ),
                        );
                        if (result is LocationResult) {
                          setFieldState(() {
                            location = result.address;
                            latitude = result.latLng.latitude;
                            longitude = result.latLng.longitude;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (categoryType == 'Vehicle')
                  DropdownButtonFormField<String>(
                    value: subType,
                    decoration: _inputDecoration(
                      'Car Class',
                      Icons.directions_car_outlined,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Premium',
                        child: Text('Premium'),
                      ),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                    ],
                    onChanged: (v) => setDialogState(() => subType = v),
                  ),
                if (categoryType == 'Food' || categoryType == 'Catering')
                  DropdownButtonFormField<String>(
                    value: subType,
                    decoration: _inputDecoration(
                      'Service Type',
                      Icons.restaurant_outlined,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Buffet', child: Text('Buffet')),
                      DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                    ],
                    onChanged: (v) => setDialogState(() => subType = v),
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed:
                      images.isNotEmpty &&
                          name.isNotEmpty &&
                          categoryType != null
                      ? () {
                          setState(() {
                            final newProduct = ProductModel(
                              images: images,
                              price: price,
                              name: name,
                              capacity: capacity,
                              mobileNumber: mobileNumber,
                              location: location,
                              priceType: priceType,
                              categoryType: categoryType,
                              subType: subType,
                              blockedDates: product?.blockedDates ?? [],
                              bookedDates: product?.bookedDates ?? [],
                              ratings: product?.ratings ?? [],
                              latitude: latitude,
                              longitude: longitude,
                            );
                            if (product == null) {
                              _products.add(newProduct);
                            } else {
                              _products[index!] = newProduct;
                            }
                          });
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF904CC1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    product == null ? 'Add Product' : 'Update Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  Widget _buildTextFieldInPopup(
    String label,
    Function(String) onChanged,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String initialValue = '',
    Widget? suffixIcon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF1F4F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<AuthProvider>(context, listen: false).userModel;
      final vendorProvider = Provider.of<VendorProvider>(
        context,
        listen: false,
      );

      final vendor = VendorModel(
        vendorId: user!.uid,
        businessName: _nameController.text.trim(),
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
        title: const Text(
          'Business Registry',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                        backgroundImage: _logoUrl != null
                            ? ImageHelper.getImageProvider(_logoUrl!)
                            : null,
                        child: _logoUrl == null
                            ? const Icon(
                                Icons.add_business_rounded,
                                size: 40,
                                color: Color(0xFF904CC1),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Company Logo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'General Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              _buildCard([
                _buildTextField(
                  _nameController,
                  'Business Name',
                  Icons.business,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _contactController,
                  'Contact Number',
                  Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  readOnly: true,
                  onTap: () async {
                    final result = await Navigator.push<LocationResult>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationPickerView(),
                      ),
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
                  const Text(
                    'Products & Services',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextButton.icon(
                    onPressed: () => _editProduct(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_products.isEmpty)
                const Center(
                  child: Text(
                    'No products added yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
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
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: ImageHelper.displayImage(
                                      p.images.isNotEmpty ? p.images.first : '',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 10,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            p.averageRating.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _editProduct(
                                            product: p,
                                            index: index,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              size: 14,
                                              color: Color(0xFF904CC1),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () => setState(
                                            () => _products.removeAt(index),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.delete,
                                              size: 14,
                                              color: Colors.red,
                                            ),
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
                              child: Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              p.priceType == 'per_person'
                                  ? '₹${p.price}/person'
                                  : '₹${p.price}',
                              style: const TextStyle(
                                color: Color(0xFF904CC1),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
      ],
    ),
    child: Column(children: children),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: _inputDecoration(label, icon),
  );

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF1F4F8),
      );
}
