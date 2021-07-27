import 'package:despesastable/database/db_data.dart';
import 'package:despesastable/provider/providerGastos.dart';
import 'package:despesastable/utils/approutes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ListarDespesas extends StatefulWidget {
  @override
  _ListarDespesasState createState() => _ListarDespesasState();
}

class _ListarDespesasState extends State<ListarDespesas> {
  Future carregarLista;
  String salary;
  String valorPagoTotal;
  bool isSearch = false;
  bool changeIconSearch = false;
  var searchController = TextEditingController();

  //MÉTODO QUE RETORNA O SALÁRIO DO BANCO DE DADOS.
  Future getSalario() async {
    final carregarSalario = await DbData.retornarSalario()
        .then((value) => salary = value.toString());
    return carregarSalario;
  }

  Future getPago() async {
    final showPago = await DbData.valorTotalPago()
        .then((value) => valorPagoTotal = value.toString());
    return showPago;
  }

  @override
  void initState() {
    super.initState();

    //LISTA TODAS AS DESPESAS CADASTRADAS NO BANCO DE DADOS.
    carregarLista =
        Provider.of<ProviderGastos>(context, listen: false).listarDespesas();

    //GUARDO A INFORMAÇÃO DO SALÁRIO DO BANCO DE DADOS NA VARIÁVEL SALÁRIO.
    getSalario().then((value) {
      setState(() {
        salary = value.toString();
      });
    });

    getPago().then((value) {
      setState(() {
        valorPagoTotal = value.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderGastos>(context);
    LocalKey _headingRowKey;

    List<ProviderGastos> dados = provider.itemList
        .map((gastos) => ProviderGastos(
              id: gastos.id,
              descricao: gastos.descricao,
              valor: gastos.valor,
              formaPagamento: gastos.formaPagamento,
              pagou: gastos.pagou,
              salario: gastos.salario,
            ))
        .toList();

    //VERIFICA SE A LISTA É VAZIA.
    bool contemDados() {
      if (provider.lenghtList == 0) {
        return false;
      } else {
        return true;
      }
    }

    //VERIFICA SE O QUE SOBROU É NEGATIVO OU NÃO.
    bool resultadoIsNegative() {
      if (provider.diferenca() < 0) {
        return true;
      } else {
        return false;
      }
    }

    void showSnackBar() {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Row(
          children: <Widget>[
            Icon(
              Icons.highlight_remove_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              "Despesa excluída!",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        duration: Duration(milliseconds: 1500),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return Scaffold(
      appBar: AppBar(
        title: isSearch
            ? TextField(
                controller: searchController,
                onChanged: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() {
                      changeIconSearch = true;
                    });
                  } else {
                    setState(() {
                      changeIconSearch = false;
                    });
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Digite o gasto que deseja procurar...',
                    labelStyle: TextStyle(
                      color: Colors.white,
                    )),
                style: TextStyle(
                  color: Colors.white,
                ),
              )
            : Text('Lista de Despesas'),
        centerTitle: true,
        actions: [
          changeIconSearch
              ? IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.send_sharp),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      isSearch = !isSearch;
                    });
                  },
                  icon: Icon(Icons.search),
                ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder(
              future: carregarLista,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Text('Carregando...'));
                } else if (snapshot.connectionState == ConnectionState.none) {
                  return Text(
                      'Ops, infelizmente houve algum problema.\nEntre em contato com o dev!');
                } else {
                  return Text('Oi');
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  contemDados()
                      ? _resultadoCalculo(
                          salary,
                          Colors.blue,
                          'Salario',
                        )
                      : Text(''),
                  SizedBox(height: 10),
                  contemDados()
                      ? _resultadoCalculo(
                          valorPagoTotal,
                          Colors.green,
                          'Valor Pago',
                        )
                      : Text(''),
                  SizedBox(height: 10),
                  _resultadoCalculo(
                    provider.calcularGastos().toStringAsFixed(2),
                    Colors.red,
                    'Total de Gastos',
                  ),
                  SizedBox(height: 10),
                  Container(
                    alignment: Alignment.center,
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color:
                            resultadoIsNegative() ? Colors.red : Colors.green,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        resultadoIsNegative()
                            ? _containerSobrou(provider, 'Você está devendo')
                            : _containerSobrou(provider, 'Sobrou'),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _containerSobrou(ProviderGastos provider, String texto) {
    return Column(
      children: [
        Text(texto),
        Text(
          'R\$ ${provider.diferenca().toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  _resultadoCalculo(String acessData, Color color, String text) {
    return Container(
      alignment: Alignment.center,
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: color,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text),
          Text(
            'R\$ $acessData',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

_listaVazia() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        height: 20,
      ),
      Center(
        child: Image.asset(
          "assets/images/money-png.png",
          fit: BoxFit.cover,
          height: 150,
        ),
      ),
      SizedBox(
        height: 40,
      ),
      Text('Infelizmente não há registros de gastos cadastrado.'),
    ],
  );
}

_removerGasto(BuildContext context, ProviderGastos gastos) {
  Provider.of<ProviderGastos>(context, listen: false).removeItem(gastos.id);
}

_diferenca(BuildContext context) {
  Provider.of<ProviderGastos>(context, listen: false).diferenca();
}
