# DESForSwift 

在 xxx-Bridging-Header.h 中要引入两个 oc 库
```
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>
```

```
let dict = ["key":"value",
            "aaa":"bbbb",
            "haha":["1",
                    "2",
                    "3",
                    "4",
                    "5"],
            "json":["key":"value"],
            "chinese":"测试"
            ] as [String : Any]

let str = DesForSwift.encrypt(dict: dict)
print(str)
        
let dic : Dictionary<String,Any> = DesForSwift.decrypt(string: str)
print(dic)
```
