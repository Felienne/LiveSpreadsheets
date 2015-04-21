module Transform

import XanaSyntax;
import ParseTree;
import AST;
import Align;
import Edit;
import Eval;
import PPAst;

XanaSyntax::Sheet transform(XanaSyntax::Sheet s) {
  env = ();
  visit (s) {
    case XanaSyntax::TableDef td: {
      if (td is def) {
        tbl = implode(#AST::Table, td.table);
        env["<td.name>"] = edit(align(tbl));
      }
    }
  }
  
  return visit (s) {
    case XanaSyntax::TableDef td: {
      if (td is view) {
        td.table = parse(#XanaSyntax::Table, ppTable(eval(env["<td.name>"]), td.table@\loc.begin.column + 1));
        insert td;
      }
      else if (td is emptyView) {
        tbl = parse(#XanaSyntax::Table, ppTable(eval(env["<td.name>"]), td.table@\loc.begin.column + 1));
        id = td.name;
        insert (TableDef)`view <Id id> = <Table tbl>.`;
      }
    }
  }
  
}