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

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Despesas'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          existData()
              ? DataTable(
                  columnSpacing: 40,
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
                                e.valor.toString(),
                              ),
                              showEditIcon: true,
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.HOME, arguments: e);
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
                      "assets/images/20-201026_money-png-money-vector-png.png",
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
                          ? Text('Salário: ' + dados.first.salario.toString())
                          : Text(''),
                      Text('Valor dos Gastos: ' +
                          provider.calcularGastos().toString()),
                      Text('Sobrou: ' + provider.diferenca().toString()),
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
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
