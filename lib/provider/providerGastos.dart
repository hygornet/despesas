import 'dart:math';

import 'package:despesastable/database/db_data.dart';
import 'package:flutter/cupertino.dart';

class ProviderGastos with ChangeNotifier {
  int id;
  String descricao;
  double valor;
  double valorTotal;
  String formaPagamento;
  String pagou;
  double salario;
  double valorPago;
  double diff;

  ProviderGastos({
    this.id,
    this.descricao,
    this.valor,
    this.valorTotal,
    this.formaPagamento,
    this.pagou,
    this.salario,
    this.valorPago,
    this.diff,
  });

  List<ProviderGastos> _item = [];
  List<ProviderGastos> get itemList => [..._item];

  //Tamanho da lista.
  int get lenghtList {
    return _item.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'valor': valor,
      'formaPagamento': formaPagamento,
      'pagou': pagou,
      'salario': salario,
    };
  }

  Future<void> adicionarGastos(ProviderGastos gastos) async {
    _item.add(
      ProviderGastos(
        id: Random().nextInt(1000),
        descricao: gastos.descricao,
        valor: gastos.valor,
        formaPagamento: gastos.formaPagamento,
        pagou: gastos.pagou,
        salario: gastos.salario,
      ),
    );
    DbData.insert(
      'despesas',
      {
        'id': gastos.id,
        'descricao': gastos.descricao,
        'valor': gastos.valor,
        'formaPagamento': gastos.formaPagamento,
        'pagou': gastos.pagou,
        'salario': gastos.salario,
      },
    );

    notifyListeners();
  }

  Future<void> listarDespesas() async {
    final dataList = await DbData.getData('despesas');
    _item = dataList
        .map(
          (item) => ProviderGastos(
            id: item['id'],
            descricao: item['descricao'],
            valor: item['valor'],
            formaPagamento: item['formaPagamento'],
            pagou: item['pagou'],
            salario: item['salario'],
          ),
        )
        .toList();
    notifyListeners();
  }

  double calcularGastos() {
    if (lenghtList != 0) {
      ProviderGastos calculo = _item.reduce((value, element) =>
          ProviderGastos(valor: value.valor + element.valor));
      return valorTotal = calculo.valor;
    } else {
      return valorTotal = 0;
    }
  }

  double diferenca() {
    if (lenghtList == null || lenghtList == 0) {
      return 0;
    } else {
      return _item.first.salario - valorTotal;
    }
  }

  void removeItem(int id) {
    final index = _item.indexWhere((gastos) => gastos.id == id);

    if (index >= 0) {
      _item.removeWhere((gastos) => gastos.id == id);
      DbData.deletarDespesa('despesas', id);
      notifyListeners();
    }
  }

  void atualizarGastos(ProviderGastos gastos) {
    if (gastos.id == null && gastos == null) {
      return;
    }
    final index = _item.indexWhere((e) => e.id == gastos.id);

    if (index >= 0) {
      _item[index] = gastos;
      DbData.update(
          'despesas',
          ProviderGastos(
            id: gastos.id,
            descricao: gastos.descricao,
            valor: gastos.valor,
            formaPagamento: gastos.formaPagamento,
            pagou: gastos.pagou,
            salario: gastos.salario,
          ));
      notifyListeners();
    }
  }
}
