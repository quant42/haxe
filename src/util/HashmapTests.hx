package util;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import interfaces.Hashable;

class Obj implements Hashable {
    public var i:Int;
    public function hashCode():Int {
        return i;
    }
    public function equals(o:Hashable):Bool {
        try {
            return this.i == cast(o, Obj).i;
        } catch(e:Dynamic) {
            return false;
        }
    }
}

class HashmapTests extends TestCase {

    public function testBasic() {
        // very simplistic tests
        var hm : Hashmap<Obj,Int> = new Hashmap<Obj,Int>();
        assertEquals(1, 1);
    }

    public static function main():Void {
        var tr = new TestRunner();
        tr.add(new HashmapTests());
        tr.run();
    }
}
