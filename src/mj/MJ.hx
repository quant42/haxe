package mj;

import haxe.ds.Vector;
import util.Pair;
import util.Graph;
import util.Hashmap;
import bio.FastaReader;
import interfaces.Numeric;

class FloatEdge implements Numeric {
    public var w:Float;
    public inline function new(w:Float) {
        this.w = w;
    }
    public inline function getValue():Float {
        return 0.0;
    }
}

class MJ {
    var sampled:Vector<Seq>;
    var medianVectors:List<Seq>;

    var allV:Vector<Seq>;

    var weights:Vector<Float>;
    var rweights:Vector<Float>;
    var ipos:List<Int>; // rseqL = ipos.length
    var seqL:Int;

    var deltas:Vector<Pair<Pair<Int,Int>,Float>>;
    var rdeltas:List<Pair<Float,List<Pair<Int,Int>>>>;

    var graph:Graph<Seq,FloatEdge>;

    public inline function new(samples:Hashmap<HString,List<String>>) {
        sampled = new Vector<Seq>(samples.size);
        medianVectors = new List<Seq>();
        var i:Int = 0;
        seqL = -1;
        for(kvp in samples) {
            var seq:String = kvp.first.s;
            if(seqL == -1) {
                seqL = seq.length;
            } else if (seqL != seq.length) {
                throw "Sequences differ in size!";
            }
            var names:List<String> = kvp.second;
            sampled[i++] = new Seq(seq, names);
        }
        // sort by how often sequence got sampled
        sampled.sort(function(a:Seq, b:Seq): Int {
            return b.names.length - a.names.length;
        });
        // calculate reduced seq
        ipos = new List<Int>();
        for(pos in 0...seqL) {
            for(j in 1...sampled.length) {
                if(sampled[j].originalSeq.charCodeAt(pos) != sampled[0].originalSeq.charCodeAt(pos)) {
                    ipos.add(pos);
                    break;
                }
            }
        }
        for(i in 0...sampled.length) {
            sampled[i].reduce(ipos);
        }
    }

    public inline function dist(s1:Seq,s2:Seq):Float {
        return distStr(s1.reducedSeq, s2.reducedSeq);
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

    private inline function continueMedians(l:List<Vector<String>>,c:String,pos:Int):Void {
        for(e in l) {
            e[pos] = c;
        }
    }

    public inline function constructMedians(s1:String, s2:String, s3:String):List<String> {
        // pre result calculations
        var presult:List<Vector<String>> = new List<Vector<String>>();
        presult.add(new Vector<String>(s1.length));
        for(pos in 0...s1.length) {
            // majority
            if(s1.charAt(pos) == s2.charAt(pos)) {
                continueMedians(presult, s1.charAt(pos), pos);
                continue;
            }
            if(s1.charAt(pos) == s3.charAt(pos)) {
                continueMedians(presult, s1.charAt(pos), pos);
                continue;
            }
            if(s2.charAt(pos) == s3.charAt(pos)) {
                continueMedians(presult, s2.charAt(pos), pos);
                continue;
            }
            // everything possible
            // ok, tripple the vector
            var limit:Int = presult.length;
            for(zzzzz in 0...2) {
                var i:Int = 0;
                for(ele in presult) {
                    if(i < limit) {
                        i++;
                    } else {
                        break;
                    }
                    presult.add(ele.copy());
                }
            }
            var pp:Int = 0;
            for(ele in presult) {
                var c:String = (pp < limit) ? s1.charAt(pos) : (((pp << 1) < limit) ? s2.charAt(pos) : s3.charAt(pos));
                ele[pos] = c;
                pp++;
            }
        }
        // join vectors to string
        var result:List<String> = new List<String>();
        for(s in presult) {
            result.add(s.join(""));
        }
trace(s1,s2,s3,result);
        return result;
    }

    public inline function step1():Void {
        // first step - calculate allV
        allV = new Vector<Seq>(this.sampled.length + medianVectors.length);
        var i:Int = 0;
        while(i < this.sampled.length) {
            allV[i] = this.sampled[i];
            i++;
        }
        for(e in medianVectors) {
            allV[i++] = e;
        }
        // calculate deltas on allV
        deltas = new Vector<Pair<Pair<Int,Int>,Float>>(((allV.length-1) * (allV.length)) >> 1);
        var iii:Int = 0;
        for(i in 0...allV.length) {
            for(j in (i+1)...allV.length) {
                deltas[iii++] = new Pair(new Pair(i, j), dist(allV[i], allV[j]));
            }
        }
        // calculate reduced deltas
        deltas.sort(function(a:Pair<Pair<Int,Int>,Float>, b:Pair<Pair<Int,Int>,Float>):Int {
            if (a.second == b.second) {
                return 0;
            }
            if (a.second > b.second) {
                return 1;
            }
            return -1;
        });
        rdeltas = new List<Pair<Float,List<Pair<Int,Int>>>>();
        var lastDelta:Float = 0.0;
        var c:Pair<Float,List<Pair<Int,Int>>> = null;
        for(e in deltas) {
            var pair:Pair<Int,Int> = e.first;
            if(lastDelta != e.second) {
                lastDelta = e.second;
                if(c != null) {
                    rdeltas.add(c);
                }
                c = new Pair<Float,List<Pair<Int,Int>>>(e.second, new List<Pair<Int,Int>>());
            }
            c.second.add(pair);
        }
    }

    public inline function step2(epsilon:Float):Void {
        // build up the graph
        graph = new Graph<Seq,FloatEdge>();
        // add all seqs ...
        for(s in this.allV) {
            graph.addNode(s);
        }
        // ok, now edges
        for(deltas in rdeltas) { // e is of type Pair<Float,List<Pair<Int,Int>>>
            var toAdd:List<Pair<Seq,Seq>> = new List<Pair<Seq,Seq>>();
            for(delta in deltas.second) { // delta is of type Pair<Int,Int>
                var fS:Seq = allV[delta.first];
                var sS:Seq = allV[delta.second];
                if(!graph.existPathBetween(fS, sS) || graph.getLowestEdgeInConnectedComponent(fS).w >= deltas.first - epsilon) {
                    toAdd.add(new Pair(fS, sS));
                }
            }
            var e:FloatEdge = new FloatEdge(deltas.first);
            for(p in toAdd) {
                graph.addEdge(p.first, p.second, e);
            }
        }
    }

    public inline function step3():Int {
        // remove sequences (that have not been sampled) which are connected to at most two other sequences ...
        var origLen:Int = medianVectors.length;
        medianVectors = medianVectors.filter(function(v) {
            return graph.degreeOf(v) > 2;
        });
        return origLen - medianVectors.length;
    }

    public inline function step4(epsilon:Float):Int {
        var added:Hashmap<Seq,Float> = new Hashmap<Seq,Float>();
        var minCosts:Float = Math.POSITIVE_INFINITY;
        for(kvp1 in graph.nodes) {
            for(kvp2 in graph.edges.get(kvp1.first)) { // kvp2 is pair of Node=Seq Edge=FloatEdge
                var kvp2Id:Int = graph.nodes.get(kvp2.first);
                if(kvp1.second > kvp2Id) {
                    var s1:String = kvp1.first.reducedSeq;
                    var s2:String = kvp2.first.reducedSeq;
                    for(s in allV) {
                        var s3Id:Int = graph.nodes.get(s);
                        if(s3Id != kvp1.second && s3Id != kvp2Id &&
                                (graph.areNeighbours(s, kvp1.first) || graph.areNeighbours(s, kvp2.first))) { // TODO there's a speedup for this ...
                            var s3:String = s.reducedSeq;
                            var l:List<String> = constructMedians(s1, s2, s3);
                            var lambdaEps:Float = distStr(s1, s2) + Math.min(distStr(s1, s3), distStr(s2, s3));
trace(s1, s2, s3, lambdaEps);
                            for(stre in l) {
                                // is present in list?
                                var nS:Seq = new Seq(null, new List<String>(), stre);
                                if(added.contains(nS) || graph.nodes.contains(nS)) {
                                    continue;
                                }
                                var costs:Float = distStr(s1, stre) + distStr(s2, stre) + distStr(s3, stre);
                                added.put(nS, costs);
                                minCosts = Math.min(costs, minCosts);
                            }
                        }
                    }
                }
            }
        }
        var addedMedians:Int = 0;
        for(kvp in added) {
            if(kvp.second <= minCosts + epsilon) {
                addedMedians++;
                medianVectors.add(kvp.first);
            }
        }
        return addedMedians;
    }

    public inline function step5() {
        while(true) {
            step1();
            step2(0);
            if(step3() == 0) {
                break;
            }
        }
    }

    public function runMJ(weights:Vector<Float>,epsilon:Float):Void {
        // initialize weights
        if(seqL != weights.length) {
            throw "Weights length and sequence length differ!";
        }
        this.weights = weights;
        this.rweights = new Vector(ipos.length);
        var iii:Int = 0;
        for(e in ipos) {
            this.rweights[iii++] = weights[e];
        }
        // perform algo
        var i:Int = 0;
        do {
            step1();
            step2(epsilon);
            i = step3();
trace("3 " + i);
            if(i != 0) {
                continue;
            }
            i = step4(epsilon);
trace("4 " + i);
            if(i != 0) {
                continue;
            } else {
                break;
            }
        } while(true);
trace("5 s");
        step5();
trace("5 e");
//TODO add "originalSeq" to median vectors for output
    }

    public static function main():Void {
/*
*/
        var fr:FastaReader = new FastaReader(">A\n00000\n>B\n11000\n>C\n10110\n>D\n01101");
        var mj:MJ = new MJ(fr.getReduce());
        var v:Vector<Float> = new Vector<Float>(5);
        v[0] = 1.0;
        v[1] = 3.0;
        v[2] = 2.0;
        v[3] = 1.0;
        v[4] = 2.0;
        mj.runMJ(v, 2.0);
        for(e in mj.graph.nodes) {
            trace(e.first.names + " " + e.first.originalSeq + " " + e.first.reducedSeq);
        }
    }
}
