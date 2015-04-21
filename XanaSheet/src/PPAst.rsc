module PPAst

import AST;
import String;
import List;
import Priorities;
import util::Math;

str ppTable(Table t, int indent) {
  array = [[]];
  colWidths = ();
  for (i <- [0..size(t.header.names)]) {
    s = ppCName(i);
    array[0] += [s];
    if (i notin colWidths) colWidths[i] = 0;
    colWidths[i] = max(colWidths[i], size(s));
  } 
  
  ri = 0;
  rowNameWidth = 0;
  array += for (r <- t.rows) {
    rn = ppRName(ri);
    rowNameWidth = max(rowNameWidth, size(rn));
    rl = [rn];
    i = 0;
    rl += for (c <- r.cells) {
      cstr = ppCell(c);
      append cstr;
      colWidths[i] = max(colWidths[i], size(cstr));
      i += 1;      
    }
    ri += 1;
    append rl;
  }
  
  tblStr = left("", indent) + left("#", rowNameWidth + 1);
  tblStr += intercalate(" / ", [ left(array[0][j], colWidths[j]) | j <- [0..size(array[0])]]);
  for (i <- [1..size(array)]) {
     tblStr += left("\n", indent + 1)
       + left(array[i][0], rowNameWidth + 1) 
       + intercalate(" | ", [ left(array[i][j], colWidths[j - 1]) | j <- [1..size(array[i])] ]);
  }
  return tblStr;
}

str ppCName(int col) = "<colName(col + 1)>";
str ppRName(int idx) = "<idx + 1>:";

str ppCell(Cell::integer(n)) = "<n>";
str ppCell(Cell::float(n)) = "<n>";
str ppCell(Cell::string(s)) = s;
str ppCell(symbol(s)) = s;
str ppCell(Cell::empty()) = "";
str ppCell(formula(e)) = "= <ppExpr(e)>";
str ppCell(openRect(c)) = "[ <ppCell(c)>";
str ppCell(closeRect(c)) = "<ppCell(c)> ]";
str ppCell(rect(c)) = "[ <ppCell(c)> ]";

str ppRef(p:relCell(str col, int row)) = "<col><row>";
str ppRef(p:absRow(str col, int row)) = "<col>$<row>";
str ppRef(p:absCol(str col, int row)) = "$<col><row>";
str ppRef(p:absCell(str col, int row)) = "$<col>$<row>";

str ppExpr(p:ref(Ref r)) = ppRef(r);
str ppExpr(p:range(Ref f, Ref t)) = "<ppRef(f)>:<ppRef(t)>";
str ppExpr(p:Expr::integer(int n)) = "<n>";
str ppExpr(p:Expr::string(str s)) = s;
str ppExpr(p:Expr::float(real f)) = "<f>";
str ppExpr(p:\true()) = "true";
str ppExpr(p:\false()) = "false";
str ppExpr(p:call(str func, list[Expr] args)) = "<func>(<intercalate(", ", [ ppExpr(a) | a <- args ])>)";
str ppExpr(p:not(Expr arg)) = "!<ppExpr(p, arg)>";
str ppExpr(p:mul(Expr lhs, Expr rhs)) = "<ppExpr(p, lhs)> * <ppExpr(p, rhs)>";
str ppExpr(p:div(Expr lhs, Expr rhs)) = "<ppExpr(p, lhs)> / <ppExpr(p, rhs)>";
str ppExpr(p:add(Expr lhs, Expr rhs)) = "<ppExpr(p, lhs)> + <ppExpr(p, rhs)>";
str ppExpr(p:sub(Expr lhs, Expr rhs)) = "<ppExpr(p, lhs)> - <ppExpr(p, rhs)>";
str ppExpr(p:lt(Expr lhs, Expr rhs)) = "<ppExpr(p, lhs)> \< <ppExpr(p, rhs)>";
str ppExpr(p:leq(Expr lhs, Expr rhs)) = "<ppExpr(p, lhs)> \<= <ppExpr(p, rhs)>";
str ppExpr(p:gt(Expr lhs, Expr rhs)) = "<ppExpr(p, lhs)> \> <ppExpr(p, rhs)>";
str ppExpr(p:geq(Expr lhs, Expr rhs)) = "<ppExpr(p, lhs)> \>= <ppExpr(p, rhs)>";
str ppExpr(p:eq(Expr lhs, Expr rhs)) = "<ppExpr(p, lhs)> == <ppExpr(p, rhs)>";
str ppExpr(p:neq(Expr lhs, Expr rhs)) = "<ppExpr(p, lhs)> != <ppExpr(p, rhs)>";
str ppExpr(p:and(Expr lhs, Expr rhs)) = "<ppExpr(p, lhs)> && <ppExpr(p, rhs)>";
str ppExpr(p:or(Expr lhs, Expr rhs)) = "<ppExpr(p, lhs)> || <ppExpr(p, rhs)>";

str ppExpr(Expr parent, Expr kid) =
  parens(parent, kid, ppExpr(kid), parenizer);

str parenizer(str x) = "(<x>)";