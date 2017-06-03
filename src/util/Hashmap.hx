package util;

import interfaces.Hashable;
import util.Pair;
import haxe.ds.Vector;
import haxe.ds.List;

@:generic
class HashMapEntry<K:Hashable,V> {
    public var prev:HashMapEntry<K,V> = null;
    public var next:HashMapEntry<K,V> = null;
    public var key:K = null;
    public var item:V = null;

    // functions of an hashmap entry ...
    // functions should be called by the HashMap class only
    public function get(i:Int):HashMapEntry<K,V> {
        if (i == 0) {
            return this;
        }
        return next.get(i-1);
    }
    public function hasNext():Bool {
        return next != null;
    }
    public function hasPrev():Bool {
        return prev != null;
    }
}

@:generic
class Hashmap<K:Hashable,V> {
    // constants
    private var loadFact:Float = 0.75;
    // the number of elements currently stored in this hashmap
    public var size(default, null):Int = 0;
    // HashMap implementation
    private var data:Vector<List<HashMapEntry<K,V>>> = null;
    
    public function new(?size:Int=100, ?loadFact:Float=0.75) {
        // size should be at least 1
        if (size < 1) {
            throw "Size need to be bigger than 1!";
        }
        // load factor should be greater than 0
        if (loadFact <= 0) {
            throw "Load factor should be bigger than 0!";
        }
        // save load factor
        this.loadFact = loadFact;
        // create the list
        this.data = new Vector<List<HashMapEntry<K,V>>>(size);
    }

// todo methods: add, remove, iter, contains, clear, clone, resize, isEmpty

    public static function main():Void {}
}
