import 'package:flutter/material.dart';
import 'package:notasdiarias/database/database_helper.dart';
import 'package:notasdiarias/models/anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  List<Anotacao> anotacaoList = List();
  var _db = DatabaseHelper();

  _salvarAnotacao({Anotacao anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    //Salvar
    if (anotacaoSelecionada == null) {
      Anotacao anotacao = Anotacao(
        titulo: titulo,
        descricao: descricao,
        data: DateTime.now().toString(),
      );

      int resultado = await _db.salvar(anotacao);
    } else {
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
    }

    _tituloController.clear();
    _descricaoController.clear();

    obterAnotacoes();
  }

  obterAnotacoes() async {
    List anotacoes = await _db.obterAnotacoes();
    List<Anotacao> anotacoesTemp = List();
    for (var a in anotacoes) {
      Anotacao anotacao = Anotacao.fromMap(a);
      anotacoesTemp.add(anotacao);
    }

    setState(() {
      anotacaoList = anotacoesTemp;
    });

    anotacoesTemp = null;
    //print(anotacoes);
    return anotacoes;
  }

  formatarData(String data) {
    initializeDateFormatting("pt_BR");
    // var formatador = DateFormat("d/MM/y H:m");
    var formatador = DateFormat.yMd("pt_BR");
    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);
    return dataFormatada;
  }

  _removerAnotacao(int id) async {
    await _db.excluir(id);
    obterAnotacoes();
  }

  @override
  void initState() {
    super.initState();

    obterAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Anotações"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: anotacaoList.length,
              itemBuilder: (context, index) {
                final item = anotacaoList[index];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text(item.titulo),
                    subtitle:
                        Text("${formatarData(item.data)} - ${item.descricao}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _exibirDialog(anotacao: item);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _removerAnotacao(item.id);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _exibirDialog();
        },
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _exibirDialog({Anotacao anotacao}) {
    String textoAtualizarSalvar = "";
    //Salvando
    if (anotacao == null) {
      _tituloController.text = "";
      _descricaoController.text = "";
      textoAtualizarSalvar = "Adicionar";
    } else {
      //Atualizando
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      textoAtualizarSalvar = "Atualizar";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$textoAtualizarSalvar anotação"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: _descricaoController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Descrição",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            FlatButton(
              onPressed: () {
                _salvarAnotacao(anotacaoSelecionada: anotacao);
              },
              child: Text("Salvar"),
            )
          ],
        );
      },
    );
  }
}
