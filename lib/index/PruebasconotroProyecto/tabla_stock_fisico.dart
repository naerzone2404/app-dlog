import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TablaUbicacion extends StatefulWidget {
  final String codigoSba;
  final List<dynamic> jsonData;
  final List<dynamic> jsonDataUbi;

  TablaUbicacion({
    Key? key,
    required this.jsonData,
    required this.jsonDataUbi,
    required this.codigoSba,
    required List resultados,
  }) : super(key: key);

  @override
  State<TablaUbicacion> createState() => _TablaUbicacionState();
}

class _TablaUbicacionState extends State<TablaUbicacion> {

 
  Future<void> _eliminarDataPorId(int ids) async {
  try {
    final url = 'http://190.107.181.163:81/amq/flutter_ajax_delete.php';
    final response = await http.post(Uri.parse(url), body: {
      'id_ubi': ids.toString(),
       'usuario': ids.toString(),
    });
    print('id :----- $ids');
    print('usuario:--- ${ids.toString()},');
    if (response.statusCode == 404) {
      setState(() {
        widget.jsonDataUbi.removeWhere((element) => element['id'] == ids);
        widget.jsonDataUbi.removeWhere((element) => element['usuario'] == ids);

      });
    } else {
      print('Error al eliminar la ubicación. Código de estado: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> _alertMensaje(BuildContext context, int ids) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('ALERTA'),
        content: const Text(
          '¿ESTÁS SEGURO QUE DESEAS BORRAR?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _eliminarDataPorId(ids);
              Navigator.of(context).pop();
            },
            child: const Text('SI'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('NO'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    double totalCantidadUbicaciones = 0.0;

    for (var data in widget.jsonDataUbi) {
      if (data['Cantidad'] != null && data['Cantidad'] is num) {
        totalCantidadUbicaciones += data['Cantidad'];
      } else if (data['Cantidad'] != null && data['Cantidad'] is String) {
        totalCantidadUbicaciones += double.tryParse(data['Cantidad']) ?? 0.0;
      }
    }

    // ignore: unused_local_variable
    double totalCantidadAlmacen = 0.0;
    widget.jsonData
        .where((data) => ![
          
              'ALMACEN DE FALTANTES',
              'ALMACEN DE PRODUCTOS TERMINADO'
            ].contains(data['Name']))
        .forEach((data) {
      double stockValue = 0.0;
      if (data['Stock'] != null) {
        if (data['Stock'] is num) {
          stockValue = (data['Stock'] as num).toDouble();
        } else if (data['Stock'] is String) {
          stockValue = double.tryParse(data['Stock']) ?? 0.0;
        }
      }
      totalCantidadAlmacen += stockValue;
    });

    double diferencia = totalCantidadAlmacen - totalCantidadUbicaciones;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.jsonData.isNotEmpty) ...[
              Container(
                width: 600,
                height: 60,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STOCK FISICO',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 100),
                  ],
                ),
              ),
              SizedBox(height: 10)
            ],
            widget.jsonDataUbi.isNotEmpty
                ? Container(
                    width: 700,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: DataTable(
                          columnSpacing: 10.0,
                          horizontalMargin: 20.0,
                          headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.grey[300]!,
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                '      -',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                             DataColumn(
                              label: Text(
                                'ID',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'ZONA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'STAND',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'COL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'FILA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'CANTIDAD',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'IMG',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                          rows: [
                            ...widget.jsonDataUbi.map<DataRow>((data) {
                              //final index = widget.jsonDataUbi.indexOf(data);
                              final ids = int.tryParse(data['id'] ?? '') ?? 0;
                              return DataRow(
                                cells: [
                                  DataCell(IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                     
                                      _alertMensaje(context, ids);
                                    },
                                  )),
                                  DataCell(Container(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      data['id'] ?? 'Sin ID',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  )),
                                  DataCell(Container(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      data['Zona'] ?? 'Sin zona',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  )),
                                  DataCell(Container(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      data['Stand'] ?? 'Sin stand',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  )),
                                  DataCell(Container(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      data['col']?.toString() ?? 'Sin col',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  )),
                                  DataCell(Container(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      data['fil']?.toString() ?? 'Sin fila',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  )),
                                  DataCell(Container(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      data['Cantidad']?.toString() ??
                                          'Sin cantidad',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  )),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.image),
                                      onPressed: () {
                                        // Obtener la cadena que contiene las URLs de las imágenes desde jsonDataUbi
                                        final String? imageListString =
                                            data['Img'];

                                        // Parsear la cadena a una lista dinámica
                                        List<String> imageUrls = [];
                                        if (imageListString != null &&
                                            imageListString.isNotEmpty) {
                                          try {
                                            // Parsear la cadena JSON a una lista
                                            imageUrls = List<String>.from(
                                                jsonDecode(imageListString));
                                          } catch (e) {
                                            print(
                                                'Error al parsear la cadena de imágenes: $e');
                                          }
                                        }

                                        // Mostrar las imágenes en un dialog
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Imágenes'),
                                              content: Container(
                                                width: 400,
                                                height: 500,
                                                child: ListView.builder(
                                                  itemCount: imageUrls.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final url =
                                                        imageUrls[index].trim();
                                                    // Verificar que la URL no esté vacía y sea válida
                                                    if (url.isNotEmpty &&
                                                        (url.startsWith(
                                                                'http://') ||
                                                            url.startsWith(
                                                                'https://'))) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Card(
                                                          child: FadeInImage
                                                              .assetNetwork(
                                                            width: 80,
                                                            height: 150,
                                                            placeholder:
                                                                'assets/iph.gif', // Reemplaza con tu imagen de carga
                                                            image: url,
                                                            fit: BoxFit.cover,
                                                            imageErrorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Center(
                                                                  child: Icon(Icons
                                                                      .error));
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Card(
                                                          child: Center(
                                                              child: Text(
                                                                  'URL de imagen no válida')),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Cerrar'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                            DataRow(
                              cells: [
                                DataCell(Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    '',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                )),
                                DataCell(Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    '',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                )),
                                DataCell(Container(
                                  padding: EdgeInsets.all(8),
                                  child: const Text(
                                    'TOTAL',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                )),
                                DataCell(Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    '',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                )),
                                DataCell(Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    '',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                )),
                                DataCell(Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    '',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                )),
                                DataCell(Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    totalCantidadUbicaciones.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                )),
                                DataCell(Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    '',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const Center(child: Text('')),
            SizedBox(height: 20),
            if (widget.jsonData.isNotEmpty) ...[
              _buildDiferencias(
                  totalCantidadAlmacen, totalCantidadUbicaciones, diferencia),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiferencias(double totalCantidadAlmacen,
      double totalCantidadUbicaciones, double diferencia) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DIFERENCIAS',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 700,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: 160,
                    height: 60,
                    child: Center(
                      child: Text(
                        ' Total stock sistema:  \n $totalCantidadAlmacen', // text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: 160,
                    height: 60,
                    child: Center(
                      child: Text(
                        ' Total stock fisico: \n $totalCantidadUbicaciones', // text,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: 160,
                    height: 60,
                    child: Center(
                      child: Text(
                        'Diferencia : \n $diferencia', // text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

 
}
