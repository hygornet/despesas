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

  //MÉTODO QUE RETORNA O SALÁRIO DO BANCO DE DADOS.
  Future getSalario() async {
    final carregarSalario = await DbData.retornarSalario()
        .then((value) => salary = value.toString());
    return carregarSalario;
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
        title: Text('Lista de Despesas'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/download.png',
              fit: BoxFit.cover,
            ),
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
                  return contemDados()
                      ? DataTable(
                          columnSpacing: MediaQuery.of(context).size.width / 15,
                          showBottomBorder: true,
                          columns: [
                            DataColumn(
                              label: Text('Descrição'),
                              tooltip:
                                  'Se você clicar sobre a descrição irá excluir o registro.',
                            ),
                            DataColumn(
                              label: Text('Valor'),
                              tooltip:
                                  'Se você clicar sobre o valor você poderá atualizar o registro.',
                            ),
                            DataColumn(
                              label: Flexible(child: Text('Pagamento')),
                            ),
                            DataColumn(
                              label: Text('Pagou?'),
                            ),
                          ],
                          rows: dados
                              .map(
                                (gastos) => DataRow(
                                  key: _headingRowKey,
                                  cells: [
                                    DataCell(
                                      Text(
                                        toBeginningOfSentenceCase(
                                            gastos.descricao.toString()),
                                      ),
                                      showEditIcon: true,
                                      onTap: () {
                                        Provider.of<ProviderGastos>(context,
                                                listen: false)
                                            .removeItem(gastos.id);
                                        showSnackBar();
                                        Provider.of<ProviderGastos>(context,
                                                listen: false)
                                            .diferenca();
                                      },
                                    ),
                                    DataCell(
                                      Text(
                                        'R\$ ${gastos.valor.toStringAsFixed(2)}',
                                      ),
                                      showEditIcon: true,
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            AppRoutes.HOME,
                                            arguments: gastos);
                                      },
                                    ),
                                    DataCell(
                                      FittedBox(
                                        child: Text(
                                          gastos.formaPagamento,
                                        ),
                                      ),
                                    ),
                                    if (gastos.pagou == "Sim")
                                      DataCell(
                                        Text(
                                          gastos.pagou,
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (gastos.pagou == "Não")
                                      DataCell(
                                        Text(
                                          gastos.pagou,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                              .toList(),
                        )
                      : Column(
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
                            )),
                          ],
                        );
                }
              },
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  contemDados()
                      ? resultadoCalculoDespesa(
                          salary,
                          Colors.blue,
                          'Salario',
                        )
                      : Text(''),
                  SizedBox(height: 10),
                  resultadoCalculoDespesa(
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
                            ? Column(
                                children: [
                                  Text('Você está devendo:'),
                                  Text(
                                    'R\$ ${provider.diferenca().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Text('Sobrou'),
                                  Text(
                                    'R\$ ${provider.diferenca().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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

  Container resultadoCalculoDespesa(String provider, Color color, String text) {
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
            'R\$ $provider',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
