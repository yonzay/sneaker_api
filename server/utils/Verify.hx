package utils;

import haxe.crypto.Hmac;
import haxe.io.Bytes;

class Verify {
    public static function nonce(nonce:String, key:String):Bool {
        var time = Date.now();
        var h = time.getHours();
        h = ((h + 11) % 12 + 1); 
        var i:String = Std.string(h);
        if (h < 10) { i = "0" + i; }
        var session:Array<String> = [new Hmac(SHA256).make(Bytes.ofString(key), Bytes.ofString(DateTools.format(DateTools.delta(time, -3000), "%m:%d:" + i + ":%M:%S:%Y"))).toHex(), 
                                     new Hmac(SHA256).make(Bytes.ofString(key), Bytes.ofString(DateTools.format(DateTools.delta(time, -2000), "%m:%d:" + i + ":%M:%S:%Y"))).toHex(),
                                     new Hmac(SHA256).make(Bytes.ofString(key), Bytes.ofString(DateTools.format(DateTools.delta(time, -1000), "%m:%d:" + i + ":%M:%S:%Y"))).toHex(),
                                     new Hmac(SHA256).make(Bytes.ofString(key), Bytes.ofString(DateTools.format(DateTools.delta(time,  0.00), "%m:%d:" + i + ":%M:%S:%Y"))).toHex()];
        if (session.indexOf(nonce) == -1) {
            return false; 
        } else {
            return true; 
        }
        return false;
    }

    public static function monitorNonce(nonce:String, key:String):Bool {
        var time = Date.now();
        var h = time.getHours();
        h = ((h + 11) % 12 + 1); 
        var i:String = Std.string(h); 
        if (h < 10) { i = "0" + i; }
        var session:Array<String> = [new Hmac(SHA256).make(Bytes.ofString(key), Bytes.ofString(DateTools.format(DateTools.delta(time,  0.00), "%m:%d:" + i + ":%M:%S:%Y"))).toHex()];
        for (x in 1...60) {
            session.push(new Hmac(SHA256).make(Bytes.ofString(key), Bytes.ofString(DateTools.format(DateTools.delta(time, -x * 1000), "%m:%d:" + i + ":%M:%S:%Y"))).toHex());
        }
        if (session.indexOf(nonce) == -1) {
            return false; 
        } else {
            return true; 
        }
        return false;
    }

    public static inline function createKey():Bytes {
        var bytes = Bytes.alloc(32);
        for (i in 0...bytes.length) { bytes.set(i,Std.random(255)); }
        return bytes;
    }    
}