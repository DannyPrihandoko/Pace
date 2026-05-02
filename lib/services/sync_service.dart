import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_service.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  final DatabaseService _db = DatabaseService.instance;
  
  bool _isSyncing = false;

  SyncService._init();

  void initialize() {
    if (kIsWeb) return;
    
    // Listen against network changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) || 
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet)) {
        processQueue();
      }
    });
    
    // Attempt to sync on startup
    processQueue();
  }

  Future<void> processQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final db = await _db.database;
      // Get the oldest pending queues first
      final pendingQueue = await db.query(
        'sync_queue', 
        where: 'status = ?', 
        whereArgs: ['pending'],
        orderBy: 'created_at ASC'
      );

      for (var item in pendingQueue) {
        bool success = false;
        
        try {
          // Here you would implement your actual API calls
          // Example:
          // final payload = item['payload'] != null ? jsonDecode(item['payload'] as String) : null;
          // if (item['operation'] == 'CREATE') {
          //   success = await ApiClient.post('/activities', payload);
          // } else if (item['operation'] == 'UPDATE') {
          //   success = await ApiClient.put('/activities/${item['entity_id']}', payload);
          // } else if (item['operation'] == 'DELETE') {
          //   success = await ApiClient.delete('/activities/${item['entity_id']}');
          // }
          
          debugPrint('Syncing \${item['operation']} on \${item['entity']} ID: \${item['entity_id']}...');
          // Simulate network request
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Assume success for now
          success = true; 
        } catch (e) {
          debugPrint('Sync failed for item \${item['id']}: \$e');
          // Leave as 'pending', will be retried when connection restores
          success = false; 
        }

        if (success) {
           // Delete from queue if successfully synced
           await db.delete('sync_queue', where: 'id = ?', whereArgs: [item['id']]);
           debugPrint('Successfully synced item \${item['id']}');
        }
      }
    } catch (e) {
      debugPrint('Error processing sync queue: \$e');
    } finally {
      _isSyncing = false;
    }
  }
}
