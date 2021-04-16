import 'package:despesastable/provider/providerGastos.dart';
import 'package:despesastable/utils/approutes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListarDespesas extends StatefulWidget {
  @override
  _ListarDespesasState createState() => _ListarDespesasState();
}

class _ListarDespesasState extends State<ListarDespesas> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderGastos>(context);
    LocalKey _headingRowKey;

    List<ProviderGastos> dados = provider.itemList
        .map((e) => ProviderGastos(
              id: e.id,
              descricao: e.descricao,
              valor: e.valor,
              formaPagamento: e.formaPagamento,
              pagou: e.pagou,
              salario: e.salario,
            ))
        .toList();

    bool verificarLista() {
      if (provider.valorTotal == null) {
        return false;
      } else {
        return true;
      }
    }

    bool existData() {
      if (provider.lenghtList == 0) {
        return false;
      } else {
        return true;
      }
    }

    bool verificaSobrouNegativo() {
      if (provider.diferenca() < 0) {
        return true;
      } else {
        return false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Despesas'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/cartao.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            existData()
                ? SingleChildScrollView(
                    controller: ScrollController(),
                    physics: ScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: MediaQuery.of(context).size.width / 9,
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
                        DataColumn(label: Text('Pagou?')),
                      ],
                      rows: dados
                          .map(
                            (e) => DataRow(
                              key: _headingRowKey,
                              cells: [
                                DataCell(
                                  Text(
                                    e.descricao.toString(),
                                  ),
                                  showEditIcon: true,
                                  onTap: () {
                                    Provider.of<ProviderGastos>(context,
                                            listen: false)
                                        .removeItem(e.id);
                                    Provider.of<ProviderGastos>(context,
                                            listen: false)
                                        .diferenca();
                                  },
                                ),
                                DataCell(
                                  Text(
                                    'R\$ ${e.valor.toStringAsFixed(2)}',
                                  ),
                                  showEditIcon: true,
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        AppRoutes.HOME,
                                        arguments: e);
                                  },
                                ),
                                DataCell(
                                  FittedBox(
                                    child: Text(
                                      e.formaPagamento,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(e.pagou),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
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
                  ),
            SizedBox(
              height: 10,
            ),
            verificarLista()
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        existData()
                            ? resultadoCalculoDespesa(
                                dados.first.salario.toStringAsFixed(2),
                                Colors.blue,
                                'Salario')
                            : Text(''),
                        SizedBox(height: 10),
                        resultadoCalculoDespesa(
                            provider.calcularGastos().toStringAsFixed(2),
                            Colors.red,
                            'Total de Gastos'),
                        SizedBox(height: 10),
                        Container(
                          alignment: Alignment.center,
                          width: 200,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: verificaSobrouNegativo()
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              verificaSobrouNegativo()
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
                        )
                        // resultadoCalculoDespesa(
                        //     provider.diferenca().toStringAsFixed(2),
                        //     Colors.green,
                        //     'Sobrou'),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Ops! Você não tem despesa cadastrada...',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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
