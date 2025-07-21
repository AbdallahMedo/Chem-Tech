import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/constants.dart';

class DataFormShimmer extends StatelessWidget {
  const DataFormShimmer({super.key});

  Widget _buildShimmerLine({double width = 100, double height = 16}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildTopCard() {
    return Card(
      color: Colors.blueGrey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: kSecondaryColor,
              radius: 24,
              child: const Icon(Icons.hourglass_top, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerLine(width: 140, height: 16),
                  const SizedBox(height: 8),
                  _buildShimmerLine(width: 100, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow({required String label}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        _buildShimmerLine(width: 40, height: 20),
      ],
    );
  }

  Widget _buildBottomCard() {
    return Card(
      color: kSecondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDataRow(label: "T1"),
            const SizedBox(height: 16),
            _buildDataRow(label: "T2"),
            const SizedBox(height: 16),
            _buildDataRow(label: "ΔT"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopCard(),
          const SizedBox(height: 20),
          _buildBottomCard(),
        ],
      ),
    );
  }
}
