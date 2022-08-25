import haxe.Json;
import haxe.Timer;
import js.Syntax; 
import modules.FootSites;
import haxe.crypto.Sha256; 
import utils.Security; 
import utils.Uuid;
import utils.Nonce;
import utils.Verify; 
import utils.Miscellaneous; 
import Fastify; 
import Mongodb;

class DeadLockerAPI {
    public static var sizeMap:Array<String> = ["01.0", "01.5", "02.0", "02.5", "03.0", "03.5", "04.0", "04.5", "05.0", "05.5", "06.0", "06.5", "07.0", "07.5", "08.0", "08.5", "09.0", "09.5", "10.0", "10.5", "11.0", "11.5", "12.0", "12.5", "13.0", "13.5", "14.0", "14.5", "15.0", "15.5", "16.0", "16.5", "17.0", "17.5", "18.0", "18.5", "19.0", "19.5", "20.0" ];
    public static var Discord = Syntax.code("require")("discord.js");
    public static var client = Syntax.code("new DeadLockerAPI.Discord.Client")();
    public static var url = 'mongodb+srv://DeadLockerAdmin:1ijZJze5j7y0jiVB@cluster0.ekqdp.mongodb.net';
    public static var dbName = 'DeadLocker';
    public static var collections:Array<String> = ['Licenses', 'Sessions', 'Keys', 'CheckOuts'];
    public static var licenses:Dynamic;
    public static var checkOuts:Dynamic;
    public static var sessions:Dynamic; 
    public static var keys:Dynamic;
    public static var adminToken = "3f8d40ad6a1d0038b8c334303fe06e70df25a1b78220855f6acc3aec951ffb3b";
    public static var monitorMap = [];
    public static var version = Sha256.encode("V1.5.0 Saturday, April 10th, 2021");
    var monitor = new Timer(1000 * 30);
    var filter = new Timer(1000 * 60);
    var host = '0.0.0.0';
    var port = 8080;

    static function main() {
        Mongodb.connect(url, function(error, client) {
            if (error != null) {
                //write(Colors.cyan.call('Failed to connect to MongoDB server at ') + Colors.underline.call(Colors.bold.call('$url'))); 
                Sys.exit(null);
            } else {
                var database = client.db(dbName);
                database.createCollection(collections[0], function(error, response) {
                    if (error != null) {
                        licenses = database.collection(collections[0]);
                        //write(Colors.cyan.call('Setting up ') + Colors.bold.call(collections[0]) + Colors.cyan.call(' collection on database ') + Colors.bold.call('$dbName')); 
                    } else {
                        licenses = database.collection(collections[0]);
                        //write(Colors.cyan.call('Collection ') + Colors.bold.call(collections[0]) + Colors.cyan.call(' created on database ') + Colors.bold.call('$dbName')); 
                    }
                });
                database.createCollection(collections[1], function(error, response) {
                    if (error != null) {
                        sessions = database.collection(collections[1]);
                        //write(Colors.cyan.call('Setting up ') + Colors.bold.call(collections[1]) + Colors.cyan.call(' collection on database ') + Colors.bold.call('$dbName')); 
                    } else {
                        sessions = database.collection(collections[1]);
                        //write(Colors.cyan.call('Collection ') + Colors.bold.call(collections[1]) + Colors.cyan.call(' created on database ') + Colors.bold.call('$dbName')); 
                    }
                });
                database.createCollection(collections[2], function(error, response) {
                    if (error != null) {
                        keys = database.collection(collections[2]);
                        //write(Colors.cyan.call('Setting up ') + Colors.bold.call(collections[2]) + Colors.cyan.call(' collection on database ') + Colors.bold.call('$dbName')); 
                    } else {
                        keys = database.collection(collections[2]);
                        //write(Colors.cyan.call('Collection ') + Colors.bold.call(collections[2]) + Colors.cyan.call(' created on database ') + Colors.bold.call('$dbName')); 
                    }
                });
                database.createCollection(collections[3], function(error, response) {
                    if (error != null) {
                        checkOuts = database.collection(collections[3]);
                        //write(Colors.cyan.call('Setting up ') + Colors.bold.call(collections[3]) + Colors.cyan.call(' collection on database ') + Colors.bold.call('$dbName')); 
                    } else {
                        checkOuts = database.collection(collections[3]);
                        //write(Colors.cyan.call('Collection ') + Colors.bold.call(collections[3]) + Colors.cyan.call(' created on database ') + Colors.bold.call('$dbName')); 
                    }
                });
                //write(Colors.cyan.call('Connected to MongoDB server at ') + Colors.underline.call(Colors.bold.call('$url'))); 
            }
        });
        new DeadLockerAPI();
    }

    public var server = Fastify.fastify({
        keepAliveTimeout: 15000,
        connectionTimeout: 15000,
        trustProxy: true
    });

    public function new() {
        filter.run = function() {
            updateSessions();
            updateNonceKeys();
            sessions.find({}).toArray(function(error, response) { 
                if (error != null || response == null) {
                    return; 
                } else {
                    for(i in 0...response.length) {
                        sessions.findOne({sessionId:response[i].sessionId}, function (error, user) {
                            if (user.idle) {
                                sessions.deleteOne({sessionId:response[i].sessionId}); 
                            }
                        }); 
                    }
                }
            });
        }
        
        monitor.run = function() {
            monitorMap = []; 
            Syntax.code("
            try {
                DeadLockerAPI.client.guilds.cache.get(\"841411716864540742\").channels.cache.find(ch => ch.name === 'log-alerts').messages.fetch({ limit: 100 }).then(messages => {
                    for (var x = 0; x < 100; x++) {
                        if (Date.now() - messages.array()[x].createdTimestamp <= 60000) {
                            DeadLockerAPI.monitorMap.push({sku:messages.array()[x].embeds[0].fields[1].value}); 
                        }
                    }
                });
            } catch (e) {
                console.log(\"Failed to fetch messages.\");
            }
            ");
        }

        server.get('/', function(request, response) {
            response.send("DeadLockerAPI | Copyright © 2020-2021 DeadLocker, LLC | All rights reserved.");
            return null;
        });

        server.get('/api/v1/user/ip', function(request, response) {
            response.send(request.ip);
            return null;
        });
        //check for updates
        server.get('/api/v1/user/check', function(request, response) {
            if (request.query.version == version) {
                response.send(true);
                return null; 
            } else {
                response.send(false); 
                return null;
            }
            return null;
        });
        
        server.get('/api/v1/user/instance', function(request, response) {
            var time = Date.now();
            var h = time.getHours();
            h = ((h + 11) % 12 + 1); 
            var i:String = Std.string(h); 
            if (h < 10) { i = "0" + i; }
            var key = Verify.createKey().toHex();
            return keys.insertOne({key:key, time:Date.now().getTime()}, function (error, res) {
                response.send(Json.stringify({"success":true, "1":key, "2":DateTools.format(time, "%m:%d:" + i + ":%M:%S:%Y")}));
                //write(Colors.cyan.call('Successfully created key ')  + Colors.bold.call(key));
            });
        }); 

        server.post('/api/v1/user/test/webhook', function (request, response) {
            try {
                var body = Json.parse(Std.string(Security.APIPrivateKey.decrypt(request.body, 'utf8')));
                if (request.query.key == null) {
                    response.send(null);
                    return null;
                }
                return sessions.findOne({"sessionId":body.ddlkr}, function (error, sessionUser) { 
                    if (error != null || sessionUser == null) {
                        response.send(null);
                    } else {
                        keys.findOne({"key":request.query.key}, function (error, info) {
                            if (error != null || info == null) {
                                response.send(null);
                                //write(Colors.cyan.call('Verification for key ') + Colors.bold.call(request.query.key) + Colors.cyan.call(' was unsuccessful, key does not exist.'));
                            } else if (!Verify.nonce(body.nonce, info.key)) {
                                response.send(null);
                                //write(Colors.cyan.call('Invalid nonce'));
                            } else {
                                Miscellaneous.webhook(body.webhook, function(data) {
                                    sessions.updateOne({sessionId:body.ddlkr}, {$set:{expiryTime:DateTools.delta(Date.now(), 1000 * 60 * 10).getTime()}});
                                    response.send(data); 
                                });
                            }
                        }); 
                    }
                }); 
            } catch (e) {
                response.send(null);
                return null;
            }
        });
        //FOOTSITE ENDPOINTS 
        //monitor
        server.post('/api/v1/footsites/monitor', function(request, response) {
            try {
                var body = Json.parse(request.body);
                var encryptedBody = Json.parse(Std.string(Security.APIPrivateKey.decrypt(body.encrypted, 'utf8')));
                if (request.query.key == null) {
                    response.send(null);
                    return null;
                }
                return sessions.findOne({"sessionId":encryptedBody.ddlkr}, function (error, sessionUser) {
                    if (error != null || sessionUser == null) {
                        response.send(null);
                    } else {
                        keys.findOne({"key":request.query.key}, function (error, info) {
                            if (error != null || info == null) {
                                response.send(null);
                                //write(Colors.cyan.call('Verification for key ') + Colors.bold.call(request.query.key) + Colors.cyan.call(' was unsuccessful, key does not exist.'));
                            } else if (!Verify.monitorNonce(encryptedBody.nonce, info.key)) {
                                response.send(null);
                                //write(Colors.cyan.call('Invalid nonce'));
                            } else {
                                var found = false; 
                                for (n in 0...body.sku.length) {
                                    for (i in 0...monitorMap.length) {
                                        if (body.sku[n] == monitorMap[i].sku) {
                                            found = true;
                                            sessions.updateOne({sessionId:encryptedBody.ddlkr}, {$set:{expiryTime:DateTools.delta(Date.now(), 1000 * 60 * 10).getTime()}});
                                            response.send(Json.stringify({"response":{"status":200, "sku":body.sku[n]}})); 
                                            break; 
                                        }
                                    }
                                }
                                if (!found) {
                                    sessions.updateOne({sessionId:encryptedBody.ddlkr}, {$set:{expiryTime:DateTools.delta(Date.now(), 1000 * 60 * 10).getTime()}});
                                    response.send(Json.stringify({"response":{"status":400}})); 
                                }
                            }
                        });
                    }
                });
            } catch (e) { 
                response.send(null);
                return null;
            }
        });
        //gets session
        server.post('/api/v1/footsites/session', function(request, response) {
            try {
                var body = Json.parse(Std.string(Security.APIPrivateKey.decrypt(request.body, 'utf8')));
                return sessions.findOne({"sessionId":body.ddlkr}, function (error, sessionUser) { 
                    if (error != null || sessionUser == null) {
                        response.send(null);
                    } else {
                        FootSites.getSession(body.site, body.queuecookie, body.proxy, function(data) { //add session 
                            sessions.updateOne({sessionId:body.ddlkr}, {$set:{expiryTime:DateTools.delta(Date.now(), 1000 * 60 * 10).getTime()}});
                            response.send(data); 
                        });
                    }
                });
            } catch (e) {
                response.send(null);
                return null;
            }
        }); 
        //get product id and shoe size
        server.post('/api/v1/footsites/product', function(request, response) {
            try {
                var body = Json.parse(Std.string(Security.APIPrivateKey.decrypt(request.body, 'utf8')));
                var currentSizes:Array<String> = [];
                for (i in 0...DeadLockerAPI.sizeMap.length) {
                    if (body.size.split('-')[0] == DeadLockerAPI.sizeMap[i]) {
                        for (b in i...DeadLockerAPI.sizeMap.length) {
                            currentSizes.push(DeadLockerAPI.sizeMap[b]); 
                            if (body.size.split('-')[1] == DeadLockerAPI.sizeMap[b]) {
                                break; 
                            }
                        }
                    }
                }
                return sessions.findOne({"sessionId":body.ddlkr}, function (error, sessionUser) { 
                    if (error != null || sessionUser == null) {
                        response.send(null);
                    } else {
                        FootSites.getProductInfo(body.site, body.queuecookie, body.proxy, body.sku, currentSizes, body.color, function(data) {
                            sessions.updateOne({sessionId:body.ddlkr}, {$set:{expiryTime:DateTools.delta(Date.now(), 1000 * 60 * 30).getTime()}});
                            response.send(data); 
                        }); 
                    }
                }); 
            } catch (e) {
                response.send(null);
                return null;
            }
        }); 
        //adds to cart
        server.post('/api/v1/footsites/atc', function(request, response) {
            try {
                var body = Json.parse(Std.string(Security.APIPrivateKey.decrypt(request.body, 'utf8')));
                return sessions.findOne({"sessionId":body.ddlkr}, function (error, sessionUser) { 
                    if (error != null || sessionUser == null) {
                        response.send(null);
                    } else {
                        FootSites.addToCart(body.site, body.queuecookie, body.proxy, body.product, body.session, function(data) {
                            sessions.updateOne({sessionId:body.ddlkr}, {$set:{expiryTime:DateTools.delta(Date.now(), 1000 * 60 * 10).getTime()}});
                            response.send(data); 
                        }); 
                    }
                });
            } catch (e) {
                response.send(null);
                return null;
            }
        }); 
        //authorizes the session
        server.post('/api/v1/footsites/auth', function(request, response) {
            try {
                var body = Json.parse(request.body);
                var encryptedBody = Json.parse(Std.string(Security.APIPrivateKey.decrypt(body.encrypted, 'utf8')));
                return sessions.findOne({"sessionId":encryptedBody.ddlkr}, function (error, sessionUser) { 
                    if (error != null || sessionUser == null) {
                        response.send(null);
                    } else {
                        FootSites.authSession(encryptedBody.site, body.queuecookie, encryptedBody.proxy, encryptedBody.guid, encryptedBody.session, encryptedBody.csrf, encryptedBody.email, function(data) {
                            response.send(data); 
                        });
                    }
                });
            } catch (e) {
                response.send(null);
                return null;
            }
        }); 
        //sets shipping info 
        server.post('/api/v1/footsites/shipping', function(request, response) {
            try {
                var body = Json.parse(request.body);
                var encryptedBody = Json.parse(Std.string(Security.APIPrivateKey.decrypt(body.encrypted, 'utf8')));
                return sessions.findOne({"sessionId":encryptedBody.ddlkr}, function (error, sessionUser) { 
                    if (error != null || sessionUser == null) {
                        response.send(null);
                    } else {
                        FootSites.setShipping(body.site, body.queuecookie, encryptedBody.proxy, body.guid, body.session, body.csrf, body.firstname, body.lastname, body.stateName, body.statecode, body.streetone, body.streettwo, body.city, body.zipcode, body.phonenumber, function(data) {
                            response.send(data); 
                        });
                    }
                }); 
            } catch (e) {
                response.send(null);
                return null;
            }
        });
        //sets billing info 
        server.post('/api/v1/footsites/billing', function(request, response) {
            try {
                var body = Json.parse(request.body);
                var encryptedBody = Json.parse(Std.string(Security.APIPrivateKey.decrypt(body.encrypted, 'utf8')));
                return sessions.findOne({"sessionId":encryptedBody.ddlkr}, function (error, sessionUser) { 
                    if (error != null || sessionUser == null) {
                        response.send(Json.stringify({"success":false}));
                    } else {
                        FootSites.setBilling(body.site, body.queuecookie, encryptedBody.proxy, body.guid, body.session, body.csrf, body.firstname, body.lastname, body.stateName, body.statecode, body.streetone, body.streettwo, body.city, body.zipcode, body.phonenumber, function(data) {
                            response.send(data); 
                        });
                    }
                }); 
            } catch (e) {
                response.send(null);
                return null;
            }
        }); 
        //place order
        server.post('/api/v1/footsites/order', function(request, response) {
            try {
                var body = Json.parse(request.body);
                var encryptedBody = Json.parse(Std.string(Security.APIPrivateKey.decrypt(body.encrypted, 'utf8')));
                return sessions.findOne({"sessionId":encryptedBody.ddlkr}, function (error, sessionUser) { 
                    if (error != null || sessionUser == null) {
                        response.send(null);
                    } else {
                        FootSites.placeOrder(body.site, body.webhook, body.profile, body.email, body.name, body.picture, body.style, body.size, body.queuecookie, encryptedBody.proxy, encryptedBody.guid, encryptedBody.session, encryptedBody.csrf, encryptedBody.cardnumber, encryptedBody.cvc, encryptedBody.holdername, encryptedBody.expirymonth, encryptedBody.expiryyear,  function(data) {
                            sessions.updateOne({sessionId:encryptedBody.ddlkr}, {$set:{expiryTime:DateTools.delta(Date.now(), 1000 * 60 * 10).getTime()}});
                            try {
                                if (Json.parse(data).response.status == 201) {
                                    checkOuts.insertOne({site:Json.parse(data).response.site, email:body.email, order:Json.parse(data).response.order, shoe:body.name, price:Json.parse(data).response.price, time:Date.now().toString()}, function (error, res) {
                                        response.send(data); 
                                    });
                                } else {
                                    response.send(data); 
                                }
                            } catch (e) {
                                response.send(null); 
                            }
                        });
                    }
                }); 
            } catch (e) {
                response.send(null);
                return null;
            }
        }); 

        server.post('/api/v1/user/license', function(request, response) {
            try {
                var payload = Json.parse(request.body); 
                var body = Json.parse(Std.string(Security.APIPrivateKey.decrypt(payload.encrypted, 'utf8')));
                updateSessions();
                updateNonceKeys();
                if (payload.encryptedLicense == null && body.license == null || body.hwid== null || body.ip == null || body.nonce == null || request.query.key == null) {
                    response.send(Json.stringify({"success":false}));
                    return null;
                }
                try { if (payload.encryptedLicense != null) { body.license = Std.string(Security.APIPrivateKey.decrypt(payload.encryptedLicense, 'utf8')); } } catch (e) {}; 
                return keys.findOne({"key":request.query.key}, function (error, info) {
                    if (error != null || info == null) {
                        response.send(Json.stringify({"success":false}));
                        //write(Colors.cyan.call('Verification for key ') + Colors.bold.call(request.query.key) + Colors.cyan.call(' was unsuccessful, key does not exist.'));
                    } else if (!Verify.nonce(body.nonce, info.key)) {
                        response.send(Json.stringify({"success":false}));
                        //write(Colors.cyan.call('Invalid nonce'));
                    } else {
                        licenses.findOne({"license":body.license}, function (error, user) {
                            if (error != null || user == null) {
                                response.send(Json.stringify({"success":false, "code":1}));
                                //write(Colors.cyan.call('Verification for license ') + Colors.bold.call(body.license) + Colors.cyan.call(' was unsuccessful, license does not exist.'));
                            } else if ((body.hwid != user.hwid && user.registered && user.binded ) || (body.ip != user.ip && user.registered && user.binded)) {
                                response.send(Json.stringify({"success":false, "code":2}));
                                //write(Colors.cyan.call('Validation for machine ') + Colors.bold.call(body.hwid) + Colors.cyan.call(' was unsuccessful, license ') + Colors.bold.call(user.license) + Colors.cyan.call(' is not registered to this machine.'));
                            } else if (!user.binded && user.registered) {
                                sessions.findOne({"license":body.license}, function (error, sessionUser) { 
                                    if (error != null || sessionUser == null) {
                                        if (Date.now().getTime() > user.expiryDate) {
                                            if (!user.expired) {
                                                licenses.updateOne({license:user.license}, {$set:{expired:true}}, function(err, res) {
                                                    response.send(Json.stringify({"success":false, "code":6}));
                                                    //write(Colors.cyan.call("License ") + Colors.bold.call(user.license) + Colors.cyan.call(" has expired.")); 
                                                });
                                            } else {
                                                response.send(Json.stringify({"success":false, "code":6}));
                                            }
                                        } else {
                                            licenses.findOne({"hwid":body.hwid}, function (error, res) {
                                                if (error != null || res == null) {
                                                    licenses.findOne({"ip":body.ip}, function (error, res) {
                                                        if (error != null || res == null) {
                                                            licenses.updateOne({license:user.license}, {$set:{hwid:body.hwid, ip:body.ip, binded:true}}, function(err, res) {
                                                                var session = Uuid.generate(); 
                                                                sessions.insertOne({license:user.license, sessionId:session,  hwid:body.hwid, ip:body.ip, expiryTime:DateTools.delta(Date.now(), 1000 * 60 * 10).getTime(), idle:false}, function (error, res) {
                                                                    response.send(Json.stringify({"success":true, "session":session, "code":3}));
                                                                    //write(Colors.cyan.call('Successfully created session ')  + Colors.bold.call(session));
                                                                    //write(Colors.cyan.call('Successfully rebinded license ') + Colors.bold.call(user.license) + Colors.cyan.call(" to machine ") + Colors.bold.call(body.hwid));
                                                                });
                                                            });
                                                        } else {
                                                            response.send(Json.stringify({"success":false, "code":11}));
                                                        }
                                                    }); 
                                                } else {
                                                    response.send(Json.stringify({"success":false, "code":11}));
                                                }
                                            }); 
                                        }
                                    } else {
                                        response.send(Json.stringify({"success":false, "code":10}));
                                        //write(Colors.cyan.call("Failed to validate user ") + Colors.bold.call(user.hwid) + Colors.cyan.call(" session ") + Colors.bold.call(sessionUser.sessionId) + Colors.cyan.call(" is in use.")); 
                                    }
                                }); 
                            } else if (!user.registered) {
                                licenses.findOne({"hwid":body.hwid}, function (error, res) {
                                    if (error != null || res == null) {
                                        licenses.findOne({"ip":body.ip}, function (error, res) {
                                            if (error != null || res == null) {
                                                licenses.updateOne({license:user.license}, {$set:{hwid:body.hwid, ip:body.ip, dateRegistered:Date.now().getTime(), expiryDate:DateTools.delta(Date.now(), 24 * 60 * 60 * 1000 * 30).getTime(), registered:true, binded:true}}, function(err, res) {
                                                    var session = Uuid.generate(); 
                                                    sessions.insertOne({license:user.license, sessionId:session,  hwid:body.hwid, ip:body.ip, expiryTime:DateTools.delta(Date.now(), 1000 * 60 * 10).getTime(), idle:false}, function (error, res) {
                                                        response.send(Json.stringify({"success":true, "session":session, "code":3}));
                                                        //write(Colors.cyan.call('Successfully created session ')  + Colors.bold.call(session));
                                                        //write(Colors.cyan.call('Successfully registered license ') + Colors.bold.call(user.license) + Colors.cyan.call(" on machine ") + Colors.bold.call(body.hwid));
                                                    });
                                                });
                                            } else {
                                                response.send(Json.stringify({"success":false, "code":11}));
                                            }
                                        }); 
                                    } else {
                                        response.send(Json.stringify({"success":false, "code":11}));
                                    }
                                }); 
                            } else {
                                sessions.findOne({"license":body.license}, function (error, sessionUser) { 
                                    if (error != null || sessionUser == null) {
                                        if (Date.now().getTime() > user.expiryDate) {
                                            if (!user.expired) {
                                                licenses.updateOne({license:user.license}, {$set:{expired:true}}, function(err, res) {
                                                    response.send(Json.stringify({"success":false, "code":6}));
                                                    //write(Colors.cyan.call("License ") + Colors.bold.call(user.license) + Colors.cyan.call(" has expired.")); 
                                                });
                                            } else {
                                                response.send(Json.stringify({"success":false, "code":6}));
                                            }
                                        } else {
                                            var session = Uuid.generate();
                                            sessions.insertOne({license:user.license, sessionId:session,  hwid:user.hwid, ip:body.ip, expiryTime:DateTools.delta(Date.now(), 1000 * 60 * 10).getTime(), idle:false}, function (error, res) {
                                                response.send(Json.stringify({"success":true, "session":session, "code":4}));
                                                //write(Colors.cyan.call('Successfully created session ')  + Colors.bold.call(session));
                                                //write(Colors.cyan.call('Successfully validated machine ') + Colors.bold.call(user.hwid) + Colors.cyan.call(" to use license ") + Colors.bold.call(user.license)); 
                                            });
                                        }
                                    } else {
                                        response.send(Json.stringify({"success":false, "code":5}));
                                        //write(Colors.cyan.call("Failed to validate user ") + Colors.bold.call(user.hwid) + Colors.cyan.call(" session ") + Colors.bold.call(sessionUser.sessionId) + Colors.cyan.call(" is in use.")); 
                                    }
                                }); 
                            }
                        }); 
                    }
                }); 
            } catch (e) {
                response.send(Json.stringify({"success":false}));
                //write(Colors.cyan.call(Colors.bold.call('Suspicious request detected'))); // for ip 
                return;
            }
        });
        
        server.post('/api/v1/user/license/info', function (request, response) {
            try {
                var payload = Json.parse(request.body); 
                var body =  Json.parse(Std.string(Security.APIPrivateKey.decrypt(payload.encrypted, 'utf8')));
                updateSessions();
                updateNonceKeys();
                if (payload.encryptedLicense == null || body.hwid == null || body.ip == null || body.session == null  || body.nonce == null || request.query.key == null) {
                    response.send(Json.stringify({"success":false}));
                    return null;
                }
                try { body.license = Std.string(Security.APIPrivateKey.decrypt(payload.encryptedLicense, 'utf8')); } catch (e) {};
                return keys.findOne({"key":request.query.key}, function (error, info) {
                    if (error != null || info == null) {
                        response.send(Json.stringify({"success":false}));
                        //write(Colors.cyan.call('Verification for key ') + Colors.bold.call(request.query.key) + Colors.cyan.call(' was unsuccessful, key does not exist.'));
                    } else if (!Verify.nonce(body.nonce, info.key)) {
                        response.send(Json.stringify({"success":false}));
                        //write(Colors.cyan.call('Invalid nonce'));
                    } else {
                        sessions.findOne({"sessionId":body.session}, function (error, sessionUser) { 
                            if (error != null || sessionUser == null) {
                                response.send(Json.stringify({"success":false, "code":7}));
                            } else if (sessionUser.ip != body.ip || sessionUser.hwid != body.hwid) {
                                response.send(Json.stringify({"success":false, "code":5}));
                            } else {
                                licenses.findOne({"license":body.license}, function (error, user) {
                                    if (error != null || user == null) {
                                        response.send(Json.stringify({"success":false, "code":1}));
                                        //write(Colors.cyan.call('Search for license ') + Colors.bold.call(body.license) + Colors.cyan.call(' was unsuccessful, license does not exist.'));
                                    } else {
                                        if (Date.now().getTime() > user.expiryDate) {
                                            if (!user.expired) {
                                                licenses.updateOne({license:user.license}, {$set:{expired:true}}, function(err, res) {
                                                    sessions.deleteOne({"sessionId":body.session});
                                                    response.send(Json.stringify({"success":false, "code":6}));
                                                    //write(Colors.cyan.call("License ") + Colors.bold.call(user.license) + Colors.cyan.call(" has expired.")); 
                                                });
                                            } else {
                                                response.send(Json.stringify({"success":false, "code":6}));
                                            }
                                        } else {
                                            response.send(Json.stringify({"success":true, "license":user.license, "registered":Date.fromTime(user.dateRegistered), "expiry":Date.fromTime(user.expiryDate), "code":8}));
                                            //write(Colors.cyan.call('Successfully found info for license ') + Colors.bold.call(user.license)); 
                                        }
                                    }
                                }); 
                            }
                        });
                    }
                }); 
            } catch (e) {
                response.send(Json.stringify({"success":false}));
                //write(Colors.cyan.call(Colors.bold.call('Suspicious request detected'))); // for ip 
                return;
            }
        }); 

        server.post('/api/v1/user/license/unbind', function (request, response) {
            try {
                var payload = Json.parse(request.body); 
                var body = Json.parse(Std.string(Security.APIPrivateKey.decrypt(payload.encrypted, 'utf8')));
                updateSessions();
                updateNonceKeys();
                if (payload.encryptedLicense == null || body.hwid == null || body.ip == null || body.session == null  || body.nonce == null) {
                    response.send(Json.stringify({"success":false}));
                    return null;
                }
                if (request.query.key == null) {
                    response.send(Json.stringify({"success":false}));
                    return null;
                }
                try { body.license = Std.string(Security.APIPrivateKey.decrypt(payload.encryptedLicense, 'utf8')); } catch (e) {};
                return sessions.findOne({"sessionId":body.session}, function (error, sessionUser) { 
                    if (error != null || sessionUser == null) {
                        response.send(Json.stringify({"success":false, "code":7}));
                    } else if (sessionUser.ip != body.ip || sessionUser.hwid != body.hwid) {
                        response.send(Json.stringify({"success":false, "code":5}));
                    } else {
                        keys.findOne({"key":request.query.key}, function (error, info) {
                            if (error != null || info == null) {
                                response.send(Json.stringify({"success":false}));
                                //write(Colors.cyan.call('Verification for key ') + Colors.bold.call(request.query.key) + Colors.cyan.call(' was unsuccessful, key does not exist.'));
                            } else if (!Verify.nonce(body.nonce, info.key)) {
                                response.send(Json.stringify({"success":false}));
                                //write(Colors.cyan.call('Invalid nonce'));
                            } else {
                                licenses.findOne({"license":body.license}, function (error, user) {
                                    if (error != null || user == null) {
                                        response.send(Json.stringify({"success":false, "code":1}));
                                        //write(Colors.cyan.call('Search for license ') + Colors.bold.call(body.license) + Colors.cyan.call(' was unsuccessful, license does not exist.'));
                                    } else {
                                        if (Date.now().getTime() > user.expiryDate) {
                                            if (!user.expired) {
                                                licenses.updateOne({license:user.license}, {$set:{expired:true}}, function(err, res) {
                                                    sessions.deleteOne({"sessionId":body.session});
                                                    response.send(Json.stringify({"success":false, "code":6}));
                                                    //write(Colors.cyan.call("License ") + Colors.bold.call(user.license) + Colors.cyan.call(" has expired.")); 
                                                });
                                            } else {
                                                response.send(Json.stringify({"success":false, "code":6}));
                                            }
                                        } else { 
                                            sessions.updateOne({sessionId:body.session}, {$set:{expiryTime:DateTools.delta(Date.now(), 1000 * 60 * 5).getTime()}}, function(err, res) {
                                                licenses.updateOne({license:user.license}, {$set:{hwid:"", ip:"", binded:false}}, function(err, res) {
                                                    response.send(Json.stringify({"success":true, "code":9}));
                                                    //write(Colors.cyan.call('Successfully unbinded license ') + Colors.bold.call(user.license) + Colors.cyan.call(" from machine ") + Colors.bold.call(body.hwid));
                                                });
                                            });
                                        }
                                    }  
                                }); 
                            }
                        });
                    }
                });
            } catch (e) {
                response.send(Json.stringify({"success":false}));
                //write(Colors.cyan.call(Colors.bold.call('Suspicious request detected'))); // for ip 
                return;
            }
        }); 

        server.post('/api/v1/87ddebd39ad55bd1178703039f39f5a877ae2034e58911345f384787c103863b/renew', function (request, response) {
            try {
                var body = Json.parse(Std.string(Security.APIPrivateKey.decrypt(request.body, 'utf8')));
                updateSessions();
                updateNonceKeys();
                if (body.license == null || body.nonce == null || request.query.key == null || body.auth == null || body.auth != adminToken) {
                    response.send(Json.stringify({"success":false, "code":403}));
                    return null;
                }
                return keys.findOne({"key":request.query.key}, function (error, info) {
                    if (error != null || info == null) {
                        response.send(Json.stringify({"success":false, "code":403}));
                        //write(Colors.cyan.call('Verification for key ') + Colors.bold.call(request.query.key) + Colors.cyan.call(' was unsuccessful, key does not exist.'));
                    } else if (!Verify.nonce(body.nonce, info.key)) {
                        response.send(Json.stringify({"success":false, "code":403}));
                        //write(Colors.cyan.call('Invalid nonce'));
                    } else {
                        licenses.findOne({"license":body.license}, function (error, user) {
                            if (error != null || user == null) {
                                response.send(Json.stringify({"success":false, "code":405}));
                                //write(Colors.cyan.call('Search for license ') + Colors.bold.call(body.license) + Colors.cyan.call(' was unsuccessful, license does not exist.'));
                            } else {
                                if (user.expired) {
                                    licenses.updateOne({license:user.license}, {$set:{expiryDate:DateTools.delta(Date.now(), 24 * 60 * 60 * 1000 * 30).getTime(), expired:false}}, function(err, res) {
                                        response.send(Json.stringify({"success":true, "code":200}));
                                        //write(Colors.cyan.call('Successfully renewed license ') + Colors.bold.call(user.license));
                                    });
                                } else {
                                    response.send(Json.stringify({"success":false, "code":400}));
                                }
                            }  
                        });
                    } 
                });
            } catch (e) {
                response.send(Json.stringify({"success":false, "code":500}));
                //write(Colors.cyan.call(Colors.bold.call('Suspicious request detected'))); // for ip 
                return;
            }
        }); 

        server.post('/api/v1/778069ac34596bb178be6e40299994d3e66b683f19ecc08a333b924d0ed8885a/create', function(request, response) {
            try {
                var body = Json.parse(Std.string(Security.APIPrivateKey.decrypt(request.body, 'utf8')));
                trace(request.body); 
                updateSessions();
                updateNonceKeys();
                if (body.license == null || body.auth == null || body.auth != adminToken || request.query.key == null) {
                    response.send(Json.stringify({"success":false, "code":403}));
                    return null;
                }
                return keys.findOne({"key":request.query.key}, function (error, info) {
                    if (error != null || info == null) {
                        response.send(Json.stringify({"success":false, "code":403}));
                        //write(Colors.cyan.call('Verification for key ') + Colors.bold.call(request.query.key) + Colors.cyan.call(' was unsuccessful, key does not exist.'));
                    } else if (!Verify.nonce(body.nonce, info.key)) {
                        response.send(Json.stringify({"success":false, "code":403}));
                        //write(Colors.cyan.call('Invalid nonce'));
                    } else {
                        licenses.findOne({"license":body.license}, function (error, user) {
                            if (error != null || user != null) {
                                response.send(Json.stringify({"success":false, "code":400}));
                                //write(Colors.cyan.call('Error creating license ') +  Colors.bold.call(body.license) + Colors.cyan.call(' perhaps license is already exists?'));
                            } else {
                                licenses.insertOne({license:body.license, hwid:"", ip:"", dateRegistered:"", expiryDate:"", registered:false, binded:false, expired:false}, function (error, res) {
                                    response.send(Json.stringify({"success":true, "code":200}));
                                    //write(Colors.cyan.call('Successfully created license ')  + Colors.bold.call(body.license));
                                });
                            }
                        }); 
                    }
                }); 
            } catch (e) {
                response.send(Json.stringify({"success":false, "code":500}));
                //write(Colors.cyan.call(Colors.bold.call('Suspicious request detected'))); // for ip 
                return;
            } 
        });

        server.listen(port, host, function(error, address) {
            if (error != null) {
                //write(Colors.cyan.call('Failed to listen on port ') + Colors.bold.call('$port') + Colors.cyan.call(', is the port occupied? or under the value ') + Colors.bold.call('65536') + Colors.cyan.call('?'));
                Sys.exit(null);
            }
            trace(Security.APIPrivateKey.exportKey('pkcs8')); 
            //Sys.command("cls"); 
            //Syntax.code("process").title = '$address'; 
            client.login('ODI5MjMxNDA1OTUxMjIxNzcx.YG1H7Q.eu4fAdrAz1HPfj7JM7Pyp-GNXt0');
            //write(Colors.cyan.call(Colors.bold.call('Copyright © 2020 DeadLocker.')) + Colors.cyan.call(' Listening on ') + Colors.underline.call(Colors.bold.call('$address'))); 
        }); 
    }

    public function updateNonceKeys() { //check all entires in keys and delete expired ones 
        keys.find({}).toArray(function(error, response) { 
            if (error != null || response == null) {
                return; 
            } else {
                for (i in 0...response.length) {
                    keys.findOne({key:response[i].key}, function (error, user) {
                        if (error != null || user == null) {
                            return; 
                        } else {
                            if (Date.now().getTime() - user.time > 10000) {
                                keys.deleteOne({key:response[i].key}); 
                            }
                        }
                    }); 
                }
            }
        });
    } 

    public function updateSessions() { //make this check all entries in sessions and set them to idle 
        sessions.find({}).toArray(function(error, response) { 
            if (error != null || response == null) {
                return; 
            } else {
                for (i in 0...response.length) {
                    sessions.findOne({sessionId:response[i].sessionId}, function (error, user) {
                        if (error != null || user == null) {
                            return; 
                        } else {
                            if (Date.now().getTime() > user.expiryTime) {
                                sessions.updateOne({sessionId:response[i].sessionId}, {$set:{idle:true}});
                            }
                        }
                    }); 
                }
            }
        });
    } 

    /*public static function write(string:String) {
        var time = Date.now();
        var h = time.getHours();
        var m = time.getMinutes(); 
        var s = time.getSeconds(); 
        h = ((h + 11) % 12 + 1); 
        var i:String = Std.string(h); 
        if (h < 10) { i = "0" + i; }
        Syntax.code("console").log(Colors.cyan.call('[') + Colors.bold.call('$h') + Colors.cyan.call(':') + Colors.bold.call('$m') + Colors.cyan.call(':') + Colors.bold.call('$s') + Colors.cyan.call('] ') + string); 
     }*/
}