package io.nondev.spoon.util;

import io.nondev.spoon.SpoonParser;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

import java.util.Arrays;

public class PrettyPrinter {
    public static String pp(final ParseTree parseTree, final SpoonParser parser){
        final TreePrinterListener listener = new TreePrinterListener(parser);
        ParseTreeWalker.DEFAULT.walk(listener, parseTree);
        return listener.toString();
    }
}
