package util;

import util.Hashmap;
import interfaces.Hashable;
import interfaces.Numeric;

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

    public function isConnected(v1:V, v2:V):Bool {
        // check if v2 is in the neighborhood of v1
        return this.edges.get(v1).contains(v2);
    }

    public static function main():Void {
        trace("Hello World!"); // TODO: replace by tests
    }
}
