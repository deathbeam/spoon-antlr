grammar Spoon;

tokens { INDENT, DEDENT }

@parser::header {
    package io.nondev.spoon;
}

@lexer::header {
    package io.nondev.spoon;
}

@lexer::members {
    // A queue where extra tokens are pushed on (see the NEWLINE lexer rule).
    private java.util.LinkedList<Token> tokens = new java.util.LinkedList<>();
    // The stack that keeps track of the indentation level.
    private java.util.Stack<Integer> indents = new java.util.Stack<>();
    // The amount of opened braces, brackets and parenthesis.
    private int opened = 0;
    // The most recently produced token.
    private Token lastToken = null;

    @Override
    public void emit(Token t) {
        super.setToken(t);
        tokens.offer(t);
    }

    @Override
    public Token nextToken() {
        // Check if the end-of-file is ahead and there are still some DEDENTS expected.
        if (_input.LA(1) == EOF && !this.indents.isEmpty()) {
            // Remove any trailing EOF tokens from our buffer.
            for (int i = tokens.size() - 1; i >= 0; i--) {
                if (tokens.get(i).getType() == EOF) {
                    tokens.remove(i);
                }
            }

            // First emit an extra line break that serves as the end of the statement.
            this.emit(commonToken(SpoonParser.NEWLINE, "\n"));

            // Now emit as much DEDENT tokens as needed.
            while (!indents.isEmpty()) {
                this.emit(createDedent());
                indents.pop();
            }

            // Put the EOF back on the token stream.
            this.emit(commonToken(SpoonParser.EOF, "<EOF>"));
        }

        Token next = super.nextToken();

        if (next.getChannel() == Token.DEFAULT_CHANNEL) {
            // Keep track of the last token on the default channel.
            this.lastToken = next;
        }

        return tokens.isEmpty() ? next : tokens.poll();
    }

    private Token createDedent() {
        CommonToken dedent = commonToken(SpoonParser.DEDENT, "");
        dedent.setLine(this.lastToken.getLine());
        return dedent;
    }

    private CommonToken commonToken(int type, String text) {
        int stop = this.getCharIndex() - 1;
        int start = text.isEmpty() ? stop : stop - text.length() + 1;
        return new CommonToken(this._tokenFactorySourcePair, type, DEFAULT_TOKEN_CHANNEL, start, stop);
    }

    // Calculates the indentation of the provided spaces, taking the
    // following rules into account:
    //
    // "Tabs are replaced (from left to right) by one to eight spaces
    //  such that the total number of characters up to and including
    //  the replacement is a multiple of eight [...]"
    private int getIndentationCount(String spaces) {
        int count = 0;
        for (char ch : spaces.toCharArray()) {
            switch (ch) {
                case '\t':
                count += 8 - (count % 8);
                break;
            default:
                // A normal space char.
                count++;
            }
        }

        return count;
    }

    private boolean atStartOfInput() {
        return super.getCharPositionInLine() == 0 && super.getLine() == 1;
    }

    private void processEndOfLine() {
        String newLine = getText().replaceAll("[^\r\n]+", "");
        String spaces = getText().replaceAll("[\r\n]+", "");
        int next = _input.LA(1);

        if (opened > 0 || next == '\r' || next == '\n' || next == '#') {
            // If we're inside a list or on a blank line, ignore all indents,
            // dedents and line breaks.
            skip();
        } else {
            emit(commonToken(NEWLINE, newLine));
            int indent = getIndentationCount(spaces);
            int previous = indents.isEmpty() ? 0 : indents.peek();

            if (indent == previous) {
                // skip indents of the same size as the present indent-size
                skip();
            } else if (indent > previous) {
                indents.push(indent);
                emit(commonToken(SpoonParser.INDENT, spaces));
            } else {
                // Possibly emit more than 1 DEDENT token.
                while(!indents.isEmpty() && indents.peek() > indent) {
                    this.emit(createDedent());
                    indents.pop();
                }
            }
        }
    }
}

chunk
    : (NEWLINE | stat)* (NEWLINE | retstat)? EOF
    ;

block
    : 'do'?
    ( stat
    | retstat
    | NEWLINE INDENT (NEWLINE | stat)* (NEWLINE | retstat)? DEDENT
    )
    ;

stat
    : ( varlist '=' explist
    | functioncall
    | 'break'
    | 'continue'
    | whileStat
    | ifStat
    | forStat
    | functionStat
    ) NEWLINE?
    ;

ifStat
    : 'if' exp block ('elseif' exp block)* ('else' block)?
    ;

forStat
    : 'for' namelist 'in' explist block
    ;

functionStat
    : 'function' NAME params block
    ;

whileStat
    : 'while' exp block
    ;

retstat
    : ('return' explist? | explist) NEWLINE?
    ;

varlist
    : var (',' var)*
    ;

namelist
    : NAME (',' NAME)*
    ;

explist
    : exp (',' exp)*
    ;

// TODO: If, while and for can also be expressions, and postfix expressions
exp
    : 'nil' | 'false' | 'true'
    | number
    | string
    | '...'
    | closure
    | prefixexp
    | tableconstructor
    | <assoc=right> exp operatorPower exp
    | operatorUnary exp
    | exp operatorMulDivMod exp
    | exp operatorAddSub exp
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
    : var | OPEN_PAREN exp CLOSE_PAREN
    ;

var
    : (NAME | OPEN_PAREN exp CLOSE_PAREN varSuffix) varSuffix*
    ;

varSuffix
    : nameAndArgs* (OPEN_BRACK exp CLOSE_BRACK | '.' NAME)
    ;

nameAndArgs
    : (':' NAME)? args
    ;

args
    : OPEN_PAREN explist? CLOSE_PAREN | tableconstructor | string
    ;

closure
    : params '->' block
    ;

params
    : OPEN_PAREN parlist? CLOSE_PAREN
    ;

parlist
    : namelist (',' '...')? | '...'
    ;

tableconstructor
    : OPEN_BRACE fieldlist? CLOSE_BRACE
    ;

fieldlist
    : field (fieldsep field)* fieldsep?
    ;

field
    : OPEN_BRACK exp CLOSE_BRACK '=' exp | NAME '=' exp | exp
    ;

fieldsep
    : ','
    ;

operatorOr 
	: 'or' | '||';

operatorAnd 
	: 'and' | '&&';

operatorComparison 
	: '<' | '>' | '<=' | '>=' | '~=' | '!=' | '==';

operatorAddSub
	: '+' | '-';

operatorMulDivMod
	: '*' | '/' | '%' | '//';

operatorBitwise
	: '&' | '|' | '~' | '<<' | '>>';

operatorUnary
    : 'not' | '!' | '-' | '~';

operatorPower
    : '^';

number
    : INT | HEX | FLOAT | HEX_FLOAT
    ;

string
    : NORMALSTRING | CHARSTRING
    ;

// LEXER

NEWLINE
    : ( { atStartOfInput() }? Spaces
    | ( '\r'? '\n' | '\r' ) Spaces?
    ) { processEndOfLine(); }
    ;

OPEN_PAREN : '('  { opened++; };
CLOSE_PAREN : ')' { opened--; };
OPEN_BRACK : '['  { opened++; };
CLOSE_BRACK : ']' { opened--; };
OPEN_BRACE : '{'  { opened++; };
CLOSE_BRACE : '}' { opened--; };

NAME
    : [a-zA-Z_][a-zA-Z_0-9]*
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
    : ( Spaces | Comment | LineJoining ) -> skip
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

fragment
Spaces
    : [ \t]+
    ;

fragment
Comment
    : '#' ~[\r\n]*
    ;
fragment
LineJoining
    : '\\' Spaces? ( '\r'? '\n' | '\r' )
    ;