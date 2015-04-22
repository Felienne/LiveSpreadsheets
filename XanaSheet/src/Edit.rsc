module Edit

import AST;
import List;

import IO;
import String;

/*

Order:
- parse
- implode
- align
- edit
- eval
- format (also normalizes cnames and rnames).

*/

//list[Cell] adjustRefs(list[Cell] cells, int rowOffset, int colOffset, list[CName] oldNames) {
//   Cell adjust(Cell c, int colIdx) {
//     return visit (c) {
//       case relCell(str col, int row): {
//          ci = indexOf(oldNames, cname(col)) + 1;
//          if (ci > colOffset) {
//            col = colName(ci + 1);
//          }
//          if (row > rowOffset) {
//            row += 1;
//          }
//          insert relCell(col, row);
//       }
//       case absRow(str col, int row): {
//          ci = indexOf(oldNames, cname(col)) + 1;
//          if (ci > colOffset) {
//            col = colName(ci + 1);
//          }
//          insert absRow(col, row);
//       }
//       case absCol(str col, int row): {
//          if (row > rowOffset) {
//            row += 1;
//          }
//          insert absCol(col, row);
//       }
//     }
//  }
//  
//  i = 0;
//  cells = for (c <- cells) {
//     append adjust(c, i + 1);
//     i += 1;
//  }
//  iprintln(cells);
//  return cells; 
//} 




int columnIndex(str col, list[CName] oldNames) {
  i = 0;
  for (cn <- oldNames) {
    if (/cname(col) := cn) { // deep match to deal with +/- etc.
      return i;
    }
    i += 1;
  }
  return -1 ;
}

list[Cell] adjustColumns(list[Cell] cells, int from, int dir, list[CName] oldNames) {
  println("Adjusting: from = <from>, dir = <dir>");
  for (i <- [0..size(cells)]) {
    cells[i] = visit (cells[i]) {
      case relCell(str col, int row): {
        ci = columnIndex(col, oldNames);
        println("ci = <ci>");
        println("col = <col>");
        if (ci >= from) { 
          insert relCell(colName(ci + dir + 1), row);
        }
      }
      case absRow(str col, int row): {
        ci = columnIndex(col, oldNames);
        if (ci >= from) {
          insert absRow(colName(ci + dir + 1), row);
        }
      }
    } 
  }
  return cells;
}

Table edit(Table tbl) {
  // only support 1 edit at a time
  
  ns = tbl.header.names;
  for (i <- [0..size(ns)]) {
    if (ns[i] is addBefore) {
      tbl.header.names = insertAt(tbl.header.names, i, CName::empty());
      tbl.rows = for (r <- tbl.rows) {
        r.cells = adjustColumns(insertAt(r.cells, i, Cell::empty()), i, 1, ns);
        append r;
      }
      return tbl;
    }
    if (ns[i] is addAfter) {
      tbl.header.names = insertAt(tbl.header.names, i + 1, CName::empty());
      tbl.rows = for (r <- tbl.rows) {
        r.cells = adjustColumns(insertAt(r.cells, i + 1, Cell::empty()), i + 1, 1, ns);
        append r;
      }
      return tbl;
    }
    if (ns[i] is delete) {
      tbl.header.names = remove(tbl.header.names, i);
      tbl.rows = for (r <- tbl.rows) {
        r.cells = adjustColumns(remove(r.cells, i), i, -1, ns);
        append r;
      }
      return tbl;
    }
  } 
  
  return tbl;
}

// assumes aligned
// align basically fills adds columns to the right to match the longest row
Table edit___advanced(Table tbl) {
  mods = [];

  oldWidth = size(tbl.header.names);

  offset = 0;
  
  ns = tbl.header.names;
  for (i <- [0..size(ns)]) {
    if (ns[i] is addBefore) {
      println("Add before: <ns[i]>");
      tbl.header.names[i + offset] = ns[i].cname; 
      tbl.header.names = insertAt(tbl.header.names, i + offset, CName::empty());
      mods += [i + 1];
      offset += 1;
    }
    if (ns[i] is addAfter) {
      tbl.header.names[i + offset] = ns[i].cname; 
      tbl.header.names = insertAt(tbl.header.names, i + offset + 1, CName::empty());
      mods += [i + 1 + 1];
      offset += 1;
    }
    if (ns[i] is delete) {
      tbl.header.names = remove(tbl.header.names, i + offset);
      mods += [-i - 1];
      offset -= 1;
    }
  } 
  
  absDiff = ( 0 | it + (x > 0 ? 1 : -1) | x <- mods );
  
  println("MODS = <mods>");
  rowOffset = 0;
  tbl.rows = for (r <- tbl.rows) {
     offset = 0;
     for (i <- mods) { 
       if (i > 0) {
         r.cells = insertAt(r.cells, i + offset - 1, Cell::empty());
       }
       else {
         // the - 1 seems wrong...
         r.cells = remove(r.cells, i + offset - 1);
       }
       dir = i > 0 ? 1 : -1;
       r.cells = adjustRefs(r.cells, rowOffset, i + offset - 1);
       offset += dir;
     }
     if (r.name is addBefore) {
       r.name = r.name.rname;
       append row(empty(), [ Cell::empty() | k <- [0..oldWidth + absDiff] ]);
       rowOffset += 1;
       r.cells = adjustRefs(r.cells, rowOffset, offset);
       append r; 
       
     }
     else if (r.name is addAfter) {
       r.name = r.name.rname;
       append r;
       append row(empty(), [ Cell::empty() | k <- [0..oldWidth + absDiff] ]);
       rowOffset += 1;
     }
     else if (!(r.name is delete)) {
       r.cells = adjustRefs(r.cells, rowOffset, offset);
       append r;
       rowOffset -= 1;
     }
  } 
  
  return tbl;
}
Table example() 
  = table(header([cname("A"), cname("B")]), 
     [
      row(rname(1), [ symbol("foo"), symbol("bar") ])      
     ]);

Table emptyTable() 
  = table(header([cname("A"), cname("B")]), 
     [
     ]);


test bool noopExample() = edit(example()) == example();
test bool emptyStaysEmpty() = edit(emptyTable()) == emptyTable();


Table allTogether() 
  = table(header([delete(cname("A")), addAfter(cname("B")), addBefore(cname("C"))]), 
     [
      row(addBefore(rname(1)), [ symbol("foo"), symbol("bar") ]),      
      row(addAfter(rname(2)), [ symbol("baz"), symbol("bla") ]),      
      row(delete(rname(3)), [ symbol("baz"), symbol("bla") ])      
     ]);

Table addRowBeforeFormulaTable() 
  = table(header([cname("A"), cname("B")]), 
     [
      row(addBefore(rname(1)), [ symbol("foo"), formula(ref(relCell("A", 1))) ])      
     ]);

Table addRowAndColumnBeforeFormulaTable() 
  = table(header([addBefore(cname("A")), cname("B")]), 
     [
      row(addBefore(rname(1)), [ Cell::integer(23), formula(add(Expr::integer(3), ref(relCell("A", 1)))) ])      
     ]);


Table addRowBeforeTable() 
  = table(header([cname("A"), cname("B")]), 
     [
      row(addBefore(rname(1)), [ symbol("foo"), symbol("bar") ])      
     ]);

Table addRowAfterTable() 
  = table(header([cname("A"), cname("B")]), 
     [
      row(addAfter(rname(1)), [ symbol("foo"), symbol("bar") ])      
     ]);

Table addColBeforeTable() 
  = table(header([addBefore(cname("A")), cname("B")]), 
     [
      row(rname(1), [ symbol("foo"), symbol("bar") ])      
     ]);

Table addColAfterTable() 
  = table(header([addAfter(cname("A")), cname("B")]), 
     [
      row(rname(1), [ symbol("foo"), symbol("bar") ])      
     ]);


Table delColTable() 
  = table(header([delete(cname("A")), cname("B")]), 
     [
      row(rname(1), [ symbol("foo"), symbol("bar") ])      
     ]);

Table delRowTable() 
  = table(header([cname("A"), cname("B")]), 
     [
      row(rname(1), [ symbol("foo"), symbol("bar") ]),      
      row(delete(rname(2)), [ symbol("foo"), symbol("bar") ])      
     ]);


Table delColAndRowTable() 
  = table(header([delete(cname("A")), cname("B")]), 
     [
      row(rname(1), [ symbol("foo"), symbol("bar") ]),      
      row(delete(rname(2)), [ symbol("foo"), symbol("bar") ])      
     ]);


test bool
  addRowBeforeTest() =
    edit(addRowBeforeTable()) ==
    table(header([cname("A"), cname("B")]), 
     [
      row(RName::empty(), [ Cell::empty(), Cell::empty() ]),      
      row(rname(1), [ symbol("foo"), symbol("bar") ])      
     ]); 
    
test bool
  addRowAfterTest() =
    edit(addRowAfterTable()) ==
    table(header([cname("A"), cname("B")]), 
     [
      row(rname(1), [ symbol("foo"), symbol("bar") ]),      
      row(RName::empty(), [ Cell::empty(), Cell::empty() ])      
     ]); 
    


