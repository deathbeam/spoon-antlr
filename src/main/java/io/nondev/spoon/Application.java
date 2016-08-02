package io.nondev.spoon;

import java.io.InputStream;

import io.nondev.spoon.util.PrettyPrinter;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;

public class Application {
    public static void main(String... args) throws Exception {
        InputStream inputStream = Application.class.getResourceAsStream("example.spoon");
        ANTLRInputStream input = new ANTLRInputStream(inputStream);
        SpoonLexer lexer = new SpoonLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        SpoonParser parser = new SpoonParser(tokens);
        ParseTree tree = parser.chunk();

        System.out.println(PrettyPrinter.pp(tree, parser));
    }
}