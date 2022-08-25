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
                json: {"username":"DeadLocker","avatar_url":"https://cdn.discordapp.com/avatars/829231405951221771/1c6f782e4f88175580fe53e98b68b613.png?size=128","embeds":[{"title":"The DeadLocker webhook","description":'```fix\nAnd the webhook was divine...\n```',"color":65530,"footer":{"text":"DeadLocker","icon_url":"https://cdn.discordapp.com/avatars/829231405951221771/1c6f782e4f88175580fe53e98b68b613.png?size=128"},"thumbnail":{"url":'https://cdn.discordapp.com/avatars/829231405951221771/1c6f782e4f88175580fe53e98b68b613.png?size=128'},"author":{"name":"DeadLocker","icon_url":"https://cdn.discordapp.com/avatars/829231405951221771/1c6f782e4f88175580fe53e98b68b613.png?size=128"}}]}
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