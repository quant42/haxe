package util;

import util.Hashmap;
import interfaces.Hashable;
import interfaces.Numeric;

private class IPair implements Hashable {
    public var i:Int;
    public var j:Int;
    public var l:Int;
    public inline function new(i:Int, j:Int) {
        if (i > j) {
            this.i = j;
            this.j = i;
        } else {
            this.i = i;
            this.j = j;
        }
        this.l = j;
    }
    public inline function hashCode():Int {
        return this.i + this.j * 5;
    }
    public inline function equals(o:Hashable):Bool {
        try {
            var o:IPair = cast(o, IPair);
            return o.i == this.i && o.j == this.j;
        } catch(e:Dynamic) {
            return false;
        }
    }
}

@:generic
class Graph<V:Hashable,E:Numeric> {
    // The nodes of the graph datastructure
    public var nodes(default, null):Hashmap<V,Int>;
    // The current node insertion id
    public var nodeInsertId(default, null):Int;
    // The edges present in this graph datastructure
    public var edges(default, null):Hashmap<V,Hashmap<V,E>>;

    public inline function new() {
        this.nodes = new Hashmap<V,Int>();
        this.nodeInsertId = 0;
        this.edges = new Hashmap<V,Hashmap<V,E>>();
    }

    public inline function addNode(v:V):Bool {
        // check if the node is already part of the graph
        if (this.nodes.contains(v)) {
            return false; // Already part of the graph - don't add
        }
        // add the node to the Hashmap of nodes
        this.nodes.put(v, this.nodeInsertId);
        // increment the node insertion id for next node ...
        this.nodeInsertId++;
        // add map for edges
        this.edges.put(v, new Hashmap<V,E>());
        // everything ok ...
        return true;
    }

    private inline function addE(v1:V, v2:V, e:E):Bool {
        // check if edge is already in list ...
        if (this.edges.get(v1).contains(v2)) {
            return false;
        }
        // nope - add edge
        this.edges.get(v1).put(v2, e);
        return true;
    }
    public function addEdge(v1:V, v2:V, e:E):Bool {
        // check if v1 and v2 are part of the graph ...
        // if not add them
        addNode(v1);
        addNode(v2);
        // now add the connection between v1 and v2
        return addE(v1, v2, e) && addE(v2, v1, e);
    }

    public function areNeighbours(v1:V, v2:V):Bool {
        // check if v2 is in the neighborhood of v1
        return this.edges.get(v1).contains(v2);
    }

    public function existPathBetween(v1:V, v2:V):Bool {
        // check if there is any path from v1 to v2 ...
        // trivial case
        if (v1.equals(v2)) { // same nodes -> is connected
            return true;
        }
        // ok, search
        var visited:Hashmap<V,Bool> = new Hashmap<V,Bool>();
        var l:List<V> = new List<V>();
        l.push(v1);
        visited.put(v1, true);
        while(!l.isEmpty()) {
            var v:V = l.pop();
            for (keyValEle in this.edges.get(v)) {
                var newV:V = keyValEle.first;
                if (newV.equals(v2)) {
                    return true;
                }
                if(!visited.contains(newV)) {
                    l.push(newV);
                    visited.put(newV, true);
                }
            }
        }
        return false;
    }

    public function totallyConnected():Bool {
        // check that the graph contains at least one node (trivial cases)
        if (nodes.size <= 1) {
            return true; // empty graph and/or graph containing only one node => fully connected
        }
        // Checks whether there is at least one path from any node towards any other node
        var visited:Hashmap<V,Bool> = new Hashmap<V,Bool>();
        var l:List<V> = new List<V>();
        l.push(nodes.first.key); // nodes.first is refering to the first added node
        visited.put(nodes.first.key, true);
        while(!l.isEmpty()) {
            var v:V = l.pop();
            for (keyValEle in this.edges.get(v)) {
                var newV:V = keyValEle.first;
                if(!visited.contains(newV)) {
                    l.push(newV);
                    visited.put(newV, true);
                }
            }
        }
        return visited.size == nodes.size;
    }

    public inline function degreeOf(v:V) {
        return this.edges.get(v).size;
    }

    public inline function removeNode(v:V) {
        this.nodes.remove(v);
        for(u in this.edges.get(v)) {
            this.edges.get(u.first).remove(v);
        }
        this.edges.remove(v);
    }

    public inline function removeEdge(v1:V, v2:V) {
        this.edges.get(v1).remove(v2);
        this.edges.get(v2).remove(v1);
    }

    public function getLowestEdgeInConnectedComponent(v1:V):E {
        var result:E = null;
        var visited:Hashmap<V,Bool> = new Hashmap<V,Bool>();
        var l:List<V> = new List<V>();
        l.push(v1);
        visited.put(v1, true);
        while(!l.isEmpty()) {
            var v:V = l.pop();
            for (keyValEle in this.edges.get(v)) {
                var newV:V = keyValEle.first;
                var newE:E = keyValEle.second;
                if(result == null || newE.getValue() < result.getValue()) {
                    result = newE;
                }
                if(!visited.contains(newV)) {
                    l.push(newV);
                    visited.put(newV, true);
                }
            }
        }
        return result;
    }

/*    public static function main():Void {
        trace("Hello World!"); // TODO: replace by tests
    }*/
}
