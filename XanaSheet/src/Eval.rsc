module Eval

import AST;
import List;
import util::Math;
import IO;


Table exampleEval() =
table(
  header([
      cname("A"),
      cname("B")
    ]),
  [row(
      rname(1),
      [
        Cell::integer(23),
        formula(add(
            Expr::integer(3),
            ref(relCell("A",1))))
      ]),
      row(
      rname(1),
      [
        Cell::integer(223),
        formula(call("sum", [range(relCell("A",1), relCell("A", 2))]))
      ])
      
      ]);

Table eval(Table t, map[str, Table] env) {
  for (i <- [0..size(t.rows)], j <- [0..size(t.header.names)]) {
    t.rows[i].cells[j] = evalCell(t.rows[i].cells[j], t, env);
  }
  return t;
}

// !! this assumes there are no edits in header names...
// better to invert the colName function
Cell lookup(str col, int row, Table t) {
  c = t.rows[row - 1].cells[indexOf(t.header.names, cname(col))];
  return c;
} 

Cell evalCell(formula(Expr e), Table t, map[str, Table] env) = Cell::float(evalExpr(e, t, env)[0][0]);

default Cell evalCell(Cell c, Table t, map[str, Table] env) = c;


real evalRef(relCell(c, r), Table t, map[str, Table] env) = toValue(lookup(c, r, t), t, env);

real evalRef(absRow(c, r), Table t, map[str, Table] env) = toValue(lookup(c, r, t), t, env);

real evalRef(absCol(c, r), Table t, map[str, Table] env) = toValue(lookup(c, r, t), t, env);

real evalRef(absCell(c, r), Table t, map[str, Table] env) = toValue(lookup(c, r, t), t, env);

list[list[real]] evalExpr(ref(r), Table t, map[str, Table] env)
  = [[evalRef(r, t, env)]];

list[list[real]] evalExpr(tableRef(str x, Ref r), Table t, map[str, Table] env) 
  = x in env ? [[evalRef(r, env[x], env)]] : [[0.0]];


list[list[real]] evalExpr(range(from, to), Table t, map[str, Table] env) {
   rows = for (r <- [from.row..to.row  + 1]) { // NB: 1-based
     fi = indexOf(t.header.names, cname(from.col));
     ti = indexOf(t.header.names, cname(to.col));
      // NB: 1-based columns
     append [ evalRef(relCell(colName(c + 1), r), t, env) | c <- [fi..ti + 1] ];
   }
   return rows;
}

real sum(list[list[real]] rs)
  = ( 0.0 | it + (0.0 | it + v | v <- r ) | r <- rs );

list[list[real]] evalExpr(call("sum", es), Table t, map[str, Table] env) =
  [[( 0.0 | it + sum(v) | v <- vs )]]
  when vs := [ evalExpr(e, t, env) | e <- es ];

real count(list[list[real]] rs)
  = ( 0.0 | it + (0.0 | it + 1 | v <- r ) + 1 | r <- rs );

list[list[real]] evalExpr(call("count", es), Table t, map[str, Table] env) =
  [[( 0.0 | it + count(v) | v <- vs )]]
  when vs := [ evalExpr(e, t, env) | e <- es ];


list[list[real]] evalExpr(call("round", es), Table t, map[str, Table] env) =
  [[toReal(round([ evalExpr(e, t, env) | e <- es ][0][0][0]))]];


list[list[real]] evalExpr(Expr::integer(int n), Table t, map[str, Table] env) = [[toReal(n)]];
list[list[real]] evalExpr(Expr::string(str s), Table t, map[str, Table] env) = [[0.0]];
list[list[real]] evalExpr(Expr::float(real f), Table t, map[str, Table] env) = [[f]];

  
list[list[real]] evalExpr(mul(l, r), Table t, map[str, Table] env)
  = [[evalExpr(l, t, env)[0][0] * evalExpr(r, t, env)[0][0]]];
  
list[list[real]] evalExpr(div(l, r), Table t, map[str, Table] env)
  = [[evalExpr(l, t, env)[0][0] / evalExpr(r, t, env)[0][0]]];

list[list[real]] evalExpr(add(l, r), Table t, map[str, Table] env)
  = [[evalExpr(l, t, env)[0][0] + evalExpr(r, t, env)[0][0]]];
  
list[list[real]] evalExpr(sub(l, r), Table t, map[str, Table] env)
  = [[evalExpr(l, t, env)[0][0] - evalExpr(r, t, env)[0][0]]];

default list[list[real]] evalExpr(Expr _, Table t, map[str, Table] env) = [[0.0]];

real toValue(Cell::integer(v), Table t, map[str, Table] env) = toReal(v);
real toValue(Cell::float(v), Table t, map[str, Table] env) = v;
real toValue(Cell::empty(), Table t, map[str, Table] env) = 0.0;
real toValue(Cell::string(_), Table t, map[str, Table] env) = 0.0;
real toValue(Cell::symbol(_), Table t, map[str, Table] env) = 0.0;
real toValue(Cell::formula(e), Table t, map[str, Table] env) = evalExpr(e, t, env)[0][0];

