import 'package:mysql1/mysql1.dart';

Future<void> connectToDMS() async {
  final conn = await MySqlConnection.connect(
    ConnectionSettings(
      host: 'your-dms-address.aliyuncs.com',
      port: 3306, // typical MySQL port
      user: 'username',
      password: 'password',
      db: 'database_name',
    ),
  );

  var results = await conn.query('SELECT * FROM your_table');
  for (var row in results) {
    print(row);
  }

  await conn.close();
}
