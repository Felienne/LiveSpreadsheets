module Plugin

import XanaSyntax;
import Pretty;
import util::IDE;
import ParseTree;
import IO;
import Transform;


void main() {
   registerLanguage("XanaSheet", "xs", Tree(str src, loc l) {
     pt = parse(#start[Sheet], src, l);
     return pt;
   });
   
   registerContributions("XanaSheet", {
      liveUpdater(str (Tree t) {
            if (XanaSyntax::Sheet sh := t.top) {
              return unparse(t[top=transform(sh)]);
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

