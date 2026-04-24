# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Better Player & Video Player
-keep class com.google.android.exoplayer2.** { *; }
-keep class com.jhomlala.better_player.** { *; }
-keep class dev.fluttercommunity.plus.wakelock.** { *; }

# Hive & Binary Adapters
-keep class io.hive.** { *; }
-keep class com.phuocem.artverse.app.data.models.** { *; }
-keep public class * extends io.hive.TypeAdapter
-keep @io.hive.HiveType class * { *; }
-keep @io.hive.HiveField class * { *; }

# Flutter Secure Storage
-keep class com.it_is_used.flutter_secure_storage.** { *; }

# General safety for generated code
-dontwarn io.flutter.plugins.**
-dontwarn com.google.android.exoplayer2.**

-dontwarn com.google.android.play.core.**

# Keep GetX and its dynamic logic
-keep class com.getwidgets.** { *; }
-keep interface com.getwidgets.** { *; }
-keep class com.getx.** { *; }
-keep interface com.getx.** { *; }
-keep class * extends com.getx.GetxController { *; }
-keep class * extends com.getx.GetxService { *; }

# Keep Lottie
-keep class com.airbnb.lottie.** { *; }

# Keep Flutter translations and localized resources
-keep class *.R$* { *; }

# General Flutter issues with R8
-dontwarn io.flutter.embedding.gesture.**
-dontwarn io.flutter.view.**
-dontwarn io.flutter.plugins.**
