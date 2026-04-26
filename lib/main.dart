import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/core/bindings/initial_binding.dart';
import 'app/data/services/database_service.dart';
import 'app/data/services/secure_logging_service.dart';
import 'app/data/services/translations.dart';
import 'app/modules/layout/controllers/layout_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/widgets/common/error_views.dart';
import 'app/data/services/app_globals.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  ErrorWidget.builder = (FlutterErrorDetails details) {
    final bool isSliverError = details.exception.toString().contains('RenderSliver');
    final Widget errorContent = Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFF0F172A),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 64),
            const SizedBox(height: 16),
            const Text(
              "Lỗi hiển thị (Rendering Error)",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              details.exception.toString(),
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
      ),
    );
    if (isSliverError) return SliverToBoxAdapter(child: errorContent);
    return Material(color: Colors.transparent, child: errorContent);
  };

  try {
    
    try {
      SecureLoggingService.info("Init: Loading .env...", tag: "Init");
      await dotenv.load(fileName: ".env").timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw "Timeout loading .env",
          );
      SecureLoggingService.success(".env loaded successfully", tag: "Init");
    } catch (e) {
      throw "Error loading .env: $e. Vui lòng tạo file .env từ file mẫu.";
    }

    
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    if (supabaseUrl == '' || supabaseUrl.contains('your_')) {
      throw "CẤU HÌNH THIẾU: Vui lòng điền 'SUPABASE_URL' vào file .env";
    }
    
    SecureLoggingService.info("Init: Initializing Supabase...", tag: "Init");
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw "Supabase initialization timed out",
    );
    SecureLoggingService.success("Supabase initialized", tag: "Init");

    
    SecureLoggingService.info("Init: Initializing Hive Database...", tag: "Init");
    await Get.putAsync(() => DatabaseService().init()).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw "Database initialization timed out",
    );
    SecureLoggingService.success("Hive initialized", tag: "Init");

    
    await Get.putAsync(() => TranslationService().init()).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        SecureLoggingService.warning("Translations sync timed out");
        return TranslationService();
      },
    );

    
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    
    final dbService = Get.find<DatabaseService>();
    final String? savedLangCode = dbService.settingsBox.get('languageCode') as String?;
    final String? savedCountryCode = dbService.settingsBox.get('countryCode') as String?;
    final initialLocale = (savedLangCode != null && savedCountryCode != null)
        ? Locale(savedLangCode, savedCountryCode)
        : Get.deviceLocale;

    runApp(
      GetMaterialApp(
        scaffoldMessengerKey: snackbarKey,
        translations: AppTranslations(),
        locale: initialLocale,
        fallbackLocale: const Locale('en', 'US'),
        initialBinding: InitialBinding(), 
        debugShowCheckedModeBanner: false,
        title: 'ArtVerse',
        themeMode: ThemeMode.dark, 
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        defaultTransition: Transition.fadeIn,
        builder: (context, child) {
          final size = MediaQuery.of(context).size;
          final isTablet = size.shortestSide >= 600;
          if (!isTablet) return const TabletOnlyView();
          
          
          if (Get.isRegistered<LayoutController>()) {
            final layout = Get.find<LayoutController>();
            return Obx(() => Theme(
              data: layout.currentTheme.value.toThemeData(),
              child: child!,
            ));
          }
          return child!;
        },
      ),
    );
  } catch (e) {
    runApp(InitializationErrorApp(error: e.toString()));
  }
}

