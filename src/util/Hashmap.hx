package util;

import interfaces.Hashable;
import util.Pair;
import haxe.ds.Vector;

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
    public inline function hasNext():Bool {
        return next != null;
    }
    public inline function hasPrev():Bool {
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
    private var data:Vector<LList<HashMapEntry<K,V>>> = null;
    // for faster iteration
    private var first:HashMapEntry<K,V> = null;
    private var last:HashMapEntry<K,V> = null;
    
    /**
     * Create a new hashmap.
     *
     * @param size The internal size of the vector where the objects in this hashmap gets stored.
     * @param loadFact A loading factor. Once more than size*loadFact elements are present in the hashmap,
     * the internal size of the storing vector gets increased.
     */
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
        // create the LList
        this.data = new Vector<LList<HashMapEntry<K,V>>>(size);
    }

    /**
     * Returns whether there are objects stored in the hashmap.
     */
    public function isEmpty():Bool {
        return size == 0;
    }

    /**
     * Remove all elements from the hasmap.
     */
    public function clear():Void {
        this.size = 0;
        this.data = new Vector<LList<HashMapEntry<K,V>>>(this.data.length);
        this.first = null;
        this.last = null;
    }

    /**
     * Return a copy of this hashmap.
     */
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

    /**
     * Change the internal capacity of this hashmap.
     *
     * @param newCapacity The new capacity of this hashmap.
     */
    public function changeCapacity(newCapacity:Int):Void {
        // check new capacity level
        if (newCapacity < 1) {
            throw "Capacity needs to be at least 1!";
        }
        // create a new vector with a higher capacity
        var newData:Vector<LList<HashMapEntry<K,V>>> = new Vector<LList<HashMapEntry<K,V>>>(newCapacity);
        // copy elements to newData
        var ele:HashMapEntry<K,V> = first;
        while (ele != null) {
            // get the position in data where to insert the object
            var hC:Int = ele.key.hashCode();
            var index:Int = hC % newCapacity;
            // check if there's already a LList at the requested position
            // if not create one ...
            if (newData[index] == null) {
                newData[index] = new LList<HashMapEntry<K,V>>();
            }
            // add element to new LList
            newData[index].add(ele);
            // next
            ele = ele.next;
        }
        // set data
        this.data = newData;
    }

    /**
     * Put a new item with it's corresponding value into the hashmap. If there's already an object with this
     * key, the element will be overwritten.
     *
     * @param key The key under which to save the object. (May not be null!)
     * @param item The item to save under the corresponding key.
     */
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
            this.data[index] = new LList<HashMapEntry<K,V>>();
        }
        // there is nothing at the corresponding position or the item was not found in the LList of items already there ...
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

    /**
     * Remove an key/item from the hashmap.
     *
     * @param key The key object to remove.
     */
    public function remove(key:K):Bool {
        // get the position in data
        var hC:Int = key.hashCode();
        var index:Int = hC % this.data.length;
        // check if there is already something at the corresponding position ...
        if (this.data[index] != null) {
            var prev:LListNode<HashMapEntry<K,V>> = null;
            var l = this.data[index].head;
            var ele = l.item;
            while(ele != null) {
                if (ele.key.equals(key)) {
                    // found - do not search anymore further ...
                    // ok, we need to remove this entry ...
                    this.size--;
                    // remove from LList of connections
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
                    if (prev == null) {
                        this.data[index].head = l.next;
                    } else {
                        prev.next = l.next;
                    }
                    if (this.data[index].end == l) {
                        this.data[index].end = prev;
                    }
                    // found and removed - so return true
                    return true;
                }
                prev = l;
                l = l.next;
            }
        }
        return false;
    }

    /**
     * Check whether the hashmap contains an item at the given position.
     *
     * @param key The hey of the object to check whether it exists.
     */
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

    /**
     * Iterate over the elements stored in this hashmap.
     */
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

// LList is a special list implementation for HashMapEntries (<K:Hashable,V>) ...
@:generic
private class LList<T> {
    // The head element of the list.
    public var head : LListNode<T>;
    // The final element of the list.
    public var end : LListNode<T>;
   
    // construct a new LList (nothing to do)
    public inline function new() {}

    // add an element to the end of this list.
    public function add(item:T) {
        var e : LListNode<T> = new LListNode<T>(item);
        if(head == null) {
            head = e;
        } else {
            end.next = e;
        }
        end = e;
    }

    public inline function iterator() : LListIterator<T> {
        return new LListIterator<T>(this.head, this);
    }
}
@:generic
private class LListNode<T> {
    // the item that is saved in this list node
    public var item:T;
    // next / successive list node
    public var next:LListNode<T>;
    // create a new list node
    public inline function new(item:T) {
        this.item = item;
    }
}
@:generic
private class LListIterator<T> {
    var e:LListNode<T>;
    var l:LList<T>;
    public inline function new(head:LListNode<T>, lst:LList<T>) {
        this.e = head;
        this.l = lst;
    }
    public inline function hasNext():Bool {
        return this.e != null;
    }
    public inline function next():T {
        var val:T = this.e.item;
        this.e = this.e.next;
        return val;
    }
}
