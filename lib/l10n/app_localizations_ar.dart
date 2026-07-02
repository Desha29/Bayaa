// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'بياع';

  @override
  String get systemSubtitle => 'نظام نقاط البيع وإدارة مبيعات التجزئة';

  @override
  String get loginWelcome => 'أهلاً بك مجدداً!';

  @override
  String get loginSubtitle => 'الرجاء إدخال بيانات حسابك للوصول إلى النظام';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get usernameHint => 'أدخل اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get rememberMe => 'تذكرني على هذا الجهاز';

  @override
  String get loginButton => 'دخول النظام';

  @override
  String get quickLoginHeader => 'تجربة سريعة للنظام بأدوار مختلفة:';

  @override
  String get sessionOpenWarning =>
      'يوجد يومية مفتوحة حالياً. تسجيل الدخول سيتابع عليها.';

  @override
  String get offlineFeature => 'عمل كامل دون اتصال بالإنترنت (أوفلاين)';

  @override
  String get barcodeFeature => 'فحص مبيعات سريع بالباركود وطباعة فواتير PDF';

  @override
  String get reportsFeature => 'تقارير أرباح يومية ومراقبة وتتبع حركة المبيعات';

  @override
  String get systemDescription =>
      'نظام نقاط البيع الاحترافي وإدارة التجزئة لجميع المحلات التجارية ومحلات الهواتف الذكية. يعمل بالكامل أوفلاين دون الحاجة للإنترنت مع حماية كاملة ومزامنة محلية لبياناتك.';

  @override
  String get version => 'إصدار';

  @override
  String get copyright => 'جميع الحقوق محفوظة.';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get sales => 'المبيعات';

  @override
  String get invoices => 'الفواتير';

  @override
  String get products => 'المنتجات';

  @override
  String get stockAlerts => 'المنتجات الناقصة';

  @override
  String get stockSummary => 'ملخص المخزون';

  @override
  String get reports => 'الإحصائيات';

  @override
  String get sessions => 'الايام';

  @override
  String get notifications => 'التنبيهات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get homeSection => 'الرئيسية';

  @override
  String get salesSection => 'المبيعات والفواتير';

  @override
  String get stockSection => 'المخازن والمنتجات';

  @override
  String get systemSection => 'النظام والتقارير';

  @override
  String get roleManager => 'مدير النظام';

  @override
  String get roleCashier => 'كاشير';

  @override
  String get connected => 'متصل';

  @override
  String get trial => 'تجريبي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تأكيد تسجيل الخروج';

  @override
  String get logoutConfirmMessage => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get logoutConfirmSub =>
      'سيتم إنهاء يوم العمل الحالي والعودة إلى شاشة تسجيل الدخول.';

  @override
  String get loggingOut => 'جاري تسجيل الخروج...';

  @override
  String get logoutSuccess => 'تم تسجيل الخروج بنجاح';

  @override
  String get logoutFailed => 'فشل تسجيل الخروج';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get search => 'بحث';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get error => 'حدث خطأ';

  @override
  String get screenUnavailable => 'الشاشة غير متاحة';

  @override
  String get systemSlogan => 'نظام نقاط البيع الاحترافي';

  @override
  String get salesSubtitle => 'إدارة عمليات البيع';

  @override
  String get invoicesSubtitle => 'إدارة الفواتير';

  @override
  String get productsSubtitle => 'إدارة المخزون';

  @override
  String get stockAlertsSubtitle => 'تنبيهات المخزون';

  @override
  String get stockSummarySubtitle => 'تصنيفات المخزون';

  @override
  String get reportsSubtitle => 'تحليلات النظام';

  @override
  String get sessionsSubtitle => 'سجل الأيام المغلقة';

  @override
  String get settingsSubtitle => 'إدارة إعدادات النظام';

  @override
  String get notificationsSubtitle => 'الإشعارات والتنبيهات';

  @override
  String closedSessionsCount(Object count) {
    return '$count يوم مغلق';
  }

  @override
  String get todaySalesNet => 'مبيعات اليوم (صافي)';

  @override
  String get totalProducts => 'إجمالي المنتجات';

  @override
  String productCount(Object count) {
    return '$count منتج';
  }

  @override
  String get lowStockAlerts => 'تنبيهات النواقص';

  @override
  String lowStockCount(Object count) {
    return '$count منتج ناقص';
  }

  @override
  String get unreadNotifications => 'تنبيهات غير مقروءة';

  @override
  String notificationsCount(Object count) {
    return '$count تنبيه';
  }

  @override
  String get currencyEg => 'ج.م';

  @override
  String get salesTrendTitle => 'مؤشر المبيعات (آخر 7 أيام)';

  @override
  String get dailyNetSales => 'صافي المبيعات اليومية';

  @override
  String welcomeUser(Object name) {
    return 'مرحباً بك في نظام $name لإدارة نقاط البيع';
  }

  @override
  String sessionStaleWarning(Object time) {
    return 'اليوم الحالي مفتوح منذ $time — يُنصح بإغلاقه وفتح يوم جديد';
  }

  @override
  String sessionOpenInfo(Object time) {
    return 'أنت الآن تعمل على يومية مفتوحة مسبقاً منذ $time';
  }

  @override
  String get daysText => 'يوم';

  @override
  String get hoursText => 'ساعة';

  @override
  String get minutesText => 'دقيقة';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get recentSalesTitle => 'المبيعات الأخيرة';

  @override
  String get hideRecentSales => 'إخفاء المبيعات الأخيرة';

  @override
  String get noSales => 'لا توجد مبيعات';

  @override
  String get refundProcess => 'عملية استرجاع';

  @override
  String get saleProcess => 'عملية بيع';

  @override
  String saleItemsSummary(Object count, Object currency, Object total) {
    return '$count عنصر • $total $currency';
  }

  @override
  String get recentOperationsTitle => 'العمليات الأخيرة';

  @override
  String get noRecentOperations => 'لا توجد عمليات حديثة';

  @override
  String get noOperationsToday => 'لا توجد عمليات في هذا اليوم بعد';

  @override
  String loginsCount(Object count) {
    return '$count تسجيل دخول';
  }

  @override
  String activeDayUser(Object user) {
    return 'يوم نشط • $user';
  }

  @override
  String closedDayUser(Object user) {
    return 'يوم مغلق • $user';
  }

  @override
  String operationsCount(Object count) {
    return '$count عملية';
  }

  @override
  String get showMore => 'عرض المزيد';

  @override
  String get actSale => 'بيع';

  @override
  String get actRefund => 'استرجاع';

  @override
  String get actProductAdd => 'إضافة منتج';

  @override
  String get actProductUpdate => 'تعديل منتج';

  @override
  String get actProductDelete => 'حذف منتج';

  @override
  String get actProductQtyUpdate => 'تعديل كمية';

  @override
  String get actUserAdd => 'إضافة مستخدم';

  @override
  String get actUserUpdate => 'تعديل مستخدم';

  @override
  String get actUserDelete => 'حذف مستخدم';

  @override
  String get actSessionOpen => 'فتح يوم';

  @override
  String get actSessionClose => 'إغلاق يوم';

  @override
  String get actRestock => 'شحنة جديدة';

  @override
  String get actExpense => 'مصروفات';

  @override
  String get actInvoiceDelete => 'حذف فاتورة';

  @override
  String get actPrintReport => 'طباعة تقرير';

  @override
  String get actLogin => 'تسجيل دخول';

  @override
  String detailsItems(Object items) {
    return 'الأصناف: $items';
  }

  @override
  String detailsTotal(Object currency, Object total) {
    return 'الإجمالي: $total $currency';
  }

  @override
  String detailsProduct(Object name) {
    return 'المنتج: $name';
  }

  @override
  String detailsQty(Object newQty, Object oldQty) {
    return 'الكمية: $oldQty ← $newQty';
  }

  @override
  String detailsPrice(Object newPrice, Object oldPrice) {
    return 'السعر: $oldPrice ← $newPrice';
  }

  @override
  String detailsAddedQty(Object qty) {
    return 'الكمية المضافة: $qty';
  }

  @override
  String detailsCategory(Object category) {
    return 'الفئة: $category';
  }

  @override
  String detailsAmount(Object amount, Object currency) {
    return 'المبلغ: $amount $currency';
  }

  @override
  String detailsUser(Object user) {
    return 'المستخدم: $user';
  }

  @override
  String detailsRole(Object role) {
    return 'الصلاحية: $role';
  }

  @override
  String get salesScreenTitle => 'شاشة المبيعات';

  @override
  String get salesScreenSubtitle => 'إدارة عمليات البيع والفواتير';

  @override
  String searchErrorMsg(Object message) {
    return 'خطأ في البحث: $message';
  }

  @override
  String productNotFound(Object code) {
    return 'المنتج غير موجود: $code';
  }

  @override
  String get outOfStock => 'نفذ';

  @override
  String maxQtyReached(Object qty) {
    return 'لقد وصلت إلى الحد الأقصى للكمية المتاحة ($qty)';
  }

  @override
  String get cartEmpty => 'السلة فارغة';

  @override
  String saveSaleFailed(Object message) {
    return 'فشل حفظ البيع: $message';
  }

  @override
  String saleCompleted(Object currency, Object total) {
    return 'تمت عملية البيع - الإجمالي: $total $currency';
  }

  @override
  String saleActivityDesc(Object currency, Object total) {
    return 'عملية بيع: $total $currency';
  }

  @override
  String cantAddMoreStock(Object qty) {
    return 'لا يمكن إضافة المزيد! الكمية المتاحة في المخزون: $qty';
  }

  @override
  String get showRecentSales => 'عرض المبيعات الأخيرة';

  @override
  String get recentSalesLabel => 'المبيعات الأخيرة';

  @override
  String get cartProductList => 'قائمة المنتجات';

  @override
  String get cartEmptyTitle => 'السلة فارغة';

  @override
  String get cartEmptySubtitle => 'قم بمسح المنتجات لإضافتها';

  @override
  String get editPriceTitle => 'تعديل السعر';

  @override
  String minPriceLabel(Object currency, Object price) {
    return 'الحد الأدنى للسعر: $price $currency';
  }

  @override
  String get newPriceLabel => 'السعر الجديد';

  @override
  String priceValidationError(Object currency, Object price) {
    return 'السعر يجب أن يكون أكبر من أو يساوي $price $currency';
  }

  @override
  String get cancelBtn => 'إلغاء';

  @override
  String get saveBtn => 'حفظ';

  @override
  String codeLabel(Object code) {
    return 'كود: $code';
  }

  @override
  String dateLabel(Object date) {
    return 'تاريخ: $date';
  }

  @override
  String remainingLabel(Object qty) {
    return 'متبقي: $qty';
  }

  @override
  String priceWithCurrency(Object currency, Object price) {
    return '$price $currency';
  }

  @override
  String get invoiceSummaryTitle => 'خلاصة الفاتورة';

  @override
  String get itemCountLabel => 'عدد العناصر';

  @override
  String itemCountValue(Object count) {
    return '$count منتج';
  }

  @override
  String get subtotalLabel => 'المجموع الفرعي';

  @override
  String get grandTotalLabel => 'المبلغ الإجمالي';

  @override
  String get checkoutBtn => 'إتمام عملية الدفع';

  @override
  String get clearCartBtn => 'إفراغ السلة';

  @override
  String get barcodeScanHint => 'امسح الباركود أو ابحث عن منتج...';

  @override
  String stockLabel(Object qty) {
    return 'المخزون: $qty';
  }

  @override
  String get enterUsername => 'الرجاء إدخال اسم المستخدم';

  @override
  String get enterPassword => 'الرجاء إدخال كلمة المرور';

  @override
  String get usersManagement => 'إدارة المستخدمين';

  @override
  String get addUser => 'إضافة مستخدم';

  @override
  String get noUsers => 'لا يوجد مستخدمين';

  @override
  String get today => 'اليوم';

  @override
  String get storeInfo => 'معلومات المتجر';

  @override
  String get noStoreInfo => 'لا توجد معلومات متجر';

  @override
  String get storeName => 'اسم المتجر';

  @override
  String get storeAddress => 'العنوان';

  @override
  String get storePhone => 'رقم الهاتف';

  @override
  String get storeEmail => 'البريد الإلكتروني';

  @override
  String get storeVat => 'الرقم الضريبي';

  @override
  String get editStoreInfo => 'تعديل معلومات المتجر';

  @override
  String get storeNameRequired => 'اسم المتجر *';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get enterStoreName => 'يرجى إدخال اسم المتجر';

  @override
  String get infoSavedSuccess => 'تم حفظ المعلومات بنجاح';

  @override
  String get logoutWarningMessage =>
      'سيتم إنهاء يوم العمل الحالي والعودة لشاشة الدخول';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get usernameColumn => 'اسم المستخدم';

  @override
  String get permission => 'الصلاحية';

  @override
  String get accountStatus => 'حالة الحساب';

  @override
  String get lastLoginColumn => 'آخر تسجيل دخول';

  @override
  String get actions => 'العمليات';

  @override
  String get active => 'نشط';

  @override
  String get disabled => 'معطل';

  @override
  String get editPermissions => 'تعديل الصلاحيات';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get confirmDeleteUser => 'تأكيد حذف المستخدم';

  @override
  String confirmDeleteUserMessage(Object name) {
    return 'هل أنت متأكد من حذف حساب المستخدم \"$name\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get protectionActivated => 'تم تفعيل نظام الحماية بنجاح';

  @override
  String get restartApp => 'إعادة تشغيل التطبيق';

  @override
  String get protectionActivatedMessage =>
      'تم تفعيل نظام الحماية بنجاح!\n\nللاستفادة الكاملة من النظام، يُفضل إعادة تشغيل التطبيق.';

  @override
  String get ok => 'حسناً';

  @override
  String get operationCancelled => 'تم إلغاء العملية';

  @override
  String get noProducts => 'لا توجد منتجات';

  @override
  String get addProductsHint => 'قم بإضافة منتجات جديدة لعرضها هنا';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get barcode => 'الباركود';

  @override
  String get category => 'الفئة';

  @override
  String get price => 'السعر';

  @override
  String get wholesalePrice => 'جملة';

  @override
  String get minPriceColumn => 'أدنى سعر';

  @override
  String get quantity => 'الكمية';

  @override
  String get status => 'الحالة';

  @override
  String get barcodeError => 'خطأ في الباركود';

  @override
  String barcodeExistsMessage(Object barcode) {
    return 'المنتج ذو الباركود \"$barcode\" موجود بالفعل.\nالرجاء استخدام باركود مختلف أو تعديل المنتج الموجود.';
  }

  @override
  String get addNewProduct => 'إضافة منتج جديد';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get barcodeNumber => 'رقم الباركود';

  @override
  String get wholesalePriceLabel => 'سعرالجملة';

  @override
  String get minPriceLabel2 => 'الحدالأدنى للسعر';

  @override
  String get sellingPrice => 'سعر البيع';

  @override
  String get availableQty => 'الكميةالمتوفرة';

  @override
  String get minStockLevel => 'الحدالأدنى للمخزون';

  @override
  String get addProduct => 'إضافة المنتج';

  @override
  String get categoryLabel => 'الفئة';

  @override
  String get selectValidCategory => 'يجب اختيار فئة صالحة';

  @override
  String get addNewCategory => 'إضافة صنف جديد';

  @override
  String get categoryName => 'اسم الصنف';

  @override
  String get addCategory => 'إضافة الصنف';

  @override
  String get all => 'الكل';

  @override
  String get lowStock => 'منخفض';

  @override
  String get available => 'متوفر';

  @override
  String get restockProduct => 'إعادة تخزين المنتج';

  @override
  String get currentQuantity => 'الكمية الحالية';

  @override
  String get minLimit => 'الحد الأدنى';

  @override
  String get needed => 'المطلوب';

  @override
  String get restockQuantity => 'كمية إعادة التخزين';

  @override
  String get enterQuantity => 'أدخل الكمية';

  @override
  String get quantityAfterRestock => 'الكمية بعد التخزين:';

  @override
  String get enterValidQuantity => 'الرجاء إدخال كمية صحيحة أكبر من صفر';

  @override
  String get confirmRestock => 'تأكيد إعادة التخزين';

  @override
  String get restock => 'إعادة التخزين';

  @override
  String get stockManagement => 'إدارة مخزون السلع';

  @override
  String get stockManagementSubtitle =>
      'متابعة المنتجات منخفضة الكمية وتحديث التوريدات وسد العجز بالمخازن';

  @override
  String productsNeedRestock(Object count) {
    return 'المنتجات التي تتطلب إعادة تخزين حالياً ($count)';
  }

  @override
  String get stockComplete => 'المخزون مكتمل ولا توجد عواجز';

  @override
  String get allProductsAvailable =>
      'جميع السلع متوفرة بكميات تتجاوز الحد الأدنى للمخزون الموصى به';

  @override
  String get loadingStockData => 'جاري جرد وتحديث بيانات المخزن اليومي...';

  @override
  String get partialRefund => 'استرجاع جزئي';

  @override
  String invoiceNumber(Object id) {
    return 'فاتورة #$id';
  }

  @override
  String get totalRefundAmount => 'إجمالي المبلغ المسترجع:';

  @override
  String get confirmRefund => 'تأكيد الاسترجاع';

  @override
  String get noRefundableProducts => 'لا توجد منتجات قابلة للاسترجاع';

  @override
  String get productColumn => 'المنتج';

  @override
  String get soldQty => 'الكمية المباعة';

  @override
  String get alreadyRefunded => 'تم استرجاعه';

  @override
  String get remaining => 'المتبقي';

  @override
  String get priceColumn => 'السعر';

  @override
  String get refundQty => 'الكمية المسترجعة';

  @override
  String get totalColumn => 'الإجمالي';

  @override
  String get invalidNumber => 'رقم غير صالح';

  @override
  String get cannotBeNegative => 'لا يمكن أن يكون سالب';

  @override
  String maxLimit(Object qty) {
    return 'الحد الأقصى: $qty';
  }

  @override
  String get loadingInvoices => 'جاري تحميل الفواتير...';

  @override
  String get noInvoicesInPeriod => 'لا توجد فواتير في الفترة المحددة';

  @override
  String get noRecentInvoices => 'لا توجد فواتير حديثة';

  @override
  String get tryChangingFilter => 'جرب تغيير معايير البحث أو الفلتر';

  @override
  String get fromDate => 'من تاريخ';

  @override
  String get toDate => 'إلى تاريخ';

  @override
  String get searchInvoiceHint => 'امسح الباركود أو اكتب رقم الفاتورة...';

  @override
  String searchLabel(Object query) {
    return 'بحث: $query';
  }

  @override
  String get salesFilter => 'مبيعات';

  @override
  String get refundsFilter => 'مرتجعات';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get selectDateRangeFirst => 'يجب تحديد نطاق التاريخ أولاً';

  @override
  String get deleteInvoices => 'حذف الفواتير';

  @override
  String get clearInvoices => 'مسح الفواتير';

  @override
  String get cashier => 'الكاشير';

  @override
  String get refunded => 'مرتجع';

  @override
  String itemsCount(Object count) {
    return '$count أصناف';
  }

  @override
  String get print => 'طباعة';

  @override
  String get thermalReceiptTitle => 'إيصال دفع حراري (80mm)';

  @override
  String get a4InvoiceTitle => 'فاتورة مبيعات (A4)';

  @override
  String invoiceNumberLabel(Object id) {
    return 'رقم الفاتورة: #$id';
  }

  @override
  String get instantPrint => 'طباعة فورية';

  @override
  String get managerOnlyDelete => 'فقط المدير يمكنه حذف الورديات.';

  @override
  String get cannotDeleteOpenSession =>
      'لا يمكن حذف الوردية الحالية وهي مفتوحة.';

  @override
  String get confirmDeleteSession => 'تأكيد حذف الوردية';

  @override
  String get confirmDeleteSessionMessage =>
      'هل أنت متأكد من حذف هذه الوردية؟ سيتم حذف تقرير الإغلاق المرتبط بها نهائياً ولا يمكن التراجع.';

  @override
  String get sessionDeletedSuccess => 'تم حذف الوردية بنجاح.';

  @override
  String sessionDeleteFailed(Object error) {
    return 'فشل حذف الوردية: $error';
  }

  @override
  String get activeNow => 'نشطة الآن';

  @override
  String hoursMinutes(Object hours, Object minutes) {
    return '$hoursس $minutesد';
  }

  @override
  String minutesOnly(Object minutes) {
    return '$minutesد';
  }

  @override
  String get sessionsHistory => 'سجل الورديات';

  @override
  String sessionsCount(Object count) {
    return '$count وردية مسجلة';
  }

  @override
  String get sessionsList => 'قائمة الورديات';

  @override
  String get loadingSessions => 'جاري تحميل الورديات...';

  @override
  String get noSessions => 'لا توجد ورديات مسجلة';

  @override
  String get sessionsAutoAdd => 'ستُضاف الورديات تلقائياً فور فتحها وإغلاقها';

  @override
  String get sessionActive => 'نشطة';

  @override
  String get sessionClosed => 'مغلقة';

  @override
  String sessionId(Object id) {
    return 'وردية #$id';
  }

  @override
  String get selectSessionForDetails => 'اختر وردية لعرض تفاصيلها';

  @override
  String get selectSessionHint =>
      'اختر إحدى الورديات من القائمة لعرض سجل العمليات والتقرير المالي';

  @override
  String get operationsLog => 'سجل العمليات';

  @override
  String get financialReport => 'التقرير المالي';

  @override
  String get activeSession => 'وردية نشطة';

  @override
  String get closedSession => 'وردية مغلقة';

  @override
  String get printReport => 'طباعة التقرير';

  @override
  String get deleteSession => 'حذف الوردية';

  @override
  String get sessionStart => 'بدء الوردية';

  @override
  String get sessionEnd => 'إغلاق الوردية';

  @override
  String get totalDuration => 'إجمالي المدة';

  @override
  String get searchOperationsHint => 'بحث بالعملية أو اسم المستخدم...';

  @override
  String get allOperations => 'كل العمليات';

  @override
  String get noMatchingOperations => 'لا توجد عمليات تطابق البحث';

  @override
  String get reportAfterClose => 'التقرير يتاح بعد إغلاق الوردية';

  @override
  String get closeSessionForReport =>
      'أغلق الوردية الحالية لإنشاء التقرير المالي وعرض الإحصائيات';

  @override
  String get failedLoadReport => 'فشل تحميل التقرير المالي';

  @override
  String get noFinancialReport => 'لم يتم العثور على تقرير مالي';

  @override
  String get ensureSessionClosed => 'تأكد من إغلاق الوردية بنجاح';

  @override
  String get netSales => 'صافي المبيعات';

  @override
  String get salesOperations => 'عمليات البيع';

  @override
  String get refunds => 'المرتجعات';

  @override
  String get datasheet => 'الجدول';

  @override
  String get noReportForSession => 'لا يوجد تقرير لهذه الوردية';

  @override
  String get previewBeforePrint => 'معاينة التقرير قبل الطباعة';

  @override
  String failedLoadReportError(Object error) {
    return 'فشل تحميل التقرير: $error';
  }

  @override
  String get readNotifications => 'مقروءة';

  @override
  String get urgentNotifications => 'عاجلة';

  @override
  String get unreadLabel => 'غير مقروءة';

  @override
  String get markAsReadUnread => 'وضع كغير مقروء';

  @override
  String get markAsRead => 'وضع كمقروء';

  @override
  String get deleteNotification => 'حذف التنبيه';

  @override
  String productCode(Object sku) {
    return 'كود المنتج: $sku';
  }

  @override
  String get markSelectedRead => 'تحديد المقروءة';

  @override
  String get markAllRead => 'تحديد الكل كمقروءة';

  @override
  String get deleteSelected => 'حذف المحدد';

  @override
  String get unexpectedError => 'حدث خطأ غير متوقع';

  @override
  String get productOutOfStock => 'المنتج نفد من المخزون';

  @override
  String productLowStock(Object qty) {
    return 'كمية المنتج في المخزون منخفضة ($qty)';
  }

  @override
  String get yearlySalesSummary => 'ملخص المبيعات السنوي';

  @override
  String totalLabel(Object amount) {
    return 'الإجمالي: $amount';
  }

  @override
  String get noYearlyData => 'لا توجد بيانات سنوية';

  @override
  String get topSellingProducts => 'المنتجات الأكثر مبيعاً';

  @override
  String soldCount(Object qty) {
    return 'بيع: $qty قطعة';
  }

  @override
  String get totalSales => 'إجمالي المبيعات';

  @override
  String salesCount(Object count) {
    return '$count عملية بيع';
  }

  @override
  String get totalCost => 'التكلفة الكلية';

  @override
  String get productsCost => 'تكلفة المنتجات';

  @override
  String get netProfit => 'صافي الربح';

  @override
  String get loss => 'الخسارة';

  @override
  String margin(Object percent) {
    return '$percent% هامش';
  }

  @override
  String get averageSale => 'متوسط البيعة';

  @override
  String get perSale => 'لكل عملية بيع';

  @override
  String get monthlySales => 'المبيعات الشهرية';

  @override
  String get monthlyAverage => 'المتوسط/شهر';

  @override
  String get months => 'الأشهر';

  @override
  String get noDataToShow => 'لا توجد بيانات للعرض';

  @override
  String get topProductsByMonth => 'أكثر المنتجات مبيعاً بالشهر';

  @override
  String monthTotal(Object month) {
    return 'إجمالي $month:';
  }

  @override
  String get noProductsThisMonth => 'لا توجد منتجات في هذا الشهر';

  @override
  String get salesByCategory => 'المبيعات حسب الفئة';

  @override
  String get noCategoryData => 'لا توجد بيانات تصنيفات';

  @override
  String get dailySales => 'المبيعات اليومية';

  @override
  String get noDailyData => 'لا توجد بيانات يومية';

  @override
  String get salesByHour => 'المبيعات حسب الساعة';

  @override
  String get noHourData => 'لا توجد بيانات للساعات';

  @override
  String get salesReportTitle => 'تقارير وتحليلات المبيعات';

  @override
  String get salesReportSubtitle => 'تحليل شامل لأداء المبيعات والأرباح';

  @override
  String get currentSession => 'الجلسة الحالية';

  @override
  String get allTime => 'كل الوقت';

  @override
  String get monthJan => 'يناير';

  @override
  String get monthFeb => 'فبراير';

  @override
  String get monthMar => 'مارس';

  @override
  String get monthApr => 'أبريل';

  @override
  String get monthMay => 'مايو';

  @override
  String get monthJun => 'يونيو';

  @override
  String get monthJul => 'يوليو';

  @override
  String get monthAug => 'أغسطس';

  @override
  String get monthSep => 'سبتمبر';

  @override
  String get monthOct => 'أكتوبر';

  @override
  String get monthNov => 'نوفمبر';

  @override
  String get monthDec => 'ديسمبر';

  @override
  String get monthJanShort => 'ينا';

  @override
  String get monthFebShort => 'فبر';

  @override
  String get monthMarShort => 'مار';

  @override
  String get monthAprShort => 'أبر';

  @override
  String get monthMayShort => 'ماي';

  @override
  String get monthJunShort => 'يون';

  @override
  String get monthJulShort => 'يول';

  @override
  String get monthAugShort => 'أغس';

  @override
  String get monthSepShort => 'سبت';

  @override
  String get monthOctShort => 'أكت';

  @override
  String get monthNovShort => 'نوف';

  @override
  String get monthDecShort => 'ديس';

  @override
  String get stockSummaryTitle => 'تحليلات وملخص المخزون';

  @override
  String get stockSummarySubtitleLong =>
      'متابعة حركة رأس المال في السلع، الأرباح المتوقعة، وقيم المخازن الكلية والتاريخية';

  @override
  String get totalHistoricValue => 'القيمة الكلية التاريخية';

  @override
  String get historicValueTooltip =>
      'إجمالي تكلفة جميع البضائع التي تم إدخالها للنظام تاريخياً';

  @override
  String get currentWholesaleValue => 'القيمة الحالية (جملة)';

  @override
  String get currentWholesaleTooltip =>
      'قيمة المخزون الحالي بالكامل بسعر الجملة';

  @override
  String get expectedProfit => 'صافي الأرباح المتوقعة';

  @override
  String get expectedProfitTooltip =>
      'العائد المالي المتوقع (الفرق بين قيمة البيع وسعر الجملة للمخزون الحالي)';

  @override
  String get filterByCategory => 'تصفية حسب تصنيف السلع';

  @override
  String get allCategoriesFilter => 'كل الأقسام والتصنيفات';

  @override
  String get totalValue => 'القيمة الإجمالية';

  @override
  String get historicValue => 'القيمة التاريخية';

  @override
  String get profitMarginPercent => 'هامش الربح %';

  @override
  String get sortAsc => 'ترتيب تصاعدي';

  @override
  String get sortDesc => 'ترتيب تنازلي';

  @override
  String get sectionColumn => 'القسم';

  @override
  String get productsColumn => 'المنتجات';

  @override
  String get currentStock => 'المخزون الحالي';

  @override
  String get outputsColumn => 'المخرجات';

  @override
  String get historicValueColumn => 'القيمة التاريخية';

  @override
  String get currentWholesaleColumn => 'القيمة الحالية (جملة)';

  @override
  String get expectedSellValue => 'القيمة المتوقعة (بيع)';

  @override
  String get archivedSection => 'قسم أرشيفي ممسوح يحتوي على عمليات بيع سابقة';

  @override
  String get otherSections => 'أقسام أخرى';

  @override
  String get stockValueDistribution => 'توزيع قيمة المخزون الحالي (جملة)';

  @override
  String get capitalInGoods => 'رأس المال المستثمر في البضائع حسب القسم';

  @override
  String totalValueAmount(Object amount) {
    return 'إجمالي القيمة: $amount ج.م';
  }

  @override
  String get stockQtyDistribution => 'توزيع كميات السلع المتوفرة';

  @override
  String get qtyBySection => 'عدد القطع المتوفرة في المخازن حسب القسم';

  @override
  String totalQtyAmount(Object amount) {
    return 'إجمالي الكمية: $amount قطعة';
  }

  @override
  String get insufficientDataForChart => 'لا توجد بيانات كافية لعرض المخطط';

  @override
  String get categoryDetails => 'تفاصيل حركة منتجات القسم';

  @override
  String get productNameColumn => 'اسم المنتج';

  @override
  String get salesColumn => 'المبيعات';

  @override
  String get refundsColumn => 'المرتجعات';

  @override
  String get netSoldColumn => 'صافي المباع';

  @override
  String unitCount(Object count) {
    return '$count وحدة';
  }

  @override
  String get totalSalesOverall => 'إجمالي المبيعات الكلية';

  @override
  String get totalRefundsOverall => 'إجمالي المرتجعات الكلية';

  @override
  String get netActualSales => 'صافي المبيعات الفعلية';

  @override
  String get nameSort => 'الاسم';

  @override
  String get qtySort => 'الكمية';

  @override
  String get generalCategory => 'عام';

  @override
  String get deletedCategory => 'المحذوفة';

  @override
  String receiptPhone(Object phone) {
    return 'هاتف: $phone';
  }

  @override
  String get refundInvoice => 'فاتورة مرتجع';

  @override
  String get salesInvoice => 'فاتورة مبيعات';

  @override
  String get invoiceNumberPdf => 'رقم الفاتورة:';

  @override
  String get datePdf => 'التاريخ:';

  @override
  String get cashierPdf => 'الكاشير:';

  @override
  String get unknown => 'غير معروف';

  @override
  String get totalPdf => 'الإجمالي:';

  @override
  String get thankYou => 'شكراً لزيارتكم!';

  @override
  String vatNumber(Object vat) {
    return 'الرقم الضريبي: $vat';
  }

  @override
  String get pdfProductHeader => 'المنتج';

  @override
  String get pdfQtyHeader => 'ق';

  @override
  String get pdfPriceHeader => 'س';

  @override
  String get pdfTotalHeader => 'ج';

  @override
  String get productNotFoundCubit => 'المنتج غير موجود';

  @override
  String get productUnavailable => 'المنتج غير متوفر في المخزون';

  @override
  String priceBelowMin(Object price) {
    return 'السعر أقل من الحد الأدنى ($price ج.م)';
  }

  @override
  String get cartIsEmpty => 'السلة فارغة';

  @override
  String failedOpenSession(Object error) {
    return 'فشل فتح يوم جديد: $error';
  }

  @override
  String get saleSuccess => 'تمت عملية البيع بنجاح';

  @override
  String get dbError => 'حدث خطأ في قاعدة البيانات';

  @override
  String get fileSystemError => 'حدث خطأ في نظام الملفات';

  @override
  String get unexpectedErrorGeneric => 'حدث خطأ غير متوقع';

  @override
  String get noProductsEmpty => 'لا توجد منتجات';

  @override
  String get noProductsSearchMatch => 'لم يتم العثور على منتجات تطابق البحث';

  @override
  String get noAlertsEmpty => 'لا توجد تنبيهات';

  @override
  String get alertsWillShowHere => 'سيتم عرض التنبيهات هنا عند توفرها';

  @override
  String get msgProductAdded => 'تم إضافة المنتج بنجاح';

  @override
  String get msgProductUpdated => 'تم تحديث المنتج بنجاح';

  @override
  String get msgProductDeleted => 'تم حذف المنتج بنجاح';

  @override
  String get msgSaleCompleted => 'تم إتمام البيع بنجاح';

  @override
  String get msgDataSaved => 'تم حفظ البيانات بنجاح';

  @override
  String get msgReportGenerated => 'تم إنشاء التقرير بنجاح';

  @override
  String get msgUserCreated => 'تم إنشاء المستخدم بنجاح';

  @override
  String get msgUserUpdated => 'تم تحديث المستخدم بنجاح';

  @override
  String get msgUserDeleted => 'تم حذف المستخدم بنجاح';

  @override
  String get msgLoginSuccess => 'تم تسجيل الدخول بنجاح';

  @override
  String get msgLogoutSuccess => 'تم تسجيل الخروج بنجاح';

  @override
  String get msgPasswordChanged => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get msgSettingsSaved => 'تم حفظ الإعدادات بنجاح';

  @override
  String get errProductNotFound => 'المنتج غير موجود';

  @override
  String get errInsufficientStock => 'الكمية المتاحة غير كافية';

  @override
  String get errInvalidInput => 'البيانات المدخلة غير صحيحة';

  @override
  String get errNetworkError => 'خطأ في الاتصال بالشبكة';

  @override
  String get errServerError => 'خطأ في الخادم';

  @override
  String get errLoginFailed => 'فشل في تسجيل الدخول';

  @override
  String get errAccessDenied => 'ليس لديك صلاحية للوصول';

  @override
  String get errFileNotFound => 'الملف غير موجود';

  @override
  String get errSaveFailed => 'فشل في حفظ البيانات';

  @override
  String get errDeleteFailed => 'فشل في حذف البيانات';

  @override
  String get errUpdateFailed => 'فشل في تحديث البيانات';

  @override
  String get closeSession => 'إغلاق اليومية';

  @override
  String get closeSessionSub => 'إنهاء الوردية الحالية وإصدار تقرير الإغلاق';

  @override
  String get dayClosedSuccess => 'تم إغلاق اليوم بنجاح. جاري تسجيل الخروج...';

  @override
  String get dayClosedSuccessReport => 'تم إغلاق اليوم بنجاح';

  @override
  String get viewDayReport => 'عرض تقرير اليوم';

  @override
  String get savedReportManager =>
      'تم حفظ تقرير اليوم. يمكنك عرض التقرير التفصيلي.';

  @override
  String get savedReportCashier =>
      'تم حفظ تقرير اليوم. سيتم تسجيل الخروج الآن.';

  @override
  String get logoutShort => 'خروج';

  @override
  String get settingsScreenSubtitle => 'إعدادات النظام وإدارة المستخدمين';

  @override
  String get fillRequiredFields => 'يرجى ملء الحقول المطلوبة';

  @override
  String get addNewUser => 'إضافة مستخدم جديد';

  @override
  String get editUser => 'تعديل المستخدم';

  @override
  String get nameRequired => 'الاسم *';

  @override
  String get usernameRequired => 'اسم المستخدم *';

  @override
  String get passwordRequired => 'كلمة المرور *';

  @override
  String get userType => 'نوع المستخدم';

  @override
  String get addUserButton => 'إضافة المستخدم';

  @override
  String get dataManagement => 'إدارة البيانات والنسخ الاحتياطي';

  @override
  String get dataManagementSub =>
      'عرض سجلات النظام، النسخ الاحتياطي، ونقاط الاستعادة';
}
