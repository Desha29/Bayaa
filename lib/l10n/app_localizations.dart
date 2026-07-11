import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'بياع'**
  String get appName;

  /// No description provided for @systemSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نظام نقاط البيع وإدارة مبيعات التجزئة'**
  String get systemSubtitle;

  /// No description provided for @loginWelcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك مجدداً!'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال بيانات حسابك للوصول إلى النظام'**
  String get loginSubtitle;

  /// No description provided for @username.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المستخدم'**
  String get usernameHint;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get passwordHint;

  /// No description provided for @rememberMe.
  ///
  /// In ar, this message translates to:
  /// **'تذكرني على هذا الجهاز'**
  String get rememberMe;

  /// No description provided for @loginButton.
  ///
  /// In ar, this message translates to:
  /// **'دخول النظام'**
  String get loginButton;

  /// No description provided for @quickLoginHeader.
  ///
  /// In ar, this message translates to:
  /// **'تجربة سريعة للنظام بأدوار مختلفة:'**
  String get quickLoginHeader;

  /// No description provided for @sessionOpenWarning.
  ///
  /// In ar, this message translates to:
  /// **'يوجد يومية مفتوحة حالياً. تسجيل الدخول سيتابع عليها.'**
  String get sessionOpenWarning;

  /// No description provided for @offlineFeature.
  ///
  /// In ar, this message translates to:
  /// **'عمل كامل دون اتصال بالإنترنت (أوفلاين)'**
  String get offlineFeature;

  /// No description provided for @barcodeFeature.
  ///
  /// In ar, this message translates to:
  /// **'فحص مبيعات سريع بالباركود وطباعة فواتير PDF'**
  String get barcodeFeature;

  /// No description provided for @reportsFeature.
  ///
  /// In ar, this message translates to:
  /// **'تقارير أرباح يومية ومراقبة وتتبع حركة المبيعات'**
  String get reportsFeature;

  /// No description provided for @systemDescription.
  ///
  /// In ar, this message translates to:
  /// **'نظام نقاط البيع الاحترافي وإدارة التجزئة لجميع المحلات التجارية ومحلات الهواتف الذكية. يعمل بالكامل أوفلاين دون الحاجة للإنترنت مع حماية كاملة ومزامنة محلية لبياناتك.'**
  String get systemDescription;

  /// No description provided for @version.
  ///
  /// In ar, this message translates to:
  /// **'إصدار'**
  String get version;

  /// No description provided for @copyright.
  ///
  /// In ar, this message translates to:
  /// **'جميع الحقوق محفوظة.'**
  String get copyright;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @sales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get sales;

  /// No description provided for @invoices.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير'**
  String get invoices;

  /// No description provided for @products.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get products;

  /// No description provided for @stockAlerts.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات الناقصة'**
  String get stockAlerts;

  /// No description provided for @stockSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص المخزون'**
  String get stockSummary;

  /// No description provided for @reports.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get reports;

  /// No description provided for @sessions.
  ///
  /// In ar, this message translates to:
  /// **'الايام'**
  String get sessions;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @homeSection.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get homeSection;

  /// No description provided for @salesSection.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات والفواتير'**
  String get salesSection;

  /// No description provided for @stockSection.
  ///
  /// In ar, this message translates to:
  /// **'المخازن والمنتجات'**
  String get stockSection;

  /// No description provided for @systemSection.
  ///
  /// In ar, this message translates to:
  /// **'النظام والتقارير'**
  String get systemSection;

  /// No description provided for @roleManager.
  ///
  /// In ar, this message translates to:
  /// **'مدير النظام'**
  String get roleManager;

  /// No description provided for @roleCashier.
  ///
  /// In ar, this message translates to:
  /// **'كاشير'**
  String get roleCashier;

  /// No description provided for @connected.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get connected;

  /// No description provided for @trial.
  ///
  /// In ar, this message translates to:
  /// **'تجريبي'**
  String get trial;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد تسجيل الخروج'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج؟'**
  String get logoutConfirmMessage;

  /// No description provided for @logoutConfirmSub.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إنهاء يوم العمل الحالي والعودة إلى شاشة تسجيل الدخول.'**
  String get logoutConfirmSub;

  /// No description provided for @loggingOut.
  ///
  /// In ar, this message translates to:
  /// **'جاري تسجيل الخروج...'**
  String get loggingOut;

  /// No description provided for @logoutSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الخروج بنجاح'**
  String get logoutSuccess;

  /// No description provided for @logoutFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل الخروج'**
  String get logoutFailed;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noData;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get error;

  /// No description provided for @screenUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الشاشة غير متاحة'**
  String get screenUnavailable;

  /// No description provided for @systemSlogan.
  ///
  /// In ar, this message translates to:
  /// **'نظام نقاط البيع الاحترافي'**
  String get systemSlogan;

  /// No description provided for @salesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة عمليات البيع'**
  String get salesSubtitle;

  /// No description provided for @invoicesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الفواتير'**
  String get invoicesSubtitle;

  /// No description provided for @productsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المخزون'**
  String get productsSubtitle;

  /// No description provided for @stockAlertsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات المخزون'**
  String get stockAlertsSubtitle;

  /// No description provided for @stockSummarySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تصنيفات المخزون'**
  String get stockSummarySubtitle;

  /// No description provided for @reportsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليلات النظام'**
  String get reportsSubtitle;

  /// No description provided for @sessionsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل الأيام المغلقة'**
  String get sessionsSubtitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة إعدادات النظام'**
  String get settingsSubtitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات والتنبيهات'**
  String get notificationsSubtitle;

  /// No description provided for @closedSessionsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم مغلق'**
  String closedSessionsCount(Object count);

  /// No description provided for @todaySalesNet.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات اليوم (صافي)'**
  String get todaySalesNet;

  /// No description provided for @totalProducts.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المنتجات'**
  String get totalProducts;

  /// No description provided for @productCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} منتج'**
  String productCount(Object count);

  /// No description provided for @lowStockAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات النواقص'**
  String get lowStockAlerts;

  /// No description provided for @lowStockCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} منتج ناقص'**
  String lowStockCount(Object count);

  /// No description provided for @unreadNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات غير مقروءة'**
  String get unreadNotifications;

  /// No description provided for @notificationsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} تنبيه'**
  String notificationsCount(Object count);

  /// No description provided for @currencyEg.
  ///
  /// In ar, this message translates to:
  /// **'ج.م'**
  String get currencyEg;

  /// No description provided for @salesTrendTitle.
  ///
  /// In ar, this message translates to:
  /// **'مؤشر المبيعات (آخر 7 أيام)'**
  String get salesTrendTitle;

  /// No description provided for @dailyNetSales.
  ///
  /// In ar, this message translates to:
  /// **'صافي المبيعات اليومية'**
  String get dailyNetSales;

  /// No description provided for @welcomeUser.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في نظام {name} لإدارة نقاط البيع'**
  String welcomeUser(Object name);

  /// No description provided for @sessionStaleWarning.
  ///
  /// In ar, this message translates to:
  /// **'اليوم الحالي مفتوح منذ {time} — يُنصح بإغلاقه وفتح يوم جديد'**
  String sessionStaleWarning(Object time);

  /// No description provided for @sessionOpenInfo.
  ///
  /// In ar, this message translates to:
  /// **'أنت الآن تعمل على يومية مفتوحة مسبقاً منذ {time}'**
  String sessionOpenInfo(Object time);

  /// No description provided for @daysText.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get daysText;

  /// No description provided for @hoursText.
  ///
  /// In ar, this message translates to:
  /// **'ساعة'**
  String get hoursText;

  /// No description provided for @minutesText.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get minutesText;

  /// No description provided for @quickActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get quickActions;

  /// No description provided for @recentSalesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات الأخيرة'**
  String get recentSalesTitle;

  /// No description provided for @hideRecentSales.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء المبيعات الأخيرة'**
  String get hideRecentSales;

  /// No description provided for @noSales.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مبيعات'**
  String get noSales;

  /// No description provided for @refundProcess.
  ///
  /// In ar, this message translates to:
  /// **'عملية استرجاع'**
  String get refundProcess;

  /// No description provided for @saleProcess.
  ///
  /// In ar, this message translates to:
  /// **'عملية بيع'**
  String get saleProcess;

  /// No description provided for @saleItemsSummary.
  ///
  /// In ar, this message translates to:
  /// **'{count} عنصر • {total} {currency}'**
  String saleItemsSummary(Object count, Object currency, Object total);

  /// No description provided for @recentOperationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'العمليات الأخيرة'**
  String get recentOperationsTitle;

  /// No description provided for @noRecentOperations.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات حديثة'**
  String get noRecentOperations;

  /// No description provided for @noOperationsToday.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات في هذا اليوم بعد'**
  String get noOperationsToday;

  /// No description provided for @loginsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} تسجيل دخول'**
  String loginsCount(Object count);

  /// No description provided for @activeDayUser.
  ///
  /// In ar, this message translates to:
  /// **'يوم نشط • {user}'**
  String activeDayUser(Object user);

  /// No description provided for @closedDayUser.
  ///
  /// In ar, this message translates to:
  /// **'يوم مغلق • {user}'**
  String closedDayUser(Object user);

  /// No description provided for @operationsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عملية'**
  String operationsCount(Object count);

  /// No description provided for @showMore.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get showMore;

  /// No description provided for @actSale.
  ///
  /// In ar, this message translates to:
  /// **'بيع'**
  String get actSale;

  /// No description provided for @actRefund.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع'**
  String get actRefund;

  /// No description provided for @actProductAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج'**
  String get actProductAdd;

  /// No description provided for @actProductUpdate.
  ///
  /// In ar, this message translates to:
  /// **'تعديل منتج'**
  String get actProductUpdate;

  /// No description provided for @actProductDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف منتج'**
  String get actProductDelete;

  /// No description provided for @actProductQtyUpdate.
  ///
  /// In ar, this message translates to:
  /// **'تعديل كمية'**
  String get actProductQtyUpdate;

  /// No description provided for @actUserAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستخدم'**
  String get actUserAdd;

  /// No description provided for @actUserUpdate.
  ///
  /// In ar, this message translates to:
  /// **'تعديل مستخدم'**
  String get actUserUpdate;

  /// No description provided for @actUserDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف مستخدم'**
  String get actUserDelete;

  /// No description provided for @actSessionOpen.
  ///
  /// In ar, this message translates to:
  /// **'فتح يوم'**
  String get actSessionOpen;

  /// No description provided for @actSessionClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق يوم'**
  String get actSessionClose;

  /// No description provided for @actRestock.
  ///
  /// In ar, this message translates to:
  /// **'شحنة جديدة'**
  String get actRestock;

  /// No description provided for @actExpense.
  ///
  /// In ar, this message translates to:
  /// **'مصروفات'**
  String get actExpense;

  /// No description provided for @actInvoiceDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف فاتورة'**
  String get actInvoiceDelete;

  /// No description provided for @actPrintReport.
  ///
  /// In ar, this message translates to:
  /// **'طباعة تقرير'**
  String get actPrintReport;

  /// No description provided for @actLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دخول'**
  String get actLogin;

  /// No description provided for @detailsItems.
  ///
  /// In ar, this message translates to:
  /// **'الأصناف: {items}'**
  String detailsItems(Object items);

  /// No description provided for @detailsTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي: {total} {currency}'**
  String detailsTotal(Object currency, Object total);

  /// No description provided for @detailsProduct.
  ///
  /// In ar, this message translates to:
  /// **'المنتج: {name}'**
  String detailsProduct(Object name);

  /// No description provided for @detailsQty.
  ///
  /// In ar, this message translates to:
  /// **'الكمية: {oldQty} ← {newQty}'**
  String detailsQty(Object newQty, Object oldQty);

  /// No description provided for @detailsPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر: {oldPrice} ← {newPrice}'**
  String detailsPrice(Object newPrice, Object oldPrice);

  /// No description provided for @detailsAddedQty.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المضافة: {qty}'**
  String detailsAddedQty(Object qty);

  /// No description provided for @detailsCategory.
  ///
  /// In ar, this message translates to:
  /// **'الفئة: {category}'**
  String detailsCategory(Object category);

  /// No description provided for @detailsAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ: {amount} {currency}'**
  String detailsAmount(Object amount, Object currency);

  /// No description provided for @detailsUser.
  ///
  /// In ar, this message translates to:
  /// **'المستخدم: {user}'**
  String detailsUser(Object user);

  /// No description provided for @detailsRole.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحية: {role}'**
  String detailsRole(Object role);

  /// No description provided for @salesScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'شاشة المبيعات'**
  String get salesScreenTitle;

  /// No description provided for @salesScreenSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة عمليات البيع والفواتير'**
  String get salesScreenSubtitle;

  /// No description provided for @searchErrorMsg.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في البحث: {message}'**
  String searchErrorMsg(Object message);

  /// No description provided for @productNotFound.
  ///
  /// In ar, this message translates to:
  /// **'المنتج غير موجود: {code}'**
  String productNotFound(Object code);

  /// No description provided for @outOfStock.
  ///
  /// In ar, this message translates to:
  /// **'نفذ'**
  String get outOfStock;

  /// No description provided for @maxQtyReached.
  ///
  /// In ar, this message translates to:
  /// **'لقد وصلت إلى الحد الأقصى للكمية المتاحة ({qty})'**
  String maxQtyReached(Object qty);

  /// No description provided for @cartEmpty.
  ///
  /// In ar, this message translates to:
  /// **'السلة فارغة'**
  String get cartEmpty;

  /// No description provided for @saveSaleFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل حفظ البيع: {message}'**
  String saveSaleFailed(Object message);

  /// No description provided for @saleCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تمت عملية البيع - الإجمالي: {total} {currency}'**
  String saleCompleted(Object currency, Object total);

  /// No description provided for @saleActivityDesc.
  ///
  /// In ar, this message translates to:
  /// **'عملية بيع: {total} {currency}'**
  String saleActivityDesc(Object currency, Object total);

  /// No description provided for @cantAddMoreStock.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن إضافة المزيد! الكمية المتاحة في المخزون: {qty}'**
  String cantAddMoreStock(Object qty);

  /// No description provided for @showRecentSales.
  ///
  /// In ar, this message translates to:
  /// **'عرض المبيعات الأخيرة'**
  String get showRecentSales;

  /// No description provided for @recentSalesLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات الأخيرة'**
  String get recentSalesLabel;

  /// No description provided for @cartProductList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة المنتجات'**
  String get cartProductList;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'السلة فارغة'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قم بمسح المنتجات لإضافتها'**
  String get cartEmptySubtitle;

  /// No description provided for @editPriceTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل السعر'**
  String get editPriceTitle;

  /// No description provided for @minPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للسعر: {price} {currency}'**
  String minPriceLabel(Object currency, Object price);

  /// No description provided for @newPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر الجديد'**
  String get newPriceLabel;

  /// No description provided for @priceValidationError.
  ///
  /// In ar, this message translates to:
  /// **'السعر يجب أن يكون أكبر من أو يساوي {price} {currency}'**
  String priceValidationError(Object currency, Object price);

  /// No description provided for @cancelBtn.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancelBtn;

  /// No description provided for @saveBtn.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get saveBtn;

  /// No description provided for @codeLabel.
  ///
  /// In ar, this message translates to:
  /// **'كود: {code}'**
  String codeLabel(Object code);

  /// No description provided for @dateLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ: {date}'**
  String dateLabel(Object date);

  /// No description provided for @remainingLabel.
  ///
  /// In ar, this message translates to:
  /// **'متبقي: {qty}'**
  String remainingLabel(Object qty);

  /// No description provided for @priceWithCurrency.
  ///
  /// In ar, this message translates to:
  /// **'{price} {currency}'**
  String priceWithCurrency(Object currency, Object price);

  /// No description provided for @invoiceSummaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'خلاصة الفاتورة'**
  String get invoiceSummaryTitle;

  /// No description provided for @itemCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد العناصر'**
  String get itemCountLabel;

  /// No description provided for @itemCountValue.
  ///
  /// In ar, this message translates to:
  /// **'{count} منتج'**
  String itemCountValue(Object count);

  /// No description provided for @subtotalLabel.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي'**
  String get subtotalLabel;

  /// No description provided for @grandTotalLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ الإجمالي'**
  String get grandTotalLabel;

  /// No description provided for @checkoutBtn.
  ///
  /// In ar, this message translates to:
  /// **'إتمام عملية الدفع'**
  String get checkoutBtn;

  /// No description provided for @clearCartBtn.
  ///
  /// In ar, this message translates to:
  /// **'إفراغ السلة'**
  String get clearCartBtn;

  /// No description provided for @barcodeScanHint.
  ///
  /// In ar, this message translates to:
  /// **'امسح الباركود أو ابحث عن منتج...'**
  String get barcodeScanHint;

  /// No description provided for @stockLabel.
  ///
  /// In ar, this message translates to:
  /// **'المخزون: {qty}'**
  String stockLabel(Object qty);

  /// No description provided for @enterUsername.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال اسم المستخدم'**
  String get enterUsername;

  /// No description provided for @enterPassword.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال كلمة المرور'**
  String get enterPassword;

  /// No description provided for @usersManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المستخدمين'**
  String get usersManagement;

  /// No description provided for @addUser.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستخدم'**
  String get addUser;

  /// No description provided for @noUsers.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مستخدمين'**
  String get noUsers;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @storeInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات المتجر'**
  String get storeInfo;

  /// No description provided for @noStoreInfo.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معلومات متجر'**
  String get noStoreInfo;

  /// No description provided for @storeName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المتجر'**
  String get storeName;

  /// No description provided for @storeAddress.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get storeAddress;

  /// No description provided for @storePhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get storePhone;

  /// No description provided for @storeEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get storeEmail;

  /// No description provided for @storeVat.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الضريبي'**
  String get storeVat;

  /// No description provided for @editStoreInfo.
  ///
  /// In ar, this message translates to:
  /// **'تعديل معلومات المتجر'**
  String get editStoreInfo;

  /// No description provided for @storeNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم المتجر *'**
  String get storeNameRequired;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get saveChanges;

  /// No description provided for @enterStoreName.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم المتجر'**
  String get enterStoreName;

  /// No description provided for @infoSavedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المعلومات بنجاح'**
  String get infoSavedSuccess;

  /// No description provided for @logoutWarningMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إنهاء يوم العمل الحالي والعودة لشاشة الدخول'**
  String get logoutWarningMessage;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @usernameColumn.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get usernameColumn;

  /// No description provided for @permission.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحية'**
  String get permission;

  /// No description provided for @accountStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الحساب'**
  String get accountStatus;

  /// No description provided for @lastLoginColumn.
  ///
  /// In ar, this message translates to:
  /// **'آخر تسجيل دخول'**
  String get lastLoginColumn;

  /// No description provided for @actions.
  ///
  /// In ar, this message translates to:
  /// **'العمليات'**
  String get actions;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get active;

  /// No description provided for @disabled.
  ///
  /// In ar, this message translates to:
  /// **'معطل'**
  String get disabled;

  /// No description provided for @editPermissions.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الصلاحيات'**
  String get editPermissions;

  /// No description provided for @deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteAccount;

  /// No description provided for @confirmDeleteUser.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد حذف المستخدم'**
  String get confirmDeleteUser;

  /// No description provided for @confirmDeleteUserMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف حساب المستخدم \"{name}\"؟ لا يمكن التراجع عن هذا الإجراء.'**
  String confirmDeleteUserMessage(Object name);

  /// No description provided for @protectionActivated.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل نظام الحماية بنجاح'**
  String get protectionActivated;

  /// No description provided for @restartApp.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تشغيل التطبيق'**
  String get restartApp;

  /// No description provided for @protectionActivatedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل نظام الحماية بنجاح!\n\nللاستفادة الكاملة من النظام، يُفضل إعادة تشغيل التطبيق.'**
  String get protectionActivatedMessage;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get ok;

  /// No description provided for @operationCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء العملية'**
  String get operationCancelled;

  /// No description provided for @noProducts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات'**
  String get noProducts;

  /// No description provided for @addProductsHint.
  ///
  /// In ar, this message translates to:
  /// **'قم بإضافة منتجات جديدة لعرضها هنا'**
  String get addProductsHint;

  /// No description provided for @productName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المنتج'**
  String get productName;

  /// No description provided for @barcode.
  ///
  /// In ar, this message translates to:
  /// **'الباركود'**
  String get barcode;

  /// No description provided for @category.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get category;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @wholesalePrice.
  ///
  /// In ar, this message translates to:
  /// **'جملة'**
  String get wholesalePrice;

  /// No description provided for @minPriceColumn.
  ///
  /// In ar, this message translates to:
  /// **'أدنى سعر'**
  String get minPriceColumn;

  /// No description provided for @quantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantity;

  /// No description provided for @status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// No description provided for @barcodeError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الباركود'**
  String get barcodeError;

  /// No description provided for @barcodeExistsMessage.
  ///
  /// In ar, this message translates to:
  /// **'المنتج ذو الباركود \"{barcode}\" موجود بالفعل.\nالرجاء استخدام باركود مختلف أو تعديل المنتج الموجود.'**
  String barcodeExistsMessage(Object barcode);

  /// No description provided for @addNewProduct.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج جديد'**
  String get addNewProduct;

  /// No description provided for @editProduct.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المنتج'**
  String get editProduct;

  /// No description provided for @barcodeNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الباركود'**
  String get barcodeNumber;

  /// No description provided for @wholesalePriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعرالجملة'**
  String get wholesalePriceLabel;

  /// No description provided for @minPriceLabel2.
  ///
  /// In ar, this message translates to:
  /// **'الحدالأدنى للسعر'**
  String get minPriceLabel2;

  /// No description provided for @sellingPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر البيع'**
  String get sellingPrice;

  /// No description provided for @availableQty.
  ///
  /// In ar, this message translates to:
  /// **'الكميةالمتوفرة'**
  String get availableQty;

  /// No description provided for @minStockLevel.
  ///
  /// In ar, this message translates to:
  /// **'الحدالأدنى للمخزون'**
  String get minStockLevel;

  /// No description provided for @addProduct.
  ///
  /// In ar, this message translates to:
  /// **'إضافة المنتج'**
  String get addProduct;

  /// No description provided for @categoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get categoryLabel;

  /// No description provided for @selectValidCategory.
  ///
  /// In ar, this message translates to:
  /// **'يجب اختيار فئة صالحة'**
  String get selectValidCategory;

  /// No description provided for @addNewCategory.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صنف جديد'**
  String get addNewCategory;

  /// No description provided for @categoryName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الصنف'**
  String get categoryName;

  /// No description provided for @addCategory.
  ///
  /// In ar, this message translates to:
  /// **'إضافة الصنف'**
  String get addCategory;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @lowStock.
  ///
  /// In ar, this message translates to:
  /// **'منخفض'**
  String get lowStock;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'متوفر'**
  String get available;

  /// No description provided for @restockProduct.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تخزين المنتج'**
  String get restockProduct;

  /// No description provided for @currentQuantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية الحالية'**
  String get currentQuantity;

  /// No description provided for @minLimit.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى'**
  String get minLimit;

  /// No description provided for @needed.
  ///
  /// In ar, this message translates to:
  /// **'المطلوب'**
  String get needed;

  /// No description provided for @restockQuantity.
  ///
  /// In ar, this message translates to:
  /// **'كمية إعادة التخزين'**
  String get restockQuantity;

  /// No description provided for @enterQuantity.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الكمية'**
  String get enterQuantity;

  /// No description provided for @quantityAfterRestock.
  ///
  /// In ar, this message translates to:
  /// **'الكمية بعد التخزين:'**
  String get quantityAfterRestock;

  /// No description provided for @enterValidQuantity.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال كمية صحيحة أكبر من صفر'**
  String get enterValidQuantity;

  /// No description provided for @confirmRestock.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد إعادة التخزين'**
  String get confirmRestock;

  /// No description provided for @restock.
  ///
  /// In ar, this message translates to:
  /// **'إعادة التخزين'**
  String get restock;

  /// No description provided for @stockManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة مخزون السلع'**
  String get stockManagement;

  /// No description provided for @stockManagementSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'متابعة المنتجات منخفضة الكمية وتحديث التوريدات وسد العجز بالمخازن'**
  String get stockManagementSubtitle;

  /// No description provided for @productsNeedRestock.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات التي تتطلب إعادة تخزين حالياً ({count})'**
  String productsNeedRestock(Object count);

  /// No description provided for @stockComplete.
  ///
  /// In ar, this message translates to:
  /// **'المخزون مكتمل ولا توجد عواجز'**
  String get stockComplete;

  /// No description provided for @allProductsAvailable.
  ///
  /// In ar, this message translates to:
  /// **'جميع السلع متوفرة بكميات تتجاوز الحد الأدنى للمخزون الموصى به'**
  String get allProductsAvailable;

  /// No description provided for @loadingStockData.
  ///
  /// In ar, this message translates to:
  /// **'جاري جرد وتحديث بيانات المخزن اليومي...'**
  String get loadingStockData;

  /// No description provided for @partialRefund.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع جزئي'**
  String get partialRefund;

  /// No description provided for @invoiceNumber.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة #{id}'**
  String invoiceNumber(Object id);

  /// No description provided for @totalRefundAmount.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبلغ المسترجع:'**
  String get totalRefundAmount;

  /// No description provided for @confirmRefund.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الاسترجاع'**
  String get confirmRefund;

  /// No description provided for @noRefundableProducts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات قابلة للاسترجاع'**
  String get noRefundableProducts;

  /// No description provided for @productColumn.
  ///
  /// In ar, this message translates to:
  /// **'المنتج'**
  String get productColumn;

  /// No description provided for @soldQty.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المباعة'**
  String get soldQty;

  /// No description provided for @alreadyRefunded.
  ///
  /// In ar, this message translates to:
  /// **'تم استرجاعه'**
  String get alreadyRefunded;

  /// No description provided for @remaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get remaining;

  /// No description provided for @priceColumn.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get priceColumn;

  /// No description provided for @refundQty.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المسترجعة'**
  String get refundQty;

  /// No description provided for @totalColumn.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get totalColumn;

  /// No description provided for @invalidNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم غير صالح'**
  String get invalidNumber;

  /// No description provided for @cannotBeNegative.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن أن يكون سالب'**
  String get cannotBeNegative;

  /// No description provided for @maxLimit.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى: {qty}'**
  String maxLimit(Object qty);

  /// No description provided for @loadingInvoices.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل الفواتير...'**
  String get loadingInvoices;

  /// No description provided for @noInvoicesInPeriod.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير في الفترة المحددة'**
  String get noInvoicesInPeriod;

  /// No description provided for @noRecentInvoices.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير حديثة'**
  String get noRecentInvoices;

  /// No description provided for @tryChangingFilter.
  ///
  /// In ar, this message translates to:
  /// **'جرب تغيير معايير البحث أو الفلتر'**
  String get tryChangingFilter;

  /// No description provided for @fromDate.
  ///
  /// In ar, this message translates to:
  /// **'من تاريخ'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In ar, this message translates to:
  /// **'إلى تاريخ'**
  String get toDate;

  /// No description provided for @searchInvoiceHint.
  ///
  /// In ar, this message translates to:
  /// **'امسح الباركود أو اكتب رقم الفاتورة...'**
  String get searchInvoiceHint;

  /// No description provided for @searchLabel.
  ///
  /// In ar, this message translates to:
  /// **'بحث: {query}'**
  String searchLabel(Object query);

  /// No description provided for @salesFilter.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات'**
  String get salesFilter;

  /// No description provided for @refundsFilter.
  ///
  /// In ar, this message translates to:
  /// **'مرتجعات'**
  String get refundsFilter;

  /// No description provided for @selectDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ'**
  String get selectDate;

  /// No description provided for @clearFilters.
  ///
  /// In ar, this message translates to:
  /// **'مسح الفلاتر'**
  String get clearFilters;

  /// No description provided for @selectDateRangeFirst.
  ///
  /// In ar, this message translates to:
  /// **'يجب تحديد نطاق التاريخ أولاً'**
  String get selectDateRangeFirst;

  /// No description provided for @deleteInvoices.
  ///
  /// In ar, this message translates to:
  /// **'حذف الفواتير'**
  String get deleteInvoices;

  /// No description provided for @clearInvoices.
  ///
  /// In ar, this message translates to:
  /// **'مسح الفواتير'**
  String get clearInvoices;

  /// No description provided for @cashier.
  ///
  /// In ar, this message translates to:
  /// **'الكاشير'**
  String get cashier;

  /// No description provided for @refunded.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع'**
  String get refunded;

  /// No description provided for @itemsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} أصناف'**
  String itemsCount(Object count);

  /// No description provided for @print.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get print;

  /// No description provided for @thermalReceiptTitle.
  ///
  /// In ar, this message translates to:
  /// **'إيصال دفع حراري (80mm)'**
  String get thermalReceiptTitle;

  /// No description provided for @a4InvoiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة مبيعات (A4)'**
  String get a4InvoiceTitle;

  /// No description provided for @invoiceNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الفاتورة: #{id}'**
  String invoiceNumberLabel(Object id);

  /// No description provided for @instantPrint.
  ///
  /// In ar, this message translates to:
  /// **'طباعة فورية'**
  String get instantPrint;

  /// No description provided for @managerOnlyDelete.
  ///
  /// In ar, this message translates to:
  /// **'فقط المدير يمكنه حذف الورديات.'**
  String get managerOnlyDelete;

  /// No description provided for @cannotDeleteOpenSession.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن حذف الوردية الحالية وهي مفتوحة.'**
  String get cannotDeleteOpenSession;

  /// No description provided for @confirmDeleteSession.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد حذف الوردية'**
  String get confirmDeleteSession;

  /// No description provided for @confirmDeleteSessionMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذه الوردية؟ سيتم حذف تقرير الإغلاق المرتبط بها نهائياً ولا يمكن التراجع.'**
  String get confirmDeleteSessionMessage;

  /// No description provided for @sessionDeletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الوردية بنجاح.'**
  String get sessionDeletedSuccess;

  /// No description provided for @sessionDeleteFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل حذف الوردية: {error}'**
  String sessionDeleteFailed(Object error);

  /// No description provided for @activeNow.
  ///
  /// In ar, this message translates to:
  /// **'نشطة الآن'**
  String get activeNow;

  /// No description provided for @hoursMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{hours}س {minutes}د'**
  String hoursMinutes(Object hours, Object minutes);

  /// No description provided for @minutesOnly.
  ///
  /// In ar, this message translates to:
  /// **'{minutes}د'**
  String minutesOnly(Object minutes);

  /// No description provided for @sessionsHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الورديات'**
  String get sessionsHistory;

  /// No description provided for @sessionsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} وردية مسجلة'**
  String sessionsCount(Object count);

  /// No description provided for @sessionsList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الورديات'**
  String get sessionsList;

  /// No description provided for @loadingSessions.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل الورديات...'**
  String get loadingSessions;

  /// No description provided for @noSessions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ورديات مسجلة'**
  String get noSessions;

  /// No description provided for @sessionsAutoAdd.
  ///
  /// In ar, this message translates to:
  /// **'ستُضاف الورديات تلقائياً فور فتحها وإغلاقها'**
  String get sessionsAutoAdd;

  /// No description provided for @sessionActive.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get sessionActive;

  /// No description provided for @sessionClosed.
  ///
  /// In ar, this message translates to:
  /// **'مغلقة'**
  String get sessionClosed;

  /// No description provided for @sessionId.
  ///
  /// In ar, this message translates to:
  /// **'وردية #{id}'**
  String sessionId(Object id);

  /// No description provided for @selectSessionForDetails.
  ///
  /// In ar, this message translates to:
  /// **'اختر وردية لعرض تفاصيلها'**
  String get selectSessionForDetails;

  /// No description provided for @selectSessionHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر إحدى الورديات من القائمة لعرض سجل العمليات والتقرير المالي'**
  String get selectSessionHint;

  /// No description provided for @operationsLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل العمليات'**
  String get operationsLog;

  /// No description provided for @financialReport.
  ///
  /// In ar, this message translates to:
  /// **'التقرير المالي'**
  String get financialReport;

  /// No description provided for @activeSession.
  ///
  /// In ar, this message translates to:
  /// **'وردية نشطة'**
  String get activeSession;

  /// No description provided for @closedSession.
  ///
  /// In ar, this message translates to:
  /// **'وردية مغلقة'**
  String get closedSession;

  /// No description provided for @printReport.
  ///
  /// In ar, this message translates to:
  /// **'طباعة التقرير'**
  String get printReport;

  /// No description provided for @deleteSession.
  ///
  /// In ar, this message translates to:
  /// **'حذف الوردية'**
  String get deleteSession;

  /// No description provided for @sessionStart.
  ///
  /// In ar, this message translates to:
  /// **'بدء الوردية'**
  String get sessionStart;

  /// No description provided for @sessionEnd.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق الوردية'**
  String get sessionEnd;

  /// No description provided for @totalDuration.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المدة'**
  String get totalDuration;

  /// No description provided for @searchOperationsHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث بالعملية أو اسم المستخدم...'**
  String get searchOperationsHint;

  /// No description provided for @allOperations.
  ///
  /// In ar, this message translates to:
  /// **'كل العمليات'**
  String get allOperations;

  /// No description provided for @noMatchingOperations.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات تطابق البحث'**
  String get noMatchingOperations;

  /// No description provided for @reportAfterClose.
  ///
  /// In ar, this message translates to:
  /// **'التقرير يتاح بعد إغلاق الوردية'**
  String get reportAfterClose;

  /// No description provided for @closeSessionForReport.
  ///
  /// In ar, this message translates to:
  /// **'أغلق الوردية الحالية لإنشاء التقرير المالي وعرض الإحصائيات'**
  String get closeSessionForReport;

  /// No description provided for @failedLoadReport.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل التقرير المالي'**
  String get failedLoadReport;

  /// No description provided for @noFinancialReport.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على تقرير مالي'**
  String get noFinancialReport;

  /// No description provided for @ensureSessionClosed.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من إغلاق الوردية بنجاح'**
  String get ensureSessionClosed;

  /// No description provided for @netSales.
  ///
  /// In ar, this message translates to:
  /// **'صافي المبيعات'**
  String get netSales;

  /// No description provided for @salesOperations.
  ///
  /// In ar, this message translates to:
  /// **'عمليات البيع'**
  String get salesOperations;

  /// No description provided for @refunds.
  ///
  /// In ar, this message translates to:
  /// **'المرتجعات'**
  String get refunds;

  /// No description provided for @datasheet.
  ///
  /// In ar, this message translates to:
  /// **'الجدول'**
  String get datasheet;

  /// No description provided for @noReportForSession.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تقرير لهذه الوردية'**
  String get noReportForSession;

  /// No description provided for @previewBeforePrint.
  ///
  /// In ar, this message translates to:
  /// **'معاينة التقرير قبل الطباعة'**
  String get previewBeforePrint;

  /// No description provided for @failedLoadReportError.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل التقرير: {error}'**
  String failedLoadReportError(Object error);

  /// No description provided for @readNotifications.
  ///
  /// In ar, this message translates to:
  /// **'مقروءة'**
  String get readNotifications;

  /// No description provided for @urgentNotifications.
  ///
  /// In ar, this message translates to:
  /// **'عاجلة'**
  String get urgentNotifications;

  /// No description provided for @unreadLabel.
  ///
  /// In ar, this message translates to:
  /// **'غير مقروءة'**
  String get unreadLabel;

  /// No description provided for @markAsReadUnread.
  ///
  /// In ar, this message translates to:
  /// **'وضع كغير مقروء'**
  String get markAsReadUnread;

  /// No description provided for @markAsRead.
  ///
  /// In ar, this message translates to:
  /// **'وضع كمقروء'**
  String get markAsRead;

  /// No description provided for @deleteNotification.
  ///
  /// In ar, this message translates to:
  /// **'حذف التنبيه'**
  String get deleteNotification;

  /// No description provided for @productCode.
  ///
  /// In ar, this message translates to:
  /// **'كود المنتج: {sku}'**
  String productCode(Object sku);

  /// No description provided for @markSelectedRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد المقروءة'**
  String get markSelectedRead;

  /// No description provided for @markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروءة'**
  String get markAllRead;

  /// No description provided for @deleteSelected.
  ///
  /// In ar, this message translates to:
  /// **'حذف المحدد'**
  String get deleteSelected;

  /// No description provided for @unexpectedError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get unexpectedError;

  /// No description provided for @productOutOfStock.
  ///
  /// In ar, this message translates to:
  /// **'المنتج نفد من المخزون'**
  String get productOutOfStock;

  /// No description provided for @productLowStock.
  ///
  /// In ar, this message translates to:
  /// **'كمية المنتج في المخزون منخفضة ({qty})'**
  String productLowStock(Object qty);

  /// No description provided for @yearlySalesSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص المبيعات السنوي'**
  String get yearlySalesSummary;

  /// No description provided for @totalLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي: {amount}'**
  String totalLabel(Object amount);

  /// No description provided for @noYearlyData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات سنوية'**
  String get noYearlyData;

  /// No description provided for @topSellingProducts.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات الأكثر مبيعاً'**
  String get topSellingProducts;

  /// No description provided for @soldCount.
  ///
  /// In ar, this message translates to:
  /// **'بيع: {qty} قطعة'**
  String soldCount(Object qty);

  /// No description provided for @totalSales.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبيعات'**
  String get totalSales;

  /// No description provided for @salesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عملية بيع'**
  String salesCount(Object count);

  /// No description provided for @totalCost.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة الكلية'**
  String get totalCost;

  /// No description provided for @productsCost.
  ///
  /// In ar, this message translates to:
  /// **'تكلفة المنتجات'**
  String get productsCost;

  /// No description provided for @netProfit.
  ///
  /// In ar, this message translates to:
  /// **'صافي الربح'**
  String get netProfit;

  /// No description provided for @loss.
  ///
  /// In ar, this message translates to:
  /// **'الخسارة'**
  String get loss;

  /// No description provided for @margin.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% هامش'**
  String margin(Object percent);

  /// No description provided for @averageSale.
  ///
  /// In ar, this message translates to:
  /// **'متوسط البيعة'**
  String get averageSale;

  /// No description provided for @perSale.
  ///
  /// In ar, this message translates to:
  /// **'لكل عملية بيع'**
  String get perSale;

  /// No description provided for @monthlySales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات الشهرية'**
  String get monthlySales;

  /// No description provided for @monthlyAverage.
  ///
  /// In ar, this message translates to:
  /// **'المتوسط/شهر'**
  String get monthlyAverage;

  /// No description provided for @months.
  ///
  /// In ar, this message translates to:
  /// **'الأشهر'**
  String get months;

  /// No description provided for @noDataToShow.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات للعرض'**
  String get noDataToShow;

  /// No description provided for @topProductsByMonth.
  ///
  /// In ar, this message translates to:
  /// **'أكثر المنتجات مبيعاً بالشهر'**
  String get topProductsByMonth;

  /// No description provided for @monthTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي {month}:'**
  String monthTotal(Object month);

  /// No description provided for @noProductsThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات في هذا الشهر'**
  String get noProductsThisMonth;

  /// No description provided for @salesByCategory.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات حسب الفئة'**
  String get salesByCategory;

  /// No description provided for @noCategoryData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات تصنيفات'**
  String get noCategoryData;

  /// No description provided for @dailySales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات اليومية'**
  String get dailySales;

  /// No description provided for @noDailyData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات يومية'**
  String get noDailyData;

  /// No description provided for @salesByHour.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات حسب الساعة'**
  String get salesByHour;

  /// No description provided for @noHourData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات للساعات'**
  String get noHourData;

  /// No description provided for @salesReportTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقارير وتحليلات المبيعات'**
  String get salesReportTitle;

  /// No description provided for @salesReportSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليل شامل لأداء المبيعات والأرباح'**
  String get salesReportSubtitle;

  /// No description provided for @currentSession.
  ///
  /// In ar, this message translates to:
  /// **'الجلسة الحالية'**
  String get currentSession;

  /// No description provided for @allTime.
  ///
  /// In ar, this message translates to:
  /// **'كل الوقت'**
  String get allTime;

  /// No description provided for @monthJan.
  ///
  /// In ar, this message translates to:
  /// **'يناير'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In ar, this message translates to:
  /// **'فبراير'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In ar, this message translates to:
  /// **'مارس'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In ar, this message translates to:
  /// **'أبريل'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In ar, this message translates to:
  /// **'مايو'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In ar, this message translates to:
  /// **'يونيو'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In ar, this message translates to:
  /// **'يوليو'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In ar, this message translates to:
  /// **'أغسطس'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In ar, this message translates to:
  /// **'سبتمبر'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In ar, this message translates to:
  /// **'أكتوبر'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In ar, this message translates to:
  /// **'نوفمبر'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In ar, this message translates to:
  /// **'ديسمبر'**
  String get monthDec;

  /// No description provided for @monthJanShort.
  ///
  /// In ar, this message translates to:
  /// **'ينا'**
  String get monthJanShort;

  /// No description provided for @monthFebShort.
  ///
  /// In ar, this message translates to:
  /// **'فبر'**
  String get monthFebShort;

  /// No description provided for @monthMarShort.
  ///
  /// In ar, this message translates to:
  /// **'مار'**
  String get monthMarShort;

  /// No description provided for @monthAprShort.
  ///
  /// In ar, this message translates to:
  /// **'أبر'**
  String get monthAprShort;

  /// No description provided for @monthMayShort.
  ///
  /// In ar, this message translates to:
  /// **'ماي'**
  String get monthMayShort;

  /// No description provided for @monthJunShort.
  ///
  /// In ar, this message translates to:
  /// **'يون'**
  String get monthJunShort;

  /// No description provided for @monthJulShort.
  ///
  /// In ar, this message translates to:
  /// **'يول'**
  String get monthJulShort;

  /// No description provided for @monthAugShort.
  ///
  /// In ar, this message translates to:
  /// **'أغس'**
  String get monthAugShort;

  /// No description provided for @monthSepShort.
  ///
  /// In ar, this message translates to:
  /// **'سبت'**
  String get monthSepShort;

  /// No description provided for @monthOctShort.
  ///
  /// In ar, this message translates to:
  /// **'أكت'**
  String get monthOctShort;

  /// No description provided for @monthNovShort.
  ///
  /// In ar, this message translates to:
  /// **'نوف'**
  String get monthNovShort;

  /// No description provided for @monthDecShort.
  ///
  /// In ar, this message translates to:
  /// **'ديس'**
  String get monthDecShort;

  /// No description provided for @stockSummaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليلات وملخص المخزون'**
  String get stockSummaryTitle;

  /// No description provided for @stockSummarySubtitleLong.
  ///
  /// In ar, this message translates to:
  /// **'متابعة حركة رأس المال في السلع، الأرباح المتوقعة، وقيم المخازن الكلية والتاريخية'**
  String get stockSummarySubtitleLong;

  /// No description provided for @totalHistoricValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة الكلية التاريخية'**
  String get totalHistoricValue;

  /// No description provided for @historicValueTooltip.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي تكلفة جميع البضائع التي تم إدخالها للنظام تاريخياً'**
  String get historicValueTooltip;

  /// No description provided for @currentWholesaleValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة الحالية (جملة)'**
  String get currentWholesaleValue;

  /// No description provided for @currentWholesaleTooltip.
  ///
  /// In ar, this message translates to:
  /// **'قيمة المخزون الحالي بالكامل بسعر الجملة'**
  String get currentWholesaleTooltip;

  /// No description provided for @expectedProfit.
  ///
  /// In ar, this message translates to:
  /// **'صافي الأرباح المتوقعة'**
  String get expectedProfit;

  /// No description provided for @expectedProfitTooltip.
  ///
  /// In ar, this message translates to:
  /// **'العائد المالي المتوقع (الفرق بين قيمة البيع وسعر الجملة للمخزون الحالي)'**
  String get expectedProfitTooltip;

  /// No description provided for @filterByCategory.
  ///
  /// In ar, this message translates to:
  /// **'تصفية حسب تصنيف السلع'**
  String get filterByCategory;

  /// No description provided for @allCategoriesFilter.
  ///
  /// In ar, this message translates to:
  /// **'كل الأقسام والتصنيفات'**
  String get allCategoriesFilter;

  /// No description provided for @totalValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة الإجمالية'**
  String get totalValue;

  /// No description provided for @historicValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة التاريخية'**
  String get historicValue;

  /// No description provided for @profitMarginPercent.
  ///
  /// In ar, this message translates to:
  /// **'هامش الربح %'**
  String get profitMarginPercent;

  /// No description provided for @sortAsc.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب تصاعدي'**
  String get sortAsc;

  /// No description provided for @sortDesc.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب تنازلي'**
  String get sortDesc;

  /// No description provided for @sectionColumn.
  ///
  /// In ar, this message translates to:
  /// **'القسم'**
  String get sectionColumn;

  /// No description provided for @productsColumn.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get productsColumn;

  /// No description provided for @currentStock.
  ///
  /// In ar, this message translates to:
  /// **'المخزون الحالي'**
  String get currentStock;

  /// No description provided for @outputsColumn.
  ///
  /// In ar, this message translates to:
  /// **'المخرجات'**
  String get outputsColumn;

  /// No description provided for @historicValueColumn.
  ///
  /// In ar, this message translates to:
  /// **'القيمة التاريخية'**
  String get historicValueColumn;

  /// No description provided for @currentWholesaleColumn.
  ///
  /// In ar, this message translates to:
  /// **'القيمة الحالية (جملة)'**
  String get currentWholesaleColumn;

  /// No description provided for @expectedSellValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة المتوقعة (بيع)'**
  String get expectedSellValue;

  /// No description provided for @archivedSection.
  ///
  /// In ar, this message translates to:
  /// **'قسم أرشيفي ممسوح يحتوي على عمليات بيع سابقة'**
  String get archivedSection;

  /// No description provided for @otherSections.
  ///
  /// In ar, this message translates to:
  /// **'أقسام أخرى'**
  String get otherSections;

  /// No description provided for @stockValueDistribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع قيمة المخزون الحالي (جملة)'**
  String get stockValueDistribution;

  /// No description provided for @capitalInGoods.
  ///
  /// In ar, this message translates to:
  /// **'رأس المال المستثمر في البضائع حسب القسم'**
  String get capitalInGoods;

  /// No description provided for @totalValueAmount.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي القيمة: {amount} ج.م'**
  String totalValueAmount(Object amount);

  /// No description provided for @stockQtyDistribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع كميات السلع المتوفرة'**
  String get stockQtyDistribution;

  /// No description provided for @qtyBySection.
  ///
  /// In ar, this message translates to:
  /// **'عدد القطع المتوفرة في المخازن حسب القسم'**
  String get qtyBySection;

  /// No description provided for @totalQtyAmount.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الكمية: {amount} قطعة'**
  String totalQtyAmount(Object amount);

  /// No description provided for @insufficientDataForChart.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات كافية لعرض المخطط'**
  String get insufficientDataForChart;

  /// No description provided for @categoryDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل حركة منتجات القسم'**
  String get categoryDetails;

  /// No description provided for @productNameColumn.
  ///
  /// In ar, this message translates to:
  /// **'اسم المنتج'**
  String get productNameColumn;

  /// No description provided for @salesColumn.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get salesColumn;

  /// No description provided for @refundsColumn.
  ///
  /// In ar, this message translates to:
  /// **'المرتجعات'**
  String get refundsColumn;

  /// No description provided for @netSoldColumn.
  ///
  /// In ar, this message translates to:
  /// **'صافي المباع'**
  String get netSoldColumn;

  /// No description provided for @unitCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} وحدة'**
  String unitCount(Object count);

  /// No description provided for @totalSalesOverall.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبيعات الكلية'**
  String get totalSalesOverall;

  /// No description provided for @totalRefundsOverall.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المرتجعات الكلية'**
  String get totalRefundsOverall;

  /// No description provided for @netActualSales.
  ///
  /// In ar, this message translates to:
  /// **'صافي المبيعات الفعلية'**
  String get netActualSales;

  /// No description provided for @nameSort.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get nameSort;

  /// No description provided for @qtySort.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get qtySort;

  /// No description provided for @generalCategory.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get generalCategory;

  /// No description provided for @deletedCategory.
  ///
  /// In ar, this message translates to:
  /// **'المحذوفة'**
  String get deletedCategory;

  /// No description provided for @receiptPhone.
  ///
  /// In ar, this message translates to:
  /// **'هاتف: {phone}'**
  String receiptPhone(Object phone);

  /// No description provided for @refundInvoice.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة مرتجع'**
  String get refundInvoice;

  /// No description provided for @salesInvoice.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة مبيعات'**
  String get salesInvoice;

  /// No description provided for @invoiceNumberPdf.
  ///
  /// In ar, this message translates to:
  /// **'رقم الفاتورة:'**
  String get invoiceNumberPdf;

  /// No description provided for @datePdf.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ:'**
  String get datePdf;

  /// No description provided for @cashierPdf.
  ///
  /// In ar, this message translates to:
  /// **'الكاشير:'**
  String get cashierPdf;

  /// No description provided for @unknown.
  ///
  /// In ar, this message translates to:
  /// **'غير معروف'**
  String get unknown;

  /// No description provided for @totalPdf.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي:'**
  String get totalPdf;

  /// No description provided for @thankYou.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لزيارتكم!'**
  String get thankYou;

  /// No description provided for @vatNumber.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الضريبي: {vat}'**
  String vatNumber(Object vat);

  /// No description provided for @pdfProductHeader.
  ///
  /// In ar, this message translates to:
  /// **'المنتج'**
  String get pdfProductHeader;

  /// No description provided for @pdfQtyHeader.
  ///
  /// In ar, this message translates to:
  /// **'ق'**
  String get pdfQtyHeader;

  /// No description provided for @pdfPriceHeader.
  ///
  /// In ar, this message translates to:
  /// **'س'**
  String get pdfPriceHeader;

  /// No description provided for @pdfTotalHeader.
  ///
  /// In ar, this message translates to:
  /// **'ج'**
  String get pdfTotalHeader;

  /// No description provided for @productNotFoundCubit.
  ///
  /// In ar, this message translates to:
  /// **'المنتج غير موجود'**
  String get productNotFoundCubit;

  /// No description provided for @productUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'المنتج غير متوفر في المخزون'**
  String get productUnavailable;

  /// No description provided for @priceBelowMin.
  ///
  /// In ar, this message translates to:
  /// **'السعر أقل من الحد الأدنى ({price} ج.م)'**
  String priceBelowMin(Object price);

  /// No description provided for @cartIsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'السلة فارغة'**
  String get cartIsEmpty;

  /// No description provided for @failedOpenSession.
  ///
  /// In ar, this message translates to:
  /// **'فشل فتح يوم جديد: {error}'**
  String failedOpenSession(Object error);

  /// No description provided for @saleSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت عملية البيع بنجاح'**
  String get saleSuccess;

  /// No description provided for @dbError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في قاعدة البيانات'**
  String get dbError;

  /// No description provided for @fileSystemError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في نظام الملفات'**
  String get fileSystemError;

  /// No description provided for @unexpectedErrorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get unexpectedErrorGeneric;

  /// No description provided for @noProductsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات'**
  String get noProductsEmpty;

  /// No description provided for @noProductsSearchMatch.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على منتجات تطابق البحث'**
  String get noProductsSearchMatch;

  /// No description provided for @noAlertsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات'**
  String get noAlertsEmpty;

  /// No description provided for @alertsWillShowHere.
  ///
  /// In ar, this message translates to:
  /// **'سيتم عرض التنبيهات هنا عند توفرها'**
  String get alertsWillShowHere;

  /// No description provided for @msgProductAdded.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة المنتج بنجاح'**
  String get msgProductAdded;

  /// No description provided for @msgProductUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المنتج بنجاح'**
  String get msgProductUpdated;

  /// No description provided for @msgProductDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المنتج بنجاح'**
  String get msgProductDeleted;

  /// No description provided for @msgSaleCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم إتمام البيع بنجاح'**
  String get msgSaleCompleted;

  /// No description provided for @msgDataSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ البيانات بنجاح'**
  String get msgDataSaved;

  /// No description provided for @msgReportGenerated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء التقرير بنجاح'**
  String get msgReportGenerated;

  /// No description provided for @msgUserCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء المستخدم بنجاح'**
  String get msgUserCreated;

  /// No description provided for @msgUserUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المستخدم بنجاح'**
  String get msgUserUpdated;

  /// No description provided for @msgUserDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المستخدم بنجاح'**
  String get msgUserDeleted;

  /// No description provided for @msgLoginSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدخول بنجاح'**
  String get msgLoginSuccess;

  /// No description provided for @msgLogoutSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الخروج بنجاح'**
  String get msgLogoutSuccess;

  /// No description provided for @msgPasswordChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور بنجاح'**
  String get msgPasswordChanged;

  /// No description provided for @msgSettingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الإعدادات بنجاح'**
  String get msgSettingsSaved;

  /// No description provided for @errProductNotFound.
  ///
  /// In ar, this message translates to:
  /// **'المنتج غير موجود'**
  String get errProductNotFound;

  /// No description provided for @errInsufficientStock.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المتاحة غير كافية'**
  String get errInsufficientStock;

  /// No description provided for @errInvalidInput.
  ///
  /// In ar, this message translates to:
  /// **'البيانات المدخلة غير صحيحة'**
  String get errInvalidInput;

  /// No description provided for @errNetworkError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال بالشبكة'**
  String get errNetworkError;

  /// No description provided for @errServerError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الخادم'**
  String get errServerError;

  /// No description provided for @errLoginFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تسجيل الدخول'**
  String get errLoginFailed;

  /// No description provided for @errAccessDenied.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك صلاحية للوصول'**
  String get errAccessDenied;

  /// No description provided for @errFileNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الملف غير موجود'**
  String get errFileNotFound;

  /// No description provided for @errSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل في حفظ البيانات'**
  String get errSaveFailed;

  /// No description provided for @errDeleteFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل في حذف البيانات'**
  String get errDeleteFailed;

  /// No description provided for @errUpdateFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحديث البيانات'**
  String get errUpdateFailed;

  /// No description provided for @closeSession.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق اليومية'**
  String get closeSession;

  /// No description provided for @closeSessionSub.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الوردية الحالية وإصدار تقرير الإغلاق'**
  String get closeSessionSub;

  /// No description provided for @dayClosedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إغلاق اليوم بنجاح. جاري تسجيل الخروج...'**
  String get dayClosedSuccess;

  /// No description provided for @dayClosedSuccessReport.
  ///
  /// In ar, this message translates to:
  /// **'تم إغلاق اليوم بنجاح'**
  String get dayClosedSuccessReport;

  /// No description provided for @viewDayReport.
  ///
  /// In ar, this message translates to:
  /// **'عرض تقرير اليوم'**
  String get viewDayReport;

  /// No description provided for @savedReportManager.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ تقرير اليوم. يمكنك عرض التقرير التفصيلي.'**
  String get savedReportManager;

  /// No description provided for @savedReportCashier.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ تقرير اليوم. سيتم تسجيل الخروج الآن.'**
  String get savedReportCashier;

  /// No description provided for @logoutShort.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get logoutShort;

  /// No description provided for @settingsScreenSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات النظام وإدارة المستخدمين'**
  String get settingsScreenSubtitle;

  /// No description provided for @fillRequiredFields.
  ///
  /// In ar, this message translates to:
  /// **'يرجى ملء الحقول المطلوبة'**
  String get fillRequiredFields;

  /// No description provided for @addNewUser.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستخدم جديد'**
  String get addNewUser;

  /// No description provided for @editUser.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المستخدم'**
  String get editUser;

  /// No description provided for @nameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم *'**
  String get nameRequired;

  /// No description provided for @usernameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم *'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور *'**
  String get passwordRequired;

  /// No description provided for @userType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المستخدم'**
  String get userType;

  /// No description provided for @addUserButton.
  ///
  /// In ar, this message translates to:
  /// **'إضافة المستخدم'**
  String get addUserButton;

  /// No description provided for @dataManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة البيانات والنسخ الاحتياطي'**
  String get dataManagement;

  /// No description provided for @dataManagementSub.
  ///
  /// In ar, this message translates to:
  /// **'عرض سجلات النظام، النسخ الاحتياطي، ونقاط الاستعادة'**
  String get dataManagementSub;

  /// No description provided for @activitySessionOpened.
  ///
  /// In ar, this message translates to:
  /// **'فتح {user} يومية عمل جديدة'**
  String activitySessionOpened(Object user);

  /// No description provided for @activitySessionClosed.
  ///
  /// In ar, this message translates to:
  /// **'أغلق {user} اليومية'**
  String activitySessionClosed(Object user);

  /// No description provided for @activityLogin.
  ///
  /// In ar, this message translates to:
  /// **'قام {user} بتسجيل الدخول'**
  String activityLogin(Object user);

  /// No description provided for @activityProductAdded.
  ///
  /// In ar, this message translates to:
  /// **'قام {user} بإضافة المنتج {product}'**
  String activityProductAdded(Object user, Object product);

  /// No description provided for @activityProductUpdated.
  ///
  /// In ar, this message translates to:
  /// **'قام {user} بتحديث المنتج {product}'**
  String activityProductUpdated(Object user, Object product);

  /// No description provided for @activityProductDeleted.
  ///
  /// In ar, this message translates to:
  /// **'قام {user} بحذف المنتج {product}'**
  String activityProductDeleted(Object user, Object product);

  /// No description provided for @activityProductQtyUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تحديث مخزون {product} بواسطة {user} ({qty})'**
  String activityProductQtyUpdated(Object user, Object product, Object qty);

  /// No description provided for @activityRestock.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تخزين {product} بواسطة {user} بـ {qty} وحدات'**
  String activityRestock(Object user, Object product, Object qty);

  /// No description provided for @activitySaleCompleted.
  ///
  /// In ar, this message translates to:
  /// **'عملية بيع بواسطة {user} بقيمة {total}'**
  String activitySaleCompleted(Object user, Object total);

  /// No description provided for @activityRefundCompleted.
  ///
  /// In ar, this message translates to:
  /// **'عملية مرتجع بواسطة {user} بقيمة {total}'**
  String activityRefundCompleted(Object user, Object total);

  /// No description provided for @activityUserAdded.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مستخدم {targetUser} بواسطة {user}'**
  String activityUserAdded(Object user, Object targetUser);

  /// No description provided for @activityUserUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تعديل مستخدم {targetUser} بواسطة {user}'**
  String activityUserUpdated(Object user, Object targetUser);

  /// No description provided for @activityUserDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حذف مستخدم {targetUser} بواسطة {user}'**
  String activityUserDeleted(Object user, Object targetUser);

  /// No description provided for @activityInvoiceDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حذف فاتورة #{id} بواسطة {user}'**
  String activityInvoiceDeleted(Object user, Object id);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
