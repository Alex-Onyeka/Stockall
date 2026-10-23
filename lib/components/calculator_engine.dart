import 'dart:math' as math;
import 'package:intl/intl.dart';

class CalculatorEngine {
  String _expression = '';
  String? _errorMessage;
  double _mainResult = 0;
  bool _hasResult = false;

  String get rawExpression => _expression;
  String? get errorMessage => _errorMessage;
  double get mainResult => _mainResult;
  bool get hasResult => _hasResult;

  String get displayExpression {
    if (_expression.isEmpty) {
      return '';
    }
    return formatExpressionForDisplay(_expression);
  }

  String get resultText {
    if (_errorMessage != null) {
      return _errorMessage!;
    }
    return formatCalculatorResult(_mainResult);
  }

  static String formatCalculatorResult(double val) {
    if (val.isNaN) return 'Invalid input';
    if (val.isInfinite) return 'Cannot divide by 0';

    val = cleanPrecision(val);

    if (val == val.roundToDouble()) {
      return NumberFormat('#,##0.0').format(val);
    } else {
      return NumberFormat('#,##0.0########').format(val);
    }
  }

  static double cleanPrecision(double val) {
    if (val.isInfinite || val.isNaN) return val;
    if ((val - val.roundToDouble()).abs() < 1e-11) {
      return val.roundToDouble();
    }
    String str = val.toStringAsPrecision(12);
    return double.parse(str);
  }

  static String _formatIntWithCommas(String intStr) {
    if (intStr.length <= 3) return intStr;
    StringBuffer sb = StringBuffer();
    int remainder = intStr.length % 3;
    if (remainder > 0) {
      sb.write(intStr.substring(0, remainder));
    }
    for (int i = remainder; i < intStr.length; i += 3) {
      if (sb.isNotEmpty) sb.write(',');
      sb.write(intStr.substring(i, i + 3));
    }
    return sb.toString();
  }

  static String formatExpressionForDisplay(String expr) {
    return expr.replaceAllMapped(RegExp(r'(\d+)(\.\d*)?'), (match) {
      String intPart = match.group(1)!;
      String? decPart = match.group(2);
      String formattedInt = _formatIntWithCommas(intPart);
      if (decPart != null) {
        return '$formattedInt$decPart';
      }
      return formattedInt;
    });
  }

  void clear() {
    _expression = '';
    _errorMessage = null;
    _mainResult = 0;
    _hasResult = false;
  }

  void inputDigit(String digit) {
    _errorMessage = null;
    if (_hasResult) {
      _expression = digit;
      _hasResult = false;
      return;
    }

    if (_expression == '0') {
      _expression = digit;
      return;
    }

    // Check if ends with ' 0' after an operator
    if (_expression.endsWith(' 0') || _expression.endsWith('(0')) {
      _expression = _expression.substring(0, _expression.length - 1) + digit;
      return;
    }

    // Implicit multiplication if follows ')' or '²'
    if (_expression.isNotEmpty) {
      String last = _expression[_expression.length - 1];
      if (last == ')' || last == '²') {
        _expression += ' × $digit';
        return;
      }
    }

    _expression += digit;
  }

  void inputDot() {
    _errorMessage = null;
    if (_hasResult) {
      _expression = '0.';
      _hasResult = false;
      return;
    }

    if (_expression.isEmpty) {
      _expression = '0.';
      return;
    }

    if (_expression.endsWith(' ') || _expression.endsWith('(')) {
      _expression += '0.';
      return;
    }

    if (_expression.endsWith(')') || _expression.endsWith('²')) {
      _expression += ' × 0.';
      return;
    }

    // Check if the current number already contains a dot
    int lastOpIdx = _expression.lastIndexOf(RegExp(r'[+\-×÷/(]'));
    String currentNum =
        lastOpIdx == -1 ? _expression : _expression.substring(lastOpIdx + 1);

    if (!currentNum.contains('.')) {
      _expression += '.';
    }
  }

  void inputOperator(String op) {
    _errorMessage = null;
    String displayOp = op;
    if (op == '*' || op == 'X' || op == 'x') displayOp = '×';
    if (op == '/') displayOp = '÷';

    if (_hasResult) {
      // Use previous result to start calculation
      String resStr = _formatNumberWithoutCommas(_mainResult);
      _expression = '$resStr $displayOp ';
      _hasResult = false;
      return;
    }

    if (_expression.isEmpty) {
      if (displayOp == '-') {
        _expression = '-';
        return;
      }
      _expression = '0 $displayOp ';
      return;
    }

    if (_expression == '-') {
      if (displayOp != '-') {
        _expression = '0 $displayOp ';
      }
      return;
    }

    if (_expression.endsWith('(')) {
      if (displayOp == '-') {
        _expression += '-';
      }
      return;
    }

    if (_expression.endsWith('(-')) {
      return;
    }

    // If ends with an operator like ' + '
    if (_expression.endsWith(' ')) {
      // Check if ends with ' [op] '
      if (_expression.length >= 3 &&
          _expression.substring(_expression.length - 3).startsWith(' ')) {
        _expression =
            _expression.substring(0, _expression.length - 3) + ' $displayOp ';
        return;
      }
    }

    if (_expression.endsWith('.')) {
      _expression = _expression.substring(0, _expression.length - 1);
    }

    _expression += ' $displayOp ';
  }

  void inputLeftBracket() {
    _errorMessage = null;
    if (_hasResult) {
      _expression = '(';
      _hasResult = false;
      return;
    }

    if (_expression.isEmpty || _expression.endsWith(' ') || _expression.endsWith('(')) {
      _expression += '(';
      return;
    }

    // Implicit multiplication
    _expression += ' × (';
  }

  void inputRightBracket() {
    _errorMessage = null;
    if (_hasResult) {
      return;
    }

    int openCount = '('.allMatches(_expression).length;
    int closeCount = ')'.allMatches(_expression).length;

    if (openCount <= closeCount) return;

    if (_expression.isEmpty ||
        _expression.endsWith(' ') ||
        _expression.endsWith('(') ||
        _expression.endsWith('-')) {
      return;
    }

    if (_expression.endsWith('.')) {
      _expression = _expression.substring(0, _expression.length - 1);
    }

    _expression += ')';
  }

  void inputSquare() {
    _errorMessage = null;
    if (_hasResult) {
      String resStr = _formatNumberWithoutCommas(_mainResult);
      _expression = '$resStr²';
      _hasResult = false;
      return;
    }

    if (_expression.isEmpty) {
      _expression = '0²';
      return;
    }

    if (_expression.endsWith('.')) {
      _expression = _expression.substring(0, _expression.length - 1);
    }

    if (_expression.endsWith(' ') || _expression.endsWith('(')) {
      _expression += '0²';
      return;
    }

    _expression += '²';
  }

  void inputSquareRoot() {
    _errorMessage = null;
    if (_hasResult) {
      String resStr = _formatNumberWithoutCommas(_mainResult);
      _expression = '√($resStr)';
      _hasResult = false;
      return;
    }

    if (_expression.isEmpty || _expression.endsWith(' ') || _expression.endsWith('(')) {
      _expression += '√(';
      return;
    }

    if (_expression.endsWith('.')) {
      _expression = _expression.substring(0, _expression.length - 1);
    }

    // If ends with a number or bracket, wrap it into √(...)
    if (_expression.endsWith(')')) {
      // Find matching '('
      int depth = 0;
      int matchIdx = -1;
      for (int i = _expression.length - 1; i >= 0; i--) {
        if (_expression[i] == ')') depth++;
        if (_expression[i] == '(') {
          depth--;
          if (depth == 0) {
            matchIdx = i;
            break;
          }
        }
      }
      if (matchIdx != -1) {
        String before = _expression.substring(0, matchIdx);
        String inside = _expression.substring(matchIdx);
        _expression = '$before√($inside)';
        return;
      }
    }

    // Number at the end
    int lastOpIdx = _expression.lastIndexOf(RegExp(r'[+\-×÷/( ]'));
    if (lastOpIdx == -1) {
      _expression = '√($_expression)';
    } else {
      String before = _expression.substring(0, lastOpIdx + 1);
      String num = _expression.substring(lastOpIdx + 1);
      _expression = '$before√($num)';
    }
  }

  void deleteAction() {
    _errorMessage = null;
    if (_hasResult) {
      _hasResult = false;
      return;
    }

    if (_expression.isEmpty) return;

    if (_expression.endsWith('√(')) {
      _expression = _expression.substring(0, _expression.length - 2);
      return;
    }

    if (_expression.endsWith(' ') && _expression.length >= 3) {
      // Remove operator and surrounding spaces ' + '
      _expression = _expression.substring(0, _expression.length - 3);
      return;
    }

    _expression = _expression.substring(0, _expression.length - 1);
  }

  void calculate() {
    if (_expression.isEmpty) {
      _mainResult = 0;
      _errorMessage = null;
      _hasResult = true;
      return;
    }

    String expr = _expression.trim();

    // Remove trailing dot
    if (expr.endsWith('.')) {
      expr = expr.substring(0, expr.length - 1).trim();
    }

    // Remove trailing operators
    while (expr.endsWith(' ') ||
        expr.endsWith('+') ||
        expr.endsWith('-') ||
        expr.endsWith('×') ||
        expr.endsWith('÷')) {
      if (expr.endsWith(' ')) {
        expr = expr.substring(0, expr.length - 1).trim();
      } else {
        expr = expr.substring(0, expr.length - 1).trim();
      }
    }

    // Auto-close missing parentheses
    int openCount = '('.allMatches(expr).length;
    int closeCount = ')'.allMatches(expr).length;
    while (openCount > closeCount) {
      expr += ')';
      closeCount++;
    }

    if (expr.isEmpty) {
      _mainResult = 0;
      _errorMessage = null;
      _hasResult = true;
      return;
    }

    try {
      double result = ExpressionEvaluator(expr).evaluate();
      if (result.isNaN) {
        _errorMessage = 'Invalid input';
      } else if (result.isInfinite) {
        _errorMessage = 'Cannot divide by 0';
      } else {
        _mainResult = cleanPrecision(result);
        _errorMessage = null;
      }
    } on IntegerDivisionByZeroException {
      _errorMessage = 'Cannot divide by 0';
    } on ArgumentError {
      _errorMessage = 'Invalid input';
    } catch (_) {
      _errorMessage = 'Error';
    }

    _hasResult = true;
  }

  static String _formatNumberWithoutCommas(double val) {
    val = cleanPrecision(val);
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    return val.toString();
  }
}

class ExpressionEvaluator {
  final String rawInput;
  late final String input;
  int _pos = 0;

  ExpressionEvaluator(this.rawInput) {
    input = _preprocess(rawInput);
  }

  // Handle implicit multiplications
  String _preprocess(String s) {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      String curr = s[i];
      sb.write(curr);
      if (i + 1 < s.length) {
        String next = s[i + 1];
        bool currIsDigit = _isDigit(curr);
        bool nextIsDigit = _isDigit(next);
        bool currIsClose = curr == ')' || curr == '²';
        bool nextIsOpen = next == '(' || next == '√';

        if ((currIsDigit && nextIsOpen) ||
            (currIsClose && nextIsOpen) ||
            (currIsClose && nextIsDigit)) {
          sb.write(' × ');
        }
      }
    }
    return sb.toString();
  }

  bool _isDigit(String ch) {
    if (ch.isEmpty) return false;
    int code = ch.codeUnitAt(0);
    return code >= '0'.codeUnitAt(0) && code <= '9'.codeUnitAt(0);
  }

  double evaluate() {
    _pos = 0;
    if (input.trim().isEmpty) return 0.0;
    double res = _parseExpression();
    _skipWhitespace();
    return res;
  }

  void _skipWhitespace() {
    while (_pos < input.length && input[_pos] == ' ') {
      _pos++;
    }
  }

  bool _match(String token) {
    _skipWhitespace();
    if (_pos + token.length <= input.length &&
        input.substring(_pos, _pos + token.length) == token) {
      _pos += token.length;
      return true;
    }
    return false;
  }

  double _parseExpression() {
    double left = _parseTerm();
    while (true) {
      if (_match('+')) {
        double right = _parseTerm();
        left = left + right;
      } else if (_match('-')) {
        double right = _parseTerm();
        left = left - right;
      } else {
        break;
      }
    }
    return left;
  }

  double _parseTerm() {
    double left = _parsePower();
    while (true) {
      if (_match('×') || _match('*') || _match('X') || _match('x')) {
        double right = _parsePower();
        left = left * right;
      } else if (_match('÷') || _match('/')) {
        double right = _parsePower();
        if (right == 0) {
          throw const IntegerDivisionByZeroException();
        }
        left = left / right;
      } else {
        break;
      }
    }
    return left;
  }

  double _parsePower() {
    double left = _parseUnary();
    while (true) {
      if (_match('²')) {
        left = left * left;
      } else if (_match('^')) {
        double exponent = _parseUnary();
        left = math.pow(left, exponent).toDouble();
      } else {
        break;
      }
    }
    return left;
  }

  double _parseUnary() {
    _skipWhitespace();
    if (_match('+')) {
      return _parseUnary();
    }
    if (_match('-')) {
      return -_parseUnary();
    }
    if (_match('√')) {
      double val = _parseUnary();
      if (val < 0) {
        throw ArgumentError("Cannot calculate square root of negative number");
      }
      return math.sqrt(val);
    }
    return _parsePrimary();
  }

  double _parsePrimary() {
    _skipWhitespace();
    if (_match('(')) {
      double val = _parseExpression();
      _match(')');
      return val;
    }

    int start = _pos;
    bool hasDot = false;
    while (_pos < input.length) {
      String ch = input[_pos];
      if (_isDigit(ch)) {
        _pos++;
      } else if (ch == '.' && !hasDot) {
        hasDot = true;
        _pos++;
      } else {
        break;
      }
    }

    if (start == _pos) {
      return 0.0;
    }

    String numStr = input.substring(start, _pos);
    return double.tryParse(numStr) ?? 0.0;
  }
}

