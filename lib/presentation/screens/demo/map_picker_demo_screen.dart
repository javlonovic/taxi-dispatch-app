import 'package:flutter/material.dart';
import '../../widgets/location_map_picker.dart';
import '../../widgets/location_confirmation_dialog.dart';

/// Демо экран для тестирования выбора местоположения на карте
class MapPickerDemoScreen extends StatefulWidget {
  const MapPickerDemoScreen({super.key});

  @override
  State<MapPickerDemoScreen> createState() => _MapPickerDemoScreenState();
}

class _MapPickerDemoScreenState extends State<MapPickerDemoScreen> {
  SelectedLocation? _selectedPickupLocation;
  SelectedLocation? _selectedDestinationLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тест выбора местоположения'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Демонстрация выбора местоположения на карте',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Pickup location section
            _buildLocationSection(
              title: 'Место отправления',
              icon: Icons.my_location,
              color: Colors.green,
              selectedLocation: _selectedPickupLocation,
              onTap: () => _selectLocation(isPickup: true),
            ),

            const SizedBox(height: 20),

            // Destination location section
            _buildLocationSection(
              title: 'Место назначения',
              icon: Icons.location_on,
              color: Colors.red,
              selectedLocation: _selectedDestinationLocation,
              onTap: () => _selectLocation(isPickup: false),
            ),

            const SizedBox(height: 32),

            // Order button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedPickupLocation != null
                    ? _showOrderSummary
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Показать сводку заказа',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection({
    required String title,
    required IconData icon,
    required Color color,
    required SelectedLocation? selectedLocation,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: selectedLocation != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    selectedLocation.address,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Координаты: ${selectedLocation.geoPoint.latitude.toStringAsFixed(6)}, ${selectedLocation.geoPoint.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              )
            : const Text(
                'Нажмите для выбора',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _selectLocation({required bool isPickup}) async {
    // Определяем начальное местоположение
    SelectedLocation? currentLocation = isPickup 
        ? _selectedPickupLocation 
        : _selectedDestinationLocation;

    // Открываем карту для выбора местоположения
    final result = await Navigator.of(context).push<SelectedLocation>(
      MaterialPageRoute(
        builder: (context) => LocationMapPicker(
          initialLocation: currentLocation?.geoPoint,
          title: isPickup ? 'Выберите место отправления' : 'Выберите место назначения',
          confirmButtonText: 'Выбрать это место',
          onLocationSelected: (selectedLocation) {
            Navigator.of(context).pop(selectedLocation);
          },
        ),
      ),
    );

    if (result == null) return;

    // Показываем диалог подтверждения
    final confirmed = await showLocationConfirmationDialog(
      context: context,
      title: isPickup ? 'Подтвердите место отправления' : 'Подтвердите место назначения',
      address: result.address,
      location: result.geoPoint,
      subtitle: isPickup 
          ? 'Водители будут искать вас по этому адресу'
          : 'Водитель доставит вас по этому адресу',
    );

    if (confirmed) {
      setState(() {
        if (isPickup) {
          _selectedPickupLocation = result;
        } else {
          _selectedDestinationLocation = result;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPickup
                ? 'Место отправления выбрано'
                : 'Место назначения выбрано',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showOrderSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сводка заказа'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedPickupLocation != null) ...[
              const Text(
                'Место отправления:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_selectedPickupLocation!.address),
              const SizedBox(height: 12),
            ],
            if (_selectedDestinationLocation != null) ...[
              const Text(
                'Место назначения:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_selectedDestinationLocation!.address),
              const SizedBox(height: 12),
            ],
            const Text(
              'Статус: Готов к заказу такси',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Заказ такси отправлен!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Заказать такси'),
          ),
        ],
      ),
    );
  }
}