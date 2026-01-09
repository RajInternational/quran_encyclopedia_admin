import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:nb_utils/nb_utils.dart';

class QuranDatabaseService {
  static Database? _database;
  static bool _isInitialized = false;
  static const String _dbName = 'quran.db';
  static const String _table1 = 'ArabicSubjects_Pak';
  static const String _table2 = 'ArabicSubjects_Pak2';
  static const String _rootWordHashIdColumn = 'rootword_hash_id';

  /// Get database instance
  Future<Database?> get database async {
    if (_database != null) return _database;
    
    // Initialize web support if on web
    if (isWeb && !_isInitialized) {
      try {
        // Use no-web-worker factory first (runs in main thread, no worker file needed)
        // This is simpler and doesn't require sqflite_sw.js setup
        databaseFactory = databaseFactoryFfiWebNoWebWorker;
        _isInitialized = true;
        log('Initialized sqflite_common_ffi_web without web worker (main thread)');
      } catch (e) {
        log('Error initializing sqflite_common_ffi_web (no worker): $e');
        // Try fallback to prebuilt factory with web worker
        try {
          databaseFactory = databaseFactoryFfiWeb;
          _isInitialized = true;
          log('Using sqflite_common_ffi_web with prebuilt factory');
        } catch (e2) {
          log('Error initializing sqflite_common_ffi_web: $e2');
          log('SQLite will not be available on web.');
          return null;
        }
      }
    }
    
    try {
      _database = await _initDatabase();
      return _database;
    } catch (e) {
      log('Error initializing database: $e');
      if (isWeb) {
        log('Note: SQLite on web may require additional setup.');
        log('The app will continue without SQLite features on web.');
      }
      return null;
    }
  }

  /// Initialize database - copy from assets if needed
  Future<Database> _initDatabase() async {
    try {
      String dbPath;
      
      if (isWeb) {
        // For web, use IndexedDB storage via sqflite_common_ffi_web
        dbPath = _dbName;
        
        // Open database (will use IndexedDB on web)
        // Note: The database file from assets needs to be loaded differently on web
        // For now, we'll open/create the database and it will be stored in IndexedDB
        // The factory is already set globally in the database getter
        final db = await openDatabase(
          dbPath,
          version: 1,
          singleInstance: true,
        );
        
        // Try to check if tables exist
        try {
          await db.rawQuery('SELECT COUNT(*) FROM $_table1 LIMIT 1');
          // Table exists, check for column
          await _ensureRootWordHashIdColumn(db);
          log('Database opened successfully on web');
          return db;
        } catch (e) {
          // Table doesn't exist - database might be new
          // On web, we need to load the database file differently
          // For now, we'll ensure columns exist and return the db
          // The actual data import would need to be done separately
          log('Database tables may not exist yet on web. Error: $e');
          await _ensureRootWordHashIdColumn(db);
          return db;
        }
      } else {
        // For mobile/desktop, use file system
        final documentsDirectory = await getApplicationDocumentsDirectory();
        dbPath = path.join(documentsDirectory.path, _dbName);

        // Check if database exists, if not copy from assets
        if (!await File(dbPath).exists()) {
          // Copy from assets
          final byteData = await rootBundle.load('assets/$_dbName');
          final bytes = byteData.buffer.asUint8List();
          await File(dbPath).writeAsBytes(bytes);
          log('Database copied from assets to $dbPath');
        }

        // Open database
        final db = await openDatabase(
          dbPath,
          version: 1,
          onCreate: (db, version) async {
            // Database already exists from assets, so onCreate won't be called
          },
        );

        // Check and add rootword_hash_id column if needed
        await _ensureRootWordHashIdColumn(db);

        return db;
      }
    } catch (e) {
      log('Error initializing database: $e');
      rethrow;
    }
  }

  /// Check if rootword_hash_id column exists and add it if missing
  Future<void> _ensureRootWordHashIdColumn(Database db) async {
    try {
      // Check table 1
      final table1Info = await db.rawQuery('PRAGMA table_info($_table1)');
      log('Table $_table1 columns: ${table1Info.map((c) => c['name']).toList()}');
      
      final hasColumn1 = table1Info.any((col) => col['name'] == _rootWordHashIdColumn);
      log('Table $_table1 has $_rootWordHashIdColumn column: $hasColumn1');
      
      if (!hasColumn1) {
        log('Attempting to add $_rootWordHashIdColumn column to $_table1...');
        await db.execute('ALTER TABLE $_table1 ADD COLUMN $_rootWordHashIdColumn TEXT');
        
        // Verify it was added
        final verify1 = await db.rawQuery('PRAGMA table_info($_table1)');
        final hasColumn1After = verify1.any((col) => col['name'] == _rootWordHashIdColumn);
        if (hasColumn1After) {
          log('✓ Successfully added $_rootWordHashIdColumn column to $_table1');
        } else {
          log('✗ Failed to add $_rootWordHashIdColumn column to $_table1');
        }
      } else {
        log('$_rootWordHashIdColumn column already exists in $_table1');
      }

      // Check table 2
      final table2Info = await db.rawQuery('PRAGMA table_info($_table2)');
      log('Table $_table2 columns: ${table2Info.map((c) => c['name']).toList()}');
      
      final hasColumn2 = table2Info.any((col) => col['name'] == _rootWordHashIdColumn);
      log('Table $_table2 has $_rootWordHashIdColumn column: $hasColumn2');
      
      if (!hasColumn2) {
        log('Attempting to add $_rootWordHashIdColumn column to $_table2...');
        await db.execute('ALTER TABLE $_table2 ADD COLUMN $_rootWordHashIdColumn TEXT');
        
        // Verify it was added
        final verify2 = await db.rawQuery('PRAGMA table_info($_table2)');
        final hasColumn2After = verify2.any((col) => col['name'] == _rootWordHashIdColumn);
        if (hasColumn2After) {
          log('✓ Successfully added $_rootWordHashIdColumn column to $_table2');
        } else {
          log('✗ Failed to add $_rootWordHashIdColumn column to $_table2');
        }
      } else {
        log('$_rootWordHashIdColumn column already exists in $_table2');
      }
    } catch (e, stackTrace) {
      log('Error ensuring rootword_hash_id column: $e');
      log('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Verify and get table structure - useful for debugging
  Future<Map<String, dynamic>> verifyTableStructure() async {
    final db = await database;
    if (db == null) {
      return {'error': 'Database not available'};
    }
    
    try {
      final table1Info = await db.rawQuery('PRAGMA table_info($_table1)');
      final table2Info = await db.rawQuery('PRAGMA table_info($_table2)');
      
      final table1Columns = table1Info.map((c) => c['name'] as String).toList();
      final table2Columns = table2Info.map((c) => c['name'] as String).toList();
      
      final hasColumn1 = table1Columns.contains(_rootWordHashIdColumn);
      final hasColumn2 = table2Columns.contains(_rootWordHashIdColumn);
      
      return {
        'table1': {
          'name': _table1,
          'columns': table1Columns,
          'has_rootword_hash_id': hasColumn1,
          'column_count': table1Columns.length,
        },
        'table2': {
          'name': _table2,
          'columns': table2Columns,
          'has_rootword_hash_id': hasColumn2,
          'column_count': table2Columns.length,
        },
      };
    } catch (e) {
      log('Error verifying table structure: $e');
      return {'error': e.toString()};
    }
  }

  /// Get table structure (columns)
  Future<Map<String, List<Map<String, dynamic>>>> getTableStructures() async {
    final db = await database;
    if (db == null) {
      return {_table1: [], _table2: []};
    }
    
    try {
      final table1Info = await db.rawQuery('PRAGMA table_info($_table1)');
      final table2Info = await db.rawQuery('PRAGMA table_info($_table2)');
      
      return {
        _table1: table1Info,
        _table2: table2Info,
      };
    } catch (e) {
      log('Error getting table structures: $e');
      return {_table1: [], _table2: []};
    }
  }

  /// Search words from both tables (supports Arabic and Urdu)
  /// Searches in Arabic_Text column and any Urdu column if available
  Future<List<Map<String, dynamic>>> searchArabicWords(String query, {int limit = 50}) async {
    final db = await database;
    if (db == null) return [];
    
    try {
      // Use Arabic_Text column as confirmed by user
      const String arabicWordColumn = 'Arabic_Text';
      
      // Try to find Urdu column name (common names: Urdu_Text, Urdu, UrduText)
      String? urduColumn;
      try {
        final table1Info = await db.rawQuery('PRAGMA table_info($_table1)');
        final urduColumns = table1Info
            .where((col) {
              final colName = (col['name'] as String?)?.toLowerCase();
              return colName != null && 
                     (colName.contains('urdu') || colName == 'urdu');
            })
            .map((col) => col['name'] as String)
            .where((name) => name != null)
            .toList();
        
        if (urduColumns.isNotEmpty) {
          urduColumn = urduColumns.first;
          log('Found Urdu column: $urduColumn');
        }
      } catch (e) {
        log('Could not detect Urdu column: $e');
      }
      
      // Build WHERE clause to search in both Arabic and Urdu columns
      String whereClause;
      List<dynamic> whereArgs;
      
      if (urduColumn != null) {
        // Search in both Arabic and Urdu columns
        whereClause = '$arabicWordColumn LIKE ? OR $urduColumn LIKE ?';
        whereArgs = ['%$query%', '%$query%'];
      } else {
        // Only search in Arabic column
        whereClause = '$arabicWordColumn LIKE ?';
        whereArgs = ['%$query%'];
      }
      
      // Build SELECT clause to include both Arabic and Urdu if available
      String selectClause = 'rowid as id, $arabicWordColumn as arabic_word, $_rootWordHashIdColumn as rootword_hash_id';
      if (urduColumn != null) {
        selectClause += ', $urduColumn as urdu_word';
      }
      selectClause += ', \'$_table1\' as source_table';
      
      // Search in table 1
      final results1 = await db.rawQuery(
        '''
        SELECT $selectClause
        FROM $_table1
        WHERE $whereClause
        LIMIT ?
        ''',
        [...whereArgs, limit],
      );
      
      // Update select clause for table 2
      selectClause = 'rowid as id, $arabicWordColumn as arabic_word, $_rootWordHashIdColumn as rootword_hash_id';
      if (urduColumn != null) {
        selectClause += ', $urduColumn as urdu_word';
      }
      selectClause += ', \'$_table2\' as source_table';
      
      // Search in table 2
      final results2 = await db.rawQuery(
        '''
        SELECT $selectClause
        FROM $_table2
        WHERE $whereClause
        LIMIT ?
        ''',
        [...whereArgs, limit],
      );
      
      return [...results1, ...results2];
    } catch (e) {
      log('Error searching words: $e');
      return [];
    }
  }
  
  /// Update rootword_hash_id for words matching Arabic_Text
  Future<void> updateRootWordHashIdByArabicText({
    required String arabicText,
    required String? rootWordHashId,
  }) async {
    final db = await database;
    if (db == null) {
      log('Database not available for update');
      return;
    }
    
    try {
      // First, ensure the column exists before updating
      await _ensureRootWordHashIdColumn(db);
      
      // Verify column exists before updating
      final table1Info = await db.rawQuery('PRAGMA table_info($_table1)');
      final hasColumn1 = table1Info.any((col) => col['name'] == _rootWordHashIdColumn);
      
      if (!hasColumn1) {
        log('WARNING: $_rootWordHashIdColumn column does not exist in $_table1. Attempting to force add...');
        await forceAddRootWordHashIdColumn();
      }
      
      // Update in table 1
      final result1 = await db.update(
        _table1,
        {_rootWordHashIdColumn: rootWordHashId},
        where: 'Arabic_Text = ?',
        whereArgs: [arabicText],
      );
      log('Updated $_table1: $result1 row(s) affected for Arabic_Text: $arabicText');
      
      // Update in table 2
      final result2 = await db.update(
        _table2,
        {_rootWordHashIdColumn: rootWordHashId},
        where: 'Arabic_Text = ?',
        whereArgs: [arabicText],
      );
      log('Updated $_table2: $result2 row(s) affected for Arabic_Text: $arabicText');
      
      log('✓ Successfully updated rootword_hash_id for Arabic_Text: $arabicText');
    } catch (e, stackTrace) {
      log('✗ Error updating rootword_hash_id by Arabic_Text: $e');
      log('Stack trace: $stackTrace');
      // Don't rethrow, just log the error
    }
  }

  /// Update rootword_hash_id for a word by rowid
  Future<void> updateRootWordHashId({
    required String tableName,
    required dynamic id,
    required String? rootWordHashId,
  }) async {
    final db = await database;
    if (db == null) return;
    
    try {
      await db.update(
        tableName,
        {_rootWordHashIdColumn: rootWordHashId},
        where: 'rowid = ?',
        whereArgs: [id],
      );
      
      log('Updated rootword_hash_id for $tableName rowid: $id');
    } catch (e) {
      log('Error updating rootword_hash_id: $e');
      // Don't rethrow, just log the error
    }
  }

  /// Get all columns from a table (for debugging)
  Future<List<String>> getTableColumns(String tableName) async {
    final db = await database;
    if (db == null) return [];
    
    try {
      final info = await db.rawQuery('PRAGMA table_info($tableName)');
      return info.map((col) => col['name'] as String).toList();
    } catch (e) {
      log('Error getting table columns: $e');
      return [];
    }
  }
  
  /// Verify table structure and check if rootword_hash_id column exists
  /// Returns detailed information about both tables
  // Future<Map<String, dynamic>> verifyTableStructure() async {
  //   final db = await database;
  //   if (db == null) {
  //     return {'error': 'Database not available'};
  //   }
  //
  //   try {
  //     final table1Info = await db.rawQuery('PRAGMA table_info($_table1)');
  //     final table2Info = await db.rawQuery('PRAGMA table_info($_table2)');
  //
  //     final table1Columns = table1Info.map((c) => c['name'] as String).toList();
  //     final table2Columns = table2Info.map((c) => c['name'] as String).toList();
  //
  //     final hasColumn1 = table1Columns.contains(_rootWordHashIdColumn);
  //     final hasColumn2 = table2Columns.contains(_rootWordHashIdColumn);
  //
  //     log('=== Table Structure Verification ===');
  //     log('Table 1 ($_table1):');
  //     log('  Columns: $table1Columns');
  //     log('  Has rootword_hash_id: $hasColumn1');
  //     log('Table 2 ($_table2):');
  //     log('  Columns: $table2Columns');
  //     log('  Has rootword_hash_id: $hasColumn2');
  //     log('====================================');
  //
  //     return {
  //       'table1': {
  //         'name': _table1,
  //         'columns': table1Columns,
  //         'has_rootword_hash_id': hasColumn1,
  //         'column_count': table1Columns.length,
  //       },
  //       'table2': {
  //         'name': _table2,
  //         'columns': table2Columns,
  //         'has_rootword_hash_id': hasColumn2,
  //         'column_count': table2Columns.length,
  //       },
  //     };
  //   } catch (e) {
  //     log('Error verifying table structure: $e');
  //     return {'error': e.toString()};
  //   }
  // }
  
  /// Force add rootword_hash_id column to both tables (use if column is missing)
  Future<bool> forceAddRootWordHashIdColumn() async {
    final db = await database;
    if (db == null) return false;
    
    try {
      bool success = true;
      
      // Force add to table 1
      try {
        await db.execute('ALTER TABLE $_table1 ADD COLUMN $_rootWordHashIdColumn TEXT');
        log('✓ Force added $_rootWordHashIdColumn to $_table1');
      } catch (e) {
        if (e.toString().contains('duplicate column')) {
          log('Column already exists in $_table1');
        } else {
          log('Error adding column to $_table1: $e');
          success = false;
        }
      }
      
      // Force add to table 2
      try {
        await db.execute('ALTER TABLE $_table2 ADD COLUMN $_rootWordHashIdColumn TEXT');
        log('✓ Force added $_rootWordHashIdColumn to $_table2');
      } catch (e) {
        if (e.toString().contains('duplicate column')) {
          log('Column already exists in $_table2');
        } else {
          log('Error adding column to $_table2: $e');
          success = false;
        }
      }
      
      // Verify
      await verifyTableStructure();
      
      return success;
    } catch (e) {
      log('Error in forceAddRootWordHashIdColumn: $e');
      return false;
    }
  }

  /// Query sample data from tables to verify column exists and has data
  Future<List<Map<String, dynamic>>> getSampleData({int limit = 5}) async {
    final db = await database;
    if (db == null) return [];
    
    try {
      // Get sample data from both tables
      final table1Data = await db.rawQuery(
        '''
        SELECT rowid, Arabic_Text, $_rootWordHashIdColumn as rootword_hash_id
        FROM $_table1
        WHERE $_rootWordHashIdColumn IS NOT NULL AND $_rootWordHashIdColumn != ''
        LIMIT ?
        ''',
        [limit],
      );
      
      final table2Data = await db.rawQuery(
        '''
        SELECT rowid, Arabic_Text, $_rootWordHashIdColumn as rootword_hash_id
        FROM $_table2
        WHERE $_rootWordHashIdColumn IS NOT NULL AND $_rootWordHashIdColumn != ''
        LIMIT ?
        ''',
        [limit],
      );
      
      return [
        ...table1Data.map((row) => {...row, 'table': _table1}),
        ...table2Data.map((row) => {...row, 'table': _table2}),
      ];
    } catch (e) {
      log('Error getting sample data: $e');
      // If column doesn't exist, try without it
      try {
        final table1Data = await db.rawQuery(
          'SELECT rowid, Arabic_Text FROM $_table1 LIMIT ?',
          [limit],
        );
        log('Column might not exist. Sample data (without rootword_hash_id): ${table1Data.length} rows');
      } catch (e2) {
        log('Error getting sample data without column: $e2');
      }
      return [];
    }
  }
  
  /// Get database file path (for debugging)
  Future<String?> getDatabasePath() async {
    if (isWeb) {
      return 'Web (IndexedDB)';
    }
    
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = path.join(documentsDirectory.path, _dbName);
      return dbPath;
    } catch (e) {
      log('Error getting database path: $e');
      return null;
    }
  }

  /// Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

