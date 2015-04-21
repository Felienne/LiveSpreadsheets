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
  visit (s) {
    case XanaSyntax::TableDef td: {
      if (td is def) {
        tbl = implode(#AST::Table, td.table);
        ast = edit(align(tbl));
        env["<td.name>"] = ast;
      }
    }
  }
  
  return visit (s) {
    case XanaSyntax::TableDef td: {
      if (td is view) {
        tname = "<td.name>";
        if (tname in env) {
          src = trim(ppTable(eval(env[tname]), td.table@\loc.begin.column + 2));
          td.table = parse(#XanaSyntax::Table, src);
          insert td;
        }
      }
      else if (td is emptyView) {
        tname = "<td.name>";
        if (tname in env) {
          src = trim(ppTable(eval(env["<td.name>"]), td@\loc.end.column + 2));
          tbl = parse(#XanaSyntax::Table, src);
          id = td.name;
          insert (TableDef)`view <Id id> = <Table tbl>.`;
        }
      }
      else {
        src = trim(ppTable(env["<td.name>"], td.table@\loc.begin.column + 2));
        td.table = parse(#XanaSyntax::Table, src);
        insert td;
      }
    }
  }
  
}