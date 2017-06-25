package bio;

import util.Pair;
import util.Hashmap;
import interfaces.Hashable;

class HString implements Hashable {
    public var s:String;
    public inline function new(s:String) {
        this.s = s;
    }
    public inline function hashCode():Int {
        var result:Int = 0;
        var mult:Int = 1;
        for(i in 0...this.s.length) {
            result += mult * this.s.charCodeAt(i);
            mult += 2;
        }
        return result;
    }
    public inline function equals(o:Hashable) {
        try {
            var o:HString = cast(o, HString);
            return this.s == o.s;
        } catch(e:Dynamic) {
            return false;
        }
    }
}

class FastaReader {
     // the read fasta sequences
     public var faSeqs:List<Pair<String,String>> = new List<Pair<String,String>>();

     // some helper functions
     private static inline function isWhitespace(s:String, pos:Int):Bool {
         var cCode:Int = s.charCodeAt(pos);
         var result:Bool = false;
         for(ele in [9,10,11,12,13,32,133,160,5760,8192,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288,6158,8203,8204,8205,8288,65279]) {
             if(ele == cCode) {
                 result = true;
                 break;
             }
         }
         return result;
     }

     private static inline function stripStringBegin(s:String):String {
         var begin:Int = 0;
         var sLen:Int = s.length;
         while(begin < sLen && isWhitespace(s, begin)) {
             begin++;
         }
         return s.substr(begin);
     }

     private static inline function stripStringEnd(s:String):String {
         var end:Int = s.length;
         while(end > 0 && isWhitespace(s, end-1)) {
             end--;
         }
         return s.substring(0, end);
     }

     private static inline function stripString(s:String):String {
         return stripStringBegin(stripStringEnd(s));
     }

     // allow the creating of such an object
     public function new(fileContent:String) {
         var lines:Array<String> = fileContent.split("\n");
         var header:String = null;
         var content:String = null;
         var lineNo:Int = 0;
         for(line in lines) {
             lineNo++;
             line = stripString(line);
             if(line == null || line == "" || line.charAt(0) == ";" || line.charAt(0) == "#") {
                 continue;
             }
             if(line.charAt(0) == ">") {
                 if(header != null) {
                     if(content == null) {
                         throw "Missing content for sequence \"" + header + "\" in line " + lineNo;
                     }
                     faSeqs.add(new Pair(header, content));
                 } else {
                     if(content != null) {
                         throw "Missing header for content previous to line " + lineNo;
                     }
                 }
                 header = stripStringBegin(line.substr(1));
                 content = null;
             } else {
                 if(content == null) {
                     content = line;
                 } else {
                     content = content + line;
                 }
             }
         }
         if(header != null) {
             if(content == null) {
                 throw "Missing content for sequence \"" + header + "\" in line " + lineNo;
             }
             faSeqs.add(new Pair(header, content));
         }
     }

     public function getReduce():Hashmap<HString,List<String>> {
         var result = new Hashmap<HString,List<String>>();
         for(seq in faSeqs) {
             var header:String = seq.first;
             var seq:HString = new HString(seq.second);
             if(result.contains(seq)) {
                 var l:List<String> = result.get(seq);
                 l.add(header);
             } else {
                 var l:List<String> = new List<String>();
                 l.add(header);
                 result.put(seq, l);
             }
         }
         return result;
     }

     public static function main():Void {}
}
