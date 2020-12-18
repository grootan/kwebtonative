package com.grootan.kwebtonative;

import java.util.Map;

/**
 * Delegate to handle listener
 */
public abstract class KWebToNativeListenerDelegate {

   public abstract void onMessage(Map<Object,Object> payload);
}
