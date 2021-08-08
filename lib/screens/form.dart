import 'package:despesastable/database/db_data.dart';
import 'package:despesastable/provider/providerGastos.dart';
import 'package:despesastable/utils/approutes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final carregarSalario = await DbData.retornarSalario().then((value) {
      if (value != null) {
        salarioController.text = value.toString();
      } else {
        value = 0;
      }
    });
    return carregarSalario;
  }

  void showSnackBar(String operation) {
    final snackBar = SnackBar(
      // background color of your snack-bar
      backgroundColor: Colors.green,
      // make the content property take a Row
      content: Row(
        children: <Widget>[
          // add your preferred icon here
          Icon(
            Icons.add_box_rounded,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          // add your preferred text content here
          Text(
            "Despesa $operation!",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
      // the duration of your snack-bar
      duration: Duration(milliseconds: 1500),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();

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
        salarioController.text = _formData['salario'].toString();
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

      gastosProvider.id = _formData['id'];
      gastosProvider.descricao = _formData['descricao'];
      gastosProvider.valor = double.parse(_formData['valor']);
      gastosProvider.formaPagamento = _formData['formaPagamento'];
      gastosProvider.pagou = _formData['pagou'];
      gastosProvider.salario = double.parse(_formData['salario']);

      //SE O ID FOR NULLO, QUER DIZER QUE É UM NOVO USUÁRIO, SENDO ASSIM, CADASTRE O NOVO USUÁRIO.
      if (_formData['id'] == null) {
        //ADICIONA NOVO USUÁRIO.

        gastosProvider.adicionarGastos(gastosProvider);

        //CALCULA OS GASTOS.
        gastosProvider.calcularGastos();
        //EXIBE UMA MENSAGEM NO RODAPE DO APLICATIVO INFORMANDO QUE A DESPESA FOI CADASTRADA.
        showSnackBar('Cadastrada');
      } else if (_formData['id'] != null) {
        //SE FOR UM ID EXISTENTE, CHAMA O MÉTODO DE ATUALIZAR.
        gastosProvider.atualizarGastos(gastosProvider);
        //CALCULA OS GASTOS.
        gastosProvider.calcularGastos();
        //EXIBE UMA MENSAGEM NO RODAPE DO APLICATIVO INFORMANDO QUE A DESPESA FOI CADASTRADA.
        showSnackBar('Atualizada');
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
              'lib/assets/images/logo2.png',
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
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Por favor, preencha o campo.';
                        } else {
                          return null;
                        }
                      },
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
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Por favor, preencha o campo.';
                        } else {
                          return null;
                        }
                      },
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
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Por favor, preencha o campo.';
                        } else {
                          return null;
                        }
                      },
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
                                  child: Text('Sim'),
                                  onPressed: () async {
                                    await DbData.deletarTabela()
                                        .then((value) async {
                                      await DbData.criarTabela();
                                    });

                                    Phoenix.rebirth(context);
                                  },
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
