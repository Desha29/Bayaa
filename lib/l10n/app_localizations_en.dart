// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get switchToArabic => 'العربية';

  @override
  String get switchToEnglish => 'English';

  @override
  String get loginBrandName => 'Bayaa POS';

  @override
  String get appName => 'Bayaa POS';

  @override
  String get systemSubtitle => 'Retail Point of Sale & Management System';

  @override
  String get loginWelcome => 'Welcome Back!';

  @override
  String get loginSubtitle =>
      'Please enter your credentials to access the system';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'Enter username';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter password';

  @override
  String get rememberMe => 'Remember me on this device';

  @override
  String get loginButton => 'Login';

  @override
  String get quickLoginHeader => 'Quick system trial with different roles:';

  @override
  String get sessionOpenWarning =>
      'There is an active session. Logging in will continue it.';

  @override
  String get offlineFeature => 'Fully offline operation';

  @override
  String get barcodeFeature => 'Quick barcode sales scan & PDF invoices';

  @override
  String get reportsFeature => 'Daily profit reports & sales tracking';

  @override
  String get systemDescription =>
      'Professional Point of Sale & Retail Management System for all shops and smartphone stores. Works fully offline without internet, with full protection and local synchronization.';

  @override
  String get version => 'Version';

  @override
  String get copyright => 'All rights reserved.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get sales => 'Sales';

  @override
  String get invoices => 'Invoices';

  @override
  String get products => 'Products';

  @override
  String get stockAlerts => 'Low Stock';

  @override
  String get stockSummary => 'Stock Summary';

  @override
  String get reports => 'Analytics';

  @override
  String get sessions => 'Sessions';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get homeSection => 'Home';

  @override
  String get salesSection => 'Sales & Invoices';

  @override
  String get stockSection => 'Inventory & Products';

  @override
  String get systemSection => 'System & Reports';

  @override
  String get roleManager => 'System Administrator';

  @override
  String get roleCashier => 'Cashier';

  @override
  String get connected => 'Connected';

  @override
  String get trial => 'Trial';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Confirm Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get logoutConfirmSub =>
      'This will end the current session and return to the login screen.';

  @override
  String get loggingOut => 'Logging out...';

  @override
  String get logoutSuccess => 'Logged out successfully';

  @override
  String get logoutFailed => 'Logout failed';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data available';

  @override
  String get error => 'An error occurred';

  @override
  String get screenUnavailable => 'Screen unavailable';

  @override
  String get systemSlogan => 'Professional Point of Sale System';

  @override
  String get salesSubtitle => 'Manage sales operations';

  @override
  String get invoicesSubtitle => 'Manage invoices';

  @override
  String get productsSubtitle => 'Manage inventory';

  @override
  String get stockAlertsSubtitle => 'Low stock alerts';

  @override
  String get stockSummarySubtitle => 'Stock classifications';

  @override
  String get reportsSubtitle => 'System analytics';

  @override
  String get sessionsSubtitle => 'Closed session history';

  @override
  String get settingsSubtitle => 'Manage system settings';

  @override
  String get notificationsSubtitle => 'Notifications & alerts';

  @override
  String closedSessionsCount(Object count) {
    return '$count closed days';
  }

  @override
  String get todaySalesNet => 'Today\'s Sales (Net)';

  @override
  String get totalProducts => 'Total Products';

  @override
  String productCount(Object count) {
    return '$count products';
  }

  @override
  String get lowStockAlerts => 'Low Stock Alerts';

  @override
  String lowStockCount(Object count) {
    return '$count low stock items';
  }

  @override
  String get unreadNotifications => 'Unread Notifications';

  @override
  String notificationsCount(Object count) {
    return '$count alerts';
  }

  @override
  String get currencyEg => 'EGP';

  @override
  String get salesTrendTitle => 'Sales Trend (Last 7 Days)';

  @override
  String get dailyNetSales => 'Daily Net Sales';

  @override
  String welcomeUser(Object name) {
    return 'Welcome to $name POS Management System';
  }

  @override
  String sessionStaleWarning(Object time) {
    return 'The current session has been open for $time — it is recommended to close it and open a new one';
  }

  @override
  String sessionOpenInfo(Object time) {
    return 'You are working on a previously opened session since $time';
  }

  @override
  String get daysText => 'days';

  @override
  String get hoursText => 'hours';

  @override
  String get minutesText => 'minutes';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get recentSalesTitle => 'Recent Sales';

  @override
  String get hideRecentSales => 'Hide Recent Sales';

  @override
  String get noSales => 'No sales recorded';

  @override
  String get refundProcess => 'Refund process';

  @override
  String get saleProcess => 'Sale process';

  @override
  String saleItemsSummary(Object count, Object currency, Object total) {
    return '$count item(s) • $total $currency';
  }

  @override
  String get recentOperationsTitle => 'Recent Operations';

  @override
  String get noRecentOperations => 'No recent operations found';

  @override
  String get noOperationsToday => 'No operations in this session yet';

  @override
  String loginsCount(Object count) {
    return '$count logins';
  }

  @override
  String activeDayUser(Object user) {
    return 'Active Session • $user';
  }

  @override
  String closedDayUser(Object user) {
    return 'Closed Session • $user';
  }

  @override
  String operationsCount(Object count) {
    return '$count operations';
  }

  @override
  String get showMore => 'Show More';

  @override
  String get actSale => 'Sale';

  @override
  String get actRefund => 'Refund';

  @override
  String get actProductAdd => 'Add Product';

  @override
  String get actProductUpdate => 'Update Product';

  @override
  String get actProductDelete => 'Delete Product';

  @override
  String get actProductQtyUpdate => 'Update Qty';

  @override
  String get actUserAdd => 'Add User';

  @override
  String get actUserUpdate => 'Update User';

  @override
  String get actUserDelete => 'Delete User';

  @override
  String get actSessionOpen => 'Open Session';

  @override
  String get actSessionClose => 'Close Session';

  @override
  String get actRestock => 'Restock';

  @override
  String get actExpense => 'Expense';

  @override
  String get actInvoiceDelete => 'Delete Invoice';

  @override
  String get actPrintReport => 'Print Report';

  @override
  String get actLogin => 'Login';

  @override
  String detailsItems(Object items) {
    return 'Items: $items';
  }

  @override
  String detailsTotal(Object currency, Object total) {
    return 'Total: $total $currency';
  }

  @override
  String detailsProduct(Object name) {
    return 'Product: $name';
  }

  @override
  String detailsQty(Object newQty, Object oldQty) {
    return 'Quantity: $oldQty ← $newQty';
  }

  @override
  String detailsPrice(Object newPrice, Object oldPrice) {
    return 'Price: $oldPrice ← $newPrice';
  }

  @override
  String detailsAddedQty(Object qty) {
    return 'Added Quantity: $qty';
  }

  @override
  String detailsCategory(Object category) {
    return 'Category: $category';
  }

  @override
  String detailsAmount(Object amount, Object currency) {
    return 'Amount: $amount $currency';
  }

  @override
  String detailsUser(Object user) {
    return 'User: $user';
  }

  @override
  String detailsRole(Object role) {
    return 'Role: $role';
  }

  @override
  String get salesScreenTitle => 'Sales';

  @override
  String get salesScreenSubtitle => 'Manage sales and invoices';

  @override
  String searchErrorMsg(Object message) {
    return 'Search error: $message';
  }

  @override
  String productNotFound(Object code) {
    return 'Product not found: $code';
  }

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String maxQtyReached(Object qty) {
    return 'Maximum available quantity reached ($qty)';
  }

  @override
  String get cartEmpty => 'Cart is empty';

  @override
  String saveSaleFailed(Object message) {
    return 'Failed to save sale: $message';
  }

  @override
  String saleCompleted(Object currency, Object total) {
    return 'Sale completed - Total: $total $currency';
  }

  @override
  String saleActivityDesc(Object currency, Object total) {
    return 'Sale: $total $currency';
  }

  @override
  String cantAddMoreStock(Object qty) {
    return 'Cannot add more! Available stock: $qty';
  }

  @override
  String get showRecentSales => 'Show Recent Sales';

  @override
  String get recentSalesLabel => 'Recent Sales';

  @override
  String get cartProductList => 'Product List';

  @override
  String get cartEmptyTitle => 'Cart is Empty';

  @override
  String get cartEmptySubtitle => 'Scan products to add them';

  @override
  String get editPriceTitle => 'Edit Price';

  @override
  String minPriceLabel(Object currency, Object price) {
    return 'Minimum price: $price $currency';
  }

  @override
  String get newPriceLabel => 'New Price';

  @override
  String priceValidationError(Object currency, Object price) {
    return 'Price must be greater than or equal to $price $currency';
  }

  @override
  String get cancelBtn => 'Cancel';

  @override
  String get saveBtn => 'Save';

  @override
  String codeLabel(Object code) {
    return 'Code: $code';
  }

  @override
  String dateLabel(Object date) {
    return 'Date: $date';
  }

  @override
  String remainingLabel(Object qty) {
    return 'Remaining: $qty';
  }

  @override
  String priceWithCurrency(Object currency, Object price) {
    return '$price $currency';
  }

  @override
  String get invoiceSummaryTitle => 'Invoice Summary';

  @override
  String get itemCountLabel => 'Item Count';

  @override
  String itemCountValue(Object count) {
    return '$count items';
  }

  @override
  String get subtotalLabel => 'Subtotal';

  @override
  String get grandTotalLabel => 'Grand Total';

  @override
  String get checkoutBtn => 'Complete Checkout';

  @override
  String get clearCartBtn => 'Clear Cart';

  @override
  String get barcodeScanHint => 'Scan barcode or search for a product...';

  @override
  String stockLabel(Object qty) {
    return 'Stock: $qty';
  }

  @override
  String get enterUsername => 'Please enter username';

  @override
  String get enterPassword => 'Please enter password';

  @override
  String get usersManagement => 'Users Management';

  @override
  String get addUser => 'Add User';

  @override
  String get noUsers => 'No users found';

  @override
  String get today => 'Today';

  @override
  String get storeInfo => 'Store Info';

  @override
  String get noStoreInfo => 'No store info available';

  @override
  String get storeName => 'Store Name';

  @override
  String get storeAddress => 'Address';

  @override
  String get storePhone => 'Phone Number';

  @override
  String get storeEmail => 'Email Address';

  @override
  String get storeVat => 'VAT Number';

  @override
  String get editStoreInfo => 'Edit Store Info';

  @override
  String get storeNameRequired => 'Store Name *';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get enterStoreName => 'Please enter store name';

  @override
  String get infoSavedSuccess => 'Information saved successfully';

  @override
  String get logoutWarningMessage =>
      'The current work session will end and return to the login screen';

  @override
  String get fullName => 'Full Name';

  @override
  String get usernameColumn => 'Username';

  @override
  String get permission => 'Permission';

  @override
  String get accountStatus => 'Account Status';

  @override
  String get lastLoginColumn => 'Last Login';

  @override
  String get actions => 'Actions';

  @override
  String get active => 'Active';

  @override
  String get disabled => 'Disabled';

  @override
  String get editPermissions => 'Edit Permissions';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get confirmDeleteUser => 'Confirm Delete User';

  @override
  String confirmDeleteUserMessage(Object name) {
    return 'Are you sure you want to delete the user account \"$name\"? This action cannot be undone.';
  }

  @override
  String get protectionActivated => 'Protection system activated successfully';

  @override
  String get restartApp => 'Restart Application';

  @override
  String get protectionActivatedMessage =>
      'Protection system activated successfully!\n\nTo fully apply the changes, it is recommended to restart the application.';

  @override
  String get ok => 'OK';

  @override
  String get operationCancelled => 'Operation cancelled';

  @override
  String get noProducts => 'No products';

  @override
  String get addProductsHint => 'Add new products to display them here';

  @override
  String get productName => 'Product Name';

  @override
  String get barcode => 'Barcode';

  @override
  String get category => 'Category';

  @override
  String get price => 'Price';

  @override
  String get wholesalePrice => 'Wholesale Price';

  @override
  String get minPriceColumn => 'Min Price';

  @override
  String get quantity => 'Quantity';

  @override
  String get status => 'Status';

  @override
  String get barcodeError => 'Barcode Error';

  @override
  String barcodeExistsMessage(Object barcode) {
    return 'A product with barcode \"$barcode\" already exists.\nPlease use a different barcode or edit the existing product.';
  }

  @override
  String get addNewProduct => 'Add New Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get barcodeNumber => 'Barcode Number';

  @override
  String get wholesalePriceLabel => 'Wholesale Price';

  @override
  String get minPriceLabel2 => 'Minimum Price';

  @override
  String get sellingPrice => 'Selling Price';

  @override
  String get availableQty => 'Available Quantity';

  @override
  String get minStockLevel => 'Minimum Stock Level';

  @override
  String get addProduct => 'Add Product';

  @override
  String get categoryLabel => 'Category';

  @override
  String get selectValidCategory => 'Please select a valid category';

  @override
  String get addNewCategory => 'Add New Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get addCategory => 'Add Category';

  @override
  String get all => 'All';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get available => 'Available';

  @override
  String get restockProduct => 'Restock Product';

  @override
  String get currentQuantity => 'Current Quantity';

  @override
  String get minLimit => 'Min Limit';

  @override
  String get needed => 'Required';

  @override
  String get restockQuantity => 'Restock Quantity';

  @override
  String get enterQuantity => 'Enter quantity';

  @override
  String get quantityAfterRestock => 'Quantity after restocking:';

  @override
  String get enterValidQuantity =>
      'Please enter a valid quantity greater than zero';

  @override
  String get confirmRestock => 'Confirm Restock';

  @override
  String get restock => 'Restock';

  @override
  String get stockManagement => 'Inventory Management';

  @override
  String get stockManagementSubtitle =>
      'Track low stock products, update supplies, and resolve inventory shortage';

  @override
  String productsNeedRestock(Object count) {
    return 'Products currently requiring restock ($count)';
  }

  @override
  String get stockComplete => 'Stock is complete with no shortage';

  @override
  String get allProductsAvailable =>
      'All products are available in quantities exceeding the recommended minimum stock level';

  @override
  String get loadingStockData =>
      'Auditing and updating daily inventory data...';

  @override
  String get partialRefund => 'Partial Refund';

  @override
  String invoiceNumber(Object id) {
    return 'Invoice #$id';
  }

  @override
  String get totalRefundAmount => 'Total Refunded Amount:';

  @override
  String get confirmRefund => 'Confirm Refund';

  @override
  String get noRefundableProducts => 'No refundable products found';

  @override
  String get productColumn => 'Product';

  @override
  String get soldQty => 'Sold Qty';

  @override
  String get alreadyRefunded => 'Already Refunded';

  @override
  String get remaining => 'Remaining';

  @override
  String get priceColumn => 'Price';

  @override
  String get refundQty => 'Refund Qty';

  @override
  String get totalColumn => 'Total';

  @override
  String get invalidNumber => 'Invalid Number';

  @override
  String get cannotBeNegative => 'Cannot be negative';

  @override
  String maxLimit(Object qty) {
    return 'Max Limit: $qty';
  }

  @override
  String get loadingInvoices => 'Loading invoices...';

  @override
  String get noInvoicesInPeriod => 'No invoices in the selected period';

  @override
  String get noRecentInvoices => 'No recent invoices';

  @override
  String get tryChangingFilter => 'Try changing search terms or filters';

  @override
  String get fromDate => 'From Date';

  @override
  String get toDate => 'To Date';

  @override
  String get searchInvoiceHint => 'Scan barcode or enter invoice number...';

  @override
  String searchLabel(Object query) {
    return 'Search: $query';
  }

  @override
  String get salesFilter => 'Sales';

  @override
  String get refundsFilter => 'Refunds';

  @override
  String get selectDate => 'Select Date';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get selectDateRangeFirst => 'Must select a date range first';

  @override
  String get deleteInvoices => 'Delete Invoices';

  @override
  String get clearInvoices => 'Clear Invoices';

  @override
  String get cashier => 'Cashier';

  @override
  String get refunded => 'Refunded';

  @override
  String itemsCount(Object count) {
    return '$count items';
  }

  @override
  String get print => 'Print';

  @override
  String get thermalReceiptTitle => 'Thermal Receipt (80mm)';

  @override
  String get a4InvoiceTitle => 'Sales Invoice (A4)';

  @override
  String invoiceNumberLabel(Object id) {
    return 'Invoice Number: #$id';
  }

  @override
  String get instantPrint => 'Instant Print';

  @override
  String get managerOnlyDelete => 'Only managers can delete sessions.';

  @override
  String get cannotDeleteOpenSession =>
      'Cannot delete the current active session while it is open.';

  @override
  String get confirmDeleteSession => 'Confirm Delete Session';

  @override
  String get confirmDeleteSessionMessage =>
      'Are you sure you want to delete this session? The associated closing report will be permanently deleted and this action cannot be undone.';

  @override
  String get sessionDeletedSuccess => 'Session deleted successfully.';

  @override
  String sessionDeleteFailed(Object error) {
    return 'Failed to delete session: $error';
  }

  @override
  String get activeNow => 'Active Now';

  @override
  String hoursMinutes(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String minutesOnly(Object minutes) {
    return '${minutes}m';
  }

  @override
  String get sessionsHistory => 'Sessions History';

  @override
  String sessionsCount(Object count) {
    return '$count registered sessions';
  }

  @override
  String get sessionsList => 'Sessions List';

  @override
  String get loadingSessions => 'Loading sessions...';

  @override
  String get noSessions => 'No registered sessions found';

  @override
  String get sessionsAutoAdd =>
      'Sessions will be added automatically upon opening and closing';

  @override
  String get sessionActive => 'Active';

  @override
  String get sessionClosed => 'Closed';

  @override
  String sessionId(Object id) {
    return 'Session #$id';
  }

  @override
  String get selectSessionForDetails => 'Select a session to view its details';

  @override
  String get selectSessionHint =>
      'Select a session from the list to view its activity log and financial report';

  @override
  String get operationsLog => 'Operations Log';

  @override
  String get financialReport => 'Financial Report';

  @override
  String get activeSession => 'Active Session';

  @override
  String get closedSession => 'Closed Session';

  @override
  String get printReport => 'Print Report';

  @override
  String get deleteSession => 'Delete Session';

  @override
  String get sessionStart => 'Session Start';

  @override
  String get sessionEnd => 'Session End';

  @override
  String get totalDuration => 'Total Duration';

  @override
  String get searchOperationsHint => 'Search by operation or username...';

  @override
  String get allOperations => 'All Operations';

  @override
  String get noMatchingOperations => 'No operations matched the search';

  @override
  String get reportAfterClose =>
      'Report becomes available after closing the session';

  @override
  String get closeSessionForReport =>
      'Close the current session to generate the financial report and view analytics';

  @override
  String get failedLoadReport => 'Failed to load financial report';

  @override
  String get noFinancialReport => 'No financial report found';

  @override
  String get ensureSessionClosed =>
      'Make sure the session is closed successfully';

  @override
  String get netSales => 'Net Sales';

  @override
  String get salesOperations => 'Sales Operations';

  @override
  String get refunds => 'Refunds';

  @override
  String get datasheet => 'Datasheet';

  @override
  String get noReportForSession => 'No report available for this session';

  @override
  String get previewBeforePrint => 'Preview Report Before Printing';

  @override
  String failedLoadReportError(Object error) {
    return 'Failed to load report: $error';
  }

  @override
  String get readNotifications => 'Read';

  @override
  String get urgentNotifications => 'Urgent';

  @override
  String get unreadLabel => 'Unread';

  @override
  String get markAsReadUnread => 'Mark as Unread';

  @override
  String get markAsRead => 'Mark as Read';

  @override
  String get deleteNotification => 'Delete Alert';

  @override
  String productCode(Object sku) {
    return 'Product SKU: $sku';
  }

  @override
  String get markSelectedRead => 'Mark Selected as Read';

  @override
  String get markAllRead => 'Mark All as Read';

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get productOutOfStock => 'Product is out of stock';

  @override
  String productLowStock(Object qty) {
    return 'Product quantity in stock is low ($qty)';
  }

  @override
  String get yearlySalesSummary => 'Yearly Sales Summary';

  @override
  String totalLabel(Object amount) {
    return 'Total: $amount';
  }

  @override
  String get noYearlyData => 'No yearly data available';

  @override
  String get topSellingProducts => 'Top Selling Products';

  @override
  String soldCount(Object qty) {
    return 'Sold: $qty units';
  }

  @override
  String get totalSales => 'Total Sales';

  @override
  String salesCount(Object count) {
    return '$count sales';
  }

  @override
  String get totalCost => 'Total Cost';

  @override
  String get productsCost => 'Cost of Products';

  @override
  String get netProfit => 'Net Profit';

  @override
  String get loss => 'Loss';

  @override
  String margin(Object percent) {
    return '$percent% Margin';
  }

  @override
  String get averageSale => 'Average Sale';

  @override
  String get perSale => 'Per Sale';

  @override
  String get monthlySales => 'Monthly Sales';

  @override
  String get monthlyAverage => 'Monthly Average';

  @override
  String get months => 'Months';

  @override
  String get noDataToShow => 'No data available to display';

  @override
  String get topProductsByMonth => 'Top Products by Month';

  @override
  String monthTotal(Object month) {
    return '$month Total:';
  }

  @override
  String get noProductsThisMonth => 'No products sold in this month';

  @override
  String get salesByCategory => 'Sales by Category';

  @override
  String get noCategoryData => 'No category data available';

  @override
  String get dailySales => 'Daily Sales';

  @override
  String get noDailyData => 'No daily data available';

  @override
  String get salesByHour => 'Sales by Hour';

  @override
  String get noHourData => 'No hourly data available';

  @override
  String get salesReportTitle => 'Sales Reports & Analytics';

  @override
  String get salesReportSubtitle =>
      'Comprehensive analysis of sales performance and profits';

  @override
  String get currentSession => 'Current Session';

  @override
  String get allTime => 'All Time';

  @override
  String get monthJan => 'January';

  @override
  String get monthFeb => 'February';

  @override
  String get monthMar => 'March';

  @override
  String get monthApr => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'June';

  @override
  String get monthJul => 'July';

  @override
  String get monthAug => 'August';

  @override
  String get monthSep => 'September';

  @override
  String get monthOct => 'October';

  @override
  String get monthNov => 'November';

  @override
  String get monthDec => 'December';

  @override
  String get monthJanShort => 'Jan';

  @override
  String get monthFebShort => 'Feb';

  @override
  String get monthMarShort => 'Mar';

  @override
  String get monthAprShort => 'Apr';

  @override
  String get monthMayShort => 'May';

  @override
  String get monthJunShort => 'Jun';

  @override
  String get monthJulShort => 'Jul';

  @override
  String get monthAugShort => 'Aug';

  @override
  String get monthSepShort => 'Sep';

  @override
  String get monthOctShort => 'Oct';

  @override
  String get monthNovShort => 'Nov';

  @override
  String get monthDecShort => 'Dec';

  @override
  String get stockSummaryTitle => 'Inventory Summary & Analytics';

  @override
  String get stockSummarySubtitleLong =>
      'Track capital in goods, expected profits, and default current & historic value';

  @override
  String get totalHistoricValue => 'Total Historic Value';

  @override
  String get historicValueTooltip =>
      'Total cost of all items ever entered into the system';

  @override
  String get currentWholesaleValue => 'Current Value (Wholesale)';

  @override
  String get currentWholesaleTooltip =>
      'Total wholesale value of the current inventory';

  @override
  String get expectedProfit => 'Expected Net Profit';

  @override
  String get expectedProfitTooltip =>
      'Expected financial return (difference between sell value and wholesale cost of current inventory)';

  @override
  String get filterByCategory => 'Filter by Category';

  @override
  String get allCategoriesFilter => 'All Categories & Classifications';

  @override
  String get totalValue => 'Total Value';

  @override
  String get historicValue => 'Historic Value';

  @override
  String get profitMarginPercent => 'Profit Margin %';

  @override
  String get sortAsc => 'Sort Ascending';

  @override
  String get sortDesc => 'Sort Descending';

  @override
  String get sectionColumn => 'Category';

  @override
  String get productsColumn => 'Products';

  @override
  String get currentStock => 'Current Stock';

  @override
  String get outputsColumn => 'Outputs';

  @override
  String get historicValueColumn => 'Historic Value';

  @override
  String get currentWholesaleColumn => 'Current Value (Wholesale)';

  @override
  String get expectedSellValue => 'Expected Value (Sell)';

  @override
  String get archivedSection =>
      'Archived category containing past sales records';

  @override
  String get otherSections => 'Other Sections';

  @override
  String get stockValueDistribution =>
      'Current Stock Value Distribution (Wholesale)';

  @override
  String get capitalInGoods => 'Capital invested in goods by category';

  @override
  String totalValueAmount(Object amount) {
    return 'Total Value: $amount EGP';
  }

  @override
  String get stockQtyDistribution => 'Available Stock Quantity Distribution';

  @override
  String get qtyBySection => 'Number of units available in stock by category';

  @override
  String totalQtyAmount(Object amount) {
    return 'Total Quantity: $amount units';
  }

  @override
  String get insufficientDataForChart => 'Insufficient data to display chart';

  @override
  String get categoryDetails => 'Category Product Movement Details';

  @override
  String get productNameColumn => 'Product Name';

  @override
  String get salesColumn => 'Sales';

  @override
  String get refundsColumn => 'Refunds';

  @override
  String get netSoldColumn => 'Net Sold';

  @override
  String unitCount(Object count) {
    return '$count units';
  }

  @override
  String get totalSalesOverall => 'Total Overall Sales';

  @override
  String get totalRefundsOverall => 'Total Overall Refunds';

  @override
  String get netActualSales => 'Net Actual Sales';

  @override
  String get nameSort => 'Name';

  @override
  String get qtySort => 'Quantity';

  @override
  String get generalCategory => 'General';

  @override
  String get deletedCategory => 'Deleted';

  @override
  String receiptPhone(Object phone) {
    return 'Phone: $phone';
  }

  @override
  String get refundInvoice => 'Refund Invoice';

  @override
  String get salesInvoice => 'Sales Invoice';

  @override
  String get invoiceNumberPdf => 'Invoice No:';

  @override
  String get datePdf => 'Date:';

  @override
  String get cashierPdf => 'Cashier:';

  @override
  String get unknown => 'Unknown';

  @override
  String get totalPdf => 'Total:';

  @override
  String get thankYou => 'Thank you for your visit!';

  @override
  String vatNumber(Object vat) {
    return 'VAT: $vat';
  }

  @override
  String get pdfProductHeader => 'Product';

  @override
  String get pdfQtyHeader => 'Qty';

  @override
  String get pdfPriceHeader => 'Price';

  @override
  String get pdfTotalHeader => 'Total';

  @override
  String get productNotFoundCubit => 'Product not found';

  @override
  String get productUnavailable => 'Product out of stock';

  @override
  String priceBelowMin(Object price) {
    return 'Price is below minimum ($price EGP)';
  }

  @override
  String get cartIsEmpty => 'Cart is empty';

  @override
  String failedOpenSession(Object error) {
    return 'Failed to open new session: $error';
  }

  @override
  String get saleSuccess => 'Sale completed successfully';

  @override
  String get dbError => 'A database error occurred';

  @override
  String get fileSystemError => 'A file system error occurred';

  @override
  String get unexpectedErrorGeneric => 'An unexpected error occurred';

  @override
  String get noProductsEmpty => 'No products';

  @override
  String get noProductsSearchMatch => 'No products matched the search';

  @override
  String get noAlertsEmpty => 'No alerts';

  @override
  String get alertsWillShowHere =>
      'Alerts will be displayed here when available';

  @override
  String get msgProductAdded => 'Product added successfully';

  @override
  String get msgProductUpdated => 'Product updated successfully';

  @override
  String get msgProductDeleted => 'Product deleted successfully';

  @override
  String get msgSaleCompleted => 'Sale completed successfully';

  @override
  String get msgDataSaved => 'Data saved successfully';

  @override
  String get msgReportGenerated => 'Report generated successfully';

  @override
  String get msgUserCreated => 'User created successfully';

  @override
  String get msgUserUpdated => 'User updated successfully';

  @override
  String get msgUserDeleted => 'User deleted successfully';

  @override
  String get msgLoginSuccess => 'Login successful';

  @override
  String get msgLogoutSuccess => 'Logout successful';

  @override
  String get msgPasswordChanged => 'Password changed successfully';

  @override
  String get msgSettingsSaved => 'Settings saved successfully';

  @override
  String get errProductNotFound => 'Product not found';

  @override
  String get errInsufficientStock => 'Insufficient stock quantity available';

  @override
  String get errInvalidInput => 'Invalid input data';

  @override
  String get errNetworkError => 'Network connection error';

  @override
  String get errServerError => 'Server error';

  @override
  String get errLoginFailed => 'Login failed';

  @override
  String get errAccessDenied => 'Access denied. You do not have permission.';

  @override
  String get errFileNotFound => 'File not found';

  @override
  String get errSaveFailed => 'Failed to save data';

  @override
  String get errDeleteFailed => 'Failed to delete data';

  @override
  String get errUpdateFailed => 'Failed to update data';

  @override
  String get closeSession => 'Close Session';

  @override
  String get closeSessionSub => 'End current shift and generate closing report';

  @override
  String get dayClosedSuccess => 'Day closed successfully. Logging out...';

  @override
  String get dayClosedSuccessReport => 'Day closed successfully';

  @override
  String get viewDayReport => 'View Day Report';

  @override
  String get savedReportManager =>
      'Day report saved. You can view the detailed report.';

  @override
  String get savedReportCashier => 'Day report saved. Logging out now.';

  @override
  String get logoutShort => 'Exit';

  @override
  String get settingsScreenSubtitle => 'System Settings & User Management';

  @override
  String get fillRequiredFields => 'Please fill in all required fields';

  @override
  String get addNewUser => 'Add New User';

  @override
  String get editUser => 'Edit User';

  @override
  String get nameRequired => 'Name *';

  @override
  String get usernameRequired => 'Username *';

  @override
  String get passwordRequired => 'Password *';

  @override
  String get userType => 'User Type';

  @override
  String get addUserButton => 'Add User';

  @override
  String get dataManagement => 'Data Management & Backups';

  @override
  String get dataManagementSub =>
      'View system logs, backups, and restore points';

  @override
  String activitySessionOpened(Object user) {
    return '$user opened a new work day';
  }

  @override
  String activitySessionClosed(Object user) {
    return '$user closed the session';
  }

  @override
  String activityLogin(Object user) {
    return '$user logged in';
  }

  @override
  String activityProductAdded(Object user, Object product) {
    return '$user added product $product';
  }

  @override
  String activityProductUpdated(Object user, Object product) {
    return '$user updated product $product';
  }

  @override
  String activityProductDeleted(Object user, Object product) {
    return '$user deleted product $product';
  }

  @override
  String activityProductQtyUpdated(Object user, Object product, Object qty) {
    return '$user updated stock of $product ($qty)';
  }

  @override
  String activityRestock(Object user, Object product, Object qty) {
    return '$user restocked $product with $qty units';
  }

  @override
  String activitySaleCompleted(Object user, Object total) {
    return '$user completed a sale of $total';
  }

  @override
  String activityRefundCompleted(Object user, Object total) {
    return '$user processed a refund of $total';
  }

  @override
  String activityUserAdded(Object user, Object targetUser) {
    return '$user created user $targetUser';
  }

  @override
  String activityUserUpdated(Object user, Object targetUser) {
    return '$user updated user $targetUser';
  }

  @override
  String activityUserDeleted(Object user, Object targetUser) {
    return '$user deleted user $targetUser';
  }

  @override
  String activityInvoiceDeleted(Object user, Object id) {
    return '$user deleted invoice #$id';
  }

  @override
  String get confirmDeleteInvoiceTitle => 'Confirm Delete Invoice';

  @override
  String confirmDeleteInvoiceMessage(Object id) {
    return 'Are you sure you want to permanently delete invoice (#$id)?\n\nThis action cannot be undone.';
  }

  @override
  String get confirmDeleteBtn => 'Confirm Delete';

  @override
  String get invoiceDeletedSuccess => 'Invoice deleted successfully';

  @override
  String invoiceDeleteFailed(Object error) {
    return 'Failed to delete invoice: $error';
  }

  @override
  String get refundSuccess => 'Refund processed successfully';

  @override
  String get confirmDeleteInvoicesTitle => 'Confirm Delete Invoices';

  @override
  String confirmDeleteInvoicesMessage(
      Object y1, Object m1, Object d1, Object y2, Object m2, Object d2) {
    return 'Are you sure you want to delete all invoices from $y1-$m1-$d1 to $y2-$m2-$d2?\n\nThis action cannot be undone.';
  }

  @override
  String get invoicesDeletedSuccess => 'Invoices deleted successfully';

  @override
  String invoicesDeleteFailed(Object error) {
    return 'Failed to delete invoices: $error';
  }

  @override
  String get productsManagement => 'Manage products and view details';

  @override
  String get noOtherCategoriesToMove =>
      'No other categories to move products to.';

  @override
  String get selectCategoryBeforeAction => 'Select category before action';

  @override
  String get chooseCategory => 'Choose category';

  @override
  String get moveProducts => 'Move Products';

  @override
  String get permanentDelete => 'Permanent Delete';

  @override
  String get mustSelectCategoryFirst => 'You must select a category first';

  @override
  String get categoryActionNoCategories =>
      'No other categories to move products to.';

  @override
  String get productSavedSuccess => 'Product saved successfully';

  @override
  String get categoryAddedSuccess => 'Category added successfully';

  @override
  String get categoryDeletedSuccess => 'Category deleted successfully';

  @override
  String get loginExistingSession =>
      'Logged in. The system will continue with the previously open session until it is closed.';

  @override
  String get loginNewSession => 'Logged in and new session opened successfully';

  @override
  String failedOpenDay(Object error) {
    return 'Failed to open day: $error';
  }

  @override
  String get wrongPassword => 'Incorrect password';

  @override
  String get noOpenSession => 'No open session to close.';

  @override
  String failedCloseDay(Object error) {
    return 'Failed to close session: $error';
  }

  @override
  String get storeInfoSaved => 'Store information saved successfully';

  @override
  String get unknownUser => 'Unknown';

  @override
  String get trialCashier => 'Trial Cashier';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get enterValidNumber => 'Please enter a valid number';

  @override
  String get confirmDeleteCategory => 'Confirm Delete Category';

  @override
  String get confirmDeleteCategoryMessage =>
      'Are you sure you want to delete this category?';

  @override
  String get viewGrid => 'Grid View';

  @override
  String get viewTable => 'Table View';

  @override
  String get searchProductHint => 'Search by name, code, barcode or price...';

  @override
  String get filterByAvailability => 'By Availability';

  @override
  String get selectAvailability => 'Select Availability';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get urgencyVeryHigh => 'Very Urgent';

  @override
  String get urgencyHigh => 'Urgent';

  @override
  String get urgencyMedium => 'Medium';

  @override
  String get urgencyLow => 'Low';

  @override
  String get categoryHasProductsError =>
      'Cannot delete category because it contains products';

  @override
  String get sameCategoryError => 'Cannot move products to the same category';

  @override
  String get dailyReports => 'Daily Reports';

  @override
  String get todayRevenue => 'Today\'s Revenue & Sales';

  @override
  String get dailyReportDesc =>
      'Review financial metrics, sales, refunds, and top selling products';

  @override
  String get noDataForDate => 'No data available for this date';

  @override
  String get ensureValidDate =>
      'Please ensure a valid date is selected or complete sales first';

  @override
  String get filterReportByDate => 'Filter report by date';

  @override
  String get currentSelectedDay => 'Currently selected day';

  @override
  String get reportGeneratedDate => 'Report generation date';

  @override
  String closedByUser(Object user) {
    return 'Closed: $user';
  }

  @override
  String get todayTotalSales => 'Today\'s Total Sales';

  @override
  String get dailyNetProfit => 'Daily Net Profit';

  @override
  String get salesReportPreview => 'Sales Report Preview';

  @override
  String get viewDetailedTable => 'View detailed sales table';

  @override
  String get instantPrintReport => 'Instant print for report';

  @override
  String get sharePdfReport => 'Share PDF Report';

  @override
  String get viewTableBtn => 'View Table';

  @override
  String get noProductsSoldDate => 'No products sold for this date';

  @override
  String dailyProductsPerformance(Object count) {
    return 'Daily Products Performance ($count)';
  }

  @override
  String salesUnits(Object qty) {
    return 'Sales: $qty units';
  }

  @override
  String profitAmount(Object amount) {
    return 'Profit: $amount';
  }

  @override
  String get returnedProductsDetails => 'Returned Products Details';

  @override
  String get returnedQty => 'Returned Quantity';

  @override
  String get returnedValue => 'Return Value';

  @override
  String get dailyFinancialLog => 'Daily Financial Operations Log';

  @override
  String get operationTime => 'Operation Time';

  @override
  String get operationType => 'Operation Type';

  @override
  String get totalAmountLabel => 'Total Amount';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String transactionCount(Object count) {
    return '$count transactions';
  }

  @override
  String get netSalesLabel => 'Net Sales';

  @override
  String get transactionsCountLabel2 => 'Number of Transactions';

  @override
  String get transactionUnit => 'transaction';

  @override
  String get noTransactionsReport => 'No transactions in this report';

  @override
  String get transactionsWillAppearHere =>
      'Transactions will appear here when available';

  @override
  String get detailedOperationsLog => 'Detailed Operations Log';

  @override
  String get transactionNumber => 'Transaction Number';

  @override
  String get timeLabel => 'Time';

  @override
  String get typeLabel => 'Type';

  @override
  String get byLabel => 'By';

  @override
  String get valueLabel => 'Value';

  @override
  String get previewReportTitle => 'Preview Report';

  @override
  String get shareBtn => 'Share';

  @override
  String get openTimeLabel => 'Open Time';

  @override
  String get closeTimeLabel => 'Close Time';

  @override
  String get openLabel => 'Open';

  @override
  String get sessionsHistorySubtitle =>
      'View and manage system sessions and daily reports';

  @override
  String get taxSalesReceipt => 'Tax Sales Receipt';

  @override
  String get taxSalesInvoice => 'Tax Sales Invoice';

  @override
  String get dateTimeLabel => 'Date and Time:';

  @override
  String get responsibleCashier => 'Responsible Cashier:';

  @override
  String get itemsTotalLabel => 'Items Total:';

  @override
  String get appliedDiscount => 'Applied Discount:';

  @override
  String get valueAddedTax => 'Value Added Tax:';

  @override
  String get grandTotalLabelPdf => 'Grand Total:';

  @override
  String get thankYouShopping => 'Thank you for shopping with us!';

  @override
  String get posSystemName => 'Bayaa POS Sales Management System';

  @override
  String get enterpriseTaxNumber => 'Enterprise Tax Number:';

  @override
  String get invoiceStatusLabel => 'Invoice Status:';

  @override
  String get fullyPaid => 'Fully Paid';

  @override
  String get productHeaderA4 => 'Product / Item';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get grandTotalColumn => 'Grand Total';

  @override
  String get termsAndConditions => 'Terms and Conditions:';

  @override
  String get termsLine1 => '1. Sold goods cannot be returned.';

  @override
  String get termsLine2 => '2. Invoice must be presented for exchange.';

  @override
  String get invoiceDiscountsLabel => 'Invoice Discounts:';

  @override
  String get finalTotal => 'Final Total:';

  @override
  String get thankYouDealing => 'Thank you for your business!';

  @override
  String get dailySalesReport => 'Daily Sales Report';

  @override
  String get advancedPosSystem => 'Advanced POS System - Bayaa';

  @override
  String get reportDateLabel => 'Report Date:';

  @override
  String get transactionCountLabel => 'Number of Transactions:';

  @override
  String get netRevenueLabel => 'Net Revenue';

  @override
  String get totalSalesLabel => 'Total Sales';

  @override
  String get totalRefundsLabel => 'Total Refunds';

  @override
  String get netProfitLabel => 'Net Profit';

  @override
  String get closedByLabel => 'Closed By';

  @override
  String get dailyPerformanceSummary => 'Daily Performance Summary';

  @override
  String get costLabel => 'Cost';

  @override
  String get profitLabel => 'Profit';

  @override
  String get profitMarginLabel => 'Profit Margin';

  @override
  String get topProductsPerformance => 'Top Selling Products Performance';

  @override
  String reportCreatedAt(Object time) {
    return 'Report created at: $time';
  }

  @override
  String get allRightsReserved => 'All Rights Reserved';

  @override
  String get settingsUpdated => 'Store information updated';

  @override
  String stockUpdateActivity(Object product, Object qty) {
    return 'Stock update: $product (+$qty)';
  }

  @override
  String activityStockUpdate(Object user, Object product, Object qty) {
    return '$user updated stock of $product (+$qty)';
  }

  @override
  String activitySettingsUpdate(Object user) {
    return '$user updated store settings';
  }

  @override
  String get selectRead => 'Select Read';

  @override
  String get deleteSelectedLabel => 'Delete Selected';

  @override
  String get allFilter => 'All';

  @override
  String get saleLabel => 'Sale';

  @override
  String get refundLabel => 'Refund';

  @override
  String get retry => 'Retry';

  @override
  String sessionLabel(Object id) {
    return 'Session: $id';
  }

  @override
  String get analyticsOverview => 'Overview';

  @override
  String get analyticsSales => 'Sales Analysis';

  @override
  String get analyticsProducts => 'Product Analysis';

  @override
  String get todayFilter => 'Today';

  @override
  String get yesterdayFilter => 'Yesterday';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get thisWeek => 'This Week';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get customDate => 'Custom Date';

  @override
  String get customRange => 'Custom Range';

  @override
  String get allSessions => 'All Sessions';

  @override
  String get sessionFilter => 'Filter by Session';

  @override
  String sessionNumber(Object id) {
    return 'Session #$id';
  }

  @override
  String get selectedDate => 'Selected Date';

  @override
  String get todayDate => 'Today\'s Date';

  @override
  String closedByLabel2(Object user) {
    return 'Closed by: $user';
  }

  @override
  String get noDataSalesAnalytics => 'No data available for sales analysis';

  @override
  String get noDataToDisplay => 'No data to display';

  @override
  String get analyticsTitle => 'Analytics & Statistics';

  @override
  String get overviewTab => 'Overview';

  @override
  String get salesTab => 'Sales Analysis';

  @override
  String get productsTab => 'Product Analysis';

  @override
  String get fromDateLabel => 'From';

  @override
  String get toDateLabel => 'To';

  @override
  String get totalSalesAnalytics => 'Total Sales';

  @override
  String get costAnalytics => 'Total Cost';

  @override
  String get netProfitAnalytics => 'Net Profit';

  @override
  String get lossLabel => 'Loss';

  @override
  String marginLabel(Object percent) {
    return '$percent% Margin';
  }

  @override
  String get avgSaleAnalytics => 'Average Sale';

  @override
  String get perSaleLabel => 'Per Sale';

  @override
  String get salesByHourAnalytics => 'Sales by Hour';

  @override
  String get amLabel => 'AM';

  @override
  String get pmLabel => 'PM';

  @override
  String get salesByCategoryAnalytics => 'Sales by Category';

  @override
  String get returnRateLabel => 'Return Rate';

  @override
  String netSoldLabel(Object qty) {
    return 'Net Sold ($qty)';
  }

  @override
  String refundCountLabel(Object qty) {
    return 'Refunds ($qty)';
  }

  @override
  String get viewAsTable => 'View as Table';

  @override
  String get quickPrint => 'Quick Print';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get previewReportBtn => 'Preview Report';

  @override
  String returnedProductsTitle(Object count) {
    return 'Returned Products ($count)';
  }

  @override
  String get operationByLabel => 'Operation by';

  @override
  String get dailySalesAnalytics => 'Daily Sales';

  @override
  String get dailyNetRevenue => 'Daily Net Revenue';

  @override
  String productPerformance(Object count) {
    return 'Product Performance ($count)';
  }

  @override
  String unitsSold(Object qty) {
    return 'Sold: $qty units';
  }

  @override
  String profitMarginAnalytics(Object percent) {
    return 'Margin: $percent%';
  }

  @override
  String get noProductsSoldToday => 'No products sold for this date';

  @override
  String get printReportSuccess => 'Report sent to printer successfully';

  @override
  String printReportError(Object error) {
    return 'Error printing report: $error';
  }

  @override
  String get shareReportSuccess => 'Report shared successfully';

  @override
  String shareReportError(Object error) {
    return 'Error sharing report: $error';
  }

  @override
  String get loadingReport => 'Preparing report for printing...';

  @override
  String get loadingShare => 'Preparing report for sharing...';

  @override
  String loadReportError(Object error) {
    return 'Error loading report: $error';
  }

  @override
  String get reportLoadedSuccess => 'Report loaded successfully';

  @override
  String get searchInvoiceHint2 => 'Scan barcode or enter invoice number...';

  @override
  String get refundBtn => 'Return';

  @override
  String get deleteBtn => 'Delete';

  @override
  String get printBtn => 'Print';

  @override
  String get invoicePreviewTitle => 'Invoice Preview';

  @override
  String get thermalReceiptLabel => 'Thermal Receipt (80mm)';

  @override
  String get a4InvoiceLabel => 'Sales Invoice (A4)';

  @override
  String get quickPrintTooltip => 'Quick Print';

  @override
  String get sharePdfTooltip => 'Share PDF';

  @override
  String deleteInvoiceFailed(Object error) {
    return 'Failed to delete invoice: $error';
  }

  @override
  String refundInvoiceFailed(Object error) {
    return 'Failed to process refund: $error';
  }

  @override
  String bulkDeleteFailed(Object error) {
    return 'Failed to delete invoices: $error';
  }

  @override
  String get dataProtection => 'Data Protection System';

  @override
  String get protectionEnabled => 'Enabled';

  @override
  String get protectionDisabled => 'Disabled';

  @override
  String get protectionSystemActive => 'System is Active';

  @override
  String get yourDataProtected => 'Your data is protected from:';

  @override
  String get accidentalDeletion => 'Accidental deletion';

  @override
  String get systemCrashes => 'System crashes';

  @override
  String get powerOutage => 'Power outage';

  @override
  String get windowsReinstall => 'Windows reinstallation';

  @override
  String get dataLocation => 'Data Location:';

  @override
  String get changeLocation => 'Change Location';

  @override
  String get protectionInactive => 'System is Inactive';

  @override
  String get dataAtRisk => 'Your data is at risk of being lost in case of:';

  @override
  String get appDeletion => 'App deletion';

  @override
  String get virusScan => 'Virus scanning';

  @override
  String get systemCrash => 'System crash';

  @override
  String get enableProtection => 'Enable Data Protection Now';

  @override
  String get dataMigrationSuccess => 'Data migrated successfully';

  @override
  String get migrationSuccess => 'Migration completed successfully';

  @override
  String migrationDetails(Object path) {
    return 'Data moved to: $path. Please restart the app.';
  }

  @override
  String get migrationFailed => 'Data migration failed or was cancelled';

  @override
  String get dataManagementTitle => 'Data Management';

  @override
  String get backupAndRestore => 'Backups & Auto-Save Points';

  @override
  String get backupLabel => 'Backup';

  @override
  String get restorePointLabel => 'Restore Point';

  @override
  String get backupSection => 'Backups';

  @override
  String get autoSaveSection => 'Auto-Save Points';

  @override
  String get systemStatus => 'System Status';

  @override
  String get createBackup => 'Create New Backup';

  @override
  String get noBackups => 'No backups available';

  @override
  String get createBackupHint => 'Create a backup to protect your data';

  @override
  String get noAutoSavePoints => 'No auto-save points';

  @override
  String get autoSaveHint =>
      'Save points are created automatically during important operations';

  @override
  String get autoSavePoint => 'Auto-Save Point';

  @override
  String get systemLabel => 'System';

  @override
  String get newestFirst => 'Newest First';

  @override
  String get restoreBtn => 'Restore';

  @override
  String get deleteBtn2 => 'Delete';

  @override
  String get currentMode => 'Current System Mode';

  @override
  String get debugModeDesc =>
      'The app is currently in development mode (demo data enabled)';

  @override
  String get releaseModeDesc => 'The app is currently in production mode';

  @override
  String get chooseMode => 'Choose operating mode:';

  @override
  String get releaseMode => 'Production Mode (Release)';

  @override
  String get releaseModeDesc2 =>
      'Use the real database only, without any demo data.';

  @override
  String get debugMode => 'Development Mode (Debug)';

  @override
  String get debugModeDesc2 =>
      'Auto-generate demo products and sales to test the system.';

  @override
  String get demoDataDangerZone => 'Demo Data Danger Zone';

  @override
  String get dbToolsDesc =>
      'Database management tools and demo data generation.';

  @override
  String get reseedWarning =>
      'This button will clear all entries and generate complete demo sales data...';

  @override
  String get reseedDatabase => 'Initialize Database & Generate Demo Data';

  @override
  String modeChanged(Object mode) {
    return 'System mode changed to: $mode';
  }

  @override
  String get modeDebug => 'Development';

  @override
  String get modeRelease => 'Production';

  @override
  String saveSettingsFailed(Object error) {
    return 'Failed to save settings: $error';
  }

  @override
  String get confirmReseed => 'Confirm Data Reset';

  @override
  String get reseedConfirmMessage =>
      'All current data will be erased and new demo data will be generated...';

  @override
  String get reseedSuccess =>
      'Data reset and demo generation completed successfully';

  @override
  String reseedError(Object error) {
    return 'Error during data reset: $error';
  }

  @override
  String get confirmRestore => 'Confirm Restore';

  @override
  String get confirmRestoreMessage =>
      'Current data will be replaced with the selected backup...';

  @override
  String get restoreSuccess => 'Restore completed successfully. Restarting...';

  @override
  String get restoreFailed => 'Failed to restore backup';

  @override
  String restoreError(Object error) {
    return 'Error during restore: $error';
  }

  @override
  String get confirmAutoRestore => 'Confirm Auto-Save Restore';

  @override
  String get confirmAutoRestoreMessage =>
      'System will revert to this save point and lose any data recorded after it...';

  @override
  String get autoRestoreSuccess =>
      'Auto-save point restored successfully. Restarting...';

  @override
  String get autoRestoreFailed => 'Failed to restore auto-save point';

  @override
  String get deleteBackup => 'Delete Backup';

  @override
  String get deleteBackupMessage =>
      'Are you sure you want to delete this backup?...';

  @override
  String get deleteBackupSuccess => 'Backup deleted successfully';

  @override
  String deleteBackupFailed(Object error) {
    return 'Failed to delete: $error';
  }

  @override
  String get settingsClose => 'Close';

  @override
  String get loadingData => 'Loading...';

  @override
  String get confirmBtn => 'Confirm';

  @override
  String get restoreDataBtn => 'Restore';

  @override
  String get backupFailed => 'Failed to create backup';

  @override
  String loadDataError(Object error) {
    return 'Failed to load data: $error';
  }

  @override
  String settingsSaveFailed(Object error) {
    return 'Failed to save settings: $error';
  }

  @override
  String get paymentMethodTitle => 'Select Payment Method';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentWallet => 'Wallet';

  @override
  String get paymentMethodLabel => 'Payment Method';

  @override
  String get notificationLowStockTitle => 'Low Stock';

  @override
  String get notificationOutOfStockTitle => 'Out of Stock';

  @override
  String get notificationLowStockBadge => 'Medium';

  @override
  String get notificationOutOfStockBadge => 'Urgent';

  @override
  String notificationLowStockMessage(Object qty, Object product) {
    return 'Only $qty units left - $product';
  }

  @override
  String notificationOutOfStockMessage(Object product) {
    return '0 units left - $product';
  }

  @override
  String quantityUnits(Object count) {
    return '$count units';
  }

  @override
  String paymentLabel(Object method) {
    return 'Payment Method: $method';
  }

  @override
  String get confirmPayment => 'Confirm';

  @override
  String get cancelPayment => 'Cancel';
}
