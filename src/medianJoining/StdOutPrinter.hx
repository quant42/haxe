package medianJoining;

import interfaces.Printer;

class StdOutPrinter implements Printer {
    public inline function new() {}
    public inline function printString(s:String):Void {
        Sys.stdout().writeString(s);
    }
    public inline function close():Void {}
}
