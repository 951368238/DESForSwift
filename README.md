# DESForSwift
let dict = ["key":"value","aaa":"bbbb","haha":["1","2","3","4","5"],"json":["key":"value"],"chinese":"测试"] as [String : Any]
let str = DesForSwift.encrypt(dict: dict)
print(str)
        
let dic : Dictionary<String,Any> = DesForSwift.decrypt(string: str)
print(dic)
