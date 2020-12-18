package com.grootan.kwebtonative;

import android.webkit.WebView;
import android.webkit.WebViewClient;
import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Main Singleton Class to handle webview wrapper
 */
public class KWebToNative {

    public static KWebToNative _shared;
    private HashMap<String, List<KWebToNativeListenerDelegate>> _listeners;
    private WebView _webview;
    private Gson _gson;
    private KWebToNativeWebViewClient _client;

    /**
     * Private constructor
     */
    private KWebToNative() {
        _listeners = new HashMap<>();
        _gson = new Gson();
    }

    /**
     * Method to get instance of KWebToNative
     * @return
     */
    public static KWebToNative shared() {
        if (_shared == null) {
            _shared = new KWebToNative();
        }
        return _shared;
    }

    /**
     * Method to initialize webview and webviewclient
     * @param webView
     * @param webViewClient
     */
    public void initialize(WebView webView, WebViewClient webViewClient)
    {
        if(_client == null)
        {
            _client = new KWebToNativeWebViewClient(_shared);
        }
        this._client.setDelegate(webViewClient);
        this._webview = webView;
        webView.getSettings().setJavaScriptEnabled(true);
        webView.setWebViewClient(_client);
    }

    /**
     * Method to listen on events
     * @param eventName
     * @param delegate
     */
    public void on(String eventName,KWebToNativeListenerDelegate delegate )
    {
        List<KWebToNativeListenerDelegate> delegates = _listeners.get(eventName);
        if(delegates == null)
        {
            delegates = new ArrayList<>();
        }
        delegates.add(delegate);
        _listeners.put(eventName,delegates);
    }

    /**
     * Method not to listen for events, it will remove the listener which is called with on
     * @param eventName
     */
    public void off(String eventName)
    {
        _listeners.remove(eventName);
    }

    /**
     * Method to send payload to webview
     * @param eventName
     * @param payload
     */
    public void send(String eventName, Object payload)
    {
        send(eventName, payload);
    }

    /**
     * Method to send payload to webview with callback
     * @param eventName
     * @param payload
     * @param delegate
     */
    public void send(String eventName, Object payload, KWebToNativeCallbackDelegate delegate)
    {
        if(_webview == null)
        {
            throw new NullPointerException("Webview cannot be null, you must call initialize before calling send");
        }

        String jsonData = _gson.toJson(payload);
        _webview.loadUrl(String.format("javascript:KWebToNative.trigger(\"%s\",%s);",eventName,jsonData));
        delegate.onComplete();
    }

    /**
     * Method to handled payload from webview
     * @param webView
     * @param envelope
     */
    protected void triggerEventFromWebView(final WebView webView,
                                           WebViewPayload envelope) {
        String type = envelope.type;

        if (_listeners.containsKey(type)) {
            List<KWebToNativeListenerDelegate> handlers = _listeners.get(type);

            for (KWebToNativeListenerDelegate handler:
                handlers ) {
                handler.onMessage(envelope.payload);
            }
        }
    }


}
