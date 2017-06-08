package util;

import interfaces.Hashable;
import util.Pair;
import haxe.ds.Vector;
//import List;

@:generic
private class HashMapEntry<K:Hashable,V> {
    public var key:K = null;
    public var item:V = null;
    public var prev:HashMapEntry<K,V> = null;
    public var next:HashMapEntry<K,V> = null;

    // functions of an hashmap entry ...
    // functions should be called by the HashMap class only
    public function new(key:K, item:V, prev:HashMapEntry<K,V>, next:HashMapEntry<K,V>) {
        this.key = key;
        this.item = item;
        this.prev = prev;
        this.next = next;
    }
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
    // for faster iteration
    private var first:HashMapEntry<K,V> = null;
    private var last:HashMapEntry<K,V> = null;
    
    public function new(?size:Int=100, ?loadFact:Float=0.75) {
        // size should be at least 1
        if (size < 1) {
            throw "Size need to be bigger than 1!";
        }
        // load factor should be greater than 0
        if (loadFact <= 0 || loadFact >= 1) {
            throw "Load factor should be between 0 and 1!";
        }
        // save load factor
        this.loadFact = loadFact;
        // create the list
        this.data = new Vector<List<HashMapEntry<K,V>>>(size);
    }

    public function isEmpty():Bool {
        return size == 0;
    }

    public function clear():Void {
        this.size = 0;
        this.data = new Vector<List<HashMapEntry<K,V>>>(this.data.length);
        this.first = null;
        this.last = null;
    }

    public function clone():Hashmap<K,V> {
        // create the hashmap
        var m:Hashmap<K, V> = new Hashmap<K, V>(this.data.length, this.loadFact);
        // copy elements
        var ele:HashMapEntry<K,V> = first;
        while (ele != null) {
            m.put(ele.key, ele.item);
            ele = ele.next;
        }
        // return the newly map
        return m;
    }

    public function changeCapacity(newCapacity:Int):Void {
        // check new capacity level
        if (newCapacity < 1) {
            throw "Capacity needs to be at least 1!";
        }
        // create a new vector with a higher capacity
        var newData:Vector<List<HashMapEntry<K,V>>> = new Vector<List<HashMapEntry<K,V>>>(newCapacity);
        // copy elements to newData
        var ele:HashMapEntry<K,V> = first;
        while (ele != null) {
            // get the position in data where to insert the object
            var hC:Int = ele.key.hashCode();
            var index:Int = hC % newCapacity;
            // check if there's already a list at the requested position
            // if not create one ...
            if (newData[index] == null) {
                newData[index] = new List<HashMapEntry<K,V>>();
            }
            // add element to new list
            newData[index].add(ele);
            // next
            ele = ele.next;
        }
        // set data
        this.data = newData;
    }

    public function put(key:K, item:V):Bool {
        // check if we need to resize ...
        if (this.data.length * this.loadFact <= this.size) {
            changeCapacity(this.data.length << 1);
        }
        // get the position in data where to insert the object
        var hC:Int = key.hashCode();
        var index:Int = hC % this.data.length;
        // check if there is already something at the corresponding position ...
        if (this.data[index] != null) {
            for (ele in this.data[index]) {
                if (ele.key.equals(key)) {
                    // found, we just need to overwrite the item
                    ele.item = item;
                    // do not search anymore further ...
                    return false;
                }
            }
        } else {
            this.data[index] = new List<HashMapEntry<K,V>>();
        }
        // there is nothing at the corresponding position or the item was not found in the list of items already there ...
        // so add ...
        var entry:HashMapEntry<K,V> = new HashMapEntry<K,V>(key, item, this.last, null);
        if (this.first == null) {
            this.first = entry;
        }
        if (this.last != null) {
            this.last.next = entry;
        }
        this.last = entry;
        this.data[index].add(entry);
        this.size++;
        return true;
    }

    public function remove(key:K):Bool {
        // get the position in data
        var hC:Int = key.hashCode();
        var index:Int = hC % this.data.length;
        // check if there is already something at the corresponding position ...
        if (this.data[index] != null) {
            for (ele in this.data[index]) {
                if (ele.key.equals(key)) {
                    // found - do not search anymore further ...
                    // ok, we need to remove this entry ...
                    this.size--;
                    // remove from list of connections
                    if (ele.prev == null) {
                        this.first = ele.next;
                    } else {
                        ele.prev.next = ele.next;
                    }
                    if (ele.next == null) {
                        this.last = ele.prev;
                    } else {
                        ele.next.prev = ele.prev;
                    }
                    // remove from hash datastructure
                    this.data[index].remove(ele);   // TODO - it seems haxe list does not contain a direct remove (speedup) ... maybe need own list implementation ...
                    return true;
                }
            }
        }
        throw false;
    }

    public function contains(key:K):Bool {
        // get the position in data
        var hC:Int = key.hashCode();
        var index:Int = hC % this.data.length;
        // check if there is already something at the corresponding position ...
        if (this.data[index] != null) {
            for (ele in this.data[index]) {
                if (ele.key.equals(key) || ele.key == key) {
                    // found - do not search anymore further ...
                    return true;
                }
            }
        }
        return false;
    }

    public function iterator():Iterator<Pair<K,V>> {
        return new HashmapIterator(first);
    }

//    public static function main():Void {}
}

@:generic
private class HashmapIterator<K:Hashable,V> {
    public var c:HashMapEntry<K,V> = null;

    public function new(c:HashMapEntry<K,V>) {
        this.c = c;
    }

    public function hasNext():Bool {
        return c != null;
    }

    public function next():Pair<K,V> {
        var r:Pair<K,V> = new Pair(c.key, c.item);
        c = c.next;
        return r;
    }
}

