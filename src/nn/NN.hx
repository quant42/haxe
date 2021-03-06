/**
 * Neuronal network implementation.
 */
package nn;

import haxe.ds.Vector;
import util.Pair;

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
            expectedNrOfWeights += layout[i] * (1 + layout[i-1]);
        }
        if (expectedNrOfWeights != weights.length) {
            throw "Number of weights do not correspond to the expected number of weights! (" + expectedNrOfWeights + " != " + weights.length + ")";
        }
        // everything ok - save
        this.layout = layout;
        this.weights = weights;
    }

    /**
     * Run a prediction.
     *
     * ``features'' The features based on which to run the predictions. The length of the input vector need to equal layout[0].
     * ``return'' The predicted values in form of an output vector (of size layout[layout.size-1]).
     */
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
            next = new Vector<Float>(this.layout[i]);
            // fill out next vector
            for (j in 0...next.length) {
                var tmp:Float = weights[z++];
                for (val in prev) {
                    tmp += weights[z++] * val;
                }
                if (-tmp > 700) { // prevent math overflow
                    next[j] = 0;
                } else {
                    next[j] = 1 / (1 + Math.exp(-tmp));
                }
            }
           // prepare next iteration
           prev = next;
        }
        // return
        return prev;
    }

    /**
     * Get a textual representation of the neuronal network.
     *
     * ``return'' A textual representation of the neuronal network. The textual representation can be
     * reconverted into another neuronal network (via the static ``fromStringRepresentation'' function).
     */
    public function getStringRepresentation():String {
        return "NN(" + this.layout.toArray().join(";") + "|" + this.weights.toArray().join(";") + ")";
    }

    /**
     * Create a new neuronal network based on a string.
     *
     * ``rep'' The textual representation from which to create the neuronal network.
     * ``return'' A new neuronal network object.
     */
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
        var l:Vector<Int> = new Vector<Int>(layoutArr.length);
        var i:Int = 0;
        for (d in layoutArr) {
            l[i++] = Std.parseInt(d);
        }
        // convert weights
        var weightArr:Array<String> = data[1].split(";");
        var v:Vector<Float> = new Vector<Float>(weightArr.length);
        i = 0;
        for (d in weightArr) {
            v[i++] = Std.parseFloat(d);
        }
        // return data
        return new NN(l, v);
    }

    /**
     * Create a new neuronal network with random weights.
     *
     * ``layout'' The layout of the new neuronal network.
     * ``return'' The newly created neuronal network with random weights.
     */
    public static function getRandomNetwork(layout:Vector<Int>):NN {
        // calculate number of weights
        var weights = 0;
        for (i in 1...layout.length) {
            weights += layout[i] * (1 + layout[i-1]);
        }
        // initialize vector containing weights
        var ws:Vector<Float> = new Vector<Float>(weights);
        for (i in 0...weights) {
            ws[i] = ((Math.random() > 0.5) ? -1 : 1) * Math.random();
        }
        // return new NN
        return new NN(layout, ws);
    }

    /**
     * Clone the current neuronal network.
     *
     * ``return'' A copy of this neuronal network.
     */
    public function clone():NN {
        return new NN(this.layout.copy(), this.weights.copy());
    }

    /**
     * Apply a random change to the current neuronal network.
     */
    public function randomlyChange():Void {
        // get a random position in this.weights
        var pos:Int = Std.int(Math.random() * this.weights.length);
        // randomly change this position
        this.weights[pos] += ((Math.random() > 0.5) ? 0.1 : -0.1) * Math.random();
    }

    /**
     * Combine/Merge two neuronal networks.
     *
     * ``o'' The other neuronal network to combine this network with. The layout of the other network need to be the same as the current network.
     * ``return'' A new neuronal network that 'combines' the weight values of both neuronal networks.
     */
    public function mergeNetworks(o:NN):NN {
        // check the others neuronal network layout
        if (this.layout.length != o.layout.length) {
            throw "Both networks need to have the same layout!";
        }
        for (i in 0...this.layout.length) {
            if (this.layout[i] != o.layout[i]) {
                throw "Both networks need to have the same layout!";
            }
        }
        // create the weights
        var w:Vector<Float> = new Vector(this.weights.length);
        for (i in 0...this.weights.length) {
            w[i] = (this.weights[i] + o.weights[i]) / 2.0;
        }
        // return
        return new NN(this.layout.copy(), w);
    }

    /**
     * Calculate the squared error of the current neuronal network for a single example.
     *
     * ``i'' The input of the neuronal network.
     * ``o'' The expected output corresponding to the input.
     * ``return'' The calculated squared error.
     */
    public function calcErrorSingle(i:Vector<Float>, o:Vector<Float>):Float {
        // check that the length of the output vector equals to the layout[-1]
        // the other check that the length of i equals to layout[0] will automatically be checked
        // by the predict function.
        if (o.length != this.layout[this.layout.length-1]) {
            throw "Unexpected ouput vector length!";
        }
        // ok, get the prediction of the network
        var p:Vector<Float> = this.predict(i);
        // calculate the error
        var err:Float = 0;
        for (z in 0...p.length) {
            var e:Float = p[z] - o[z];
            err += e * e;
        }
        // return
        return err;
    }

    /**
     * Calculate the squared error of the current neuronal network for multiple examples.
     *
     * ``td'' The trainingsData to cacluate the error on.
     * ``return'' The calculated squared error on the complete dataset.
     */
    public function calcError(td:Vector<Pair<Vector<Float>,Vector<Float>>>):Float {
        var err:Float = 0;
        for (d in td) {
            err += this.calcErrorSingle(d.first, d.second);
        }
        return err;
    }

    /**
     * Train the neuronal network on a dataset.
     *
     * ``td'' The trainingsData to train the neuronal network on.
     */
    public function trainRandom(td:Vector<Pair<Vector<Float>,Vector<Float>>>):Void {
        // TODO: implement a better learning algorithm
        // this one often works, but doing a 'neighborhood' descent will to often stick in a local min.
        var cErr:Float = calcError(td);
        for (pos in 0...this.weights.length) {
//        var pos:Int = Std.int(Math.random() * this.weights.length);
        var cVal:Float = this.weights[pos];
        var change = Math.random();
        for (sign in [0.1, -0.1]) {
            this.weights[pos] += sign * change;
            var nErr:Float = calcError(td);
            if (nErr < cErr) {
//                return;
            } else {
                this.weights[pos] = cVal;
            }
        }
        }
    }

    static function main():Void {
        var l:Vector<Int> = new Vector<Int>(2);
        l[0] = 2; l[1] = 1;
        var v:Vector<Float> = new Vector<Float>(2);
        v[0] = 0;
        v[1] = 1;
        var nn:NN = NN.getRandomNetwork(l); //fromStringRepresentation("NN(2;2;2|4;3;1;8;3;3;2;-1)"); //new NN(l, v);
//        trace(nn.predict(v));
        trace(nn.getStringRepresentation());
        trace(nn.predict(v));
        trace(nn.layout);
        trace(nn.weights);
    }
}
