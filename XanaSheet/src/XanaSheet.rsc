@license{
  Copyright (c) 2009-2015 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Tijs van der Storm storm@cwi.nl - CWI}

module XanaSheet

import IO;

alias Row = list[Cell];
data Sheet = sheet(int rowCount, int colCount, list[Row] rows);

data Cell
  = val(real val)
  | expr(Expr expr)
  | empty()
  | error(str msg)
  ;
  
alias Address = tuple[int col, int row];
  
data Expr
  = ref(int colOffset, int rowOffset) // only do relative now
  | add(Expr lhs, Expr rhs)
  | div(Expr lhs, Expr rhs)
  | lit(real val)
  ;
  
alias Origin = rel[Address ref, Address org];

alias Area = tuple[Address upLeft, Address downRight];  

data Edit
  = putFormula(Address address, Expr e)
  | putData(Address address, real val)
  | copy(Area from, Area to)
  | insertRow(int row)
  | insertCol(int col)
  ;
  
alias Script = list[Edit];
  
Sheet grades() = sheet(3, 3, [
  [val(6.0), val(9.5), expr(div(add(ref(-2, 0), ref(-1, 0)), lit(2.0)))],
  [val(9.0), val(7.0), empty()],
  [val(5.0), val(3.5), empty()]
]);


Script buildGrades1() = [
   insertRow(0), insertRow(0), insertRow(0),
   insertCol(0), insertCol(0), insertCol(0), 
   putData(<0, 0>, 6.0),
   putData(<0, 1>, 9.0),
   putData(<0, 2>, 5.0),
   putData(<1, 0>, 9.5),
   putData(<1, 1>, 7.0),
   putData(<1, 2>, 3.5),
   putFormula(<2, 0>, div(add(ref(-2, 0), ref(-1, 0)), lit(2.0)))
];


test bool buildGrades1BuildsGrades1()
  = evalScript(buildGrades1(), sheet(0, 0, []), {}).sheet == grades();


Sheet gradesModifiedAfterCopy() = sheet(3, 3, [
  [val(6.0), val(9.5), expr(div(add(ref(-2, 0), ref(-1, 0)), lit(3.0)))],
  [val(9.0), val(7.0), expr(div(add(ref(-2, 0), ref(-1, 0)), lit(3.0)))],
  [val(5.0), val(3.5), expr(div(add(ref(-2, 0), ref(-1, 0)), lit(3.0)))]
]);


Script copyAndModifyGrades1() = [
   copy(<<2, 0>, <2,0>>, <<2, 1>, <2,1>>),
   copy(<<2, 0>, <2,0>>, <<2, 2>, <2,2>>),
   putFormula(<2, 2>, div(add(ref(-2, 0), ref(-1, 0)), lit(3.0)))
];

  
test bool copyAndModifyModifiesAllClones() 
  = evalScript(buildGrades1() + copyAndModifyGrades1(), sheet(0, 0, []), {}).sheet == gradesModifiedAfterCopy();


Script insertRowAndModifyCopy() = [
   insertRow(0),
   putData(<0, 0>, 10.0),
   putData(<1, 0>, 10.0),
   //copy(<<0, 1>, <0, 1>>, <<0, 0>, <0, 0>>),
   //copy(<<1, 1>, <1, 1>>, <<1, 0>, <1, 0>>),
   copy(<<2, 1>, <2, 1>>, <<2, 0>, <2, 0>>),
   putFormula(<2, 3>, div(add(ref(-2, 0), ref(-1, 0)), lit(5.0)))
];

Sheet gradesModifiedAfterInsertRow() = sheet(4, 3, [
  [val(10.0), val(10.0), expr(div(add(ref(-2, 0), ref(-1, 0)), lit(5.0)))],
  [val(6.0), val(9.5), expr(div(add(ref(-2, 0), ref(-1, 0)), lit(5.0)))],
  [val(9.0), val(7.0), expr(div(add(ref(-2, 0), ref(-1, 0)), lit(5.0)))],
  [val(5.0), val(3.5), expr(div(add(ref(-2, 0), ref(-1, 0)), lit(5.0)))]
]);

test bool insertRowAdjustsOrigins() 
  = evalScript(buildGrades1() + copyAndModifyGrades1() + insertRowAndModifyCopy(), sheet(0, 0, []), {}).sheet
  == gradesModifiedAfterInsertRow(); 

/*
 * Editing of sheets
 */
 
alias Result = tuple[Sheet sheet, Origin origin];

Result evalScript(Script script, Sheet s, Origin org) { 
   for (e <- script) {
     iprintln(s);
     <s, org> = eval(e, s, org);
   }
   return <s, org>;
}

Result eval(putData(Address a, real v), Sheet s, Origin org) {
  s = putCell(a, val(v), s);
  return <s, removeLinks(a, org)>;
}

Origin removeLinks(Address a, Origin org) 
  = { <f, t> | <f, t> <- org, f != a};

Result eval(putFormula(Address a, Expr e), Sheet s, Origin org) {
  s = putCell(a, expr(e), s);
  if (<a, Address src> <- org) {
    toReconcile = {src} + { b | <b, src> <- org+ };
    for (Address x <- toReconcile) {
       s = putCell(x, expr(e), s);
    }
  } 
  return <s, org>;
}

Result eval(insertRow(int row), Sheet s, Origin org) {
  if (row < s.rowCount) { // bug in slicing 
    s.rows = s.rows[0..row] + [[ empty() | _ <- [0..s.colCount] ]] + s.rows[row..];
  }
  else { 
    s.rows += [[ empty() | _ <- [0..s.colCount] ]];
  }
  s.rowCount += 1;
  
  newOrgs = { <<a.col, a.row >= row ? a.row + 1 : a.row>, 
               <b.col, b.row >= row ? b.row + 1 : a.row>> | <Address a, Address b> <- org };
  
  return <s, newOrgs>;
}

Result eval(insertCol(int col), Sheet s, Origin org) {
  if (col < s.colCount) { // bug in slicing
    s.rows = [ r[0..col] + [ empty() ] + r[col..] | r <- s.rows ];
  }
  else {
    s.rows = [ r + [ empty() ] | r <- s.rows ];
  } 
  
  s.colCount += 1;
  
  newOrgs = { <<a.col >= col ? a.col + 1 : a.col, a.row>, 
               <b.col >= col ? b.col + 1 : b.col, b.row>> | <a, b> <- org };
  
  return <s, newOrgs>;
}

Sheet putCell(Address a, Cell c, Sheet s) {
   s.rows[a.row][a.col] = c;
   return s;
}

Result eval(copy(Area a1:<Address xul, xdr>, Area a2:<Address yul, ydr>), Sheet s, Origin org) {
  // for now assume single cell to single cell
  assert xul == xdr && yul == ydr;
  return copyCell(xul, yul, s, org);
}

Result copyCell(Address x, Address y, Sheet s, Origin org) {
  Cell toBeCopied = getCell(x, s);
  s = putCell(y, toBeCopied, s);
  org = removeLinks(y, org);
  if (toBeCopied is expr) {
    if (<x, Address src> <- org) {
      // maintain farthest origin 
      org += {<y, src>};
    }
    else {
      org += {<y, x>};
    }
  }
  return <s, org>;
}


/*
 * Computation of sheets
 */


Sheet compute(Sheet sheet) {
  for (i <- [0..sheet.rowCount], j <- [0..sheet.colCount]) {
    sheet.rows[i][j] = evalCell(getCell(<j, i>, sheet), <j, i>, sheet);
  }
  return sheet;
}

Cell evalCell(expr(Expr e), Address a, Sheet s) = val(evalExpr(e, a, s));

default Cell evalCell(Cell c, Address a, Sheet s) = c;


real evalExpr(ref(int colOffset, int rowOffset), <ci, ri>, Sheet s)
  = getCellValue(<ci + colOffset, ri + rowOffset>, s);

real evalExpr(add(l, r), Address a, Sheet s)
  = evalExpr(l, a, s) + evalExpr(r, a, s);
  
real evalExpr(div(l, r), Address a, Sheet s)
  = evalExpr(l, a, s) / evalExpr(r, a, s);
  
real evalExpr(lit(v), Address a, Sheet s) = v;

real getCellValue(Address a, Sheet s) {
   c = evalCell(getCell(a, s), a, s);
   switch (c) {
     case val(v):   return v;
     case empty():  return 0.0;
     case error(_): return 0.0;
     case expr(e):  return evalExpr(e, a, s);
   }
}

Cell getCell(Address a, Sheet s) {
  if (a.row < s.rowCount, a.col < s.colCount) {
     return s.rows[a.row][a.col];
  }
  return error("Out-of-bounds: <a>");
}
