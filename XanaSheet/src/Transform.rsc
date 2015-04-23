module Transform

import XanaSyntax;
import ParseTree;
import AST;
import Align;
import Edit;
import Eval;
import PPAst;
import String;
import IO;


XanaSyntax::Sheet transform(XanaSyntax::Sheet s) {
  env = ();
  ren = ();
  visit (s) {
    case XanaSyntax::TableDef td: {
      if (td is def) {
        tbl = implode(#AST::Table, td.table);
        ast = edit(align(tbl));
        n = "<td.name>";
        if (/^<old:[a-zA-Z0-9]+>-\><new:[a-zA-Z0-9]+>\./ := n) {
          n = new;
        }
        env[n] = ast;
      }
    }
    case XanaSyntax::Id id: {
      n = "<id>";
      if (/^<old:[a-zA-Z0-9]+>-\><new:[a-zA-Z0-9]+>\./ := n) {
        ren[old] = new;
        insert parse(#XanaSyntax::Id, new);
      }
    }
  }
  
  println("Ren = <ren>");
  return visit (s) {
    case XanaSyntax::Id id: {
      n = "<id>";
      if (/^<old:[a-zA-Z0-9]+>-\><new:[a-zA-Z0-9]+>\./ := n) {
        insert parse(#XanaSyntax::Id, new);
      }
      if (n in ren) {
        insert parse(#XanaSyntax::Id, ren[n]);
      }
    }
    case XanaSyntax::TableDef td: {
      if (td is view) {
        tname = "<td.name>";
        if (tname in env) {
          src = trim(ppTable(eval(env[tname], env), td.table@\loc.begin.column));
          td.table = parse(#XanaSyntax::Table, src);
          insert td;
        }
      }
      else if (td is emptyView) {
        tname = "<td.name>";
        if (tname in env) {
          src = trim(ppTable(eval(env["<td.name>"], env), td@\loc.end.column));
          tbl = parse(#XanaSyntax::Table, src);
          id = td.name;
          insert (TableDef)`view <Id id> = <Table tbl>.`;
        }
      }
      else if (td is def) {
        tname = "<td.name>";
        src = trim(ppTable(env[tname], td.table@\loc.begin.column));
        td.table = parse(#XanaSyntax::Table, src);
        insert td;
      }
      else if (td is repl) {
        ctx = "<td.ctx>";
        if (ctx in env) {
          if (td.repl is command) {
             v = evalExpr(implode(#AST::Expr, td.repl.cmd), env[ctx], env)[0][0];
             ve = parse(#XanaSyntax::Expr, "<v>");
             r = td.repl;
             src = "<r>
                   '=\> <ve>
                   '\>";
             td.repl = parse(#XanaSyntax::Repl, src);
             insert td;
          }
          else if (td.repl is result) {
            if (td.repl.prompt is command) {
               v = evalExpr(implode(#AST::Expr, td.repl.prompt.cmd), env[ctx], env)[0][0];
               ve = parse(#XanaSyntax::Expr, "<v>");
               r = td.repl;
               src = "<r>
                   '=\> <ve>
                   '\>";
               td.repl = parse(#XanaSyntax::Repl, src);
               insert td;
            }
          }
        }
      
      }
      else if (td is testSuccess) {
        ctx = "<td.ctx>";
        if (ctx in env) {
          v1 = evalExpr(implode(#AST::Expr, td.lhs), env[ctx], env)[0][0];
          v2 = evalExpr(implode(#AST::Expr, td.rhs), env[ctx], env)[0][0];
          if (v1 != v2) {
            v1e = parse(#XanaSyntax::Expr, "<v1>");
            v2e = parse(#XanaSyntax::Expr, "<v2>");
            lhs = td.lhs;
            rhs = td.rhs;
            Id id = parse(#XanaSyntax::Id, ctx);
            insert (TableDef)`test <Id id> <Expr lhs> == <Expr rhs> expected <Expr v2e>, got <Expr v1e>`;
          }
        }
      }
      else if (td is testFailed) {
        ctx = "<td.ctx>";
        if (ctx in env) {
          v1 = evalExpr(implode(#AST::Expr, td.lhs), env[ctx], env)[0][0];
          v2 = evalExpr(implode(#AST::Expr, td.rhs), env[ctx], env)[0][0];
          if (v1 != v2) {
            td.exp = parse(#XanaSyntax::Expr, "<v2>");
            td.got = parse(#XanaSyntax::Expr, "<v1>");
            insert td;
          }
          else {
            Id id = parse(#XanaSyntax::Id, ctx);
            lhs = td.lhs;
            rhs = td.rhs;
            insert (TableDef)`test <Id id> <Expr lhs> == <Expr rhs>`;
          }
        }
      }
    }
  }
  
}