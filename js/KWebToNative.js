; (function () {

    let nativeDispatcher = {
        callbacks: {},

        send: function (envelope) {
            this.dispatchMessage("event", envelope);
        },

        // `type` can either be "event" or "callback"
        dispatchMessage: function (type, envelope) {

            let src = "kwebtonative://" + type + "/?" + encodeURIComponent(JSON.stringify(envelope));
            let iframe = document.createElement("iframe");
            iframe.setAttribute("src", src);
            document.documentElement.appendChild(iframe);
            iframe.parentNode.removeChild(iframe);
            iframe = null;
        }
    };

    let IframeDispatcher = {

        callbacks: {},

        send: function(envelope, complete) {
            this.dispatchMessage("event", envelope);
        },

        // `type` can either be "jockeyEvent" or "jockeyCallback"
        dispatchMessage: function(type, envelope) {
            KWebToNative.targetWindow.postMessage({ type: type, envelope: envelope }, KWebToNative.targetDomain);
        }
    };

    let KWebToNative = {
        listeners: {},

        dispatchers: [],

        targetDomain: '*',

        targetWindow: window.parent,

        on: function (type, fn) {
            if (!this.listeners.hasOwnProperty(type) || !this.listeners[type] instanceof Array) {
                this.listeners[type] = [];
            }

            this.listeners[type].push(fn);
        },

        off: function (type) {
            if (!this.listeners.hasOwnProperty(type) || !this.listeners[type] instanceof Array) {
                this.listeners[type] = [];
            }

            this.listeners[type] = [];
        },

        send: function (type, payload) {

            payload = payload || {};

            let envelope = this.createEnvelope(type, payload);

            this.dispatchers.forEach(function (dispatcher) {
                dispatcher.send(envelope);
            });

        },

        // Called by the native application when events are sent to JS from the app.
        // Will execute every function, FIFO order, that was attached to this event type.
        trigger: function (type, json) {

            let listenerList = this.listeners[type] || [];

            for (let index = 0; index < listenerList.length; index++) {
                let listener = listenerList[index];
                listener(json);
            }

        },

        onMessageRecieved: function(event) {
            if (this.targetDomain != '*' && this.targetDomain != event.origin) {
                return;
            }

            let envelope = event.data.envelope;
            if (event.data.type == "event") {
                this.trigger(envelope.type, envelope.id, envelope.payload);
            }
        },

        createEnvelope: function (type, payload) {
            return {
                type: type,
                payload: payload
            };
        }
    };

    // Dispatcher detection. Currently only supports iOS.
    // Looking for equivalent Android implementation.
    let i = 0,
        iOS = false,
        iDevice = ['iPad', 'iPhone', 'iPod'];

    for (; i < iDevice.length; i++) {
        if (navigator.platform.indexOf(iDevice[i]) >= 0) {
            iOS = true;
            break;
        }
    }

    let UIWebView = /(iPhone|iPod|iPad).*AppleWebKit(?!.*Safari)/i.test(navigator.userAgent);
    let isAndroid = navigator.userAgent.toLowerCase().indexOf("android") > -1;

    if ((iOS && UIWebView) || isAndroid) {
        KWebToNative.dispatchers.push(nativeDispatcher);
    }
    KWebToNative.dispatchers.push(IframeDispatcher);
    window.addEventListener("message", $.proxy(KWebToNative.onMessageRecieved, KWebToNative), false);

    window.KWebToNative = KWebToNative;
})();