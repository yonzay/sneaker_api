package utils;

import haxe.crypto.Hmac;
import haxe.io.Bytes;
class Nonce {
    public static inline function create(key:String, time:String):String {
        return new Hmac(SHA256).make(Bytes.ofString(key), Bytes.ofString(time)).toHex();
    }
}