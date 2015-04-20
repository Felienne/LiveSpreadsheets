module Plugin

import XanaSyntax;
import Pretty;
import util::IDE;
import ParseTree;
import AST;
import IO;


void main() {
   registerLanguage("XanaSheet", "xs", Tree(str src, loc l) {
     pt = parse(#start[Sheet], src, l);
     visit (pt) {
       case XanaSyntax::Table t: iprintln(implode(#AST::Table, t));
     } 
     return pt;
   });
   
   registerContributions("XanaSheet", {
      liveUpdater(str (Tree t) {
            if (XanaSyntax::Sheet sh := t.top) {
              return unparse(t[top=ppSheet(sh)]);
            }
            return unparse(t);
         }
      ),
      popup(menu("&XanaSheet", [
         edit("&Align", str (Tree t, loc l) {
            if (XanaSyntax::Sheet sh := t.top) {
              return unparse(t[top=ppSheet(sh)]);
            }
            return unparse(t);
         })
      ]))
   });
}

