package io.nondev.spoon;

import io.nondev.spoon.util.PrettyDumper;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;

import java.io.InputStream;

public class Application {
    public static void main(String... args) throws Exception {
        InputStream inputStream = Application.class.getResourceAsStream("example.spoon");
        ANTLRInputStream input = new ANTLRInputStream(inputStream);
        SpoonLexer lexer = new SpoonLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        SpoonParser parser = new SpoonParser(tokens);

        System.out.println(new PrettyDumper(parser).dumpTree(parser.chunk()));
    }
}