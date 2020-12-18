
import UIKit
import KWebToNative
import WebKit

class WebViewController: UIViewController {
    var webView: WKWebView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var messageField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWkWebView()
        
        let request = URLRequest(url: URL(string: "https://kwebtonative.netlify.com/")!)
        webView.load(request)
        
        //here we initialize
        KWebToNative.shared.initialize(webView)
        
        //here we subscribe to event
        onToEvent()
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        do{
            let dic = NSMutableDictionary()
            guard let msg = messageField.text else {
                return
            }
            dic.setValue(msg, forKey: "msg")
            try KWebToNative.shared.send("chat",dic )
        }
        catch{
            print("failed to send")
        }
    }
    
    func onToEvent(){
        KWebToNative.shared.on("chat", self)
    }
    
    func offToEvent(){
        KWebToNative.shared.off("chat")
    }
    
    func setupWkWebView(){
        // Do any additional setup after loading the view.
        let webConfiguration = WKWebViewConfiguration()
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.mainContainer.frame.size.height))
        self.webView = WKWebView (frame: customFrame , configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.mainContainer.addSubview(webView)
        webView.topAnchor.constraint(equalTo: mainContainer.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: mainContainer.rightAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: mainContainer.leftAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: mainContainer.heightAnchor).isActive = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
    }
    
}

extension WebViewController: WKUIDelegate,WKNavigationDelegate  {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(String(describing: webView.url))
        // here we set the current instance of wkwebview to process
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(String(describing: webView.url))
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let requestURL = navigationAction.request.url?.absoluteString else { return }
        print(String(describing: requestURL))
        KWebToNative.shared.process(navigationAction.request.url)
        decisionHandler(.allow)
    }
}

extension WebViewController: KWebToNativeListenerDelegate{
    func onMessage(_ payload: NSDictionary) {
        let msg = messageView.text
        let payloadMsg = (payload.object(forKey: "msg") as! String)
        messageView.text = msg!+"/n"+payloadMsg
    }
}
