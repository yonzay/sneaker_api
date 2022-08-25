package utils;

import haxe.io.Bytes;

class Uuid {
    public static function generate():String  {
        return s4() + s4() + s4() + s4() + s4() + s4() + s4() + s4();
    }
    private static function s4():String {
        return StringTools.hex(Math.floor((1 + Math.random()) * 0x10000)).substr(1);
    }
}
