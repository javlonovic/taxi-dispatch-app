import 'package:flutter/material.dart';

/// Widget to display search radius information to users
class SearchRadiusInfo extends StatelessWidget {
  final double currentRadiusKm;
  final int driverCount;
  final bool isSearching;

  const SearchRadiusInfo({
    super.key,
    required this.currentRadiusKm,
    required this.driverCount,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(context),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 16,
            color: _getIconColor(context),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getTitle(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(context),
                  ),
                ),
                if (!isSearching) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getSubtitle(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: _getTextColor(context).withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isSearching) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getIconColor(context),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIcon() {
    if (isSearching) return Icons.search;
    if (driverCount == 0) return Icons.location_off;
    return Icons.location_searching;
  }

  Color _getBackgroundColor(BuildContext context) {
    if (isSearching) return Colors.blue.shade50;
    if (driverCount == 0) return Colors.orange.shade50;
    return Colors.green.shade50;
  }

  Color _getBorderColor(BuildContext context) {
    if (isSearching) return Colors.blue.shade200;
    if (driverCount == 0) return Colors.orange.shade200;
    return Colors.green.shade200;
  }

  Color _getIconColor(BuildContext context) {
    if (isSearching) return Colors.blue.shade700;
    if (driverCount == 0) return Colors.orange.shade700;
    return Colors.green.shade700;
  }

  Color _getTextColor(BuildContext context) {
    if (isSearching) return Colors.blue.shade900;
    if (driverCount == 0) return Colors.orange.shade900;
    return Colors.green.shade900;
  }

  String _getTitle() {
    if (isSearching) {
      return 'Поиск в радиусе ${currentRadiusKm.toStringAsFixed(1)} км...';
    }
    if (driverCount == 0) {
      return 'Нет водителей в радиусе ${currentRadiusKm.toStringAsFixed(1)} км';
    }
    return '$driverCount ${_getDriverWord(driverCount)} в радиусе ${currentRadiusKm.toStringAsFixed(1)} км';
  }

  String _getDriverWord(int count) {
    if (count == 1) return 'водитель';
    if (count >= 2 && count <= 4) return 'водителя';
    return 'водителей';
  }

  String _getSubtitle() {
    if (driverCount == 0) {
      return 'Попробуйте обновить или подождите';
    }
    // Remove the default search radius text completely
    return 'Расширенный радиус поиска';
  }
}

/// Compact version for displaying in headers or toolbars
class CompactSearchRadiusInfo extends StatelessWidget {
  final double radiusKm;

  const CompactSearchRadiusInfo({
    super.key,
    required this.radiusKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_searching,
            size: 12,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            '${radiusKm.toStringAsFixed(1)} km',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
