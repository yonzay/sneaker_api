package utils;

import Node_rsa;

class Security {
    public static var APIPrivateKey = new Node_rsa("-----BEGIN PRIVATE KEY-----\n" +
                    "MIIJQwIBADANBgkqhkiG9w0BAQEFAASCCS0wggkpAgEAAoICAQDwvfzeoNgZP70a\n" +
                    "mJL3V8Qq3HVG520Pp4KbKpMobuT8alhBlvy02PTxTqvI3r0p8d5y8HEM0bmCedmf\n" +
                    "qZOtFZTEVE9hQcjDIvcto/+2XndAECCFwkGn++S7PDfWvvA0YuAlGAfAZILL+KTA\n" +
                    "785azXdnGeLTznrqLkBupc0GSV+L6z3VYBysDgXvmleco7ZaSPGXQMIqJigEqyON\n" +
                    "DL2MdO+9FOAAA0UapflaFjADn/wIEKTIKRxcjZ+lOMCuAga2EHtee1q8j04gqIxN\n" +
                    "h1aj8isr+CY4n+63XR+4n6kpGqsdYkA6GQJjE0vaGdyhxgiaAsMtezmovOi9CMlE\n" +
                    "W+5N7MKzYzjAnPpZp7S3MgnLjJBOxWcLxl00SlH+MHULOq6QscD8Y8hDaPGjfq4V\n" +
                    "2SzhOigrmOucWJ4hGyJ/dZLiqOMhO8qX2SYXHGK65diqXECRkYe1VTnbayYfXhQN\n" +
                    "QEiuY1+d7vOaH2IOvbRtnn4zVAa21mUhtJz9MqtjplQhJj5+7vjoc0Nc0tqvuReG\n" +
                    "UCyfWDFW+mWkSa0/T84ikKtw1Ywk1I3n7IAtYD0BSfTR6ln4aVjyAdpaeIiged+X\n" +
                    "jDzv1eOU65qiYGjjCUXO8JK23Rbcyym1375Ep8hfkEpAod0bJRodxPuoiPIBiUpA\n" +
                    "ColyOcpnRU95p+oTLccvvZtC7pPAfwIDAQABAoICAAn92KDkzBNAMfkInBDn85xT\n" +
                    "ygpHUJ91tFX8Tl8/OwG+6CrQuWxIFOJvAXI0zGURRMpAcHC3w5tGs2GNCDQG0UXU\n" +
                    "ufavZEW1Dc03IUXQZeKiyLbEeTUfnz6mISsogY+rCuJ/PNMfWM5eY3gee9II9Quy\n" +
                    "Z1ejGjbd9I6jEv9PzEdiXA6fDpGVg2mOXlSB9u+IV36PkX9uVfrbn34bKULLF6gh\n" +
                    "VaqqeBPDD7ZNdXCxEyTCjBRCoIq21gllcZnHO8ASrwwc0odA610voaMWGuJzCpeo\n" +
                    "lO2EtcOmecqP1dV+5dsyWLgQkajLBDrpF98e+PxrYO5iTuJR9NbjpnbP2fQh/3Kd\n" +
                    "7zpNTBGzU/u4HoFYNhRqpq5Q2HfOGR9YKYyNWHpvR6s27pC/qWbKnoyf0iH1y/YU\n" +
                    "lPR1sP9bFa0TWRCfjOugE4xIelECKPgwxKeZk+wsL51SLq20ONbjFWf0esEAjwM1\n" +
                    "ZnmcL5xL5A7FIms8N6lrTwPX9r/5KyNr2u5/Jm8VACsUDJVMYnFMZVV9ojaWAGjp\n" +
                    "3HYO69mXsQ88AsY80HeVllvaqiL6LwyhUginrDQzc1C42IlyPagBVN5sMpzuqrRP\n" +
                    "jCYp3CMEBBWAFsYlRDp4RPWHr71RVlnLz7xCmXr8TXSDpqH6VIxYgG6NK64nnrMa\n" +
                    "bF2u9OppagTMzksqjKUBAoIBAQD9HMPxa9Eo2kYLCBo9gvUbjB8vEQVGGHh30yCj\n" +
                    "a2SI0lpC89SBc+0l+fxnYu5bBQ7hsNUkqW41xLVmB8z71VD3cbX3nmeo4YtKvqXw\n" +
                    "2o0csZhN6Yf85UsvrDhyf7J7pzCXLvy7o4E+J8PF8KXynhzrHo55CbzRcrLSBSP6\n" +
                    "ModFr4JkSXf57fDXuzECmPY8pe2V2KAXMACQUUqcANegjJeD6ns9Vld1QSLPDq4+\n" +
                    "xFzrelilVF9fM5Ertl/DPVob9DipcmevC7/GKrsyZVWvsd5p0jFGRF35lJRho5dL\n" +
                    "0Q8mfN9Bdifn7KHTGRQrA0KpQ8Nbq8tK7SlhXQ6e9Pu+CuilAoIBAQDzfRgaZHZ7\n" +
                    "TnwPdME9yeclzIb9DyJZ+QKWqoIJPGqtQHgYYUNmiSbow/t68O8dEu9896sYVhsr\n" +
                    "q1PAqNQcuG6q0zOSml53FUtNF7lKsMUy+VwbREofVN2ZrBAb1gVhsgyNEYIIhgln\n" +
                    "bAlbc+rfoUtVZkdIIZAy/8nFZ51aQ9n5K0YJvMdkPkgGYi3e7BxJkYmONa7L6N4J\n" +
                    "x3xfZR3DbRFDR24YAueU9TRH0yFANZ6JNYwrdrTQYaX9IzevTQgNi7Eg/AVr4HGN\n" +
                    "u0+V3nyn5oY9QSMIal8MukZ2CUo+6yUM4O6ZD4OM1I6r9EWy4/2PUOzXnmaFZvL9\n" +
                    "sRLsqgugvZdTAoIBAQD1ZlJDWzkq1pVaVLy8Lp/d2XjSdTobv9XstvHJ/3E1hlyk\n" +
                    "1SqPaAng7AJfaneWH81R29SK+wozb0hAaAfBkgwyHDlEnnv6LNKT4UuZvQtbaoQz\n" +
                    "5dtGwjinO95uhIhTgsGFkrTOZ7QCwyL4Yl1CYTHAc5vGlj5PA1mEbh93kE2+rm9J\n" +
                    "NEHyO1Nqlb7qucri+izjP2fXk164jVg88EQfELBF4a0ixvd8Y26QObeOe2trku8n\n" +
                    "PCpLbv+s1eD6th0LRTk6cAU+nbGNPBjKv5zX/yeYiYXkjpxeQkOqdqVViJebxS3f\n" +
                    "leMS5UXwGTyIh1y2J1DdLC6psk6Qa1ylmPgKRSFRAoIBAHlSmIL2Ee9I4RoWc/8k\n" +
                    "rk8wRQas1tH7+GU4WojdmM3w9KY5OItLxZ5voMvWZ16WQ8yB37fFl84/lQDHXsFc\n" +
                    "yI/HosfmsTEm5Blqu8HSqL/IbjOL6F8KO0zJ5lDoaFAQlp5n3eH/X4ov083EyYBa\n" +
                    "bx4DU3tGdgJjX5dEFKyYaHD2NfS+Ip/5RIwhuXd9MG8b3G2GpC0oQBKhWoBx8s2g\n" +
                    "d9yNJ/dA40FemIk9UzEaRn9ZthkmEdxO+5VRSfrIKD4Pn9eum8jv0cTsUzB65qQG\n" +
                    "glbdMOaNkgTWgCtqX5tQMWrkXR7ZExRGCTz2/w+u+HXDve+GFtFbxbHQ3HweEqMq\n" +
                    "NM8CggEBAOrjQ6q4ayiwl0NJebBwuMg7vngz/MUUtYgKdRg146bkho6QNU78vkAo\n" +
                    "kYjku+3WMBbGUnAqlwSVRiGkkZHr2gLFk9lJfN+V3dLbBiXEo0HkCODFR8euEv4s\n" +
                    "X2Cq8bkbyXmxlTMak8jGfkksfuqcCyvk5L2VYPjikvi7rTjr1ruki3Z2bDwM1JRj\n" +
                    "cuEhpGBAlKzlFfTNxlOjQs8LtQxRuFMSUfRyArKWjr9drVuwJQ0zbqtZZQySJrVd\n" +
                    "AabRdtMl/VHEymUbJFDyd21/FJqMd2pd6lgsCOO1MtX+wiQuWA6RTPxALT5oQfhb\n" +
                    "wKZ2vgEJ5YPF1fUmYnN2erHT1n8TQsw=\n" +
                                    "-----END PRIVATE KEY-----");
}
