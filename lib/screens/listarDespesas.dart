import 'package:despesastable/database/db_data.dart';
import 'package:despesastable/provider/providerGastos.dart';
import 'package:despesastable/utils/approutes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListarDespesas extends StatefulWidget {
  @override
  _ListarDespesasState createState() => _ListarDespesasState();
}

class _ListarDespesasState extends State<ListarDespesas> {
  Future carregarLista;
  String salary;
  String valorPagoSim;
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
    valorPagoSim = await DbData.valorTotalPago()
        .then((value) => valorPagoSim = value.toString());
    return valorPagoSim;
  }

  @override
  void initState() {
    super.initState();

    //LISTA TODAS AS DESPESAS CADASTRADAS NO BANCO DE DADOS
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
        valorPagoSim = value.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderGastos>(context);

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

    bool existeDespesa() {
      if (provider.lenghtList == null) {
        return true;
      } else {
        return false;
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _boxValores(
                    Colors.red,
                    'lib/assets/images/1694347.png',
                    'Despesa total',
                    'R\$ ${Provider.of<ProviderGastos>(context, listen: false).calcularGastos().toStringAsFixed(2)}'),
                resultadoIsNegative()
                    ? _boxValores(
                        Colors.red[700],
                        'lib/assets/images/attention.png',
                        'Devendo',
                        'R\$ ${Provider.of<ProviderGastos>(context, listen: false).diferenca().toStringAsFixed(2)}',
                      )
                    : _boxValores(
                        Colors.amber,
                        'lib/assets/images/dollar.png',
                        'Sobrando',
                        'R\$ ${Provider.of<ProviderGastos>(context, listen: false).diferenca().toStringAsFixed(2)}',
                      ),
                _boxValores(Colors.green, 'lib/assets/images/check.png', 'Pago',
                    'R\$ ${valorPagoSim.toString()}'),
              ],
            ),
            SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height / 1.6,
              child: ListView.builder(
                itemCount: dados.length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 4,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Dismissible(
                            confirmDismiss: (direction) {
                              return showDialog<bool>(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Você tem certeza desta ação de exclusão?'),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: const Text('Sim'),
                                        onPressed: () {
                                          Provider.of<ProviderGastos>(context,
                                                  listen: false)
                                              .removeItem(dados[index].id);
                                          showSnackBar();
                                          Navigator.pop(context, true);
                                        },
                                      ),
                                      ElevatedButton(
                                        child: const Text('Não'),
                                        onPressed: () {
                                          Navigator.pop(context,
                                              false); // showDialog() returns false
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.delete, color: Colors.white),
                                    Text('Deletar',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                            key: ValueKey('Dismiss'),
                            child: ListTile(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.grey[100],
                                      title: Column(
                                        children: [
                                          Icon(
                                            Icons.warning,
                                            color: Colors.amber,
                                          ),
                                          SizedBox(height: 10),
                                          Text('Detalhes da Despesa')
                                        ],
                                      ),
                                      content: Container(
                                        height: 150,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('Nome da despesa: '),
                                                Text(
                                                  dados[index]
                                                      .descricao
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text('Forma de Pagamento: '),
                                                Text(
                                                  dados[index]
                                                      .formaPagamento
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text('Valor da despesa: '),
                                                Text(
                                                  'R\$ ${dados[index].valor.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text('Pagou? '),
                                                Text(
                                                  dados[index].pagou.toString(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  TextButton.icon(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              AppRoutes.HOME,
                                                              arguments:
                                                                  dados[index]);
                                                    },
                                                    icon: Icon(Icons.sync_alt,
                                                        color: Colors.green),
                                                    label: Text('Alterar'),
                                                  ),
                                                  TextButton.icon(
                                                    onPressed: () {
                                                      Provider.of<ProviderGastos>(
                                                              context,
                                                              listen: false)
                                                          .removeItem(
                                                              dados[index].id);
                                                      showSnackBar();
                                                      Navigator.pop(
                                                          context, true);
                                                    },
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    label: Text('Excluir'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                backgroundImage: dados[index].pagou == "Sim"
                                    ? AssetImage(
                                        'lib/assets/images/check.png',
                                      )
                                    : AssetImage(
                                        'lib/assets/images/low-price.png',
                                      ),
                              ),
                              title: Text(dados[index].descricao),
                              subtitle: Text(dados[index].formaPagamento),
                              trailing: Text(
                                  'R\$ ${dados[index].valor.toStringAsFixed(2)}'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _boxValores(Color color, String image, String texto, String valor) {
    return Container(
      width: 115,
      height: 130,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 3,
            offset: Offset(4, 6),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          Image.asset(
            image,
            fit: BoxFit.cover,
            height: 48,
            width: 48,
          ),
          SizedBox(height: 10),
          Text(
            texto,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            valor.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  double diferenca(BuildContext context) {
    return Provider.of<ProviderGastos>(context, listen: false).diferenca();
  }
}
