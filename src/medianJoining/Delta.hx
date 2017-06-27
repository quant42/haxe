package medianJoining;

class Delta {
    var s1:Seq;
    var s2:Seq;
    var dist:Float = 0.0;

    public inline function new(s1:Seq, s2:Seq, dist:Float) {
        this.s1 = s1;
        this.s2 = s2;
        this.dist = dist;
    }
}
