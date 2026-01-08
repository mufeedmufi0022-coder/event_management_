import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/event_model.dart';
import '../common/location_picker_view.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<AuthProvider>(context, listen: false).userModel;
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final event = EventModel(
        eventId: '', 
        userId: user!.uid,
        eventName: _nameController.text.trim(),
        eventType: _typeController.text.trim(),
        date: _selectedDate.toLocal().toString().split(' ')[0],
        location: _locationController.text.trim(),
        status: 'active',
      );

      await userProvider.createEvent(event);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: const Text('Design Your Event', style: TextStyle(fontWeight: FontWeight.bold)),
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
              const Text('Event Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
              const SizedBox(height: 16),
              _buildFormCard([
                _buildTextField(_nameController, 'Event Name (e.g. Rahul\'s Wedding)', Icons.celebration),
                const SizedBox(height: 16),
                _buildTextField(_typeController, 'Event Type (e.g. Wedding, Birthday)', Icons.category_outlined),
              ]),
              const SizedBox(height: 24),
              const Text('Time & Venue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
              const SizedBox(height: 16),
              _buildFormCard([
                TextFormField(
                  controller: _locationController,
                  readOnly: true,
                  decoration: _inputDecoration('Location', Icons.location_on_outlined),
                  onTap: () async {
                    final result = await Navigator.push<LocationResult>(
                      context,
                      MaterialPageRoute(builder: (context) => const LocationPickerView()),
                    );
                    if (result != null) {
                      setState(() => _locationController.text = result.address);
                    }
                  },
                  validator: (v) => v!.isEmpty ? 'Please select a location' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(primary: Color(0xFF904CC1)),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF904CC1)),
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF904CC1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Create Event Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(hint, icon),
      validator: (v) => v!.isEmpty ? 'Field required' : null,
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      filled: true,
      fillColor: const Color(0xFFF1F4F8),
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
    );
  }
}
