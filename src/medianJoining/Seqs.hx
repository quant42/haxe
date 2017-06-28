package medianJoining;

import haxe.ds.Vector;

class Seqs {
    public var first:Seq;
    public var firstMed:Seq;
    public var end:Seq;
    public var length:Int;

    var weights:Vector<Float>;
    var rweights:Vector<Float>;

    public var ipos:List<Int>;

    public var nextIndex:Int;

    public inline function new() {
        ipos = new List<Int>();
    }

    public inline function addSample(names:List<String>,seq:String):Void {
        var s:Seq = Seq.createSample(names, seq);
        if(first == null) {
            first = s;
        } else {
            if(first.originalSequence.length != seq.length) {
                throw "Expected sequence of length " + first.originalSequence.length + " but got sequence of length " + seq.length + "!";
            }
            s.prev = end;
            end.next = s;
        }
        end = s;
        length++;
    }
    public inline function addMedian(seq:String):Void {
        var s:Seq = Seq.createMedian(seq);
        if(firstMed == null) {
            firstMed = s;
        }
        if(end != null) {
            s.prev = end;
            end.next = s;
        }
        end = s;
        length++;
    }
    public inline function finishedAddingSamples():Void {
        // calculate ipos
        ipos = new List<Int>();
        for(pos in 0...first.originalSequence.length) {
            var current:Seq = first;
            while(current != null) {
                if(first.originalSequence.charCodeAt(pos) != current.originalSequence.charCodeAt(pos)) {
                    ipos.add(pos);
                    break;
                }
                current = current.next;
            }
        }
        // call the reduced string calculation for each ipos
        var current:Seq = first;
        while(current != null) {
            current.createReducedSequence(ipos);
            current = current.next;
        }
        // calc rweights
        if(weights == null) {
            rweights = new Vector<Float>(ipos.length);
            for(i in 0...ipos.length) {
                rweights[i] = 1;
            }
        } else {
            this.rweights = new Vector(ipos.length);
            var iii:Int = 0;
            for(e in ipos) {
                this.rweights[iii++] = weights[e];
            }
        }
    }

    public inline function distStr(s1:String,s2:String):Float {
        var result:Float = 0.0;
        for(pos in 0...s1.length) {
            if(s1.charAt(pos) != s2.charAt(pos)){
                result += rweights[pos];
            }
        }
        return result;
    }

    public inline function step1():Void {
        var deltas:List<Delta> = new List<Delta>();
        var s1:Seq = first;
        while(s1 != null) {
            var s2:Seq = s1.next;
            while(s2 != null) {
                var d:Delta = new Delta(s1, s2, distStr(s1.reducedSequence, s2.reducedSequence));
                deltas.add(d);
                s1.deltas.add(d);
                s2.deltas.add(d);
                s2 = s2.next;
            }
            s1 = s1.next;
        }
    }

    public static function main():Void {
        
    }
}
