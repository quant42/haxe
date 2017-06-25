package mj;

import interfaces.Hashable;

class Seq implements Hashable {
    public var originalSeq:String;
    public var reducedSeq:String;
    public var names:List<String>;
    public function new(seq:String,l:List<String>) {
        this.originalSeq = seq;
        this.names = l;
    }
    public function hashCode():Int {
        var result:Int = 0;
        var mult:Int = 1;
        for(i in 0...this.reducedSeq.length) {
            result += this.reducedSeq.charCodeAt(i) * mult;
            mult += 2;
        }
        return result;
    }
    public function equals(o:Hashable):Bool {
        try {
            var o:Seq = cast(o, Seq);
            return o.reducedSeq == this.reducedSeq;
        } catch(e:Dynamic) {
            return false;
        }
    }
}
