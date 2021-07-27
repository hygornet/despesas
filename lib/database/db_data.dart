import 'package:despesastable/provider/providerGastos.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DbData {
  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'despesas.db'),
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE despesas (id INTEGER PRIMARY KEY AUTOINCREMENT, descricao TEXT, valor REAL, formaPagamento TEXT, pagou TEXT, salario REAL)");
      },
      version: 1,
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DbData.database();
    await db.insert(table, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> update(String table, ProviderGastos gastos) async {
    final db = await DbData.database();
    var result = await db
        .update(table, gastos.toMap(), where: "id = ?", whereArgs: [gastos.id]);
    return result;
  }

  static Future<void> deletarDespesa(String table, int id) async {
    final db = await DbData.database();
    await db.delete('despesas', where: "id = ?", whereArgs: [id]);
  }

  static Future retornarSalario() async {
    ProviderGastos gastos = ProviderGastos();
    final db = await DbData.database();
    List<Map> result = await db.rawQuery("SELECT salario FROM despesas");

    result.forEach((element) {
      gastos.salario = element['salario'];
    });
    return result.first.values.first;
  }

  static Future valorTotalPago() async {
    double total = 0.0;
    final db = await DbData.database();
    var resp =
        await db.rawQuery("SELECT valor FROM despesas WHERE pagou = 'Sim'");
    resp.forEach((element) {
      total += element['valor'];
    });
    return total;
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DbData.database();
    return db.query(table);
  }

  static Future<void> criarTabela() async {
    final db = await DbData.database();
    await db.execute(
        "CREATE TABLE IF NOT EXISTS despesas (id INTEGER PRIMARY KEY AUTOINCREMENT, descricao TEXT, valor REAL,  formaPagamento TEXT, pagou TEXT, salario REAL)");
  }

  static Future<void> deletarTabela() async {
    final db = await DbData.database();
    await db.execute("DROP TABLE IF EXISTS despesas");
  }
}
