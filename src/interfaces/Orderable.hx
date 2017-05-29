package interfaces;

interface Orderable {
    public function equals(o:Orderable):Bool;
    public function isGreater(o:Orderable):Bool;
    public function isLower(o:Orderable):Bool;
}
