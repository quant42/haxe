/**
 * (A linear) neuronal network implementation.
 */
package nn;

import haxe.ds.Vector;

class NN {
    // The layout of the neuronal network. Only settable via constructor.
    public var layout(default, null):Vector<Int>;
    // The weights of the neuronal network. Only settable via constructor.
    public var weights(default, null):Vector<Float>;

    /**
     * Create a new neuronal network.
     *
     * ``layout'' The neuronal network layout.
     * ``weights'' The corresponding weights of each neuron.
     */
    public function new(layout:Vector<Int>, weights:Vector<Float>) {
        // check that the layout contains only weights > 0
        for (val in layout) {
            if (val <= 0) {
                throw "Values in layout need to be strictly greater than 0!";
            }
        }
        // check that layout is not empty (length should be at least 2)
        if (layout.length < 2) {
            throw "Layout should contain at least 2 elements!";
        }
        // Check whether the weights correspond to the layout.
        var expectedNrOfWeights = 0;
        for (i in 1...layout.length) {
            expectedNrOfWeights += layout[i] * layout[i-1];
        }
        if (expectedNrOfWeights != weights.length) {
            throw "Number of weights do not correspond to the expected number of weights! (" + expectedNrOfWeights + " != " + weights.length + ")";
        }
        // everything ok - save
        this.layout = layout;
        this.weights = weights;
    }

    public function predict(features:Vector<Float>):Vector<Float> {
        // check that we have enough input
        if (features.length != this.layout[0]) {
            throw "! (" + features.length + " != " + this.layout[0] + ")";
        }
        // predict
        var prev:Vector<Float> = features;
        var next:Vector<Float>;
        var z:Int = 0;
        for (i in 1...this.layout.length) {
            next = new Vector(this.layout[i]);
            // fill out next vector
            for (j in 0...next.length) {
                var tmp:Float = 0;
                for (val in prev) {
                    tmp += weights[z++] * val;
                }
                next[j] = tmp;
            }
           // prepare next iteration
           prev = next;
        }
        // return
        return prev;
    }

    public function getStringRepresentation():String {
        return "NN(" + this.layout.toArray().join(";") + "|" + this.weights.toArray().join(";") + ")";
    }

    public static function fromStringRepresentation(rep:String):NN {
        // chop of beginning "NN(" and ending ")"
        if (! (StringTools.startsWith(rep, "NN(") && StringTools.endsWith(rep, ")"))) {
            throw "String does not represent a neuronal network! (Wrong magic)";
        }
        rep = rep.substring(3, rep.length - 1);
        // ok, now split to data
        var data:Array<String> = rep.split("|");
        if (data.length != 2) {
            throw "String does not represent a neuronal network! (Missing data)";
        }
        // convert layout
        var layoutArr:Array<String> = data[0].split(";");
        var l:Vector<Int> = new Vector(layoutArr.length);
        var i:Int = 0;
        for (d in layoutArr) {
            l[i++] = Std.parseInt(d);
        }
        // convert weights
        var weightArr:Array<String> = data[1].split(";");
        var v:Vector<Float> = new Vector(weightArr.length);
        i = 0;
        for (d in weightArr) {
            v[i++] = Std.parseFloat(d);
        }
        // return data
        return new NN(l, v);
    }

    static function main():Void {
//        var l:Vector<Int> = new Vector(2);
//        l[0] = 1; l[1] = 1;
        var v:Vector<Float> = new Vector(2);
        v[0] = 0;
        v[1] = 1;
        var nn:NN = NN.fromStringRepresentation("NN(2;2;2|4;3;1;8;3;3;2;-1)"); //new NN(l, v);
//        trace(nn.predict(v));
        trace(nn.getStringRepresentation());
        trace(nn.predict(v));
        trace(nn.layout);
        trace(nn.weights);
    }
}
