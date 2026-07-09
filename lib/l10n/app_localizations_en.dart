// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get cartProductOutOfStock => 'This product is out of stock';

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
  String get outOfStock => 'Out of Stock';

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
  String get msgConnectionTimeout => 'Connection timed out';

  @override
  String get msgInvalidCredentials => 'Invalid login credentials';

  @override
  String get warnLowStock => 'Low quantity - please restock';

  @override
  String get warnUnsavedChanges => 'You have unsaved changes';

  @override
  String get warnConfirmDelete => 'Are you sure you want to delete?';

  @override
  String get warnSessionExpired => 'The work day has ended';

  @override
  String get warnDataLoss => 'You may lose unsaved data';

  @override
  String get warnBackupRequired => 'A backup is recommended';

  @override
  String get warnSystemMaintenance =>
      'The system will shut down for maintenance';

  @override
  String get infoLoadingData => 'Loading data...';

  @override
  String get infoProcessingRequest => 'Processing request...';

  @override
  String get infoGeneratingReport => 'Generating report...';

  @override
  String get infoSavingData => 'Saving data...';

  @override
  String get infoUpdatingData => 'Updating data...';

  @override
  String get infoDeletingData => 'Deleting data...';

  @override
  String get infoExportingData => 'Exporting data...';

  @override
  String get infoImportingData => 'Importing data...';

  @override
  String get infoSynchronizingData => 'Synchronizing data...';

  @override
  String get infoSystemReady => 'System ready to use';

  @override
  String get infoNewUpdateAvailable => 'A new update is available';

  @override
  String get infoMaintenanceScheduled => 'System maintenance scheduled';

  @override
  String get systemUserName => 'System';

  @override
  String get activationTitle => '🔒 Version not activated';

  @override
  String get activationMessage =>
      'It looks like you\'re using an unactivated version of the system.\nPlease contact the developer to activate your copy.';

  @override
  String get activationCallMe => 'Call me';

  @override
  String get activationEmailSubject => 'App activation request';

  @override
  String get activationEmailBody =>
      'Hello, I would like to purchase a copy of the app.';

  @override
  String get activationEmailMe => 'Email me';

  @override
  String get activationWhatsapp => 'Contact via WhatsApp';

  @override
  String get activationCopyright => '© 2025 Amr Store. All rights reserved';

  @override
  String analyticsLoadError(Object error) {
    return 'An unexpected error occurred while loading data: $error';
  }

  @override
  String get noDataForDay => 'No data found for this day';

  @override
  String sessionAnalyticsLoadError(Object error) {
    return 'Failed to load session data: $error';
  }

  @override
  String aggregateAnalyticsLoadError(Object error) {
    return 'Failed to load overall statistics: $error';
  }

  @override
  String get amPeriod => 'AM';

  @override
  String get pmPeriod => 'PM';

  @override
  String get salesByDepartment => 'Sales by Department';

  @override
  String get refundRatio => 'Refund Ratio';

  @override
  String netSalesLabel(Object amount) {
    return 'Net Sales ($amount)';
  }

  @override
  String refundsLabel(Object amount) {
    return 'Refunds ($amount)';
  }

  @override
  String get analyticsTitle => 'Analytics & Statistics';

  @override
  String get retry => 'Retry';

  @override
  String get insufficientSalesData => 'Not enough data to analyze sales';

  @override
  String sessionFilterLabel(Object id) {
    return 'Session: $id';
  }

  @override
  String get periodYesterday => 'Yesterday';

  @override
  String get periodLast7Days => 'Last 7 days';

  @override
  String get periodThisWeek => 'This week';

  @override
  String get periodLast30Days => 'Last 30 days';

  @override
  String get periodThisMonth => 'This month';

  @override
  String get periodThisYear => 'This year';

  @override
  String get periodCustomDate => 'Specific day';

  @override
  String get periodCustomRange => 'Custom range';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabSalesAnalysis => 'Sales Analysis';

  @override
  String get tabProductAnalysis => 'Product Analysis';

  @override
  String dateRangeFromTo(Object end, Object start) {
    return 'From $start to $end';
  }

  @override
  String get filterBySessionTooltip => 'Filter by session';

  @override
  String get allSessions => 'All Sessions';

  @override
  String sessionHashLabel(Object id) {
    return 'Session #$id';
  }

  @override
  String get wrongPassword => 'Incorrect password';

  @override
  String get noOpenSessionToClose => 'There is no open day to close.';

  @override
  String get loginSuccessExistingSession =>
      'Logged in. You will continue on the previously open day until it is closed.';

  @override
  String get loginSuccessNewSession =>
      'Logged in and opened a new day successfully';

  @override
  String failedToOpenDay(Object error) {
    return 'Failed to open the day: $error';
  }

  @override
  String get sessionCloseSuccess => 'The day was closed successfully.';

  @override
  String failedToCloseSession(Object error) {
    return 'Failed to close the day: $error';
  }

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get confirmDeleteInvoiceTitle => 'Confirm invoice deletion';

  @override
  String confirmDeleteInvoiceMessage(Object id) {
    return 'Are you sure you want to permanently delete invoice (#$id)?\n\nThis action cannot be undone.';
  }

  @override
  String get confirmDeleteAction => 'Confirm delete';

  @override
  String get invoiceDeletedSuccess => 'Invoice deleted successfully';

  @override
  String invoiceDeleteFailed(Object error) {
    return 'Failed to delete invoice: $error';
  }

  @override
  String get refundSuccess => 'Refund completed successfully';

  @override
  String get selectDateRangeToDelete =>
      'You must select a date range to delete invoices';

  @override
  String get confirmDeleteInvoicesTitle => 'Confirm invoices deletion';

  @override
  String confirmDeleteInvoicesMessage(Object end, Object start) {
    return 'Are you sure you want to delete all invoices from $start to $end?\n\nThis action cannot be undone.';
  }

  @override
  String get invoicesDeletedSuccess => 'Invoices deleted successfully';

  @override
  String invoicesDeleteFailed(Object error) {
    return 'Failed to delete invoices: $error';
  }

  @override
  String get invoicesScreenSubtitle => 'View and print issued invoices';

  @override
  String get notificationsScreenSubtitle => 'Manage alerts and notifications';

  @override
  String get productsScreenSubtitle => 'Manage products and view details';

  @override
  String get selectCategoryBeforeAction =>
      'Select a category before performing this action';

  @override
  String get chooseCategory => 'Choose category';

  @override
  String get noOtherCategoriesToMove =>
      'There are no other categories to move products to.';

  @override
  String get mustChooseCategoryToContinue =>
      'You must choose a category to continue';

  @override
  String get moveProducts => 'Move Products';

  @override
  String get permanentDelete => 'Permanently Delete';

  @override
  String get msgProductSaved => 'Product saved successfully';

  @override
  String get categoryAddedSuccess => 'Added successfully';

  @override
  String get categoryDeletedSuccess => 'Deleted successfully';

  @override
  String get searchProductHint => 'Search by name, code, barcode or price...';

  @override
  String get byAvailability => 'By Availability';

  @override
  String get chooseAvailability => 'Choose availability';

  @override
  String get byCategory => 'By Category';

  @override
  String get gridView => 'Grid View';

  @override
  String get tableView => 'Table View';

  @override
  String get confirmDeleteCategoryTitle => 'Confirm category deletion';

  @override
  String get confirmDeleteCategoryMessage =>
      'Are you sure you want to delete this category?';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get mustEnterValidNumber => 'You must enter a valid number';

  @override
  String get actionsColumn => 'Actions';

  @override
  String get close => 'Close';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String transactionCount(Object count) {
    return '$count transaction';
  }

  @override
  String get numberOfTransactions => 'Number of Transactions';

  @override
  String get transactionUnit => 'transaction';

  @override
  String get noTransactionsInReport => 'No transactions in this report';

  @override
  String get transactionsWillShowHere =>
      'Transactions will appear here once available';

  @override
  String get detailedTransactionsLog => 'Detailed Transactions Log';

  @override
  String get transactionNumber => 'Transaction #';

  @override
  String get timeColumn => 'Time';

  @override
  String get typeColumn => 'Type';

  @override
  String get byColumn => 'By';

  @override
  String get valueColumn => 'Value';

  @override
  String get reportPreview => 'Report Preview';

  @override
  String get share => 'Share';

  @override
  String get openTimeLabel => 'Open Time';

  @override
  String get closeTimeLabel => 'Close Time';

  @override
  String get openStatus => 'Open';

  @override
  String errorLoadingReport(Object error) {
    return 'Error loading report: $error';
  }

  @override
  String get reportLoadedSuccess => 'Report loaded successfully';

  @override
  String get preparingReportForPrint => 'Preparing report for printing...';

  @override
  String get reportSentToPrintSuccess => 'Report sent to print successfully';

  @override
  String printErrorMsg(Object error) {
    return 'Print error: $error';
  }

  @override
  String get preparingReportForShare => 'Preparing report for sharing...';

  @override
  String get reportSharedSuccess => 'Report shared successfully';

  @override
  String shareErrorMsg(Object error) {
    return 'Error sharing report: $error';
  }

  @override
  String get dailyReportsTitle => 'Daily Reports';

  @override
  String get todayRevenueAndSales => 'Today\'s Revenue & Sales';

  @override
  String get dailyReportScreenSubtitle =>
      'Review financial indicators, sales, refunds, and the top-selling products list';

  @override
  String get noDataAvailableForDate => 'No data available for this date';

  @override
  String get checkDateOrCompleteSales =>
      'Please make sure the date is correct or complete some sales first';

  @override
  String get filterReportByDate => 'Filter report by date';

  @override
  String get currentlySelectedDay => 'Currently selected day';

  @override
  String get generatedReportDate => 'Generated report date';

  @override
  String closedByLabel(Object name) {
    return 'Closed by: $name';
  }

  @override
  String get todayTotalSalesLabel => 'Today\'s Total Sales';

  @override
  String get dailyNetProfitLabel => 'Daily Net Profit';

  @override
  String get previewSalesReport => 'Preview Sales Report';

  @override
  String get viewDetailedSalesTable => 'View Detailed Sales Table';

  @override
  String get instantPrintReport => 'Instant Print Report';

  @override
  String get sharePdfReport => 'Share PDF Report';

  @override
  String get viewTable => 'View Table';

  @override
  String get noProductsSoldForDate => 'No products sold for this date';

  @override
  String dailyProductPerformanceCount(Object count) {
    return 'Daily Product Performance ($count)';
  }

  @override
  String soldUnitsLabel(Object qty) {
    return 'Sold: $qty units';
  }

  @override
  String profitAmountLabel(Object profit) {
    return 'Profit: $profit EGP';
  }

  @override
  String get refundedProductsDetails => 'Refunded Products Details';

  @override
  String get refundedQuantityColumn => 'Refunded Quantity';

  @override
  String get refundValueColumn => 'Refund Value';

  @override
  String get dailyFinancialTransactionsLog =>
      'Daily Financial Transactions Log';

  @override
  String get invoiceNumberColumn => 'Invoice Number';

  @override
  String get transactionTimeColumn => 'Transaction Time';

  @override
  String get transactionTypeColumn => 'Transaction Type';

  @override
  String get managerLabel => 'Manager';

  @override
  String get activityUserUpdate => 'Update permissions';

  @override
  String get activitySessionOpen => 'Open shift';

  @override
  String get activitySessionClose => 'Close shift';

  @override
  String get sessionsLogTitle => 'Sessions Log';

  @override
  String get sessionsLogSubtitle =>
      'View and manage system sessions and daily reports';

  @override
  String get storeInfoSavedSuccess => 'Store information saved successfully';

  @override
  String dmFailedLoadData(Object error) {
    return 'Failed to load data: $error';
  }

  @override
  String get dmBackupCreatedSuccess => 'Backup created successfully';

  @override
  String get dmBackupCreateFailed => 'Failed to create backup';

  @override
  String dmGenericError(Object error) {
    return 'Error: $error';
  }

  @override
  String get dmConfirmRestoreTitle => 'Confirm Restore';

  @override
  String get dmConfirmRestoreMessage =>
      'The current data will be replaced with the data in the selected backup.\n\nThe app will restart after the restore.';

  @override
  String get dmRestoreSuccessRestarting =>
      'Restored successfully. Restarting...';

  @override
  String get dmRestoreBackupFailed => 'Failed to restore backup';

  @override
  String dmRestoreErrorMsg(Object error) {
    return 'Error while restoring: $error';
  }

  @override
  String get dmConfirmRestoreCheckpointTitle => 'Confirm Checkpoint Restore';

  @override
  String get dmConfirmRestoreCheckpointMessage =>
      'You will revert to this checkpoint and lose any data recorded after it.\n\nThe app will restart.';

  @override
  String get dmCheckpointRestoreSuccess =>
      'Checkpoint restored successfully. Restarting...';

  @override
  String get dmCheckpointRestoreFailed => 'Failed to restore checkpoint';

  @override
  String get dmDeleteBackupTitle => 'Delete Backup';

  @override
  String get dmDeleteBackupMessage =>
      'Are you sure you want to delete this backup?\n\nThis action cannot be undone.';

  @override
  String get dmBackupDeletedSuccess => 'Backup deleted successfully';

  @override
  String dmDeleteFailedMsg(Object error) {
    return 'Delete failed: $error';
  }

  @override
  String get dmProtectionDisabledTitle => 'Protection system is not enabled';

  @override
  String get dmProtectionDisabledSubtitle =>
      'You must enable the protection system from Settings first';

  @override
  String get back => 'Back';

  @override
  String get dataManagementTitle => 'Data Management';

  @override
  String get dataManagementHeaderSubtitle =>
      'Backups and automatic checkpoints';

  @override
  String get backupUnitLabel => 'backup';

  @override
  String get checkpointUnitLabel => 'checkpoint';

  @override
  String get backupsTabLabel => 'Backups';

  @override
  String get checkpointsTabLabel => 'Auto Checkpoints';

  @override
  String get systemModeTabLabel => 'System Mode';

  @override
  String get createNewBackup => 'Create New Backup';

  @override
  String get noBackupsTitle => 'No backups found';

  @override
  String get noBackupsSubtitle => 'Create a backup to keep your data safe';

  @override
  String get noCheckpointsTitle => 'No automatic checkpoints found';

  @override
  String get noCheckpointsSubtitle =>
      'Checkpoints are created automatically when important operations occur';

  @override
  String get autoCheckpointReason => 'Automatic checkpoint';

  @override
  String get latestBadge => 'Latest';

  @override
  String get restore => 'Restore';

  @override
  String get currentSystemModeTitle => 'Current System Mode';

  @override
  String get debugModeActiveDesc =>
      'The app is currently running in development mode (sample data enabled)';

  @override
  String get releaseModeActiveDesc =>
      'The app is currently running in real production mode';

  @override
  String get chooseOperatingMode => 'Choose operating mode:';

  @override
  String get releaseModeTitle => 'Production Mode (Release)';

  @override
  String get releaseModeDesc =>
      'Use only the real database without any sample data.';

  @override
  String get debugModeTitle => 'Development & Testing Mode (Debug)';

  @override
  String get debugModeDesc =>
      'Automatically generate sample data for products and sales to test the system.';

  @override
  String get debugDangerZoneTitle => 'Sample Data Danger Zone';

  @override
  String get debugDangerZoneDesc =>
      'Tools to control the database and generate sample data.';

  @override
  String get debugSeedExplanation =>
      'This button lets you clear all entries and generate a full set of sample sales for the past 7 days, plus 7 products with different quantities and categories and sample users, so you can inspect the dashboard and charts.';

  @override
  String get resetAndSeedButton => 'Reset Database & Generate Sample Data';

  @override
  String modeChangedSuccess(Object mode) {
    return 'System mode changed to: $mode';
  }

  @override
  String get debugModeShortLabel => 'Development Mode';

  @override
  String get releaseModeShortLabel => 'Production Mode';

  @override
  String dmSaveSettingsFailed(Object error) {
    return 'Failed to save settings: $error';
  }

  @override
  String get dmConfirmResetTitle => 'Confirm Data Reset';

  @override
  String get dmConfirmResetMessage =>
      'All current data (users, products, invoices, daily reports, and activity logs) will be completely cleared and new sample data generated.\n\nThis action cannot be undone.';

  @override
  String get dmResetSeedSuccess =>
      'Data reset and sample data generated successfully';

  @override
  String dmResetSeedError(Object error) {
    return 'Error while resetting data: $error';
  }

  @override
  String get protectionEnabledSuccess =>
      'Protection system enabled successfully';

  @override
  String get restartAppTitle => 'Restart App';

  @override
  String get protectionEnabledRestartMessage =>
      'Protection system enabled successfully!\n\nTo fully benefit from the system, it is recommended to restart the app.';

  @override
  String get dataMovedSuccess => 'Data moved successfully';

  @override
  String get dataMovedSuccessTitle => 'Move Successful';

  @override
  String dataMovedToMessage(Object path) {
    return 'Data has been moved to:\n$path\n\nIt is recommended to restart the app.';
  }

  @override
  String get dataMoveFailedOrCancelled =>
      'Failed to move data or operation was cancelled';

  @override
  String get dataProtectionSystemTitle => 'Data Loss Protection System';

  @override
  String get enabledStatus => 'Enabled';

  @override
  String get notEnabledStatus => 'Not enabled';

  @override
  String get systemEnabledLabel => 'System enabled';

  @override
  String get dataProtectedFromLabel => 'Your data is protected from:';

  @override
  String get protectionFeatureAccidentalDelete => 'Accidental deletion';

  @override
  String get protectionFeatureCrashes => 'Crashes and failures';

  @override
  String get protectionFeaturePowerOutage => 'Power outages';

  @override
  String get protectionFeatureWindowsReinstall => 'Windows reinstall';

  @override
  String dataLocationLabel(Object path) {
    return 'Data location:\n$path';
  }

  @override
  String get changeStorageLocation => 'Change Storage Location';

  @override
  String get systemNotEnabledLabel => 'System not enabled';

  @override
  String get dataAtRiskMessage =>
      'Currently, your data is at risk of loss in case of:';

  @override
  String get riskProgramDelete => 'Uninstalling the program';

  @override
  String get riskAntivirusScan => 'Antivirus scan';

  @override
  String get riskSystemCrash => 'System crash';

  @override
  String get enableProtectionNow => 'Enable Protection Now';

  @override
  String stockSummaryCalcFailed(Object error) {
    return 'Failed to calculate summary: $error';
  }

  @override
  String get pieceUnit => 'pcs';

  @override
  String get switchLanguageLabel => 'English';

  @override
  String profitMarginLabel(Object percent) {
    return 'Margin: $percent%';
  }

  @override
  String revenueAmountLabel(Object amount) {
    return '$amount EGP';
  }

  @override
  String get accessDeniedMessage =>
      'Access denied: You do not have permission to perform this action.';

  @override
  String activityDeleteUser(Object name) {
    return 'Delete user: $name';
  }

  @override
  String activityUpdateUser(Object name) {
    return 'Update user: $name';
  }

  @override
  String activityAddUser(Object name) {
    return 'Add user: $name';
  }

  @override
  String get activityLogin => 'Login';

  @override
  String activityCloseDay(Object total) {
    return 'Close day: $total EGP';
  }

  @override
  String activityUpdateProduct(Object name) {
    return 'Update product: $name';
  }

  @override
  String activityAddProduct(Object name) {
    return 'Add product: $name';
  }

  @override
  String activityDeleteProduct(Object name) {
    return 'Delete product: $name';
  }

  @override
  String activityDeleteInvoice(Object total) {
    return 'Delete invoice: $total EGP';
  }

  @override
  String activityRefund(Object total) {
    return 'Refund: $total EGP';
  }

  @override
  String get activityBulkDeleteInvoices => 'Bulk delete invoices';

  @override
  String activitySale(Object total) {
    return 'Sale: $total EGP';
  }

  @override
  String get activityUpdateStoreInfo => 'Update store information';

  @override
  String activityUpdateStock(Object name, Object qty) {
    return 'Update stock: $name (+$qty)';
  }

  @override
  String activityOpenDay(Object name) {
    return 'Open new day — $name';
  }

  @override
  String get priorityVeryUrgent => 'Very Urgent';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get pdfPhone => 'Phone:';

  @override
  String get pdfVatNumber => 'VAT Number:';

  @override
  String get pdfVatNumberFacility => 'Facility VAT Number:';

  @override
  String get pdfSalesReceipt => 'Tax Sales Receipt';

  @override
  String get pdfSalesInvoice => 'Tax Sales Invoice';

  @override
  String get pdfInvoiceNumber => 'Invoice Number:';

  @override
  String get pdfDateTime => 'Date & Time:';

  @override
  String get pdfIssueDate => 'Issue Date:';

  @override
  String get pdfCashier => 'Cashier:';

  @override
  String get pdfInvoiceStatus => 'Invoice Status:';

  @override
  String get pdfPaidInFull => 'Paid in Full';

  @override
  String get pdfProduct => 'Product';

  @override
  String get pdfProductItem => 'Product / Item';

  @override
  String get pdfQtyShort => 'Qty';

  @override
  String get pdfQtyLong => 'Quantity';

  @override
  String get pdfPrice => 'Price';

  @override
  String get pdfUnitPrice => 'Unit Price';

  @override
  String get pdfTotal => 'Total';

  @override
  String get pdfGrandTotalCol => 'Grand Total';

  @override
  String get pdfSubtotalItems => 'Items Subtotal:';

  @override
  String get pdfSubtotal => 'Subtotal:';

  @override
  String get pdfDiscountApplied => 'Discount Applied:';

  @override
  String get pdfInvoiceDiscounts => 'Invoice Discounts:';

  @override
  String get pdfVatTax => 'VAT:';

  @override
  String get pdfNetTotal => 'Net Total:';

  @override
  String get pdfFinalTotal => 'Final Total:';

  @override
  String get pdfThanksShopping => 'Thank you for shopping with us!';

  @override
  String get pdfThanksDealing => 'Thank you for dealing with us, stay safe!';

  @override
  String get pdfSystemName => 'Bayaa POS Sales Management System';

  @override
  String get pdfTermsConditions => 'Terms & Conditions:';

  @override
  String get pdfTerm1 =>
      '1. Goods sold cannot be returned or exchanged after 14 days from the invoice date.';

  @override
  String get pdfTerm2 =>
      '2. Original invoice must be presented for returns or maintenance.';

  @override
  String get pdfRefundInvoice => 'Refund Invoice';

  @override
  String get pdfDate => 'Date:';

  @override
  String get pdfCashierShort => 'Cashier:';

  @override
  String get pdfThanksVisiting => 'Thank you for visiting!';

  @override
  String get pdfTotalCol => 'Total:';

  @override
  String get pdfDailySalesReport => 'Daily Sales Report';

  @override
  String get pdfPosSystemBayaa => 'Advanced POS System - Bayaa';

  @override
  String get pdfReportDate => 'Report Date:';

  @override
  String get pdfTransactionsCount => 'Transactions Count:';

  @override
  String get pdfNetRevenue => 'Net Revenue:';

  @override
  String get pdfTotalSales => 'Total Sales';

  @override
  String get pdfTotalRefunds => 'Total Refunds';

  @override
  String get pdfNetProfit => 'Net Profit';

  @override
  String get pdfTotalTransactions => 'Total Transactions';

  @override
  String get pdfClosedBy => 'Closed By';

  @override
  String get pdfDailyPerformanceSummary => 'Daily Performance Summary';

  @override
  String get pdfRevenue => 'Revenue';

  @override
  String get pdfCost => 'Cost';

  @override
  String get pdfProfits => 'Profits';

  @override
  String get pdfProfitMargin => 'Profit Margin';

  @override
  String get pdfTopSellingProducts => 'Top Selling Products Performance';

  @override
  String get pdfReportGeneratedAt => 'Report generated at:';

  @override
  String get pdfCopyright => '© 2026 Bayaa POS - All rights reserved';

  @override
  String get pdfFallbackStoreName => 'Bayaa POS';

  @override
  String get pdfFallbackStoreAddressShort => 'Cairo, Egypt';

  @override
  String get pdfFallbackStoreAddressLong => 'Cairo, Arab Republic of Egypt';

  @override
  String get pdfUnknownCashier => 'Unknown';
}
