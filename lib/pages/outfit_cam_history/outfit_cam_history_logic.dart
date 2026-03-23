import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../db_outfitcam/data.dart';
import '../../db_outfitcam/db_outfitcam_entity.dart';
import '../../utils/index.dart';

class OutfitCamHistoryLogic extends GetxController {
  final selectedIndex = (-1).obs;
  final showFullscreen = false.obs;
  final historyRecords = <HistoryRecord>[].obs;
  final isLoading = true.obs;
  @override
  void onInit() {
    super.onInit();
    _loadHistoryRecords();
  }

  Future<void> _loadHistoryRecords() async {
    try {
      isLoading.value = true;
      final db = Get.find<OutfitCamDatabase>();
      final records = await db.getHistoryRecords();
      historyRecords.value = records;
    } catch (e) {
      print('Error loading history records: $e');
      errorToast('Failed to load history records');
    } finally {
      isLoading.value = false;
    }
  }

  void onImageTap(int index) {
    selectedIndex.value = index;
    showFullscreen.value = true;
  }

  void onCloseFullscreen() {
    showFullscreen.value = false;
    selectedIndex.value = -1;
  }

  Future<void> onDeleteSingleRecord(int index) async {
    try {
      final record = historyRecords[index];
      if (record.id == null) return;
      final db = Get.find<OutfitCamDatabase>();
      final result = await db.deleteHistoryRecord(record.id!);
      if (result > 0) {
        final file = File(record.imagePath);
        if (await file.exists()) {
          await file.delete();
        }
        historyRecords.removeAt(index);
        successToast('Record deleted');
      } else {
        errorToast('Failed to delete record');
      }
    } catch (e) {
      print('Error deleting record: $e');
      errorToast('Failed to delete record');
    }
  }

  Future<void> onDeleteAllRecords() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete All History'),
          content: const Text(
            'Are you sure you want to delete all history records? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      if (confirmed != true) return;
      isLoading.value = true;
      for (final record in historyRecords) {
        try {
          final file = File(record.imagePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error deleting file: ${record.imagePath}, error: $e');
        }
      }
      final db = Get.find<OutfitCamDatabase>();
      await db.clearHistoryRecords();
      historyRecords.clear();
      successToast('All records deleted');
    } catch (e) {
      print('Error deleting all records: $e');
      errorToast('Failed to delete records');
    } finally {
      isLoading.value = false;
    }
  }
}
