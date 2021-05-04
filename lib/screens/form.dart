import 'package:despesastable/database/db_data.dart';
import 'package:despesastable/provider/providerGastos.dart';
import 'package:despesastable/utils/approutes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';

class FormScreen extends StatefulWidget {
  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  var descricaoController = TextEditingController();
  var valorController = TextEditingController();
  var pagouController = TextEditingController();
  var formaPagamentoController = TextEditingController();
  var salarioController = TextEditingController();
  bool fieldSalario = true;
  var _key = GlobalKey<FormState>();
  var _formData = Map<String, dynamic>();
  List<String> _options = ['Sim', 'Não'];
  List<String> _methodPayment = [
    'Boleto',
    'Cartão de Crédito',
    'Cartão de Débito',
    'Dinheiro',
    'PIX',
    'Transferência',
  ];

  getSalario() async {
    final _carregarSalario = await DbData.returnRecord()
        .then((value) => salarioController.text = value.toString());
    return _carregarSalario;
  }

  @override
  void initState() {
    super.initState();
    if (Provider.of<ProviderGastos>(context, listen: false).lenghtList == 0) {
      return;
    }
    getSalario().toString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final recebeDadosListarDespesas =
        ModalRoute.of(context).settings.arguments as ProviderGastos;

    if (recebeDadosListarDespesas != null) {
      if (_formData.isEmpty) {
        _formData['id'] = recebeDadosListarDespesas.id;
        _formData['descricao'] = recebeDadosListarDespesas.descricao;
        _formData['valor'] = recebeDadosListarDespesas.valor;
        _formData['formaPagamento'] = recebeDadosListarDespesas.formaPagamento;
        _formData['pagou'] = recebeDadosListarDespesas.pagou;
        _formData['salario'] = recebeDadosListarDespesas.salario;
        descricaoController.text = _formData['descricao'];
        valorController.text = _formData['valor'].toString();
        salarioController.text = _formData['salario'].toString() ?? 0;
        fieldSalario = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    final gastosProvider = Provider.of<ProviderGastos>(context);

    void addGastos() {
      //VERIFICO SE O FORMULÁRIO NÃO É VÁLIDO. SE ELE FOR INVÁLIDO, SÓ RETORNA PARA O FORMULÁRIO.
      if (!_key.currentState.validate()) {
        return;
      }

      //SALVA OS DADOS DO FORMULÁRIO.
      _key.currentState.save();

      //GUARDA TODOS OS DADOS DIGITADOS NO FORMULÁRIO.
      final valuesGastos = ProviderGastos(
        id: _formData['id'],
        descricao: _formData['descricao'],
        valor: double.parse(_formData['valor']),
        formaPagamento: _formData['formaPagamento'],
        pagou: _formData['pagou'],
        salario: double.parse(_formData['salario']),
      );

      //SE O ID FOR NULLO, QUER DIZER QUE É UM NOVO USUÁRIO, SENDO ASSIM, CADASTRE O NOVO USUÁRIO.
      if (_formData['id'] == null) {
        //ADICIONA NOVO USUÁRIO.
        gastosProvider.adicionarGastos(valuesGastos);
        //CALCULA OS GASTOS.
        gastosProvider.calcularGastos();
        fieldSalario = false;
      } else if (_formData['id'] != null) {
        //SE FOR UM ID EXISTENTE, CHAMA O MÉTODO DE ATUALIZAR.
        gastosProvider.atualizarGastos(valuesGastos);
        //CALCULA OS GASTOS.
        gastosProvider.calcularGastos();
      }
    }

    void clear() {
      descricaoController.text = "";
      valorController.text = "";
      pagouController.text = "";
      formaPagamentoController.text = "";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Despesa'),
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
        child: Column(
          children: [
            Form(
              key: _key,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextFormField(
                      onSaved: (newValue) => _formData['salario'] = newValue,
                      enabled: fieldSalario,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      controller: salarioController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.monetization_on),
                        labelText: 'Digite seu Saldo Atual',
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    TextFormField(
                      onSaved: (newValue) => _formData['descricao'] = newValue,
                      controller: descricaoController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        icon: Icon(Icons.description_outlined),
                        labelText: 'Digite a Descrição',
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    TextFormField(
                      onSaved: (newValue) => _formData['valor'] = newValue,
                      controller: valorController,
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (_) =>
                          node.unfocus(), // Submit and hide keyboard
                      decoration: InputDecoration(
                        icon: Icon(Icons.attach_money),
                        labelText: 'Valor da Despesa',
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButton(
                      icon: Icon(Icons.payment),
                      isExpanded: true,
                      value: _formData['formaPagamento'],
                      onChanged: (value) {
                        setState(() {
                          _formData['formaPagamento'] = value;
                        });
                      },
                      hint: Text('Forma de Pagamento'),
                      items: _methodPayment
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 20),
                    DropdownButton(
                      icon: Icon(Icons.attach_money),
                      isExpanded: true,
                      value: _formData['pagou'],
                      onChanged: (value) {
                        setState(() {
                          _formData['pagou'] = value;
                        });
                      },
                      hint: Text('Pagou?'),
                      items: _options
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      child: TextButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blueAccent),
                        ),
                        onPressed: () {
                          addGastos();
                          clear();
                        },
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Adicionar gasto',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: TextButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blueAccent),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.FORM);
                        },
                        icon: Icon(
                          Icons.table_rows,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Visualizar gastos',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: TextButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blueAccent),
                        ),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Confirmação de ação'),
                              content: Text(
                                  'Você irá resetar todas suas despesas.\nVocê está certo disso?'),
                              actions: [
                                ElevatedButton(
                                  child: Text('Não'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await DbData.deletarTabela()
                                        .then((value) async {
                                      await DbData.criarTabela();
                                    });

                                    Phoenix.rebirth(context);
                                  },
                                  child: Text('Sim'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Reiniciar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
