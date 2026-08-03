import 'package:postgres/postgres.dart';

class Database {
  static Connection? connection;

  // =========================
  // CONNECT TO NEON POSTGRESQL
  // =========================
  static Future<void> connect() async {
    try {
      connection = await Connection.open(
        Endpoint(
          host: 'ep-summer-frost-adhp9gt8-pooler.c-2.us-east-1.aws.neon.tech',
          port: 5432,
          database: 'neondb',
          username: 'neondb_owner',
          password: 'npg_95PWsplfcJnq',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.require),
      );

      await connection!.execute('SELECT 1');

      print("Neon PostgreSQL Connected");
    } catch (e) {
      print("Neon Connection Failed: $e");

      connection = null;

      rethrow;
    }
  }

  static Connection get database {
    if (connection == null) {
      throw Exception("Database not connected");
    }

    return connection!;
  }

  // =========================
  // LOGIN
  // =========================
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    final result = await database.execute(
      '''
      SELECT id, email, role

      FROM users

      WHERE email = \$1

      AND password_hash = \$2

      ''',
      parameters: [email, password],
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;

    return {"id": row[0], "email": row[1], "role": row[2]};
  }

  // =========================
  // REGISTER STATION
  // =========================
  static Future<void> registerStation({
    required String businessName,
    required String businessType,
    required String address,
    required String district,
    required String owner,
    required String nin,
    required String phone,
    required String email,
    required String license,
    required String tin,
    required String status,
    required String deviceNumber,
  }) async {
    await database.execute(
      '''
      INSERT INTO stations(

        id,
        business_name,
        business_type,
        address,
        district,
        owner_name,
        owner_nin,
        phone,
        email,
        license_number,
        tin_number,
        status,
        device_id,
        created_at

      )

      VALUES(

        gen_random_uuid(),

        \$1,\$2,\$3,\$4,\$5,\$6,\$7,

        \$8,\$9,\$10,\$11,\$12,

        NOW()

      )

      ON CONFLICT(device_id)

      DO UPDATE SET

      business_name = EXCLUDED.business_name,

      business_type = EXCLUDED.business_type,

      address = EXCLUDED.address,

      district = EXCLUDED.district,

      owner_name = EXCLUDED.owner_name,

      owner_nin = EXCLUDED.owner_nin,

      phone = EXCLUDED.phone,

      email = EXCLUDED.email,

      license_number = EXCLUDED.license_number,

      tin_number = EXCLUDED.tin_number,

      status = EXCLUDED.status

      ''',
      parameters: [
        businessName,
        businessType,
        address,
        district,
        owner,
        nin,
        phone,
        email,
        license,
        tin,
        status,
        deviceNumber,
      ],
    );
  }

  // =========================
  // SAVE LIVE NOISE READING
  // =========================
  static Future<void> saveNoiseReading({
    required String deviceId,
    required double noiseLevel,
  }) async {
    await database.execute(
      '''
      INSERT INTO logs(

        id,

        device_id,

        noise_level,

        created_at

      )

      VALUES(

        gen_random_uuid(),

        \$1,

        \$2,

        NOW()

      )

      ''',
      parameters: [deviceId, noiseLevel],
    );
  }

  // =========================
  // SAVE ALERT EVENT
  // =========================
  static Future<void> saveNoiseEvent({
    required String deviceId,
    required double noiseLevel,
    required String type,
    required String message,
  }) async {
    await database.execute(
      '''
      INSERT INTO alerts_stream(

        device_id,

        noise_level,

        type,

        message,

        created_at,

        is_read

      )

      VALUES(

        \$1,

        \$2,

        \$3,

        \$4,

        NOW(),

        false

      )

      ''',
      parameters: [deviceId, noiseLevel, type, message],
    );
  }

  // =========================
  // GET ALERTS
  // =========================
  static Future<List<Map<String, dynamic>>> getAlerts(String deviceId) async {
    final result = await database.execute(
      '''
      SELECT

      id,

      device_id,

      noise_level,

      type,

      message,

      is_read,

      created_at

      FROM alerts_stream

      WHERE device_id=\$1

      ORDER BY created_at DESC

      ''',
      parameters: [deviceId],
    );

    return result.map((row) {
      return {
        "id": row[0],
        "device_id": row[1],
        "noise_level": row[2],
        "type": row[3],
        "message": row[4],
        "is_read": row[5],
        "created_at": row[6],
      };
    }).toList();
  }

  // =========================
  // MARK ALERT READ
  // =========================
  static Future<void> markAlertAsRead(String id) async {
    await database.execute(
      '''
      UPDATE alerts_stream

      SET is_read=true

      WHERE id=\$1

      ''',
      parameters: [id],
    );
  }

  // =========================
  // CREATE VIOLATION
  // =========================
  static Future<void> createViolation({
    required String deviceId,
    required double measuredLevel,
  }) async {
    await database.execute(
      '''
      INSERT INTO violations(

        id,

        device_id,

        measured_level,

        allowed_level,

        status,

        created_at

      )

      VALUES(

        gen_random_uuid(),

        \$1,

        \$2,

        75,

        'ACTIVE',

        NOW()

      )

      ''',
      parameters: [deviceId, measuredLevel],
    );
  }

  // =========================
  // GET LATEST NOISE
  // =========================
  static Future<double?> getLatestNoise(String deviceId) async {
    final result = await database.execute(
      '''
      SELECT noise_level

      FROM logs

      WHERE device_id=\$1

      ORDER BY created_at DESC

      LIMIT 1

      ''',

      parameters: [deviceId],
    );

    if (result.isEmpty) {
      return null;
    }

    return double.tryParse(result.first[0].toString());
  }

  // =========================
  // GET OWNER EMAIL
  // =========================
  static Future<String?> getOwnerEmail(String deviceId) async {
    final result = await database.execute(
      '''
      SELECT email

      FROM stations

      WHERE device_id=\$1

      LIMIT 1

      ''',

      parameters: [deviceId],
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first[0].toString();
  }

  // =========================
  // GET CONTROL CENTER EMAIL
  // =========================
  static Future<String> getControlCenterEmail() async {
    return "controlcenter@sona.com";
  }
}
