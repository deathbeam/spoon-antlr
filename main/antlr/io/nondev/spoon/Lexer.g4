lexer grammar Lexer;

tokens { INDENT, DEDENT }

@header {
  import com.yuvalshavit.antlr4.DenterHelper;
}

@members {
  private final DenterHelper denter = DenterHelper.builder()
    .nl(NL)
    .indent(INDENT)
    .dedent(DEDENT)
    .pullToken(super::nextToken);

  @Override
  public Token nextToken() {
    return denter.nextToken();
  }
}

NL
    : ('\r'? '\n' ' '*)
    ;

NAME
    : [a-zA-Z_][a-zA-Z_0-9]*
    ;

NORMALSTRING
    : '"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;

CHARSTRING
    : '\'' ( EscapeSequence | ~('\''|'\\') )* '\''
    ;

LONGSTRING
    : '[' NESTED_STR ']'
    ;

fragment
NESTED_STR
    : '=' NESTED_STR '='
    | '[' .*? ']'
    ;

INT
    : Digit+
    ;

HEX
    : '0' [xX] HexDigit+
    ;

FLOAT
    : Digit+ '.' Digit* ExponentPart?
    | '.' Digit+ ExponentPart?
    | Digit+ ExponentPart
    ;

HEX_FLOAT
    : '0' [xX] HexDigit+ '.' HexDigit* HexExponentPart?
    | '0' [xX] '.' HexDigit+ HexExponentPart?
    | '0' [xX] HexDigit+ HexExponentPart
    ;

fragment
ExponentPart
    : [eE] [+-]? Digit+
    ;

fragment
HexExponentPart
    : [pP] [+-]? Digit+
    ;

fragment
EscapeSequence
    : '\\' [abfnrtvz"'\\]
    | '\\' '\r'? '\n'
    | DecimalEscape
    | HexEscape
    | UtfEscape
    ;

fragment
DecimalEscape
    : '\\' Digit
    | '\\' Digit Digit
    | '\\' [0-2] Digit Digit
    ;

fragment
HexEscape
    : '\\' 'x' HexDigit HexDigit
    ;

fragment
UtfEscape
    : '\\' 'u{' HexDigit+ '}'
    ;

fragment
Digit
    : [0-9]
    ;

fragment
HexDigit
    : [0-9a-fA-F]
    ;

COMMENT
    : '--[' NESTED_STR ']' -> channel(HIDDEN)
    ;

LINE_COMMENT
    : '--'
    (                                               // --
    | '[' '='*                                      // --[==
    | '[' '='* ~('='|'['|'\r'|'\n') ~('\r'|'\n')*   // --[==AA
    | ~('['|'\r'|'\n') ~('\r'|'\n')*                // --AAA
    ) ('\r\n'|'\r'|'\n'|EOF)
    -> channel(HIDDEN)
    ;

WS
    : [ \t\u000C\r\n]+ -> skip
    ;

SHEBANG
    : '#' '!' ~('\n'|'\r')* -> channel(HIDDEN)
    ;

SEMI : ';' ;
EQUAL : '=' ;
BREAK : 'break' ;
GOTO : 'goto' ;
DO : 'do' ;
END : 'end' ;
WHILE : 'while' ;
REPEAT : 'repeat' ;
UNTIL : 'until' ;
IF : 'if' ;
THEN : 'then' ;
ELSEIF : 'elseif' ;
ELSE : 'else' ;
FOR : 'for' ;
COMMA : ',' ;
IN : 'in' ;
FUNCTION : 'function' ;
LOCAL : 'local' ;
RETURN : 'return' ;
T__2 : '::' ;
DOT : '.' ;
COLON : ':' ;
NIL : 'nil' ;
FALSE : 'false' ;
TRUE : 'true' ;
ELLIPSIS : '...' ;
LPAREN : '(' ;
RPAREN : ')' ;
LBRACK : '[' ;
RBRACK : ']' ;
LBRACE : '{' ;
RBRACE : '}' ;
OR : 'or' ;
AND : 'and' ;
LT : '<' ;
GT : '>' ;
LE : '<=' ;
GE : '>=' ;
T__3 : '~=' ;
EQUAL_EQUAL : '==' ;
T__4 : '..' ;
ADD : '+' ;
SUB : '-' ;
MUL : '*' ;
DIV : '/' ;
MOD : '%' ;
T__5 : '//' ;
BITAND : '&' ;
BITOR : '|' ;
TILDE : '~' ;
T__6 : '<<' ;
T__7 : '>>' ;
NOT : 'not' ;
T__8 : '#' ;
CARET : '^' ;