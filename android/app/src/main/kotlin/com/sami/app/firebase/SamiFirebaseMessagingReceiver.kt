package com.sami.app.firebase

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class SamiFirebaseMessagingReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        Log.d(TAG, "Received action: ${intent?.action}")
    }

    companion object {
        private const val TAG = "SamiFirebaseReceiver"
    }
}
