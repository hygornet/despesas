import 'package:despesastable/provider/providerGastos.dart';
import 'package:despesastable/screens/form.dart';
import 'package:despesastable/screens/listarDespesas.dart';
import 'package:despesastable/utils/approutes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ProviderGastos()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Despesas',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          AppRoutes.HOME: (ctx) => FormScreen(),
          AppRoutes.FORM: (ctx) => ListarDespesas(),
        },
      ),
    );
  }
}
