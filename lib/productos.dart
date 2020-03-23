import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:puntodeventa/productos_editar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constantes.dart';
import 'navigator.dart';
import 'productos_agregar.dart';

class Productos extends StatefulWidget {
  @override
  ProductosState createState() => ProductosState();
}

class ProductosState extends State<Productos> {
  List productos;

  @override
  void initState() {
    super.initState();
    this.obtenerProductos();
  }

  Future<String> obtenerProductos() async {
    log("Obteniendo prefs...");
    final prefs = await SharedPreferences.getInstance();
    String posibleToken = prefs.getString("token_api");
    log("Posible token: $posibleToken");
    if (posibleToken == null) {
      log("No hay token");
      return "No hay token";
    }
    log("Haciendo petición...");
    var response = await http.get(
      "$RUTA_API/productos",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );

    this.setState(() {
      productos = json.decode(response.body);
    });

    return "Success!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          /*
          * Esperamos a que vuelva de la ruta y refrescamos
          * los productos. No encontré otra manera de hacer que
          * se escuche cuando se regresa de la ruta
          * */
          await navigatorKey.currentState
              .push(MaterialPageRoute(builder: (context) => AgregarProducto()));
          this.obtenerProductos();
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Productos"),
      ),
      body: ListView.builder(
        itemCount: productos == null ? 0 : productos.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(productos[index]["descripcion"]),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            left: 0,
                            top: 0,
                            right: 5,
                            bottom: 0,
                          ),
                          child: Text(
                            "Código",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(productos[index]["codigo_barras"]),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            left: 0,
                            top: 0,
                            right: 5,
                            bottom: 0,
                          ),
                          child: Text(
                            "Compra",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text("\$" + productos[index]["precio_compra"]),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            left: 0,
                            top: 0,
                            right: 5,
                            bottom: 0,
                          ),
                          child: Text(
                            "Venta",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text("\$" + productos[index]["precio_venta"]),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            left: 0,
                            top: 0,
                            right: 5,
                            bottom: 0,
                          ),
                          child: Text(
                            "Existencia",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(productos[index]["existencia"]),
                      ],
                    ),
                  ],
                ),
//              subtitle: Text(productos[index]["codigo_barras"] + "\nxd"),
              ),
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: Icon(
                      Icons.edit,
                      color: Colors.amber,
                    ),
                    onPressed: () async {
                      await navigatorKey.currentState.push(
                        MaterialPageRoute(
                          builder: (context) => EditarProducto(
                            idProducto: this.productos[index]["id"],
                          ),
                        ),
                      );
                      this.obtenerProductos();
                    },
                  ),
                  FlatButton(
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      /* ... */
                    },
                  ),
                ],
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}
