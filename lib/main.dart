import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart'; // Importante para matemáticas

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora Pro',
      theme: ThemeData.dark(), // Tema oscuro por defecto
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String userInput = '';
  String answer = '';

  // Lógica principal de botones
  void onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        userInput = '';
        answer = '';
      } else if (value == 'DEL') {
        if (userInput.isNotEmpty) {
          userInput = userInput.substring(0, userInput.length - 1);
        }
      } else if (value == '=') {
        calculateResult();
      } else {
        handleInput(value);
      }
    });
  }

  // Validación: Evitar operadores dobles (ej: "30++") o inválidos
  void handleInput(String value) {
    if (userInput.isEmpty) {
      // No permitir iniciar con *, /, ) o +
      if (value == '*' || value == '/' || value == ')' || value == '+') {
        return; 
      }
    }

    // Si el último caracter es un operador, y pones otro operador, reemplázalo
    // (Excepción: a veces queremos escribir "(-5)")
    if (userInput.isNotEmpty) {
      String lastChar = userInput.substring(userInput.length - 1);
      bool isLastOperator = "+-*/".contains(lastChar);
      bool isNewOperator = "+-*/".contains(value);

      if (isLastOperator && isNewOperator) {
        // Reemplazar el operador anterior por el nuevo
        userInput = userInput.substring(0, userInput.length - 1) + value;
        return;
      }
    }
    
    userInput += value;
  }

  // Cálculo matemático real usando la librería
  void calculateResult() {
    try {
      String finalExpression = userInput;
      // Reemplazar símbolos visuales por los de programación si usaste 'x' o '÷'
      finalExpression = finalExpression.replaceAll('x', '*').replaceAll('÷', '/');

      Parser p = Parser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      
      // Validar división por cero (Infinity)
      if (eval.isInfinite || eval.isNaN) {
        answer = "Error";
      } else {
        // Quitar el ".0" si es entero (ej: 5.0 -> 5)
        answer = eval.toString();
        if (answer.endsWith(".0")) {
          answer = answer.substring(0, answer.length - 2);
        }
      }
    } catch (e) {
      answer = "Error"; // Error de sintaxis (ej: paréntesis sin cerrar)
    }
  }

  // --- Widgets de la UI ---

  Widget buildButton(String text, {Color? color, Color? textColor}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => onButtonPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[850],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.all(15),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Pantalla de resultados
  Widget buildDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.centerRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            userInput,
            style: const TextStyle(fontSize: 32, color: Colors.white70),
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          Text(
            answer,
            style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Layout Vertical (Portrait)
  Widget verticalLayout() {
    return Column(
      children: [
        Expanded(flex: 1, child: buildDisplay()),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Fila 1
              Expanded(child: Row(children: [
                buildButton('C', color: Colors.redAccent),
                buildButton('(', color: Colors.blueGrey),
                buildButton(')', color: Colors.blueGrey),
                buildButton('/', color: Colors.orange),
              ])),
              // Fila 2
              Expanded(child: Row(children: [
                buildButton('7'), buildButton('8'), buildButton('9'), buildButton('*', color: Colors.orange),
              ])),
              // Fila 3
              Expanded(child: Row(children: [
                buildButton('4'), buildButton('5'), buildButton('6'), buildButton('-', color: Colors.orange),
              ])),
              // Fila 4
              Expanded(child: Row(children: [
                buildButton('1'), buildButton('2'), buildButton('3'), buildButton('+', color: Colors.orange),
              ])),
              // Fila 5
              Expanded(child: Row(children: [
                buildButton('0'), buildButton('.'), buildButton('DEL'), buildButton('=', color: Colors.green),
              ])),
            ],
          ),
        ),
      ],
    );
  }

  // Layout Horizontal (Landscape) - Más botones si quisieras
  Widget horizontalLayout() {
    return Row(
      children: [
        Expanded(flex: 1, child: buildDisplay()),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(child: Row(children: [buildButton('7'), buildButton('8'), buildButton('9'), buildButton('/')])),
              Expanded(child: Row(children: [buildButton('4'), buildButton('5'), buildButton('6'), buildButton('*')])),
              Expanded(child: Row(children: [buildButton('1'), buildButton('2'), buildButton('3'), buildButton('-')])),
              Expanded(child: Row(children: [buildButton('0'), buildButton('C', color: Colors.red), buildButton('='), buildButton('+')])),
            ],
          ),
        ),
         Expanded(
          flex: 1, // Panel extra para Landscape
          child: Column(
            children: [
              Expanded(child: Row(children: [buildButton('('), buildButton(')')])),
              Expanded(child: Row(children: [buildButton('sin'), buildButton('cos')])), // Ejemplo futuro
              Expanded(child: Row(children: [buildButton('.'), buildButton('DEL')])),
              Expanded(child: Row(children: [buildButton('^'), buildButton('sqrt')])),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? verticalLayout()
                : horizontalLayout();
          },
        ),
      ),
    );
  }
}