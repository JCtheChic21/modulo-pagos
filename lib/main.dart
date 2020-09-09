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
      title: 'Cobro de membresias',
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

  bool _opcionDeMembresiaMensual = false;
  bool _opcionDeMembresiaAnual = false;
  int _opcionDePago = 0;

  Future<Map<String, dynamic>> creaPreferencia(nuevoItem, nuevoCliente) async {
    print(nuevoItem[0]);
    List<String> _item = List<String>();
    List<String> _payer = List<String>();
    _item = nuevoItem;
    _payer = nuevoCliente;
    String _title = _item[0];
    int _quantity = int.parse(_item[1]);
    String _currency = _item[2];
    double _price = double.parse(_item[3]);
    String _name = _payer[0];
    String _email = _payer[1];
    var mp = MP(globals.mercadoPagoClientID, globals.mercadoPagoClientSecret);
    var preference = {
      "items": [
        {
          "title": _title,
          "quantity": _quantity,
          "currency_id": _currency,
          "unit_price": _price,
          "operation_type": "recurring_payment",
        }
      ],
      "payer": {"name": _name, "email": _email},
    };
    var result = await mp.createPreference(preference);
    return result;
  }

  List<String> creaItem(
      String titulo, String cantidad, String moneda, String precio) {
    List<String> _item = List<String>();
    _item.add(titulo);
    _item.add(cantidad);
    _item.add(moneda);
    _item.add(precio);
    return _item;
  }

  List<String> creaCliente(String nombre, String correoElectronico) {
    List<String> _item = List<String>();
    _item.add(nombre);
    _item.add(correoElectronico);
    return _item;
  }

  void ejecutarMercadoPago(int opcionPago) async {
    if(opcionPago == 1) {
      creaPreferencia(creaItem("Plan Básico 499.00", "1", "MXN", "499.00"),
          creaCliente("Cliente de Prueba", "prueba@cliente.com"))
          .then((result) {
        if (result != null) {
          var preferenceID = result['response']['id'];
          try {
            const channelMercadoPago = const MethodChannel('cracks.com/pagos');
            final response = channelMercadoPago.invokeMethod(
                'mercadoPago', <String, dynamic>{
              "publicKey": globals.mercadoPagoTestPublicKey,
              "preferenceID": preferenceID
            });
          } on PlatformException catch (e) {
            print('Error: ${e.message}');
          }
        }
      });
    }
    if(opcionPago == 2) {
      creaPreferencia(creaItem("Plan Premium 749.00", "1", "MXN", "749.00"),
          creaCliente("Cliente de Prueba", "prueba@cliente.com"))
          .then((result) {
        if (result != null) {
          var preferenceID = result['response']['id'];
          try {
            const channelMercadoPago = const MethodChannel('cracks.com/pagos');
            final response = channelMercadoPago.invokeMethod(
                'mercadoPago', <String, dynamic>{
              "publicKey": globals.mercadoPagoTestPublicKey,
              "preferenceID": preferenceID
            });
          } on PlatformException catch (e) {
            print('Error: ${e.message}');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Pago de Membresias CRACKS';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.red.shade700,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("¡Paga aquí tu membresia anual!"),
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Container(
                child: Image.asset('assets/logos/logo_v01.png',
                  height: 90.0,
                  width: 100.0,
                ),
              ),
              SizedBox(height: 30.0),
              Container(
                child: CheckboxListTile(
                  title: Text("\$499.00 Plan Básico"),
                  secondary: Icon(Icons.payment),
                  controlAffinity:
                  ListTileControlAffinity.platform,
                  value: _opcionDeMembresiaMensual,
                  onChanged: (bool valor) {
                    setState(() {
                      _opcionDeMembresiaMensual = valor;
                      _opcionDeMembresiaAnual = false;
                      _opcionDePago = 1;
                    });
                  },
                  activeColor: Colors.white,
                  checkColor: Colors.red,
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                child: CheckboxListTile(
                  title: Text("\$749.00 Plan Premium"),
                  secondary: Icon(Icons.payment),
                  controlAffinity:
                  ListTileControlAffinity.platform,
                  value: _opcionDeMembresiaAnual,
                  onChanged: (bool valor) {
                    setState(() {
                      _opcionDeMembresiaAnual = valor;
                      _opcionDeMembresiaMensual = false;
                      _opcionDePago = 2;
                    });
                  },
                  activeColor: Colors.white,
                  checkColor: Colors.red,
                ),
              ),
              SizedBox(height: 50.0),
              SizedBox(
                width:  30.0,
                height: 50.0,
                child: MaterialButton(
                  //height: 50.0,
                  hoverColor: Colors.white,
                  onPressed: () {
                    ejecutarMercadoPago(_opcionDePago);
                  },
                  color: Colors.red,
                  child: Text('PAGAR',
                    style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
