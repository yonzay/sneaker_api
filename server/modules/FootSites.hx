package modules;

import js.Syntax; 
import haxe.Json; 
import utils.Tales; 
class FootSites {
    public static var request:Dynamic = Syntax.code("require")("request"); 
    public static var adyenEncrypt:Dynamic = Syntax.code("require")('node-adyen-encrypt')(22);
    public static var adyenKey = "10001|A237060180D24CDEF3E4E27D828BDB6A13E12C6959820770D7F2C1671DD0AEF4729670C20C6C5967C664D18955058B69549FBE8BF3609EF64832D7C033008A818700A9B0458641C5824F5FCBB9FF83D5A83EBDF079E73B81ACA9CA52FDBCAD7CD9D6A337A4511759FA21E34CD166B9BABD512DB7B2293C0FE48B97CAB3DE8F6F1A8E49C08D23A98E986B8A995A8F382220F06338622631435736FA064AEAC5BD223BAF42AF2B66F1FEA34EF3C297F09C10B364B994EA287A5602ACF153D0B4B09A604B987397684D19DBC5E6FE7E4FFE72390D28D6E21CA3391FA3CAADAD80A729FEF4823F6BE9711D4D51BF4DFCB6A3607686B34ACCE18329D415350FD0654D";

    public static inline function getSession(site:String, queueCookie:String, proxy:String, callback:String->Void) {
        try {
            proxy = 'http://' + proxy.split(":")[2] + ':' + proxy.split(":")[3] + '@' + proxy.split(":")[0] + ':' + proxy.split(":")[1];  
            request({
                method: 'GET',
                proxy: '$proxy',
                url: 'https://www.$site.com/apigate/v5/session',
                headers: {
                    'authority': 'www.$site.com',
                    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.104 Safari/537.36',
                    'Cookie': 'waiting_room=$queueCookie; Path=/; HTTPOnly'
                }
            }, function (error, response, body) {
                var session = ~/(?<=JSESSIONID=)(.*?)(?=;)/g;
                var queue = ~/(?<=waiting_room=)(.*?)(?=;)/g;
                try {
                    if (response.statusCode == 200) {
                        session.match(jsonReturnValuesForKey('set-cookie', Json.stringify(response.headers))[0]); 
                        callback(Json.stringify({"response":{"session":session.matched(1), "csrf":Json.parse(body).data.csrfToken, "status":response.statusCode}})); 
                    } else {
                        if (queue.match(jsonReturnValuesForKey('set-cookie', Json.stringify(response.headers))[0])) {
                            callback(Json.stringify({"response":{"status":529, "queue":queue.matched(1)}}));
                        } else {
                            callback(Json.stringify({"response":{"status":response.statusCode}}));
                        }
                    }
                } catch (e) {
                    if (response != null) {
                        callback(Json.stringify({"response":{"status":response.statusCode}}));
                    } else {
                        callback(null); 
                    }
                }
            });
        } catch (e) {
            callback(null); 
        }
    }

    public static inline function getProductInfo(site:String, queueCookie:String, proxy:String, sku:String, shoeSizes:Array<String>, shoeColor:String, callback:String->Void) {
        try {
            proxy = 'http://' + proxy.split(":")[2] + ':' + proxy.split(":")[3] + '@' + proxy.split(":")[0] + ':' + proxy.split(":")[1]; 
            request({
                method: 'GET',
                proxy: '$proxy',
                followAllRedirects: true,
                jar: true,
                url: 'https://www.$site.com/en/product/~/$sku.html', 
                headers: {
                    'authority': 'www.$site.com',
                    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.104 Safari/537.36',
                    'Cookie': 'waiting_room=$queueCookie; Path=/; HTTPOnly'
                }
            }, function (error, response, body:Dynamic) {
                var codes:Array<String> = [];
                var formatProduct =  ~/(?<=},"product":{)(.*?)(?=,")/g;
                var formatHtml = ~/(?<="details":{"data":{)(.*)(?=}]},"sizes")/g;
                if (!error && formatHtml.match(body) && formatProduct.match(body)) {
                    try {
                        if (response.statusCode == response.statusCode) { callback(Json.stringify({"name":null, "codes":null, "queue":true})); }
                        var randomColor;
                        var colorFound = false; 
                        var data = Json.parse(Json.stringify(jsonReturnValuesForKey('/en/product/~/$sku.html', "{" + formatHtml.matched(1) + "}]}"))); 
                        var shoe = Json.parse(Json.stringify(jsonReturnValuesForKey('/en/product/~/$sku.html', "{" + formatProduct.matched(1) + "}}"))); 
                        for (i in 0...data.length) {
                            if (shoeColor == data[i].style) {
                                colorFound = true; 
                                for (a in 0...shoeSizes.length) {
                                    for (b in 0...data[i].products.length) {
                                        if (shoeSizes[a] == data[i].products[b].size.value) {
                                            codes.push(data[i].products[b].size.id);
                                        }
                                    }
                                }
                            }
                        }
                        if (!colorFound) {
                            for (a in 0...shoeSizes.length) {
                                randomColor = Math.floor(Math.random() * data.length);
                                for (b in 0...data[randomColor].products.length) {
                                    if (shoeSizes[a] == data[randomColor].products[b].size.value) {
                                        codes.push(data[randomColor].products[b].size.id);
                                    }
                                }
                            }
                        }
                        callback(Json.stringify({"name":shoe.name, "codes":codes, "queue":false}));
                    } catch (e) {
                        callback(null);
                    }
                } else {
                    callback(null);
                }
            });
        } catch (e) {
           callback("retry"); 
        }
    }

    public static inline function addToCart(site:String, queueCookie:String, proxy:String, productID:String, session:String, callback:String->Void) {
        try {
            proxy = 'http://' + proxy.split(":")[2] + ':' + proxy.split(":")[3] + '@' + proxy.split(":")[0] + ':' + proxy.split(":")[1]; 
            request({
                method: 'POST',
                proxy: '$proxy',
                url: 'https://www.$site.com/apigate/users/carts/current/entries',
                headers: {
                    'authority': 'www.$site.com',
                    'Cookie': 'waiting_room=$queueCookie; JSESSIONID=$session; Path=/; HTTPOnly',
                    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.104 Safari/537.36',
                    'accept': 'application/json',
                    'x-fl-productid': productID
                },
                json: {"productId":productID,"productQuantity":1}
            }, function (error, response, body) {
                if (response != null) {
                    if (response.statusCode == 200) { 
                        try {
                            callback(Json.stringify({"response":{"status":response.statusCode, "guid":body.guid, "picture":body.entries[0].product.baseOptions[0].selected.images[0].url, "style":body.entries[0].product.baseOptions[0].selected.style, "size":body.entries[0].product.baseOptions[0].selected.size}})); 
                        } catch (e) {
                            callback(null); 
                        }
                    } else {
                        callback(Json.stringify({"response":{"status":response.statusCode}})); 
                    }
                } else {
                    callback(null); 
                }
            });
        } catch (e) {
            callback(null); 
        }
    }

    public static inline function authSession(site:String, queueCookie:String, proxy:String, guid:String, session:String, csrf:String, email:String, callback:String->Void) {
        try {
            proxy = 'http://' + proxy.split(":")[2] + ':' + proxy.split(":")[3] + '@' + proxy.split(":")[0] + ':' + proxy.split(":")[1]; 
            request({
                method: 'PUT',
                proxy: '$proxy',
                url: 'https://www.$site.com/apigate/users/carts/current/email/$email',
                headers: {
                    'authority': 'www.$site.com',
                    'Cookie': 'waiting_room=$queueCookie; cart-guid=$guid; JSESSIONID=$session; Path=/; HTTPOnly',
                    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.104 Safari/537.36',
                    'x-csrf-token': csrf
                },
            }, function (error, response, body) {
                if (response != null) {
                    if (response.statusCode == 200) {
                        callback(Json.stringify({"response":{"status":response.statusCode}})); 
                    } else { 
                        callback(null); 
                    }
                } else {
                    callback(null); 
                }
            });
        } catch (e) {
            callback(null); 
        }
    }

    public static inline function setShipping(site:String, queueCookie:String, proxy:String, guid:String, session:String, csrf:String, firstName:String, lastName:String, stateName:String, stateCode:String, streetOne:String, streetTwo:String, city:String, zipCode:String, phoneNumber:String, callback:String->Void) {
        try {
            proxy = 'http://' + proxy.split(":")[2] + ':' + proxy.split(":")[3] + '@' + proxy.split(":")[0] + ':' + proxy.split(":")[1]; 
            request({
                method: 'POST',
                proxy: '$proxy',
                url: 'https://www.$site.com/apigate/users/carts/current/addresses/shipping',
                headers: {
                    'authority': 'www.$site.com',
                    'Cookie': 'waiting_room=$queueCookie; cart-guid=$guid; JSESSIONID=$session; Path=/; HTTPOnly',
                    'accept': 'application/json',
                    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.104 Safari/537.36',
                    'x-csrf-token': csrf
                },
                json: {"shippingAddress":{"lastName":'$lastName',"region":{"name":'$stateName',"countryIso":"US","isocode":'US-$stateCode',"isocodeShort":'$stateCode'},"country":{"name":"United States","isocode":"US"},"line2":'$streetTwo',"isFPO":false,"phone":'$phoneNumber',"town":'$city',"line1":'$streetOne',"firstName":'$firstName',"postalCode":'$zipCode'}}
            }, function (error, response, body) {
                if (response != null) {
                    if (response.statusCode == 201) {
                        callback(Json.stringify({"response":{"status":response.statusCode}})); 
                    } else {
                        callback(null); 
                    }
                } else {
                    callback(null); 
                }
            });
        } catch (e) {
            callback(null); 
        }
    }

    public static inline function setBilling(site:String, queueCookie:String, proxy:String, guid:String, session:String, csrf:String, firstName:String, lastName:String, stateName:String, stateCode:String, streetOne:String, streetTwo:String, city:String, zipCode:String, phoneNumber:String, callback:String->Void) {
        try {
            proxy = 'http://' + proxy.split(":")[2] + ':' + proxy.split(":")[3] + '@' + proxy.split(":")[0] + ':' + proxy.split(":")[1]; 
            request({
                method: 'POST',
                proxy: '$proxy',
                url: 'https://www.$site.com/apigate/users/carts/current/set-billing',
                headers: {
                    'authority': 'www.$site.com',
                    'Cookie': 'waiting_room=$queueCookie; cart-guid=$guid; JSESSIONID=$session; Path=/; HTTPOnly',
                    'accept': 'application/json',
                    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.104 Safari/537.36',
                    'x-csrf-token': csrf
                },
                json: {"postalCode":'$zipCode',"phone":'$phoneNumber',"country":{"isocode":"US","name":"United States"},"line2":'$streetTwo',"line1":'$streetOne',"town":'$city',"region":{"countryIso":"US","isocode":'US-$stateCode',"isocodeShort":'$stateCode',"name":'$stateName'},"lastName":'$lastName',"isFPO":false,"firstName":'$firstName'}
            }, function (error, response, body) {
                if (response != null) {
                    if (response.statusCode == 200) {
                        callback(Json.stringify({"response":{"status":response.statusCode}})); 
                    } else {
                        callback(null); 
                    }
                } else {
                    callback(null); 
                }
            });
        } catch (e) {
            callback(null); 
        }
    }

    public static inline function placeOrder(site:String, webhook:String, profile:String, email:String, name:String, picture:String, style:String, size:String, queueCookie:String, proxy:String, guid:String, session:String, csrf:String, cardNumber:String, cvc:String, holderName:String, expiryMonth:String, expiryYear:String, callback:String->Void) {
        try {
            var options = {}; 
            var cseInstance = adyenEncrypt.createEncryption(adyenKey, options);
            var cardData = {
                number:cardNumber,     
                cvc:cvc,       
                holderName:holderName,
                expiryMonth:expiryMonth,
                expiryYear:expiryYear,  
                generationtime:Syntax.code("new Date")().toISOString()
            };
            cseInstance.validate(cardData);
            var format = ~/adyenjs_0_1_22/g;
            var encrypted = format.replace(cseInstance.encrypt(cardData), "adyenan0_1_1");
            var webhookSite = ""; 
            proxy = 'http://' + proxy.split(":")[2] + ':' + proxy.split(":")[3] + '@' + proxy.split(":")[0] + ':' + proxy.split(":")[1]; 
            request({
                method: 'POST',
                proxy: '$proxy',
                url: 'https://www.$site.com/apigate/v2/users/orders',
                headers: {
                    'authority': 'www.$site.com',
                    'Cookie': 'waiting_room=$queueCookie; cart-guid=$guid; JSESSIONID=$session; Path=/; HTTPOnly',
                    'accept': 'application/json',
                    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.104 Safari/537.36',
                    'x-csrf-token': csrf
                },
                json: {
                        "sid":"5238",
                        "encryptedCardNumber":encrypted,
                        "encryptedSecurityCode":encrypted,
                        "deviceId":"null",
                        "cartId":guid,
                        "encryptedExpiryMonth":encrypted,
                        "encryptedExpiryYear":encrypted
                    }
            }, function (error, response, body) {
                if (response != null) {
                    if (site == "footlocker") {
                        webhookSite = "Foot Locker";
                    } else if (site == "eastbay") {
                        webhookSite = "Eastbay";
                    } else if (site == "champssports") {
                        webhookSite = "Champs Sports"; 
                    } else if (site == "footaction") {
                        webhookSite = "Footaction"; 
                    } else if (site == "kidsfootlocker") {
                        webhookSite = "Kids Foot Locker"; 
                    }
                    if (response.statusCode == 201) {
                        var orderNumber; 
                        var price; 
                        try {
                            orderNumber = body.order.code;
                            price = body.order.totalPrice.formattedValue;
                        } catch (e) {
                            orderNumber = null;
                            price = null; 
                        }
                        var quote = Tales.scripts[Math.floor(Math.random() * 22)]; 
                        request({
                            method: 'POST',
                            url: 'https://discord.com/api/webhooks/837893478078873682/VeFhtMw9H9xtVK_7b72wN-9H_ASXjOUY1XF0RFGSmATfCFgGCuNsZbkErtO0zTGIQB-R',
                            json: {"username":"DeadLocker","avatar_url":"https://cdn.discordapp.com/avatars/829231405951221771/1c6f782e4f88175580fe53e98b68b613.png?size=128","embeds":[{"title":"Success","description":'```fix\n$quote\n```',"color":65530,"footer":{"text":"DeadLocker","icon_url":"https://cdn.discordapp.com/avatars/829231405951221771/1c6f782e4f88175580fe53e98b68b613.png?size=128"},"thumbnail":{"url":'$picture'},"author":{"name":"DeadLocker","icon_url":"https://cdn.discordapp.com/avatars/829231405951221771/1c6f782e4f88175580fe53e98b68b613.png?size=128"},"fields":[{"name":"Module Name","value":'$webhookSite US',"inline":false},{"name":"Product Name","value":'$name',"inline":false},{"name":"Style","value":'$style',"inline":false},{"name":"Size","value":'$size',"inline":false},{"name":"Price","value":'$price',"inline":false}]}]}
                        });
                        if (webhook != null || webhook != "") {
                            try {
                                request({
                                    method: 'POST',
                                    url: '$webhook',
                                    json: {"username":"DeadLocker","avatar_url":"https://cdn.discordapp.com/avatars/829231405951221771/1c6f782e4f88175580fe53e98b68b613.png?size=128","embeds":[{"title":"Success","color":65530,"footer":{"text":"DeadLocker","icon_url":"https://cdn.discordapp.com/avatars/829231405951221771/1c6f782e4f88175580fe53e98b68b613.png?size=128"},"thumbnail":{"url":'$picture'},"author":{"name":"DeadLocker","icon_url":"https://cdn.discordapp.com/avatars/829231405951221771/1c6f782e4f88175580fe53e98b68b613.png?size=128"},"fields":[{"name":"Module Name","value":'$webhookSite US',"inline":false},{"name":"Product Name","value":'$name',"inline":false},{"name":"Style","value":'$style',"inline":false},{"name":"Size","value":'$size',"inline":false},{"name":"Price","value":'$price',"inline":false},{"name":"Profile","value":'||$profile||',"inline":false},{"name":"Email","value":'||$email||',"inline":false},{"name":"Proxy","value":'||$proxy||', "inline":false},{"name":"Order Number","value":'||$orderNumber||', "inline":false}]}]}
                                });
                            } catch (e) {} 
                        }
                        callback(Json.stringify({"response":{"status":response.statusCode, "order":orderNumber, "price":price, "site":webhookSite}})); 
                    } else if (response.statusCode == 400) {
                        try {
                            if (body.errors[0].code == 12001) {
                                if (webhook != null || webhook != "") {
                                    try {
                                        request({
                                            method: 'POST',
                                            url: '$webhook',
                                            json: {"username":"DeadLocker","avatar_url":"https://cdn.discordapp.com/avatars/829231405951221771/1c6f782e4f88175580fe53e98b68b613.png?size=128","embeds":[{"title":"Failure","color":65530,"footer":{"text":"DeadLocker","icon_url":"https://cdn.discordapp.com/avatars/829231405951221771/1c6f782e4f88175580fe53e98b68b613.png?size=128"},"thumbnail":{"url":'$picture'},"author":{"name":"DeadLocker","icon_url":"https://cdn.discordapp.com/avatars/829231405951221771/1c6f782e4f88175580fe53e98b68b613.png?size=128"},"fields":[{"name":"Module Name","value":'$webhookSite US',"inline":false},{"name":"Product Name","value":'$name',"inline":false},{"name":"Style","value":'$style',"inline":false},{"name":"Size","value":'$size',"inline":false},{"name":"Profile","value":'||$profile||',"inline":false},{"name":"Email","value":'||$email||',"inline":false},{"name":"Proxy","value":'||$proxy||', "inline":false}]}]}
                                        });
                                    } catch (e) {}
                                    callback(Json.stringify({"response":{"status":response.statusCode}})); 
                                }
                            } else {
                                callback(null); 
                            }
                        } catch (e) {
                            callback(null); 
                        }
                    }
                } else {
                    callback(null); 
                }
            });
        } catch (e) {
            callback(null); 
        }
    }

    public static function jsonReturnValuesForKey(myKeyValue:String, myJSONString:String) {
        return Reflect.field(Json.parse(myJSONString), myKeyValue);
    }
}