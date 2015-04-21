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

list[Cell] adjustRefs(list[Cell] cells, int rowOffset, int colOffset) {
   return cells;
   Cell adjust(Cell c, int colIdx) {
     return visit (c) {
       case relCell(str col, int row) => relCell(colName(colIdx + colOffset), row + rowOffset)
       case absRow(str col, int row) => absRow(colName(colIdx + colOffset), row)
       case absCol(str col, int row) => absCol(col, row + rowOffset)
     }
  }
  
  i = 0;
  cells = for (c <- cells) {
     append adjust(c, i);
     i += 1;
  }
  return cells; 
} 

// assumes aligned
// align basically fills adds columns to the right to match the longest row
Table edit(Table tbl) {
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
    


