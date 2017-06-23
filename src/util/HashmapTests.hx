package util;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import interfaces.Hashable;

class Obj1 implements Hashable {
    public var i:Int;
    public function new(i:Int) {
        this.i = i;
    }
    public function hashCode():Int {
        return i;
    }
    public function equals(o:Hashable):Bool {
        try {
            return this.i == cast(o, Obj1).i;
        } catch(e:Dynamic) {
            return false;
        }
    }
}
class Obj2 implements Hashable {
    public var i:Int;
    public function hashCode():Int {
        return i;
    }
    public function equals(o:Hashable):Bool {
        try {
            return this.i == cast(o, Obj2).i;
        } catch(e:Dynamic) {
            return false;
        }
    }
}

class HashmapTests extends TestCase {

    public function testBasic() {
        // very simplistic tests
        var hm : Hashmap<Obj1,Int> = new Hashmap<Obj1,Int>();
        assertEquals(hm.isEmpty(), true);
        hm.put(new Obj1(0), 5);
        assertEquals(hm.isEmpty(), false);
        assertEquals(hm.contains(new Obj1(0)), true);
        assertEquals(hm.contains(new Obj1(100)), false);
        assertEquals(1, hm.size);
        hm.put(new Obj1(1), 6);
        assertEquals(hm.isEmpty(), false);
        assertEquals(hm.contains(new Obj1(1)), true);
        assertEquals(2, hm.size);
        hm.put(new Obj1(2), 7);
        assertEquals(hm.isEmpty(), false);
        assertEquals(hm.contains(new Obj1(2)), true);
        assertEquals(3, hm.size);
        hm.put(new Obj1(100), 105);
        assertEquals(hm.isEmpty(), false);
        assertEquals(hm.contains(new Obj1(100)), true);
        assertEquals(4, hm.size);
        assertEquals(hm.contains(new Obj1(101)), false);
        var nr:Int = 0;
        for (e in hm) {
            nr++;
            assertEquals(e.first.i + 5, e.second);
        }
        assertEquals(4, nr);
        // change capacity / remove
        for (i in 0...2000) {
            hm.put(new Obj1(i), i + 10);
        }
        assertEquals(2000, hm.size);
        nr = 0;
        for (e in hm) {
            nr++;
            assertEquals(e.first.i + 10, e.second);
        }
        assertEquals(2000, nr);
        for (i in 1000...2000) {
            hm.remove(new Obj1(i));
        }
        assertEquals(1000, hm.size);
        nr = 0;
        for (e in hm) {
            nr++;
            assertEquals(e.first.i + 10, e.second);
        }
        assertEquals(1000, nr);
        assertEquals(hm.contains(new Obj1(101)), true);
        assertEquals(hm.contains(new Obj1(1001)), false);
        hm.clear();
        assertEquals(hm.contains(new Obj1(101)), false);
        assertEquals(hm.contains(new Obj1(1001)), false);
        assertEquals(0, hm.size);
    }

    public static function main():Void {
        var tr = new TestRunner();
        tr.add(new HashmapTests());
        tr.run();
    }
}
