parser grammar Parser;

options {
    tokenVocab = Lexer;
}

chunk
    : blockbody EOF
    ;

block
    : INDENT blockbody DEDENT
    ;

blockbody
    : stat* retstat?
    ;

stat
    : (
    SEMI
    | varlist EQUAL explist
    | functioncall
    | label
    | BREAK
    | GOTO NAME
    | DO block END
    | WHILE exp DO block END
    | REPEAT block UNTIL exp
    | IF exp THEN block (ELSEIF exp THEN block)* (ELSE block)? END
    | FOR NAME EQUAL exp COMMA exp (COMMA exp)? DO block END
    | FOR namelist IN explist DO block END
    | FUNCTION funcname funcbody
    | LOCAL FUNCTION NAME funcbody
    | LOCAL namelist (EQUAL explist)?
    ) NL
    ;

retstat
    : RETURN explist? SEMI?
    ;

label
    : T__2 NAME T__2
    ;

funcname
    : NAME (DOT NAME)* (COLON NAME)?
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

exp
    : NIL | FALSE | TRUE
    | number
    | string
    | ELLIPSIS
    | functiondef
    | prefixexp
    | tableconstructor
    | <assoc=right> exp operatorPower exp
    | operatorUnary exp
    | exp operatorMulDivMod exp
    | exp operatorAddSub exp
    | <assoc=right> exp operatorStrcat exp
    | exp operatorComparison exp
    | exp operatorAnd exp
    | exp operatorOr exp
    | exp operatorBitwise exp
    ;

prefixexp
    : varOrExp nameAndArgs*
    ;

functioncall
    : varOrExp nameAndArgs+
    ;

varOrExp
    : var | LPAREN exp RPAREN
    ;

var
    : (NAME | LPAREN exp RPAREN varSuffix) varSuffix*
    ;

varSuffix
    : nameAndArgs* (LBRACK exp RBRACK | DOT NAME)
    ;

nameAndArgs
    : (COLON NAME)? args
    ;

args
    : LPAREN explist? RPAREN | tableconstructor | string
    ;

functiondef
    : FUNCTION funcbody
    ;

funcbody
    : LPAREN parlist? RPAREN block END
    ;

parlist
    : namelist (COMMA ELLIPSIS)? | ELLIPSIS
    ;

tableconstructor
    : LBRACE fieldlist? RBRACE
    ;

fieldlist
    : field (fieldsep field)* fieldsep?
    ;

field
    : LBRACK exp RBRACK EQUAL exp | NAME EQUAL exp | exp
    ;

fieldsep
    : COMMA | SEMI
    ;

operatorOr
	: OR;

operatorAnd
	: AND;

operatorComparison
	: LT | GT | LE | GE | T__3 | EQUAL_EQUAL;

operatorStrcat
	: T__4;

operatorAddSub
	: ADD | SUB;

operatorMulDivMod
	: MUL | DIV | MOD | T__5;

operatorBitwise
	: BITAND | BITOR | TILDE | T__6 | T__7;

operatorUnary
    : NOT | T__8 | SUB | TILDE;

operatorPower
    : CARET;

number
    : INT | HEX | FLOAT | HEX_FLOAT
    ;

string
    : NORMALSTRING | CHARSTRING | LONGSTRING
    ;