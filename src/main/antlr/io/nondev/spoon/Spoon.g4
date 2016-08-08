grammar Spoon;

@lexer::header { package io.nondev.spoon; }
@parser::header { package io.nondev.spoon; }

chunk
    : block EOF
    ;

block
    : DO? blockbody
    ;

blockbody
    : statement* retstatement?
    ;

statement
    :
    ( ';'
    | varlist EQUAL explist
    | functioncall
    | BREAK
    | CONTINUE
    | doblock
    | loop
    | condition
    | iterator
    | function
    | macro
    ) tailcall?
    ;

macro
    : AT exp
    ;

tailcall
    : FATARROW
    ( IF exp
    | FOR namelist IN explist
    | WHILE exp
    | closure
    | doblock
    )
    ;

retstatement
    : RETURN explist? ';'?
    ;

varlist
    : var (COMMA var)*
    ;

namelist
    : NAME (COMMA NAME)*
    ;

explist
    : exp (COMMA exp)*
    ;

fieldlist
    : field (COMMA field)*
    ;

exp
    : constant
    | closure
    | prefixexp
    | array
    | map
    | hash
    | doblock
    | statexp
    | <assoc=right> exp POWER exp
    | ( NOT | BANG | SUB | TILDE ) exp
    | exp ( MUL | DIV | MOD ) exp
    | exp ( ADD | SUB ) exp
    | exp ( LT | GT | LE | GE | BITNOT_EQUAL | NOT_EQUAL | EQUAL_EQUAL ) exp
    | exp AND exp
    | exp OR exp
    | exp ( BITAND | BITOR | TILDE | LSHIFT | RSHIFT ) exp
    ;

statexp
    : OPEN_BRACK
    ( loop
    | condition
    | iterator
    ) CLOSE_BRACK
    ;

field
    : exp COLON exp
    ;

condition
    : IF exp block (ELSEIF exp block)* (ELSE block)? END
    ;

iterator
    : FOR namelist IN explist block END
    ;

function
    : FUNCTION NAME params block END
    ;

loop
    : WHILE exp block END
    ;

doblock
    : DO blockbody END
    ;

closure
    : params? ARROW exp
    ;

array
    : OPEN_BRACK explist? CLOSE_BRACK
    ;

hash
    : OPEN_BRACE fieldlist? CLOSE_BRACE
    ;

map
    : OPEN_BRACK fieldlist CLOSE_BRACK
    ;

constant
    : NULL
    | FALSE
    | TRUE
    | number
    | string
    ;

prefixexp
    : varOrExp nameAndArgs*
    ;

functioncall
    : varOrExp nameAndArgs+
    ;

varOrExp
    : var | OPEN_PAREN exp CLOSE_PAREN
    ;

var
    : (NAME | OPEN_PAREN exp CLOSE_PAREN varSuffix) varSuffix*
    ;

varSuffix
    : nameAndArgs* (OPEN_BRACK exp CLOSE_BRACK | '.' NAME)
    ;

nameAndArgs
    : (COLON NAME)? args
    ;

args
    : OPEN_PAREN explist? CLOSE_PAREN
    ;

params
    : OPEN_PAREN namelist? CLOSE_PAREN
    ;

number
    : INT | HEX | FLOAT | HEX_FLOAT
    ;

string
    : SYMBOLSTRING | NORMALSTRING | CHARSTRING
    ;

END: 'end' ;
DO : 'do' ;
BREAK : 'break' ;
CONTINUE : 'continue' ;
IF : 'if' ;
ELSEIF : 'elseif' ;
ELSE : 'else' ;
FOR : 'for' ;
IN : 'in' ;
FUNCTION : 'function' ;
WHILE : 'while' ;
RETURN : 'return' ;
NULL : 'null' ;
FALSE : 'false' ;
TRUE : 'true' ;
NOT : 'not' ;

FATARROW : '=>' ;
OR : ( 'or' | '||' ) ;
AND : ( 'and' | '&&' ) ;
LE : '<=' ;
GE : '>=' ;
BITNOT_EQUAL : '~=' ;
NOT_EQUAL : '!=' ;
EQUAL_EQUAL : '==' ;
LSHIFT : '<<' ;
RSHIFT : '>>' ;
ARROW : '->' ;

AT: '@' ;
EQUAL : '=' ;
COMMA : ',' ;
DOT : '.' ;
COLON : ':' ;
ADD : '+' ;
SUB : '-' ;
MUL : '*' ;
DIV : '/' ;
MOD : '%' ;
BITAND : '&' ;
BITOR : '|' ;
TILDE : '~' ;
BANG : '!' ;
POWER : '^' ;
LT : '<' ;
GT : '>' ;
OPEN_PAREN : '(' ;
CLOSE_PAREN : ')' ;
OPEN_BRACK : '[' ;
CLOSE_BRACK : ']' ;
OPEN_BRACE : '{' ;
CLOSE_BRACE : '}' ;

NAME
    : Word
    ;

SYMBOLSTRING
    : '\\' Word
    ;

NORMALSTRING
    : '"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;

CHARSTRING
    : '\'' ( EscapeSequence | ~('\''|'\\') )* '\''
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

SKIP_
    : ( BlockComment | Spaces | Comment ) -> skip
    ;

fragment
Word
    : [a-zA-Z_][a-zA-Z_0-9]*
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
    : '\\' 'u' HexDigit+
    ;

fragment
Digit
    : [0-9]
    ;

fragment
HexDigit
    : [0-9a-fA-F]
    ;

fragment
Spaces
    : [ \t\u000C\r\n]+
    ;

fragment
Comment
    : '#' ~[\r\n]*
    ;

fragment
BlockComment
    : '###' .*? '###'
    ;