package medianJoining;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import haxe.ds.Vector;

class SeqsTests extends TestCase {

    public function testBasic() {
        var s:Seqs = new Seqs();
        // test chrToInt
        assertEquals(s.chrToInt("A"), 1);
        assertEquals(s.chrToInt("R"), 5);
        try {
            s.chrToInt("Z");
            assertEquals(false,true);
        } catch(e:Dynamic) {}
        // test diffChr
        s.distIUPACCode = false;
        assertTrue(s.diffChr("A", "C"));
        assertFalse(s.diffChr("A", "A"));
        s.distIUPACCode = true;
        assertFalse(s.diffChr("A", "R"));
        assertFalse(s.diffChr("N", "R"));
        assertTrue(s.diffChr("A", "T"));
        assertTrue(s.diffChr("C", "T"));
        assertTrue(s.diffChr("Y", "R"));
        // test distStr
        s.rweights = new Vector<Float>(5);
        for(i in 0...s.rweights.length) {
            s.rweights[i] = i+1;
        }
        s.distIUPACCode = false;
        assertEquals(s.distStr("Z0000", "00000"), 1);
        assertEquals(s.distStr("00000", "00001"), 5);
        assertEquals(s.distStr("00000", "00021"), 9);
        s.distIUPACCode = true;
        assertEquals(s.distStr("RRRRR", "AAAAA"), 0);
        assertEquals(s.distStr("RRRTT", "AAAAA"), 9);
        // test constructMedians
        var l:List<String> = s.constructMedians("AAA", "AAC", "AAA");
        assertEquals(1, l.length);
        assertEquals("AAA", l.first());
        var l:List<String> = s.constructMedians("", "", "");
        assertEquals(1, l.length);
        assertEquals("", l.first());
        var l:List<String> = s.constructMedians(
            "GCACGGGCCGATGTTACAGGGATGAATAAAACGTTGGATTACGAGCTACTGGAGTCGCCGGATTCAGTAGACCATCGAAC",
            "CCTGACGGAGCAACATAAATAGTCAATTCGACCATAAAGGATCTTGCATCGCACTTGGAGTGCACAATGCTAGCCGCTCA",
            "GCACAGGGAGATACTTCAGTAATCAATTCGACCTTGGATGATGATGCATTGGACTCGGAGGATACAATGCAAGCTGGACC"
        );
        assertEquals(1, l.length);
        assertEquals("GCACAGGGAGATACTTCAGTAATCAATTCGACCTTGGATGATGATGCATTGGACTCGGAGGATACAATGCAAGCTGGACC", l.first());
        var l:List<String> = s.constructMedians("AGAAATT", "ACATAGT", "ATACAAT");
        assertEquals(3 * 3 * 3, l.length);
        var ind1:Int = 0;
        var g1:Int = 0; var t1:Int = 0; var c1:Int = 0;
        var a3:Int = 0; var t3:Int = 0; var c3:Int = 0;
        var a5:Int = 0; var t5:Int = 0; var g5:Int = 0;
        for(e1 in l) {
            assertEquals("A", e1.charAt(0));
            assertEquals("A", e1.charAt(2));
            assertEquals("A", e1.charAt(4));
            assertEquals("T", e1.charAt(6));
            if(e1.charAt(1) == "G") { g1++; }
            if(e1.charAt(1) == "T") { t1++; }
            if(e1.charAt(1) == "C") { c1++; }
            if(e1.charAt(3) == "A") { a3++; }
            if(e1.charAt(3) == "T") { t3++; }
            if(e1.charAt(3) == "C") { c3++; }
            if(e1.charAt(5) == "A") { a5++; }
            if(e1.charAt(5) == "T") { t5++; }
            if(e1.charAt(5) == "G") { g5++; }
            var ind2:Int = 0;
            for(e2 in l) {
                if(ind1 != ind2) {
                    assertFalse(e1 == e2);
                }
                ind2++;
            }
            ind1++;
        }
        assertEquals(g1, t1);
        assertEquals(g1, c1);
        assertEquals(g1, a3);
        assertEquals(a3, t3);
        assertEquals(a3, c3);
        assertEquals(a3, t5);
        assertEquals(a3, g5);
        assertEquals(a3, a5);
        // test getSeqIdentifier
        assertEquals(null, s.getSeqIdentifier(null));
        assertEquals("", s.getSeqIdentifier(""));
        assertEquals("A_", s.getSeqIdentifier("A_1"));
        assertEquals("A_B_", s.getSeqIdentifier("A_B_1"));
        assertEquals("_", s.getSeqIdentifier("_1"));
        assertEquals("_a_b_c_d_", s.getSeqIdentifier("_a_b_c_d_X"));
//step1,step2,step3,step4,runMJ
        var v:Vector<Float> = new Vector<Float>(5);
        v[0] = 1; v[1] = 3; v[2] = 2; v[3] = 1; v[4] = 2;
        var s2:Seqs = new Seqs();
        s2.weights = v;
        s2.addSample(null, "00000");
        s2.addSample(null, "11000");
        s2.addSample(null, "10110");
        s2.addSample(null, "01101");
        s2.runMJ(0);
        assertEquals(5,s2.length); // TODO further test the resulting network
        var s2:Seqs = new Seqs();
        s2.weights = v;
        s2.addSample(null, "00000");
        s2.addSample(null, "11000");
        s2.addSample(null, "10110");
        s2.addSample(null, "01101");
        s2.runMJ(1);
        assertEquals(6,s2.length); // TODO further test the resulting network
    }

    public static function main():Void {
        var tr = new TestRunner();
        tr.add(new SeqsTests());
        tr.run();
    }
}
