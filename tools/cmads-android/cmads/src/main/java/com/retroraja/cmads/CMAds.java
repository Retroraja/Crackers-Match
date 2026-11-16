package com.retroraja.cmads;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Build;
import android.view.View;
import androidx.annotation.NonNull;
import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;
import java.util.HashSet;
import java.util.Set;

/** Rewarded video ads for Crackers Match (same behaviour as the web build's MainActivity). */
public class CMAds extends GodotPlugin {
    /** Google's public test unit. Swap for the real rewarded ad unit before release. */
    private static final String REWARDED_UNIT = "ca-app-pub-3940256099942544/5224354917";
    /** While on Google test ads, closing the ad still gives the reward so testing can continue. */
    private static final boolean TEST_ADS = true;
    private RewardedAd rewarded;
    private boolean earned;
    private boolean started;

    public CMAds(Godot godot) { super(godot); }

    @NonNull @Override public String getPluginName() { return "CMAds"; }

    @NonNull @Override public Set<SignalInfo> getPluginSignals() {
        Set<SignalInfo> s = new HashSet<>();
        s.add(new SignalInfo("ad_done", Boolean.class));
        return s;
    }

    @UsedByGodot public void init() {
        final Activity a = getActivity();
        if (a == null || started) return;
        started = true;
        a.runOnUiThread(() -> MobileAds.initialize(a, st -> loadAd()));
    }

    private void loadAd() {
        final Activity a = getActivity();
        if (a == null) return;
        a.runOnUiThread(() -> RewardedAd.load(a, REWARDED_UNIT, new AdRequest.Builder().build(), new RewardedAdLoadCallback() {
            @Override public void onAdLoaded(@NonNull RewardedAd ad) { rewarded = ad; }
            @Override public void onAdFailedToLoad(@NonNull LoadAdError e) { rewarded = null; }
        }));
    }

    @UsedByGodot public boolean ready() { return rewarded != null; }

    @UsedByGodot public void showAd() {
        final Activity a = getActivity();
        if (a == null) { emitSignal("ad_done", false); return; }
        a.runOnUiThread(() -> {
            if (rewarded == null) { emitSignal("ad_done", false); loadAd(); return; }
            earned = false;
            rewarded.setFullScreenContentCallback(new FullScreenContentCallback() {
                @Override public void onAdDismissedFullScreenContent() { rewarded = null; emitSignal("ad_done", earned || TEST_ADS); loadAd(); }
                @Override public void onAdFailedToShowFullScreenContent(@NonNull AdError e) { rewarded = null; emitSignal("ad_done", false); loadAd(); }
            });
            rewarded.setImmersiveMode(false);
            rewarded.show(a, item -> earned = true);
        });
    }

    @UsedByGodot public void askNotify() {
        final Activity a = getActivity();
        if (a == null) return;
        a.runOnUiThread(() -> {
            if (Build.VERSION.SDK_INT >= 33 && a.checkSelfPermission("android.permission.POST_NOTIFICATIONS") != PackageManager.PERMISSION_GRANTED)
                a.requestPermissions(new String[]{"android.permission.POST_NOTIFICATIONS"}, 7);
        });
    }
}
