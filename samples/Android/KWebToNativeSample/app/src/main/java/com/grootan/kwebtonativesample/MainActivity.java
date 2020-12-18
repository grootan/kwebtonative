package com.grootan.kwebtonativesample;

import android.content.Context;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import com.grootan.kwebtonative.KWebToNative;
import com.grootan.kwebtonative.KWebToNativeCallbackDelegate;
import com.grootan.kwebtonative.KWebToNativeListenerDelegate;

import java.util.HashMap;
import java.util.Map;

public class MainActivity extends AppCompatActivity {

    WebView _webview;
    KWebToNative _kwebtonative;
    Button _sendBtn;
    EditText _msgEt;
    TextView _receivedMsgTv;
    Context _context;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        _context = this;
        _webview = (WebView) findViewById(R.id.webview);
        _sendBtn = (Button) findViewById(R.id.sendbtn);
        _msgEt = (EditText) findViewById(R.id.msget);
        _receivedMsgTv = (TextView) findViewById(R.id.receivedmsgtv);

        _sendBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sendMessage();
            }
        });
    }

    @Override
    protected void onStart() {
        super.onStart();

        _kwebtonative = KWebToNative.shared();
        KWebToNative.shared().initialize(_webview,new WebViewClient());
        setUpEvents();
        _webview.loadUrl("https://kwebtonative.netlify.com/");

    }

    private void sendMessage()
    {
        HashMap<String, String> data = new HashMap<String, String>();
        data.put("msg", _msgEt.getText().toString());
        _kwebtonative.send("chat", data, new KWebToNativeCallbackDelegate() {
            @Override
            public void onComplete() {
                Toast.makeText(_context,"Message Sent",Toast.LENGTH_SHORT);
            }
        });
    }

    private void setUpEvents()
    {
        _kwebtonative.on("chat", new KWebToNativeListenerDelegate() {
            @Override
            public void onMessage(Map<Object, Object> map) {
                _receivedMsgTv.setText("");
                String value = map.get("msg").toString();
                _receivedMsgTv.append(value);
            }
        });
    }

}
