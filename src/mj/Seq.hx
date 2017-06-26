package mj;

import haxe.ds.Vector;
import interfaces.Hashable;

class Seq implements Hashable {
    public var originalSeq:String;
    public var reducedSeq:String;
    public var names:List<String>;

    public inline function new(seq:String,l:List<String>,?rseq:String=null) {
        this.originalSeq = seq;
        this.names = l;
        this.reducedSeq = rseq;
    }
    public inline function reduce(l:List<Int>):Void {
        var a:Vector<String> = new Vector<String>(l.length);
        var i:Int = 0;
        for(pos in l) {
            a[i++] = originalSeq.charAt(pos);
        }
        reducedSeq = a.join("");
    }
    public inline function hashCode():Int {
        var result:Int = 0;
        var mult:Int = 1;
        for(i in 0...this.reducedSeq.length) {
            result += this.reducedSeq.charCodeAt(i) * mult;
            mult += 2;
        }
        return result;
    }
    public inline function equals(o:Hashable):Bool {
        try {
            var o:Seq = cast(o, Seq);
            return o.reducedSeq == this.reducedSeq;
        } catch(e:Dynamic) {
            return false;
        }
    }
}
