import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora Básica',
      theme: ThemeData.dark(),
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

  void handleInput(String value) {
    // Validar no empezar con operadores inválidos
    if (userInput.isEmpty) {
      if (value == '*' || value == '/' || value == ')' || value == '+') {
        return;
      }
    }

    // Evitar doble operador (ej: ++, --), pero permitir paréntesis
    if (userInput.isNotEmpty) {
      String lastChar = userInput.substring(userInput.length - 1);
      bool isLastOperator = "+-*/".contains(lastChar);
      bool isNewOperator = "+-*/".contains(value);

      if (isLastOperator && isNewOperator) {
        userInput = userInput.substring(0, userInput.length - 1) + value;
        return;
      }
    }

    userInput += value;
  }

  void calculateResult() {
    try {
      String finalExpression = userInput;

      // Convertir (5)(5) -> (5)*(5)
      finalExpression = finalExpression.replaceAll(')(', ')*(');

      // Convertir 5(  -> 5*(  (Usamos expresiones regulares simples)
      finalExpression = finalExpression.replaceAllMapped(
        RegExp(r'(\d)\('),
        (Match m) => '${m[1]}*(',
      );

      // Convertir )5  -> )*5
      finalExpression = finalExpression.replaceAllMapped(
        RegExp(r'\)(\d)'),
        (Match m) => ')*${m[1]}',
      );

      // Reemplazo estándar
      finalExpression = finalExpression
          .replaceAll('x', '*')
          .replaceAll('÷', '/');

      Parser p = Parser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();

      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isInfinite || eval.isNaN) {
        answer = "Error";
      } else {
        answer = eval.toString();
        // Quitar el .0 si es entero
        if (answer.endsWith(".0")) {
          answer = answer.substring(0, answer.length - 2);
        }
      }
    } catch (e) {
      answer = "Error";
    }
  }

  // --- Widgets ---

  Widget buildButton(String text, {Color? color, Color? textColor}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => onButtonPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[850],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(0), // Padding 0 para ajustar mejor
          ),
          child: FittedBox(
            // Texto se achica si no cabe
            child: Text(
              text,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
            style: const TextStyle(
              fontSize: 48,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Diseño Vertical (Celular normal)
  Widget verticalLayout() {
    return Column(
      children: [
        Expanded(flex: 1, child: buildDisplay()),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    buildButton('C', color: Colors.redAccent),
                    buildButton('(', color: Colors.blueGrey),
                    buildButton(')', color: Colors.blueGrey),
                    buildButton('/', color: Colors.orange),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('7'),
                    buildButton('8'),
                    buildButton('9'),
                    buildButton('*', color: Colors.orange),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('4'),
                    buildButton('5'),
                    buildButton('6'),
                    buildButton('-', color: Colors.orange),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('1'),
                    buildButton('2'),
                    buildButton('3'),
                    buildButton('+', color: Colors.orange),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('0'),
                    buildButton('.'),
                    buildButton('DEL'),
                    buildButton('=', color: Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Diseño Horizontal
  Widget horizontalLayout() {
    return Row(
      children: [
        Expanded(flex: 1, child: buildDisplay()),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // Distribución más amplia para aprovechar el espacio
              Expanded(
                child: Row(
                  children: [
                    buildButton('C', color: Colors.red),
                    buildButton('('),
                    buildButton(')'),
                    buildButton('/'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('7'),
                    buildButton('8'),
                    buildButton('9'),
                    buildButton('*'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('4'),
                    buildButton('5'),
                    buildButton('6'),
                    buildButton('-'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('1'),
                    buildButton('2'),
                    buildButton('3'),
                    buildButton('+'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('0'),
                    buildButton('.'),
                    buildButton('DEL'),
                    buildButton('=', color: Colors.green),
                  ],
                ),
              ),
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
