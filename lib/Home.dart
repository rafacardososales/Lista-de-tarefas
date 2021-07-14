import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaTarefa = [];
  Map<String,dynamic> _ultimaTarefaRemovida = Map();
  TextEditingController _controllerTarefa = TextEditingController();


  //Metodo responsavel por criar a pasta no aparelho do usuario onde será salvo os aquivos.
  Future <File> _getFile()async{
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }


  //Metodo responsavel por salvar cada tarefa digitada pelo usuario
  _salvarTarefa(){
    String textoDigitado = _controllerTarefa.text;

    Map<String,dynamic> tarefa =  Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      _listaTarefa.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text = " ";
  }


  // Metodo responsavel por salvar os arquivos na memoria do aparelho.
  _salvarArquivo() async {

    var arquivo = await _getFile();
    String dados = json.encode(_listaTarefa);
    arquivo.writeAsString(dados);
    //print ("Caminho: " +diretorio.path);
  }



  //Metodo responsavel por ler todos os aquivos salvos.
  _lerArquivo()async{
    try{
      final arquivo = await _getFile();
      return arquivo.readAsString();
    }catch(e){
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lerArquivo().then((dados){
      setState(() {
        _listaTarefa = json.decode(dados);
      });
    });
  }

  Widget criarItemLista(context, index){
    //final item = _listaTarefa[index] ["titulo"];
    return Dismissible(
        key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction){

          //recupera o ultimo item removido
          _ultimaTarefaRemovida = _listaTarefa[index] ;

          //remove item da lista
          _listaTarefa.removeAt(index);
          _salvarArquivo();

          //snackbar
          final snackbar = SnackBar(
              backgroundColor: Colors.redAccent[100],
              content: Text("Tarefa excluida!!!"),
              action: SnackBarAction(
                  textColor: Colors.blueGrey,
                  label: "Desfazer",
                  onPressed: (){

                    // insere nvoamente o item removido na lista
                    setState(() {
                      _listaTarefa.insert(index, _ultimaTarefaRemovida);
                    });
                    _salvarArquivo();
                  }
              ),
          );
          
          Scaffold.of(context).showSnackBar(snackbar);
        },
        background: Container(
          color: Colors.redAccent[100],
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
          title: Text(_listaTarefa[index] ['titulo']),
          value: _listaTarefa[index] ['realizada'],
          onChanged: (valorAlterado){
            setState(() {
              _listaTarefa[index] ['realizada'] = valorAlterado;
            });
            _salvarArquivo();
          },
        )
    );
  }


  @override
  Widget build(BuildContext context) {

    //_salvarArquivo();

    //print("itens:" + DateTime.now().microsecondsSinceEpoch.toString());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text("Lista de tarefas"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _listaTarefa.length,
              itemBuilder: criarItemLista,
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
        onPressed: (){
          showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  title: Text("Adicionat tarefa"),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(
                      labelText: "Digite sua tarefa"
                    ),
                    onChanged: (text){

                    },
                  ),
                  actions: [
                    FlatButton(
                      child: Text("Cancelar"),
                      onPressed: ()=> Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text("Salvar"),
                      onPressed: (){
                        _salvarTarefa();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              }
          );
        },
      ),
    );
  }
}
