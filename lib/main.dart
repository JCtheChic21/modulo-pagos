import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mercadopago_sdk/mercadopago_sdk.dart';
import 'package:pagos/utils/var_globales.dart' as globals;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Mercado Pago',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.red.shade700,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  initState() {
    const channelMercadoPagoRespuesta =
        const MethodChannel('cracks.com/pagosRespuesta');
    channelMercadoPagoRespuesta.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "mercadoPagoOkey":
          var idPago = call.arguments[0];
          var status = call.arguments[1];
          var statusDetails = call.arguments[2];
          return mercadoPagoOkey(idPago, status, statusDetails);
        case "mercadoPagoError":
          var error = call.arguments[0];
          return mercadoPagoError(error);
      }
    });
    super.initState();
  }

  void mercadoPagoOkey(idPago, status, statusDetails) {
    print("idPago: $idPago");
    print("status: $status");
    print("statusDetails: $statusDetails");
  }

  void mercadoPagoError(error) {
    print("error: $error");
  }

  Future<Map<String, dynamic>> creaPreferencia() async {
    var mp = MP(globals.mercadoPagoClientID, globals.mercadoPagoClientSecret);
    var preference = {
      "items": [
        {
          "title": "Test",
          "quantity": 1,
          "currency_id": "MXN",
          "unit_price": 10.4
        }
      ],
      "payer": {"name": "JCtheChic", "email": "ing.jcgncracks@gmail.com"},
      // Determinas los tipos de pagos.
      //"payment_methods": {
      //        "excluded_payment_types": [
      //          {"id": "atm"},
      //          {"id": "prepaid_card"},
      //        ],
      //      },
    };
    var result = await mp.createPreference(preference);
    return result;
  }

  Future<void> ejecutarMercadoPago() async {
    //print('Ejecutando Mercado Pago...');
    creaPreferencia().then((result) {
      if (result != null) {
        var preferenceID = result['response']['id'];
        //print('Preferencia: ${preferenceID}');
        try {
          const channelMercadoPago = const MethodChannel('cracks.com/pagos');
          final response = channelMercadoPago.invokeMethod(
              'mercadoPago', <String, dynamic>{
            "publicKey": globals.mercadoPagoTestPublicKey,
            "preferenceID": preferenceID
          });
          print('response: $response');
        } on PlatformException catch (e) {
          print('Error: ${e.message}');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mercado Pago'),
      ),
      body: Center(
        child: MaterialButton(
          onPressed: ejecutarMercadoPago,
          color: Colors.red,
          child: Text('¡Comprar con mercado pago!',
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
