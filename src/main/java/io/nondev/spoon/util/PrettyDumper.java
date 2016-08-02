package io.nondev.spoon.util;

import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.RuleContext;
import org.antlr.v4.runtime.misc.Utils;
import org.antlr.v4.runtime.tree.*;

import java.util.*;

public class PrettyDumper {
    private final StringBuilder builder = new StringBuilder();
    private final TreePrinterListener listener;
    private final Parser parser;

    public PrettyDumper(final Parser parser) {
        this.parser = parser;
        this.listener = new TreePrinterListener(parser);
    }

    public String dumpRules(final RuleContext context) {
        builder.setLength(0);
        explore(parser, context, 0);
        return builder.toString();
    }

    public String dumpTree(final ParseTree parseTree) {
        ParseTreeWalker.DEFAULT.walk(listener, parseTree);
        return listener.toString();
    }

    private void explore(final Parser parser, final RuleContext context, int indentation) {
        boolean toBeIgnored = context.getChildCount() == 1 &&
                context.getChild(0) instanceof ParserRuleContext;

        if (!toBeIgnored) {
            String ruleName = parser.getRuleNames()[context.getRuleIndex()];

            for (int i = 0; i < indentation; i++) {
                builder.append("  ");
            }

            builder.append(ruleName).append("\n");
        }

        for (int i = 0; i < context.getChildCount(); i++) {
            ParseTree element = context.getChild(i);
            if (element instanceof RuleContext) {
                explore(parser, (RuleContext) element, indentation + (toBeIgnored ? 0 : 1));
            }
        }
    }

    private class TreePrinterListener implements ParseTreeListener {
        private final List<String> ruleNames;
        private final StringBuilder builder = new StringBuilder();
        private final Map<RuleContext, ArrayList<String>> stack = new HashMap<>();

        private TreePrinterListener(Parser parser) {
            this.ruleNames = Arrays.asList(parser.getRuleNames());
        }

        @Override
        public void visitTerminal(TerminalNode node) {
            String text = Utils.escapeWhitespace(Trees.getNodeText(node, ruleNames), false);
            if (text.startsWith(" ") || text.endsWith(" ")) {
                text = "'" + text + "'";
            }
            stack.get(node.getParent()).add(text);
        }

        @Override
        public void visitErrorNode(ErrorNode node) {
            stack.get(node.getParent()).add(Utils.escapeWhitespace(Trees.getNodeText(node, ruleNames), false));
        }

        @Override
        public void enterEveryRule(ParserRuleContext ctx) {
            if (!stack.containsKey(ctx.parent)) {
                stack.put(ctx.parent, new ArrayList<>());
            }
            if (!stack.containsKey(ctx)) {
                stack.put(ctx, new ArrayList<>());
            }

            final StringBuilder sb = new StringBuilder();
            int ruleIndex = ctx.getRuleIndex();
            String ruleName;
            if (ruleIndex >= 0 && ruleIndex < ruleNames.size()) {
                ruleName = ruleNames.get(ruleIndex);
            } else {
                ruleName = Integer.toString(ruleIndex);
            }
            sb.append(ruleName);
            stack.get(ctx).add(sb.toString());
        }

        @Override
        public void exitEveryRule(ParserRuleContext ctx) {
            ArrayList<String> ruleStack = stack.remove(ctx);
            StringBuilder sb = new StringBuilder();
            boolean brackit = ruleStack.size() > 1;
            if (brackit) {
                sb.append("(");
            }
            sb.append(ruleStack.get(0));
            for (int i = 1; i < ruleStack.size(); i++) {
                sb.append(" ");
                sb.append(ruleStack.get(i));
            }
            if (brackit) {
                sb.append(")");
            }
            if (sb.length() < 80) {
                stack.get(ctx.parent).add(sb.toString());
            } else {
                // Current line is too long, regenerate it using 1 line per item.
                sb.setLength(0);
                if (brackit) {
                    sb.append("(");
                }
                if (!ruleStack.isEmpty()) {
                    sb.append(ruleStack.remove(0)).append("\r\n");
                }
                while (!ruleStack.isEmpty()) {
                    sb.append(indent(ruleStack.remove(0))).append("\r\n");
                }
                if (brackit) {
                    sb.append(")");
                }
                stack.get(ctx.parent).add(sb.toString());
            }
            if (ctx.parent == null) {
                builder.append(sb.toString());
            }
        }

        @Override
        public String toString() {
            return builder.toString();
        }

        private String indent(String input) {
            return "  " + input.replaceAll("\r\n(.)", "\r\n  $1");
        }
    }
}
