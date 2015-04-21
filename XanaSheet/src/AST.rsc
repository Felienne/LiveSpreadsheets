module AST

import String;

data Sheet 
  = sheet(list[TableDef] defs)
  ;
  
data TableDef
  = def(str id, Table table)
  | view(str id, Table table)
  | emptyView(str id)
  ;
  
data Table
  = table(Header header, list[Row] rows);
  
data Header
  = header(list[CName] names)
  ;
  
data RName
  = rname(int n)
  | empty()
  | addBefore(RName rname)
  | addAfter(RName rname)
  | delete(RName rname)
  ;
  
  
data CName
  = cname(str name)
  | empty()
  | addBefore(CName cname)
  | addAfter(CName cname)
  | delete(CName cname)
  ;
  
data Row
  = row(RName name, list[Cell] cells);
  
data Cell
  = integer(int n)
  | string(str s)
  | symbol(str s)
  | float(real r)
  | empty()
  | formula(Expr expr)
  | openRect(Cell cell)
  | closeRec(Cell cell)
  | rect(Cell cell)
  ;

data Ref
  = relCell(str col, int row)
  | absRow(str col, int row)
  | absCol(str col, int row)
  | absCell(str col, int row)
  ;

data Expr
  = ref(Ref ref)
  | range(Ref from, Ref to)
  | integer(int n)
  | string(str s)
  | float(real f)
  | \true()
  | \false()
  | call(str func, list[Expr] args)
  | not(Expr arg)
  | mul(Expr lhs, Expr rhs)
  | div(Expr lhs, Expr rhs)
  | add(Expr lhs, Expr rhs)
  | sub(Expr lhs, Expr rhs)
  | lt(Expr lhs, Expr rhs)
  | leq(Expr lhs, Expr rhs)
  | gt(Expr lhs, Expr rhs)
  | geq(Expr lhs, Expr rhs)
  | eq(Expr lhs, Expr rhs)
  | neq(Expr lhs, Expr rhs)
  | and(Expr lhs, Expr rhs)
  | or(Expr lhs, Expr rhs)
  ;
    
    
data Coord
  = relative(int n)
  | absolute(int n)
  ; 
    
str colName(int columnNumber) {
  dividend = columnNumber;
  columnName = "";
  modulo = 0;
  while (dividend > 0) {
    modulo = (dividend - 1) % 26;
    columnName = stringChar(65 + modulo) + columnName;
    dividend = (dividend - modulo) / 26;
  } 

  return columnName;
}
    