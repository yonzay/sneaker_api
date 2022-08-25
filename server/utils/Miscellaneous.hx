package utils; 

import haxe.Json;
import js.Syntax; 

class Miscellaneous {
    public static var request:Dynamic = Syntax.code("require")("request"); 
    public static inline function webhook(webhook:String, callback:String->Void) {
        try {
            request({
                method: 'POST',
                url: '$webhook',
                json: {"username":"","avatar_url":"","embeds":[{"title":"The webhook","description":'```fix\nAnd the webhook was divine...\n```',"color":65530,"footer":{"text":"","icon_url":""},"thumbnail":{"url":''},"author":{"name":"","icon_url":""}}]}
            }, function (error, response, body) { 
                try {
                    callback(Json.stringify({"success":true, "code":response.statusCode}));
                } catch (e) {
                    callback(Json.stringify({"success":true, "code":200}));
                }
            });
        } catch (e) {
            callback(null); 
        }
    }
}
