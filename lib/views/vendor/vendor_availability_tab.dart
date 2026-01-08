import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../providers/vendor_provider.dart';

class VendorAvailabilityTab extends StatefulWidget {
  const VendorAvailabilityTab({super.key});

  @override
  State<VendorAvailabilityTab> createState() => _VendorAvailabilityTabState();
}

class _VendorAvailabilityTabState extends State<VendorAvailabilityTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorProvider>();
    final availability = provider.vendorModel?.availability ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: const Text('Manage Availability', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              eventLoader: (day) {
                final dateStr = day.toIso8601String().split('T')[0];
                if (availability[dateStr] == 'blocked') return ['blocked'];
                return [];
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(color: Color(0xFF904CC1), shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Color(0x60904CC1), shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedDay != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Selected: ${_selectedDay!.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateAvailability('available', availability),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Available'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateAvailability('blocked', availability),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Block Date'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                _buildLegend(Colors.red, 'Blocked'),
                const SizedBox(width: 16),
                _buildLegend(Colors.green, 'Available (Default)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _updateAvailability(String status, Map<String, String> current) {
    if (_selectedDay == null) return;
    final dateStr = _selectedDay!.toIso8601String().split('T')[0];
    final Map<String, String> newAvailability = Map.from(current);
    if (status == 'available') {
      newAvailability.remove(dateStr);
    } else {
      newAvailability[dateStr] = 'blocked';
    }
    Provider.of<VendorProvider>(context, listen: false).updateAvailability(newAvailability);
  }
}
