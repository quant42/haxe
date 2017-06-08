package nn;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import haxe.ds.Vector;

class NNTests extends TestCase {

    public function testBasic() {
        // very simplistic tests
        var l:Vector<Int> = new Vector(2);
        l[0] = 1; l[1] = 1;
        var v:Vector<Float> = new Vector(2);
        v[0] = 1; v[1] = 3;
        var nn:NN = new NN(l, v);
        assertEquals(nn.layout, l);
        assertEquals(nn.weights, v);
        try {
            assertEquals("NN(1;1|1.0;3.0)", nn.getStringRepresentation());
        } catch (ex:Dynamic) {
            assertEquals("NN(1;1|1;3)", nn.getStringRepresentation());
        }
/*
        assertEquals([0.5], nn.predict([0]));
        nn = NN.fromStringRepresentation(nn.getStringRepresentation());
        assertEquals(v, nn.predict(v));
        var l:Vector<Int> = new Vector<Int>(3);
        l[0] = 2; l[1] = 3; l[2] = 4;
        nn = NN.getRandomNetwork(l);
        v = new Vector(2);
        v[0] = 1; v[1] = 0;
        assertEquals(4, nn.predict(v).length);
        // simplistic tests
        l = new Vector(3);
        l[0] = l[1] = l[2] = 2;
        v = new Vector(8);
        v[0] = 1; v[1] = -1; v[2] = -1; v[3] = 1; v[4] = v[5] = 1; v[6] = v[7] = -1;
        nn = new NN(l, v);
        var inp:Vector<Float> = new Vector<Float>(2);
        inp[0] = inp[1] = 1;
        var res:Vector<Float> = new Vector<Float>(2);
        res[0] = res[1] = 0;
        assertEquals(res, nn.predict(inp));
*/
    }

    public static function main():Void {
        var tr = new TestRunner();
        tr.add(new NNTests());
        tr.run();
    }
}
