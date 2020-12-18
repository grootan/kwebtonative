

import Foundation
import WebKit

/**
 Delegate for listeners
 */
public protocol KWebToNativeCallBackDelegate: class {
    func onComplete(_ message:Any, _ error: Error)
}

/**
 Delegate for callback
 */
public protocol KWebToNativeListenerDelegate: class {
    func onMessage(_ payload: NSDictionary)
}

/**
 Error enum
 */
enum KWebToNativeError : Error{
    case invalid(String)
}

public class KWebToNative {
    
    public static var shared = KWebToNative()
    var _wkWebView: WKWebView?
    var _listenerDictionary : NSMutableDictionary
    
    /**
     Init to initialize properties of KWebToNative
     */
    private init(){
        _listenerDictionary = NSMutableDictionary()
    }
    
    /**
     Method to set the WKWebview
     */
    public func initialize(_ wkWebView: WKWebView)
    {
        self._wkWebView = wkWebView
    }
    
    /**
     Method to listen for events from WKWebview
     */
    public func on(_ eventName: String,_ listenerDelegate: KWebToNativeListenerDelegate)
    {
        let callBackArray: NSMutableArray = _listenerDictionary.object(forKey: eventName) as? NSMutableArray ?? []
        if(callBackArray == [])
        {
            _listenerDictionary.setValue(callBackArray, forKey: eventName)
        }

        callBackArray.add(listenerDelegate)
    }
    
    /**
     Method to remove events from listening, its always important to remove the events from listening
     */
    public func off(_ eventName: String)
    {
        _listenerDictionary.removeObject(forKey: eventName)
    }
    
    /**
     Method to send message to WkWebview without callback
     */
    public func send(_ eventName: String, _ payload: NSDictionary) throws
    {
        try self.send(eventName, payload, nil)
    }
    
    /**
     Method to send message to WkWebview with callback
     */
    public func send(_ eventName: String, _ payload: NSDictionary,_ callback: KWebToNativeCallBackDelegate?) throws
    {
        guard let webview = _wkWebView else {
            throw KWebToNativeError.invalid("Webview cannot be nil, you must call initialize before calling send")
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            guard let jsonString = String(data: jsonData, encoding:  .utf8) else{
                return
            }
            log("send",String(format: "KWebToNative.trigger(\"%@\",%@);", eventName,jsonString))
            webview.evaluateJavaScript(String(format: "KWebToNative.trigger(\"%@\",%@);", eventName,jsonString)) { (message, error) in
                               
                               if(callback != nil)
                               {
                                   callback!.onComplete(message as Any, error!)
                               }
                           }
        } catch let error as NSError {
            throw error
        }
    }
    
    /**
     Method to process result from webview
     */
    public func process(_ url: URL?)
    {
        if(url == nil)
        {
            return
        }
        
        log("process","Received URL \(String(describing: url))")
        log("process","Scheme \(url?.scheme ?? "No Scheme")")
        if( url?.scheme == "kwebtonative")
        {
            let eventType = url?.host
            let query = url?.query
            let jsonString = query?.removingPercentEncoding
            log("process","Received JSON \(String(describing: jsonString))")
            let jsonData = convertToDictionary(text: jsonString!)
            
            if(eventType == "event")
            {
                triggerEventsFromWeb(jsonData! as NSDictionary)
            }
        
        }
    }
    
    /**
    Method to trigger subscribed listeners
    */
    private func triggerEventsFromWeb(_ jsonData: NSDictionary)
    {
        let eventName = jsonData.object(forKey: "type")
        log("triggerEventsFromWeb","Event Name \(String(describing: eventName))")
        let payload = jsonData.object(forKey: "payload")
        log("triggerEventsFromWeb","Payload \(String(describing: payload))")
        let listeners = _listenerDictionary.object(forKey: eventName as Any) as? NSArray
        for listener in listeners! {
            (listener as! KWebToNativeListenerDelegate).onMessage(payload as! NSDictionary)
        }
    }
    
    /**
    Method to convert jsont to nsdictionary
    */
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    /**
     Method to log
     */
    private func log(_ methodName: String, _ message: String)
    {
        print("KWEBTONATIVE:\(methodName):\(message)")
    }
    
}
