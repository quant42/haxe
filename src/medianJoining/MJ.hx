package medianJoining;

import bio.FastaReader;
import util.Hashmap;
import util.Pair;
import haxe.ds.Vector;

class MJ {
    public static function main():Void {
        var s:Seqs = new Seqs();
        // TODO: options
        var myArgs:Array<String> = Sys.args();
        var fr:FastaReader = new FastaReader(sys.io.File.getContent(myArgs[0]).toUpperCase());
        var data:Hashmap<HString,List<String>> = fr.getReduce();
        // TODO: sort
        for(kvp in data) {
            s.addSample(kvp.second, kvp.first.s);
        }
        // end
        if(myArgs[1] != "-") {
        var r:Array<String> = myArgs[1].split(";");
        var v:Vector<Float> = new Vector<Float>(r.length);
        for(i in 0...r.length) {
            v[i] = Std.parseFloat(r[i]);
        }
        s.weights = v;}
        s.runMJ(Std.parseFloat(myArgs[2]));
        var p:StdOutPrinter = new StdOutPrinter();
        s.printTxt(p);
    }
}
