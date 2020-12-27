import 'package:notasdiarias/models/anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final String nomeTabela = "anotacao";

  static final DatabaseHelper _databaseHelper = DatabaseHelper._internal();
  Database _db;
  factory DatabaseHelper() {
    return _databaseHelper;
  }

  DatabaseHelper._internal();

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await inicializarDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql =
        "CREATE TABLE $nomeTabela (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo VARCHAR, descricao TEXT, data DATETIME)";
    await db.execute(sql);
  }

  inicializarDB() async {
    final caminho = await getDatabasesPath();
    final local = join(caminho, "banco_minhas_anotacoes.db");
    var db = await openDatabase(local, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> salvar(Anotacao anotacao) async {
    var bancoDados = await db;

    int resultado = await bancoDados.insert(nomeTabela, anotacao.toMap());

    print("RESULTADO: $resultado");
    return resultado;
  }

  obterAnotacoes() async {
    var bancoDados = await db;
    String sql = "SELECT * FROM $nomeTabela ORDER BY data DESC";
    List anotacoes = await bancoDados.rawQuery(sql);
    return anotacoes;
  }

  Future<int> atualizarAnotacao(Anotacao anotacao) async {
    var bancoDados = await db;
    return await bancoDados.update(nomeTabela, anotacao.toMap(),
        where: "id = ?", whereArgs: [anotacao.id]);
  }

  Future<int> excluir(int id) async {
    var bancoDados = await db;
    return await bancoDados
        .delete(nomeTabela, where: "id = ?", whereArgs: [id]);
  }
}
