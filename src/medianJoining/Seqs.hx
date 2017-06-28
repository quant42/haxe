package medianJoining;

import util.Pair;
import haxe.ds.Vector;
import haxe.ds.HashMap;
import haxe.ds.ListSort;
import interfaces.Printer;

class Seqs {
    public var version:String = "1.0.1";

    public var first:Seq; // "setting"
    public var firstMed:Seq;
    public var end:Seq;
    public var length:Int;

    public var weights:Vector<Float>; // setting
    public var rweights:Vector<Float>;

    public var ipos:List<Int>;

    public var deltas:List<Delta>;
    public var rdeltas:List<List<Delta>>;

    public var nextSeqId:Int;

    public var newLine:String = "\n"; // setting
    public var indent:String = "  "; // setting
    public var countingOffset:Int = 1;  // setting

    public var distIUPACCode:Bool = false; // setting
    public var lowerUpperCaseDoNotDiffer:Bool = false; // TODO setting

    public inline function new() {
        #if (debug || debugMJ || debugMJConstructor)
        trace("{MJ}.new()");
        #end
        ipos = new List<Int>();
        deltas = new List<Delta>();
        rdeltas = new List<List<Delta>>();
        nextSeqId = 1;
        length = 0;
    }

    public inline function addSample(names:List<String>,seq:String):Void {
        #if (debug || debugMJ || debugMJAddSample)
        trace("{MJ}.addSample(" + ((names == null) ? "null" : names.toString()) + "," + seq + ")");
        #end
        var s:Seq = Seq.createSample(nextSeqId++, names, seq);
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
        #if (debug || debugMJ || debugMJAddMedian)
        trace("{MJ}.addMedian(" + seq + ")");
        #end
        var s:Seq = Seq.createMedian(nextSeqId++, seq);
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

    public inline function chrToInt(s:String):Int {
        var result:Int = 0;
        if(s == "A") {        // ---A
            result = 1;
        } else if(s == "C") { // --C-
            result = 2;
        } else if(s == "M") { // --CA
            result = 3;
        } else if(s == "G") { // -G--
            result = 4;
        } else if(s == "R") { // -G-A
            result = 5;
        } else if(s == "S") { // -GC-
            result = 6;
        } else if(s == "V") { // -GCA
            result = 7;
        } else if(s == "T" || s == "U") { // T---
            result = 8;
        } else if(s == "W") { // T--A
            result = 9;
        } else if(s == "Y") { // T-C-
            result = 10;
        } else if(s == "H") { // T-CA
            result = 11;
        } else if(s == "K") { // TG--
            result = 12;
        } else if(s == "D") { // TG-A
            result = 13;
        } else if(s == "B") { // TGC-
            result = 14;
        } else if(s == "N") { // TGCA
            result = 15;
        }else {
            throw "Unexpected character \'" + s + "\'!";
        }
        return result;
    }
    public inline function diffChr(s1:String,s2:String):Bool {
        return (distIUPACCode) ? (((chrToInt(s1) & chrToInt(s2))) == 0): s1 != s2;
    }
    public inline function distStr(s1:String,s2:String):Float {
        var result:Float = 0.0;
        for(pos in 0...s1.length) {
            if(diffChr(s1.charAt(pos), s2.charAt(pos))) {
                result += rweights[pos];
            }
        }
        return result;
    }

    public inline function step1():Void {
        #if (debug || debugMJ || debugMJStep1)
        trace("{MJ}.step1()");
        #end
        deltas.clear();
        var s1:Seq = first;
        while(s1 != null) {
            var s2:Seq = s1.next;
            while(s2 != null) {
                var d:Delta = new Delta(s1, s2, distStr(s1.reducedSequence, s2.reducedSequence));
                deltas.add(d);
                //s1.deltas.add(d);
                //s2.deltas.add(d);
                s2 = s2.next;
            }
            s1 = s1.next;
        }
        #if (debug || debugMJ || debugMJStep1)
        trace("{MJ}.step1()->matrix:");
        for(d in deltas) {
            trace(d.s1.reducedSequence,d.s2.reducedSequence,d.dist);
        }
        #end
        // sort the delta list (this is in principal the idea of merge sort ... iteratively implemented)
        var sortedLists:List<List<Delta>> = new List<List<Delta>>();
        for(delta in deltas) {
            // if last element in last list is lower or equal -> add to this list
            if(sortedLists.last() != null && sortedLists.last().last() != null && sortedLists.last().last().dist <= delta.dist) {
                sortedLists.last().add(delta);
            }
            // else create new list and add element
            else {
                var newL:List<Delta> = new List<Delta>();
                newL.add(delta);
                sortedLists.add(newL);
            }
        }
        #if (debug || debugMJ || debugMJStep1)
        trace("{MJ}.step1()->sortedLists:");
        for(l in sortedLists) {
            if(l == null) {
                trace("NULL!!!");
            } else {
                for(e in l) {
                    trace(e.s1.reducedSequence,e.s2.reducedSequence,e.dist);
                }
            }
            trace("+++");
        }
        #end
        while(sortedLists.length > 1) {
            var l1:List<Delta> = sortedLists.pop();
            var l2:List<Delta> = sortedLists.pop();
            var nL:List<Delta> = new List<Delta>();
            while(!l1.isEmpty() && !l2.isEmpty()) {
                if(l1.first().dist <= l2.first().dist) {
                    nL.add(l1.pop());
                } else {
                    nL.add(l2.pop());
                }
            }
            while(!l1.isEmpty()) {
                nL.add(l1.pop());
            }
            while(!l2.isEmpty()) {
                 nL.add(l2.pop());
            }
            sortedLists.add(nL);
        }
        deltas = sortedLists.first();
        #if (debug || debugMJ || debugMJStep1)
        trace("{MJ}.step1()->pre sorted deltas:");
        for(d in deltas) {
            trace(d.s1.reducedSequence,d.s2.reducedSequence,d.dist);
        }
        #end
        // create delta list
        rdeltas.clear();
        var lastDeltaValue:Float = 0.0;
        var c:List<Delta> = null;
        for(delta in deltas) {
            if(lastDeltaValue != delta.dist) {
                lastDeltaValue = delta.dist;
                if(c != null) {
                    rdeltas.add(c);
                }
                c = new List<Delta>();
            }
            c.add(delta);
        }
        if(c != null) {
            rdeltas.add(c);
        }
        #if (debug || debugMJ || debugMJStep1)
        trace("{MJ}.step1()->result:");
        for(deltas in rdeltas) {
            if(deltas == null) {
                trace("NULL!!!");
            } else if(deltas.isEmpty()) {
                trace("EMPTY!!!");
            } else {
                for(delta in deltas) {
                    trace(delta.s1.reducedSequence,delta.s1.id,delta.s2.reducedSequence,delta.s2.id,delta.dist);
                }
            }
            trace("---");
        }
        #end
    }

    public inline function step2(epsilon:Float):Void {
        #if (debug || debugMJ || debugMJStep2)
        trace("{MJ}.step2(" + epsilon + ")");
        #end
        // remove maybe previous existing connections
        var current:Seq = first;
        while(current != null) {
            current.removeConnections();
            current.visitedId = 0; // for next part of the step - set not visited
            current = current.next;
        }
        // add new
        var nextVisitedId:Int = 1;
        var toAdd:List<Delta> = new List<Delta>();
        for(deltas in rdeltas) {
            #if (debug || debugMJ || debugMJStep2)
            trace("Processing dists for delta: " + deltas.first().dist);
            #end
            toAdd.clear();
            // check which ones to add
            for(delta in deltas) {
                var isConnected:Bool = false;
                var minL:Float = Math.POSITIVE_INFINITY;
                // check if s1 and s2 are connected
                var l:List<Seq> = new List<Seq>();
                l.add(delta.s1);
                delta.s1.visitedId = nextVisitedId;
                while(!l.isEmpty()) {
                    var c:Seq = l.pop();
                    if(c == delta.s2) {
                        isConnected = true;
                    }
                    for(p in c.connectedTo) {
                        minL = Math.min(minL, p.second);
                        if(p.first.visitedId != nextVisitedId) {
                            l.add(p.first);
                            p.first.visitedId = nextVisitedId;
                        }
                    }
                }
                nextVisitedId++;
                #if (debug || debugMJ || debugMJStep2)
                trace(delta.s1.reducedSequence,delta.s2.reducedSequence,isConnected,minL);
                #end
                // if yes, get the lowest edge in the graph
                if(!isConnected || minL >= delta.dist - epsilon) {
                    toAdd.add(delta);
                }
            }
            // add the feasable links
            for(delta in toAdd) {
                delta.s1.connectedTo.add(new Pair(delta.s2, delta.dist));
                delta.s2.connectedTo.add(new Pair(delta.s1, delta.dist));
                #if (debug || debugMJ || debugMJStep2)
                trace("Added con:",delta.s1.reducedSequence,delta.s2.reducedSequence,delta.dist);
                #end
            }
        }
    }

    public inline function step3():Int {
        #if (debug || debugMJ || debugMJStep3)
        trace("{MJ}.step3()");
        #end
        var nrRem:Int = 0;
        var current:Seq = this.firstMed;
        var markDel:List<Seq> = new List<Seq>();
        while(current != null) {
            if(current.connectedTo.length <= 2) {
                #if (debug || debugMJ || debugMJStep3)
                trace("{MJ}.step3()->marked for deletion:");
                trace(current.reducedSequence);
                #end
                markDel.add(current);
                nrRem++;
            }
            current = current.next;
        }
        for(current in markDel) {
            // need to remove this
            if(current.prev != null) {
                current.prev.next = current.next;
            }
            if(current.next != null) {
                current.next.prev = current.prev;
            }
            if(current == firstMed) {
                firstMed = current.next;
            }
            if(current == end) {
                end = current.prev;
            }
            current.prev = null;
            current.next = null;
            length--;
/* not needed - will be do by clear in step2 executed afterwards
            for(oSeq in current.connectedTo) {
                oSeq.connectedTo.remove(current);
            }
*/
            current.connectedTo.clear();
        }
        #if (debug || debugMJ || debugMJStep3)
        trace("SEQS:");
        var current:Seq = first;
        var iiiii:Int = 0;
        while(current != null) {
            trace(iiiii++,current.id,current.reducedSequence);
            current = current.next;
        }
        trace("LENGHT:", length);
        trace("RESULT:", nrRem);
        #end
        return nrRem;
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
                var c:String = (pp < limit) ? s1.charAt(pos) :
                    ((pp < (limit << 1)) ? s2.charAt(pos) : s3.charAt(pos));
                ele[pos] = c;
                pp++;
            }
        }
        // join vectors to string
        var result:List<String> = new List<String>();
        for(s in presult) {
            result.add(s.join(""));
        }
        #if (debug || debugMJ || debugMJConstructMedians)
        trace("Constructed Medians for ",s1,s2,s3);
        for(r in result) {
            trace(r);
        }
        #end
        return result;
    }

    public inline function step4(epsilon:Float):Int {
        #if (debug || debugMJ || debugMJStep4)
        trace("{MJ}.step4(" + epsilon + ")");
        #end
        var seqToAdd:List<Pair<String, Float>> = new List<Pair<String, Float>>();
        var s1:Seq = first;
        var lambda:Float = Math.POSITIVE_INFINITY;
        while(s1 != null) { // s1 is in the middle
            for(s2p in s1.connectedTo) {
                var s2:Seq = s2p.first;
//                if(s1 == s2) { continue; } // not possible
                for(s3p in s1.connectedTo) {
//                    if(s2 == s3) { continue; } // not possible
                    var s3:Seq = s3p.first;
                    if(s2 == s3) {
                        continue;
                    }
                    #if (debug || debugMJ || debugMJStep4)
                    trace("Processing tripplet:",s1.reducedSequence, s2.reducedSequence,s3.reducedSequence);
                    #end
                    var mu:List<String> = constructMedians(s1.reducedSequence, s2.reducedSequence, s3.reducedSequence);
                    for(f in mu) {
                        // check if f is in the set of sequences
                        var isInSeqs:Bool = false;  // TODO: this can be done faster
                        var current:Seq = first;
                        while(current != null) {
                            if(current.reducedSequence == f) {
                                isInSeqs = true;
                                break;
                            }
                            current = current.next;
                        }
                        #if (debug || debugMJ || debugMJStep4)
                        trace("Seq:",f,isInSeqs);
                        #end
                        if(isInSeqs) {
                            continue;
                        }
                        // compute connection costs
                        var cost:Float = distStr(f, s1.reducedSequence) + distStr(f, s2.reducedSequence) + distStr(f, s3.reducedSequence);
                        lambda = Math.min(lambda, cost);
                        seqToAdd.add(new Pair(f, cost));
                        #if (debug || debugMJ || debugMJStep4)
                        trace("Seq:",f,cost,lambda);
                        #end
                    }
                }
            }
            s1 = s1.next;
        }
        // add sequences
        #if (debug || debugMJ || debugMJStep4)
        trace("{MJ}.step4(...)->adding:");
        #end
        var nrSeqsAdded:Int = 0;
        for(seq in seqToAdd) {
            if(seq.second <= lambda + epsilon) { // connection costs do not exceed lambda + epsilon
                // not already added (before)
                var isInSeqs:Bool = false;  // TODO: this can be done faster
                var current:Seq = firstMed;
                while(current != null) {
                    if(current.reducedSequence == seq.first) {
                        isInSeqs = true;
                        break;
                    }
                    current = current.next;
                }
                if(isInSeqs) {
                    continue;
                }
                // add
                #if (debug || debugMJ || debugMJStep4)
                trace("Adding:",seq.first);
                #end
                this.addMedian(seq.first);
                nrSeqsAdded++;
            }
        }
        // return number of sequences added
        #if (debug || debugMJ || debugMJStep4)
        trace("SEQS:");
        var current:Seq = first;
        var iiiii:Int = 0;
        while(current != null) {
            trace(iiiii++,current.id,current.reducedSequence);
            current = current.next;
        }
        trace("LENGHT:", length);
        #end
        return nrSeqsAdded;
    }

    public inline function step5():Void {
        #if (debug || debugMJ || debugMJStep5)
        trace("{MJ}.step5()");
        #end
        var iii:Int = 0;
        do {
            step1();
            step2(0.0);
            iii = step3();
        } while(iii != 0);
    }

    public inline function runMJ(epsilon:Float):Void {
        #if (debug || debugMJ || debugMJfinishedAddingSamples)
        trace("{MJ}.finishedAddingSamples()");
        #end
        // calculate ipos
        ipos.clear();
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
        #if (debug || debugMJ || debugMJfinishedAddingSamples)
        trace("{MJ}.finishedAddingSamples()->ipos:");
        trace(((ipos == null) ? "null" : ipos.toString()));
        #end
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
            if(this.weights.length != first.originalSequence.length) {
                throw "Expected " + first.originalSequence.length + " weights but got " + this.weights.length + " weights!";
            }
            this.rweights = new Vector(ipos.length);
            var iii:Int = 0;
            for(e in ipos) {
                this.rweights[iii++] = weights[e];
            }
        }
        #if (debug || debugMJ || debugMJfinishedAddingSamples)
        trace("{MJ}.finishedAddingSamples()->rweights:");
        if(rweights == null) {
            trace("null");
        } else {
            for(e in rweights) {
                trace(e);
            }
        }
        #end
        #if (debug || debugMJ)
        trace("{MJ}.runMJ(" + epsilon + ")");
        var round:Int = 0;
        #end
        var iii:Int = 0;
        do {
            #if (debug || debugMJ)
            trace("{MJ}.runMJ(...)->round:" + (round++));
            #end
            step1();
            step2(epsilon);
            iii = step3();
            if(iii != 0) {
                continue;
            }
            iii = step4(epsilon);
        } while(iii != 0);
        step5();
        // finalize the whole thing
        #if (debug || debugMJ || debugMJfinalize)
        trace("{MJ}.finalize()");
        #end
        var id:Int = 1;
        var current:Seq = first;
        var v:Vector<String> = new Vector<String>(first.originalSequence.length);
        for(i in 0...first.originalSequence.length) {
            v[i] = first.originalSequence.charAt(i);
        }
        while(current != null) {
            // overwrite id
            current.id = (id++);
            // create links
            if(current.isSample) {
                var current2:Seq = current.next;
                while(current2 != null && current2.isSample) {
                    var c:Int = countConnections(current, current2);
                    if (c > 0) {
                        current.links.add(new Pair(current2,c));
                        current2.links.add(new Pair(current,c));
                    }
                    current2 = current2.next;
                }
            }
            // construct fully sequence
            else {
                current.constructSeq(v,ipos);
            }
            // process next
            current = current.next;
        }
        // assign species ids
        var nextSpId:Int = 1;
        var l:List<Seq> = new List<Seq>();
        current = first;
        while(current != null && current.isSample) {
            if(current.speciesId == 0) {
                current.speciesId = nextSpId;
                // set all species connected by link the species id.
                l.clear();
                l.add(current);
                while(!l.isEmpty()) {
                    var c:Seq = l.pop();
                    for(n in c.links) {
                        var n:Seq = n.first;
                        if(n.speciesId == 0) {
                            n.speciesId = nextSpId;
                            l.add(n);
                        } else if(n.speciesId != nextSpId) {
                            throw "Something somewhere went terribly wrong (#1)!";
                        }
                    }
                }
                // set next sp. id.
                nextSpId++;
            }
            current = current.next;
        }
    }
    public inline function getSeqIdentifier(s:String):String {
        if(s == null) {
            return null;
        }
        var pos:Int = s.lastIndexOf("_");
        if(pos == -1) {
            return s;
        }
        return s.substr(0, pos+1);
    }
    private inline function countConnections(c1:Seq,c2:Seq):Int {
        var result:Int = 0;
        if(c1.names == null || c2.names == null || c1.names.isEmpty() || c2.names.isEmpty()) {
            result = 0;
        } else {
            for(s1 in c1.names) {
                var seqId1:String = getSeqIdentifier(s1);
                for(s2 in c2.names) {
                    var seqId2:String = getSeqIdentifier(s2);
                    if(seqId1 == seqId2) {
                        result++;
                        break; // next name
                    }
                }
            }
        }
        return result;
    }

    public inline function debug():Void {
        trace("=== DEBUG ===");
        var c:Seq = first;
        while(c != null) {
            trace("Node",c.id,c.reducedSequence,c.originalSequence,c.names,c.speciesId);
            for(np in c.connectedTo) {
                trace(" CON",np.first.id,np.second);
            }
            c = c.next;
        }
    }

    public inline function printTxt(printer:Printer):Void {
        // print out all nodes
        printer.printString("#Calculated via HaplowebMaker version ");
        printer.printString(version);
        printer.printString(newLine);
        var c:Seq = first;
        while(c != null) {
            // output what this is
            printer.printString(((c.isSample) ? "SAMPLED_SEQUENCE" : "MEDIAN_VECTOR"));
            printer.printString(newLine);
            // node id
            printer.printString(indent);
            printer.printString("ID ");
            printer.printString("" + c.id);
            printer.printString(newLine);
            // species id
            printer.printString(indent);
            printer.printString("SPECIES_ID ");
            printer.printString("" + c.speciesId);
            printer.printString(newLine);
            // seq
            printer.printString(indent);
            printer.printString("SEQUENCE ");
            printer.printString("" + c.originalSequence);
            printer.printString(newLine);
            if(c.names != null && c.names.length > 0) {
                // length of names
                printer.printString(indent);
                printer.printString("No_NAMES ");
                printer.printString("" + c.names.length);
                printer.printString(newLine);
                // names
                printer.printString(indent);
                printer.printString("NAMES");
                printer.printString(newLine);
                for(name in c.names) {
                    printer.printString(indent);
                    printer.printString(indent);
                    printer.printString(name);
                    printer.printString(newLine);
                }
            }
            // connections
            if(c.connectedTo != null && c.connectedTo.length > 0) {
                printer.printString(indent);
                printer.printString("CONNECTED_TO ");
                printer.printString(newLine);
                for(con in c.connectedTo) {
                    printer.printString(indent);
                    printer.printString(indent);
                    printer.printString("ID " + con.first.id);
                    printer.printString(" COSTS " + con.second + " @");
                    for(pos in 0...c.originalSequence.length) {
                        if(diffChr(c.originalSequence.charAt(pos), con.first.originalSequence.charAt(pos))) {
                            printer.printString(" " + (pos + countingOffset));
                        }
                    }
                    printer.printString(newLine); 
                }
            }
            // links
            if(c.links != null && c.links.length > 0) {
                printer.printString(indent);
                printer.printString("LINKED_TO ");
                printer.printString(newLine);
                for(link in c.links) {
                    printer.printString(indent);
                    printer.printString(indent);
                    printer.printString("ID " + link.first.id + " COUNT " + link.second);
                    printer.printString(newLine);
                }
            }
            // next c
            c = c.next;
        }
        printer.close();
    }

    public static inline function main():Void {
/*
        var s:Seqs = new Seqs();
        s.weights = new Vector<Float>(5);
        s.weights[0] = 1;
        s.weights[1] = 3;
        s.weights[2] = 2;
        s.weights[3] = 1;
        s.weights[4] = 2;
//        s.distIUPACCode = true;
var namesList1:List<String> = new List<String>();
namesList1.add("foo_A");
namesList1.add("bar");
var namesList2:List<String> = new List<String>();
namesList2.add("foo_B");
// add Sample should be called in range of size
        s.addSample(null,       "00000");
        s.addSample(namesList1, "11000");
        s.addSample(null,       "10110");
        s.addSample(namesList2, "01101");
        s.runMJ(0);
        var p:StdOutPrinter = new StdOutPrinter();
        s.printTxt(p);
//        s.debug();
*/
    }
}
