import 'social_oauth_launcher_stub.dart'
    if (dart.library.js_interop) 'social_oauth_launcher_web.dart'
    as platform;

void launchSocialOAuth(String url) => platform.launchSocialOAuth(url);
