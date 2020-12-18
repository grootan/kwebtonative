package com.grootan.kwebtonative;

import android.annotation.TargetApi;
import android.net.Uri;
import android.os.Build;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import com.google.gson.Gson;
import com.grootan.kwebtonative.util.BaseWebViewClient;

/**
 * WebView client to handle the message from webview
 */
public class KWebToNativeWebViewClient extends BaseWebViewClient {
    private KWebToNative _kwebtonative;
    private WebViewClient _delegate;
    private Gson _gson;


    public KWebToNativeWebViewClient(KWebToNative kWebToNative)
    {
        _gson = new Gson();
        _kwebtonative = kWebToNative;
    }

    public KWebToNative getImplementation()
    {
        return  _kwebtonative;
    }

    protected void setDelegate(WebViewClient client) {
        _delegate = client;
    }

    @Override
    protected WebViewClient delegate() {
        return _delegate;
    }

    @SuppressWarnings("deprecation")
    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        final Uri uri = Uri.parse(url);
        return handleUri(view, uri);
    }

    @TargetApi(Build.VERSION_CODES.N)
    @Override
    public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
        final Uri uri = request.getUrl();
        return handleUri(view,uri);
    }

    private boolean handleUri(WebView webView, Uri uri)
    {
        if (isKWebNativeScheme(uri)) {
            try {
                processUri(webView, uri);

                return true;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    public boolean isKWebNativeScheme(Uri uri) {
        return uri.getScheme().equals("kwebtonative") && !uri.getQuery().equals("");
    }

    public void processUri(WebView view, Uri uri)
            throws Exception {
        String[] parts = uri.getPath().replaceAll("^\\/", "").split("/");
        String host = uri.getHost();

        WebViewPayload payload = _gson.fromJson(
                uri.getQuery(), WebViewPayload.class);

        if (parts.length > 0) {
            if (host.equals("event")) {
                getImplementation().triggerEventFromWebView(view, payload);
            }
        }
    }

}
