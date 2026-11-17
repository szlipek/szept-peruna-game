package org.szeptperuna.firebase;

import android.os.Bundle;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.crashlytics.FirebaseCrashlytics;
import com.google.android.ump.ConsentInformation;
import com.google.android.ump.UserMessagingPlatform;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.UsedByGodot;
import org.json.JSONObject;
import java.util.EnumMap;
import java.util.Iterator;

public final class GameFirebase extends GodotPlugin {
    private boolean analyticsEnabled;

    public GameFirebase(Godot godot) { super(godot); }
    @Override public String getPluginName() { return "GameFirebase"; }

    @UsedByGodot public void setAnalyticsEnabled(boolean enabled) {
        analyticsEnabled = enabled;
        FirebaseAnalytics analytics = FirebaseAnalytics.getInstance(getActivity());
        EnumMap<FirebaseAnalytics.ConsentType, FirebaseAnalytics.ConsentStatus> consent =
                new EnumMap<>(FirebaseAnalytics.ConsentType.class);
        consent.put(FirebaseAnalytics.ConsentType.ANALYTICS_STORAGE, enabled
                ? FirebaseAnalytics.ConsentStatus.GRANTED : FirebaseAnalytics.ConsentStatus.DENIED);
        consent.put(FirebaseAnalytics.ConsentType.AD_STORAGE, FirebaseAnalytics.ConsentStatus.DENIED);
        consent.put(FirebaseAnalytics.ConsentType.AD_USER_DATA, FirebaseAnalytics.ConsentStatus.DENIED);
        consent.put(FirebaseAnalytics.ConsentType.AD_PERSONALIZATION, FirebaseAnalytics.ConsentStatus.DENIED);
        analytics.setConsent(consent);
        analytics.setAnalyticsCollectionEnabled(enabled);
    }

    @UsedByGodot public void setCrashReportingEnabled(boolean enabled) {
        FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(enabled);
        if (!enabled) FirebaseCrashlytics.getInstance().deleteUnsentReports();
    }

    @UsedByGodot public boolean isAdPrivacyOptionsRequired() {
        if (getActivity() == null) return false;
        return UserMessagingPlatform.getConsentInformation(getActivity())
                .getPrivacyOptionsRequirementStatus() == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED;
    }

    @UsedByGodot public void showAdPrivacyOptions() {
        if (getActivity() == null) return;
        getActivity().runOnUiThread(() -> UserMessagingPlatform.showPrivacyOptionsForm(
                getActivity(), error -> {
                    if (error != null) android.util.Log.w("GameFirebase", "Privacy form unavailable: " + error.getMessage());
                }));
    }

    @UsedByGodot public void logGameEvent(String name, String json) {
        if (!analyticsEnabled || getActivity() == null) return;
        try {
            JSONObject values = new JSONObject(json);
            Bundle params = new Bundle();
            Iterator<String> keys = values.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                Object value = values.get(key);
                if (value instanceof String) params.putString(key, (String) value);
                else if (value instanceof Number) params.putLong(key, ((Number) value).longValue());
                else if (value instanceof Boolean) params.putLong(key, (Boolean) value ? 1 : 0);
            }
            FirebaseAnalytics.getInstance(getActivity()).logEvent(name, params);
        } catch (Exception error) {
            android.util.Log.w("GameFirebase", "Invalid event parameters", error);
        }
    }
}
