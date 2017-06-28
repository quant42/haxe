package medianJoining;

import haxe.ds.Vector;
import util.Pair;

class Seq {
    public var originalSequence:String;
    public var names:List<String>;
    public var isSample:Bool;

    public var reducedSequence:String;

    public var next:Seq;
    public var prev:Seq;

    public var connectedTo:List<Pair<Seq,Float>>;

    public var visitedId:Int;

    public var id:Int;

    public var links:List<Pair<Seq,Int>>;
    public var speciesId:Int;

    public inline function new() {
        this.names = new List<String>();
        this.connectedTo = new List<Pair<Seq,Float>>();
        this.links = new List<Pair<Seq,Int>>();
        this.speciesId = 0; // 0 means not assigned
        this.visitedId = 0; // 0 means not visited
    }

    public static inline function createSample(id:Int,names:List<String>, seq:String):Seq {
        var result:Seq = new Seq();
        result.id = id;
        result.names = names;
        result.originalSequence = seq;
        result.isSample = true;
        return result;
    }
    public static inline function createMedian(id:Int,seq:String):Seq {
        var result:Seq = new Seq();
        result.id = id;
        result.reducedSequence = seq;
        result.isSample = false;
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

    public inline function removeConnections():Void {
        connectedTo.clear();
    }

    public inline function constructSeq(s:Vector<String>,ipos:List<Int>):Void {
        var i:Int = 0;
        for(pos in ipos) {
            s[pos] = this.reducedSequence.charAt(i++);
        }
        this.originalSequence = s.join("");
    }
    public inline function getMuts(c:Seq):List<Int> {
        return new List<Int>(); // TODO
    }
}
