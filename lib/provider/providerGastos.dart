import 'dart:math';

import 'package:flutter/cupertino.dart';

class ProviderGastos with ChangeNotifier {
  int id;
  String descricao;
  double valor;
  double valorTotal;
  String formaPagamento;
  String pagou;
  double salario;

  ProviderGastos(
      {this.id,
      this.descricao,
      this.valor,
      this.valorTotal,
      this.formaPagamento,
      this.pagou,
      this.salario});

  List<ProviderGastos> _item = [];
  List<ProviderGastos> get itemList => [..._item];
  int get lenghtList {
    return _item.length;
  }

  void adicionarGastos(ProviderGastos gastos) {
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
      notifyListeners();
    }
  }
}
