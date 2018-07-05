//
//  DesUseOc.swift
//  testALamoFire
//
//  Created by 李想 on 2018/7/4.
//  Copyright © 2018 李想. All rights reserved.
//

import Foundation
class DesForSwift{
    
}

extension DesForSwift{
   static func encrypt(dict : Dictionary<String ,Any>) -> String {
        let jsonStr = getJsonStringFromDictionary(dictionary: dict as NSDictionary)
        let encryptStr = jsonStr.threeDESEncryptOrDecrypt(op: 1)!.Base64EncodedString()
        return encryptStr
    }
    
   static func decrypt(string : String) -> Dictionary<String,Any> {
        let obj = string.toDecryptJsonDic()
        return obj
    }
    
    //字典转换为jsonString
   static func getJsonStringFromDictionary(dictionary:NSDictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
    let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options:JSONSerialization.WritingOptions.prettyPrinted) as NSData!
        let JSONString = String(data: data as Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        return JSONString!
    }
}

extension String{
    func threeDESEncryptOrDecrypt(op: Int) -> String? {
        //op传1位加密，0为解密
        //CCOperation（kCCEncrypt）加密 1
        //CCOperation（kCCDecrypt) 解密 0
        
        var ccop = CCOperation()
        let key = "3acredit20171128bibibaba"
        let iv = "01234567"
        // Key
        let keyData: NSData = (key as NSString).data(using: String.Encoding.utf8.rawValue) as NSData!
        let keyBytes         = UnsafeRawPointer(keyData.bytes)
        
        // 加密或解密的内容
        var data: NSData = NSData()
        if op == 1 {
            ccop = CCOperation(kCCEncrypt)
            data  = (self as NSString).data(using: String.Encoding.utf8.rawValue) as NSData!
        }
        else {
            ccop = CCOperation(kCCDecrypt)
            data = NSData(base64Encoded: self, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
        }
        
        let dataLength    = size_t(data.length)
        let dataBytes     = UnsafeRawPointer(data.bytes)
        
        // 返回数据
        let cryptData    = NSMutableData(length: Int(dataLength) + kCCBlockSize3DES)
        let cryptPointer = UnsafeMutableRawPointer(cryptData!.mutableBytes)
        let cryptLength  = size_t(cryptData!.length)
        
        //  可选 的初始化向量
        let viData :NSData = (iv as NSString).data(using: String.Encoding.utf8.rawValue) as NSData!
        let viDataBytes    = UnsafeRawPointer(viData.bytes)
        
        // 特定的几个参数
        let keyLength              = size_t(kCCKeySize3DES)
        let operation: CCOperation = UInt32(ccop)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithm3DES)
        let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding)
        
        var numBytesCrypted :size_t = 0
        
        let cryptStatus = CCCrypt(operation, // 加密还是解密
            algoritm, // 算法类型
            options,  // 密码块的设置选项
            keyBytes, // 秘钥的字节
            keyLength, // 秘钥的长度
            viDataBytes, // 可选初始化向量的字节
            dataBytes, // 加解密内容的字节
            dataLength, // 加解密内容的长度
            cryptPointer, // output data buffer
            cryptLength,  // output data length available
            &numBytesCrypted) // real output data length
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData!.length = Int(numBytesCrypted)
            if op == 1  {
                let base64cryptString = cryptData!.base64EncodedString(options: .lineLength64Characters)
                //返回加密的数据
                return base64cryptString
            }
            else {
                let base64cryptString = NSString(data: cryptData! as Data,  encoding: String.Encoding.utf8.rawValue) as String?
                //返回解密的数据
                return base64cryptString
            }
        } else {
            print("Error: \(cryptStatus)")
        }
        return nil
    }
    
    
    //向后台传值的时候
    func urlBase64EncodedString() -> String {
        let first = self.replacingOccurrences(of: "/", with: "_")
        let second = first.replacingOccurrences(of: "+", with: "-")
        let third = second.replacingOccurrences(of: "=", with: "")
        return third
    }
    
    func Base64EncodedString() -> String {
        let first = self.replacingOccurrences(of: "_", with: "/")
        let second = first.replacingOccurrences(of: "-", with: "+")
        let third = second.replacingOccurrences(of: "", with: "=")
        let four = third.replacingOccurrences(of: "\r", with: "")
        let five = four.replacingOccurrences(of: "\n", with: "")

        return five
    }
    
    //接收后台返回的值的时候
    func urlBase64DecodedString() -> String {
        let first = NSMutableString(string: self)
        let mod4:Int = first.length % 4
        print(first.length)
        if(mod4>0){
            var str = "===="
            let start1 = str.index(str.startIndex, offsetBy: 0)
            str = str.substring(from: start1)
            let end1 = str.index(str.startIndex, offsetBy: 4-mod4)
            let sub5 = str.substring(to: end1)
            first.append(sub5)
        }
        let second = first.replacingOccurrences(of: "_", with: "/")
        let third = second.replacingOccurrences(of: "-", with: "+")
        return third
    }
    
    //解密加转换字典
    func toDecryptJsonDic() -> [String:Any]{
        let decryptJsonString = self.urlBase64DecodedString().threeDESEncryptOrDecrypt(op: 0)
        let decryptJsonDic = decryptJsonString?.toDictionary()
        if decryptJsonDic != nil {
            return decryptJsonDic!
        }
        return [String:Any].init()
    }
    
    func toDictionary() -> [String:Any] {
        let jsonData:Data = self.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! Dictionary
        }
        return Dictionary()
    }
    
}


