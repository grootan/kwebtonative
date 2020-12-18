KWebToNative
============

KWebToNative is a dual-iOS and Android library that facilitates two-way communication between native applications and JavaScript apps running inside them.
It also supports communication between iframes running inside a webview.


# WebApp
------
KWebToNative js will help to communicate web app to native both android and iOS

### Setup
Include javascript file from js folder inside your head tag

```
<script type="text/javascript" src="KWebToNative.js"></script>
```

### Subscribe to event

KWebNative allows to subscribe to event using the method `on` where it takes the event name and subscribe to events that receive with eventname. It also allows more than one event subscription

#### Syntax
```
KWebToNative.on(eventname, function(payload){
// here we get the payload send from native android or iOS
});
```

### UnSubscribe from event

KWebNative allows to unsubscribe to event using the method `off` where it takes the event name and unsubscribe all the events associated to the event.

#### Syntax
```
KWebToNative.off(eventname);
```

### Send Payload to Native

KWebNative allows to send payload to Native android and iOS using the method `send`

#### Syntax

```
KWebToNative.send(eventname,payload);
```


iOS
------

KWebToNative will help your iOS app to communicate with a Javascript application running inside WKWebview

### Setup
1. Copy the iOS folder to your project
2. Add following pod to your pod file or call pod init and add following pod script

```
pod 'KWebToNative', :path => 'path to KWebToNative root'

```

3. Call ``` Pod install ```
4. Add ``` import KWebToNative ``` to your viewcontroller

### Initialize

KWebNative should be initialized with WKWebView instance

#### Syntax

```
// Call under viewDidLoad
KWebToNative.shared.initialize(webView)
```

### Process Result from Javascript

Add following snippet under WKNavigationDelegate method, Take a look at the sample for more information

```
func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let requestURL = navigationAction.request.url?.absoluteString else { return }
        // Important to process the message from Web App
        KWebToNative.shared.process(navigationAction.request.url)
        decisionHandler(.allow)
    }
```

### Subscribe to event

KWebNative allows to subscribe to event using the method `on` where it takes the event name and subscribe to events that receive with eventname. It also allows more than one event subscription

#### Syntax
```
// Call under viewDidLoad
KWebToNative.shared.on(eventname, self)


extension YourViewController: KWebToNativeListenerDelegate{
    func onMessage(_ payload: NSDictionary) {
        // here you receive the payload
    }
}
```

### UnSubscribe from event

KWebNative allows to unsubscribe to event using the method `off` where it takes the event name and unsubscribe all the events associated to the event.

#### Syntax
```
KWebToNative.shared.off(eventname);
```

### Send Payload to Native

KWebNative allows to send payload from native iOS to webapp using the method `send`

#### Syntax

```
do{
   let payload = NSMutableDictionary()
   try KWebToNative.shared.send(eventname,payload);
}
catch {
    // here handle the error
}

```

Android
------

KWebToNative will help your Android app to communicate with a Javascript application running inside WebView

### Setup

1. Copy kwebtonative-release.aar file to libs folder of your android project
2. Add following imports
``` 
import com.grootan.kwebtonative.KWebToNative;
import com.grootan.kwebtonative.KWebToNativeListenerDelegate;
```


### Initialize

KWebNative should be initialized with WebView instance

#### Syntax

```
// Call under viewDidLoad
KWebToNative.shared().initialize(webView, new WebViewClient())
```

### Subscribe to event

KWebNative allows to subscribe to event using the method `on` where it takes the event name and subscribe to events that receive with eventname. It also allows more than one event subscription

#### Syntax
```
// Call under onStart()
KWebToNative.shared().on(eventname,  new KWebToNativeListenerDelegate() {
            @Override
            public void onMessage(Map<Object, Object> payload) {
                // here handle the payload
            }
        })

```

### UnSubscribe from event

KWebNative allows to unsubscribe to event using the method `off` where it takes the event name and unsubscribe all the events associated to the event.

#### Syntax
```
KWebToNative.shared().off(eventname);
```

### Send Payload to Native

KWebNative allows to send payload from native iOS to webapp using the method `send`

#### Syntax

```
HashMap<String, String> data = new HashMap<String, String>();
KWebToNative.shared().send(eventname, data);
```

