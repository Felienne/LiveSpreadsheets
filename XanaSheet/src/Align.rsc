module Align

import AST;
import List;
import util::Math;
import IO;

@doc{Makes sure all rows and header are of equal length}
Table align(Table t) {
  len = longestRowSize(t);
  hlen = size(t.header.names);
  t.header.names += [ cname(colName(i)) | i <- [hlen..hlen + (hlen - len)] ];
  
  i = 0;
  t.rows = for (r <- t.rows) {
    r.name = rname(i);
    r.cells += [ Cell::empty() | _ <- [0..size(r.cells) - len] ];
    i += 1;
    append r;
  }
  
  return t;
}

int longestRowSize(Table t)
  = ( size(t.header.names) | max(it, size(r.cells)) | r <- t.rows );


