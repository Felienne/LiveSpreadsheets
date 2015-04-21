module Eval

import AST;
import List;

alias Address = tuple[int col, int row];

Table eval(Table t) {
  for (i <- [0..size(t.rows)], j <- [0..size(t.header.names)]) {
    t.rows[i][j] = evalCell(getCell(<j, i>, t), <j, i>, t);
  }
  return sheet;
}

Cell lookup(str col, int row, Table t) 
  = t.rows[row].cells[indexOf(t.header.names, cname(col))]; 

Cell evalCell(formula(Expr e), Address a, Table t) = float(evalExpr(e, a, s));

default Cell evalCell(Cell c, Address a, Table t) = c;


real evalExpr(relCell(c, r), Table t) = toValue(lookup(c, r, t), t);

real evalExpr(absRow(c, r), Table t) = toValue(lookup(c, r, t), t);

real evalExpr(absCol(c, r), Table t) = toValue(lookup(c, r, t), t);

real evalExpr(absCell(c, r), Table t) = toValue(lookup(c, r, t), t);

real evalExpr(call("sum", es), Table t) =
  ( 0.0 | it + v | v <- vs )
  when vs := [ evalExpr(e, t) | e <- es ];

real evalExpr(call("round", es), Table t) =
  toReal(round([ evalExpr(e, t) | e <- es ][0]));

real evalExpr(call("count", es), Table t) =
  ( 0.0 | it + 1 | v <- vs )
  when vs := [ evalExpr(e, t) | e <- es ];

real evalExpr(Expr::integer(int n), Table t) = toReal(n);
real evalExpr(Expr::string(str s), Table t) = 0.0;
real evalExpr(Expr::float(real f), Table t) = f;

  
real evalExpr(mul(l, r), Table t)
  = evalExpr(l, s) + evalExpr(r, s);
  
real evalExpr(div(l, r), Table t)
  = evalExpr(l, s) + evalExpr(r, s);

real evalExpr(add(l, r), Table t)
  = evalExpr(l, s) + evalExpr(r, s);
  
real evalExpr(sub(l, r), Table t)
  = evalExpr(l, s) + evalExpr(r, s);

default real evalExpr(Expr _, Table t) = 0.0;

real toValue(Cell::integer(v), Table t) = toReal(v);
real toValue(Cell::float(v), Table t) = v;
real toValue(Cell::empty(), Table t) = 0.0;
real toValue(Cell::string(_), Table t) = 0.0;
real toValue(Cell::symbol(_), Table t) = 0.0;
real toValue(Cell::formula(e), Table t) = evalExpr(e);

