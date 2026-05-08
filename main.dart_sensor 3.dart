import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const Aplicativo());
}

class Aplicativo extends StatelessWidget {
  const Aplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaSensor(),
    );
  }
}

class TelaSensor extends StatefulWidget {
  const TelaSensor({super.key});

  @override
  State<TelaSensor> createState() => _TelaSensorState();
}

class _TelaSensorState extends State<TelaSensor> {

  double valorX = 0;
  double valorY = 0;
  double valorZ = 0;

  bool movimento = false;

  double mouseX = 0;
  double mouseY = 0;

  bool liberarAviso = true;

  StreamSubscription? sensor;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {

      sensor = accelerometerEventStream().listen((dados) {

        verificarMovimento(
          dados.x,
          dados.y,
          dados.z,
        );
      });
    }
  }

  void verificarMovimento(
    double x,
    double y,
    double z,
  ) {

    bool detectado = x.abs() > 8;

    setState(() {
      valorX = x;
      valorY = y;
      valorZ = z;
      movimento = detectado;
    });

    if (detectado) {
      mostrarAviso();
    }
  }

  void mostrarAviso() {

    if (!liberarAviso) return;

    liberarAviso = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Movimento Detectado',
        ),
      ),
    );

    Future.delayed(
      const Duration(seconds: 2),
      () {
        liberarAviso = true;
      },
    );
  }

  void moverMouse(PointerEvent event) {

    double novoX =
        event.position.dx - mouseX;

    double novoY =
        event.position.dy - mouseY;

    verificarMovimento(
      novoX,
      novoY,
      0,
    );

    mouseX = event.position.dx;
    mouseY = event.position.dy;
  }

  @override
  void dispose() {
    sensor?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MouseRegion(
      onHover: kIsWeb ? moverMouse : null,

      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Detector de Movimento',
          ),
        ),

        body: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Text(
                'X: ${valorX.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),

              Text(
                'Y: ${valorY.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),

              Text(
                'Z: ${valorZ.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 30),

              movimento
                  ? const Text(
                      'MOVIMENTO DETECTADO',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.red,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}