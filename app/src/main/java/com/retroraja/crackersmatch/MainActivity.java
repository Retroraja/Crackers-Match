package com.retroraja.crackersmatch;

import android.app.Activity;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.view.View;
import android.webkit.JavascriptInterface;
import android.webkit.WebSettings;
import android.webkit.WebView;
import androidx.annotation.NonNull;
import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;
import java.util.Locale;

/** Shows the game, which lives in assets/www. */
public class MainActivity extends Activity {
    /** Google's public test unit. Swap for the real rewarded ad unit before release. */
    private static final String REWARDED_UNIT = "ca-app-pub-3940256099942544/5224354917";
    private WebView web;
    private RewardedAd rewarded;
    private boolean earned;
    private TextToSpeech tts;
    private boolean ttsReady;

    @Override protected void onCreate(Bundle state) {
        super.onCreate(state);
        web = new WebView(this);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setMediaPlaybackRequiresUserGesture(false);
        s.setAllowFileAccess(false);
        web.setOverScrollMode(View.OVER_SCROLL_NEVER);
        web.addJavascriptInterface(new Bridge(), "AndroidVoice");
        web.loadUrl("file:///android_asset/www/index.html");
        setContentView(web);
        hideBars();
        tts = new TextToSpeech(this, status -> {
            if (status != TextToSpeech.SUCCESS) return;
            int r = tts.setLanguage(new Locale("ta", "IN"));
            if (r < 0) tts.setLanguage(new Locale("en", "IN"));
            tts.setSpeechRate(1.1f);
            tts.setPitch(1.1f);
            ttsReady = true;
        });
        MobileAds.initialize(this, st -> loadAd());
    }

    private void loadAd() {
        RewardedAd.load(this, REWARDED_UNIT, new AdRequest.Builder().build(), new RewardedAdLoadCallback() {
            @Override public void onAdLoaded(@NonNull RewardedAd ad) { rewarded = ad; }
            @Override public void onAdFailedToLoad(@NonNull LoadAdError e) { rewarded = null; }
        });
    }

    private void adResult(boolean ok) {
        web.evaluateJavascript("window.adDone&&window.adDone(" + ok + ")", null);
    }

    private class Bridge {
        @JavascriptInterface public void say(String w) {
            if (ttsReady) tts.speak(w, TextToSpeech.QUEUE_FLUSH, null, "word");
        }
        @JavascriptInterface public void showAd() {
            runOnUiThread(() -> {
                if (rewarded == null) { adResult(false); loadAd(); return; }
                earned = false;
                rewarded.setFullScreenContentCallback(new FullScreenContentCallback() {
                    @Override public void onAdDismissedFullScreenContent() { rewarded = null; adResult(earned); loadAd(); }
                    @Override public void onAdFailedToShowFullScreenContent(@NonNull AdError e) { rewarded = null; adResult(false); loadAd(); }
                });
                rewarded.setImmersiveMode(false);
                rewarded.show(MainActivity.this, item -> earned = true);
            });
        }
    }

    private void hideBars() {
        web.setSystemUiVisibility(View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY | View.SYSTEM_UI_FLAG_FULLSCREEN
            | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION);
    }

    @Override protected void onResume() {
        super.onResume();
        web.onResume();
        web.resumeTimers();
        web.evaluateJavascript("window.SFX&&SFX.resume()", null);
        hideBars();
    }

    @Override protected void onPause() {
        web.evaluateJavascript("window.SFX&&SFX.pause()", null);
        if (tts != null) tts.stop();
        web.onPause();
        web.pauseTimers();
        super.onPause();
    }

    @Override protected void onDestroy() {
        if (tts != null) tts.shutdown();
        super.onDestroy();
    }
}
