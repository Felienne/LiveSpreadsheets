module Pretty

import XanaSyntax;
import List;
import String;
import util::Math;
import ParseTree;
import IO;

Cell theEmpty() = (Cell)``;
CName theEmptyCName() = (CName)``;

Sheet ppSheet(Sheet s) {
   return visit (s) {
      case TableDef td => ppTableDef(td)
   }
}

str trimRight(str s) {
  int pos = -1;
  i = size(s) - 1;
  while (i >= 0, s[i] == " ") {
    pos = i;
    i -= 1;
  }
  if (pos > -1) {
    return s[0..pos];
  }
  return s;
}

TableDef ppTableDef(TableDef td) {
  ppt = ppTable(td.table, td.table@\loc.begin.column + 1);
  return td[table=parse(#Table, trimRight(ppt), td.table@\loc)];
}

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

str ppTable(Table t, int indent) {
  numOfCells = longestRowSize(t);
  numOfCols = maxNumOfColumns(t);
  colWidths = ( i: columnWidth(i, t)  | i <- [0..numOfCols] );
  iw = size("<numOfRows(t)>");
  
  rs = [];
  ri = 0;
  for (Row r <- t.rows) {
    i = 0;
    cs = [];
    for (Cell c <- r.cells.lst) {
      cs += [ppCell(c, colWidths[i])];
      i += 1;    
    }
    for (j <- [i..numOfCells]) {
      cs += [ppCell(theEmpty(), colWidths[j])];
    }
    rs += [ ppRName(ri, iw) + ": " + intercalate(" | ", cs)];
    ri += 1;
  }
  sep = left("\n", indent);
  return ppHeader(t.header, numOfCells, colWidths, iw) + sep + intercalate(sep, rs);
}

str ppHeader(Header h, int numOfCells, map[int,int] colWidths, int indexWidth) {
  i = 0;
  hs = [];
  for (hn <- h.lst) {
    hs += [ppCName(i, colWidths[i])];
    i += 1;
  }
  for (j <- [i..numOfCells]) {
    hs += [ppCName(j, colWidths[j])];
  }
  return left("#", indexWidth + 2) + intercalate(" / ", hs);
}

str ppCell(Cell c, int len) = left("<c>", len); 

str ppCName(int col, int len) = left("<colName(col + 1)>", len);

str ppRName(int idx, int len) = right("<idx>", len);

int maxNumOfColumns(Table t) 
  = ( headerLength(t.header) | max(it, rowLength(r)) | r <- t.rows );

int columnWidth(int c, Table t) 
  = ( hnameWidth(hnameAt(c, t.header)) | max(it, cellWidth(cellAt(c, r))) | r <- t.rows );

int indexWidth(Table t) 
  = ( 0 | max(it, rnameWidth(r.rname)) | r <- t.rows );

int cellWidth(Cell c) = size("<c>");
int hnameWidth(CName h) = size("<h>");

Cell cellAt(int n, Row r) {
  i = 0;
  for (Cell c <- r.cells.lst) {
    if (i == n) {
      return c;
    }
    i += 1;
  }
  return theEmpty();
}

CName hnameAt(int n, Header h) {
  i = 0;
  for (CName hn <- h.lst) {
    if (i == n) {
      return hn;
    }
    i += 1;
  }
  return theEmptyCName();
}

int longestRowSize(Table t)
  = ( headerLength(t.header) | max(it, rowLength(r)) | r <- t.rows );

int numOfRows(Table t) 
  = ( 0 | it + 1 | Row _ <- t.rows );

int rowLength(Row row) = ( 0 | it + 1 | _ <- row.cells.lst );
int headerLength(Header h) = (0 | it + 1 | _ <- h.lst );