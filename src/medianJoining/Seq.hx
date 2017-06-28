package medianJoining;

import haxe.ds.Vector;

class Seq {
    public var originalSequence:String;
    public var names:List<String>;
    public var isSample:Bool;

    public var next:Seq;
    public var prev:Seq;

    public var reducedSequence:String;

    public var deltas:List<Delta>;

    public var connectedTo:List<Seq>;

    public inline function new() {
        this.names = new List<String>();
        this.deltas = new List<Delta>();
        this.connectedTo = new List<Seq>();
    }

    public static inline function createSample(names:List<String>, seq:String):Seq {
        var result:Seq = new Seq();
        result.names = names;
        result.originalSequence = seq;
        return result;
    }
    public static inline function createMedian(seq:String):Seq {
        var result:Seq = new Seq();
        result.reducedSequence = seq;
        return result;
    }

    public inline function createReducedSequence(l:List<Int>):Void {
        var a:Vector<String> = new Vector<String>(l.length);
        var i:Int = 0;
        for(pos in l) {
            a[i++] = this.originalSequence.charAt(pos);
        }
        this.reducedSequence = a.join("");
    }
}
