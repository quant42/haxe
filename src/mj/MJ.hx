package mj;

import haxe.ds.Vector;
import util.Hashmap;
import bio.FastaReader;

class MJ {
    var sampled:Vector<Seq>;
    var medianVectors:List<Seq>;
    var weights:Vector<Float>;
    var ipos:List<Int>;

    public inline function new(samples:Hashmap<HString,List<String>>,weights:List<Float>) {
        sampled = new Vector<Seq>(samples.size);
        medianVectors = new List<Seq>();
        var i:Int = 0;
        for(kvp in samples) {
            var seq:String = kvp.first.s;
            var names:List<String> = kvp.second;
            sampled[i++] = new Seq(seq, names);
        }
        // sort by how often sequence got sampled
        sampled.sort(function(a:Seq, b:Seq): Int {
            return a.names.length - b.names.length;
        });
        // calculate reduced seq
        
    }

    public inline function step1() {
    }

    public function runMJ(epsilon:Float):Void {
        
        do {
            // first step
            // TODO
            
        } while(true);
    }

    public static function main():Void {}
}
