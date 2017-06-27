package medianJoining;

class Seq {
    public var originalSequence:String;
    public var reducedSequence:String;
    public var names:List<String>;

    public var isSample:Bool;

    public var myDeltas:List<Delta>;

    public var next:Seq;
    public var prev:Seq;

    public var id:Int;

    public var posX:Float;
    public var posY:Float;

    public var connectedTo:List<Seq>;
    public var links:List<Seq>;

    public inline function new() {
        this.names = new List<String>();
        this.myDeltas = new List<Delta>();
        this.connectedTo = new List<Seq>();
        this.links = new List<Seq>();
    }
}
