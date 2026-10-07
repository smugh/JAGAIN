import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { id, en }

class AppLanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => AppLanguage.id;

  void setLanguage(AppLanguage language) => state = language;

  void toggleLanguage() {
    state = state == AppLanguage.id ? AppLanguage.en : AppLanguage.id;
  }
}

final appLanguageProvider =
    NotifierProvider<AppLanguageNotifier, AppLanguage>(
      AppLanguageNotifier.new,
    );

class AppStrings {
  const AppStrings(this.lang);

  final AppLanguage lang;

  bool get isId => lang == AppLanguage.id;

  // Header & Brand
  String get appName => 'JAGAIN';
  String get brandEssence =>
      isId ? 'Jaga yang berarti.' : 'Care for what matters.';
  String get welcomeGreeting =>
      isId ? 'Halo, selamat datang' : 'Hello, welcome back';
  String get primaryTagline =>
      isId ? 'Jangan cuma punya, JAGAIN.' : "Don't just own it, JAGAIN.";
  String get welcomeDescription =>
      isId
          ? 'Catat aset pentingmu. Ingat apa yang perlu dilakukan. Rawat dengan lebih tenang.'
          : 'Record important assets. Remember what needs doing. Care with peace of mind.';
  String get addFirstAsset =>
      isId ? 'Tambah aset pertama' : 'Add your first asset';

  // Navigation
  String get navHome => isId ? 'Beranda' : 'Home';
  String get navAssets => isId ? 'Aset' : 'Assets';
  String get navAddAsset => isId ? 'Tambah' : 'Add';
  String get navActivity => isId ? 'Aktivitas' : 'Activity';
  String get navSettings => isId ? 'Pengaturan' : 'Settings';
  String get navReminders => isId ? 'Pengingat' : 'Reminders';

  // Dashboard
  String get dashboardTitle =>
      isId ? 'Dashboard Informasi Aset' : 'Asset Information Dashboard';
  String get totalAssets => isId ? 'Total Aset' : 'Total Assets';
  String get goodCondition => isId ? 'Kondisi Baik' : 'Good Condition';
  String get needsAttention => isId ? 'Perlu Perhatian' : 'Needs Attention';
  String get underMaintenance =>
      isId ? 'Sedang Ditangani' : 'Under Maintenance';
  String get activeReminders => isId ? 'Pengingat Aktif' : 'Active Reminders';
  String get categoryBreakdown =>
      isId ? 'Kategori Aset' : 'Asset Categories';

  // Sections
  String get sectionNeedsAttention =>
      isId ? 'Perlu perhatian' : 'Needs attention';
  String get sectionYourAssets => isId ? 'Aset kamu' : 'Your assets';
  String get seeAll => isId ? 'Lihat semua' : 'See all';
  String get allSafeForNow =>
      isId ? 'Semua aman untuk sekarang' : 'All good for now';
  String get allSafeSubtitle =>
      isId
          ? 'Pengingat yang perlu ditindaklanjuti akan muncul di sini.'
          : 'Reminders needing follow-up will appear here.';

  // Form Tambah Aset
  String get formTitle => isId ? 'Tambah Aset Baru' : 'Add New Asset';
  String get formSubtitle =>
      isId
          ? 'Pilih kategori dan beri nama untuk mulai merawat asetmu.'
          : 'Choose a category and name to start caring for your asset.';
  String get chooseCategory => isId ? 'Pilih Kategori' : 'Select Category';
  String get assetNameLabel => isId ? 'Nama Aset' : 'Asset Name';
  String get assetNameHint =>
      isId
          ? 'misal: Toyota Avanza, MacBook Pro, Rumah'
          : 'e.g. Toyota Avanza, MacBook Pro, House';
  String get assetNameRequired =>
      isId ? 'Nama aset wajib diisi' : 'Asset name is required';
  String get conditionLabel => isId ? 'Kondisi Saat Ini' : 'Current Condition';
  String get conditionGood => isId ? 'Kondisi baik' : 'Good';
  String get conditionAttention =>
      isId ? 'Perlu perhatian' : 'Needs attention';
  String get conditionMaintenance =>
      isId ? 'Sedang ditangani' : 'Under maintenance';
  String get conditionCritical => isId ? 'Kritis' : 'Critical';

  // Optional Fields (Progressive Enrichment)
  String get additionalInfo =>
      isId
          ? 'Informasi Tambahan (Opsional)'
          : 'Additional Information (Optional)';
  String get brandLabel => isId ? 'Merk / Brand' : 'Brand';
  String get brandHint => isId ? 'misal: Honda, Apple, Samsung' : 'e.g. Honda, Apple, Samsung';
  String get modelLabel => isId ? 'Model / Tipe' : 'Model / Type';
  String get modelHint => isId ? 'misal: Vario 160, MacBook Pro 14' : 'e.g. Vario 160, M2 Pro';
  String get yearLabel => isId ? 'Tahun Pembuatan' : 'Year';
  String get yearHint => isId ? 'misal: 2023' : 'e.g. 2023';
  String get locationLabel => isId ? 'Lokasi Aset' : 'Location';
  String get locationHint => isId ? 'misal: Garasi rumah, Meja kantor' : 'e.g. Garage, Home office';
  String get notesLabel => isId ? 'Catatan Perawatan' : 'Care Notes';
  String get notesHint =>
      isId
          ? 'Catatan khusus servis atau hal penting lainnya'
          : 'Special notes for service or maintenance';

  // Actions
  String get saveAsset => isId ? 'Simpan Aset' : 'Save Asset';
  String get cancel => isId ? 'Batal' : 'Cancel';
  String get assetSavedSuccess =>
      isId ? 'Aset berhasil disimpan!' : 'Asset successfully saved!';

  // Settings
  String get settingsTitle => isId ? 'Pengaturan' : 'Settings';
  String get settingsSubtitle =>
      isId
          ? 'Atur tampilan, bahasa, privasi, dan cara JAGAIN bekerja.'
          : 'Manage display, language, privacy, and how JAGAIN works.';
  String get darkMode => isId ? 'Tema Gelap' : 'Dark Mode';
  String get darkModeActive =>
      isId ? 'Warna gelap dominan aktif' : 'Dominant dark theme active';
  String get lightModeActive =>
      isId ? 'Warna terang aktif' : 'Light theme active';
  String get languageSetting => isId ? 'Bahasa Aplikasi' : 'App Language';
  String get languageDesc =>
      isId ? 'Bahasa Indonesia aktif' : 'English active';
  String get privacyTitle =>
      isId ? 'Privasi dan keamanan' : 'Privacy & Security';
  String get privacySubtitle =>
      isId ? 'Data disimpan di perangkat ini' : 'Data stored on this device';
  String get backupTitle =>
      isId ? 'Cadangan dan ekspor' : 'Backup & Export';
  String get backupSubtitle =>
      isId ? 'Kelola salinan data asetmu' : 'Manage your asset data copy';
  String get notificationTitle => isId ? 'Notifikasi' : 'Notifications';
  String get notificationSubtitle =>
      isId ? 'Atur pengingat lokal' : 'Manage local reminders';
  String get footerText => isId ? 'JAGAIN · Catat – Ingat – Rawat' : 'JAGAIN · Record – Remember – Care';

  // Master Kategori & Foto
  String get masterCategoryTitle => isId ? 'Master Kategori' : 'Category Master';
  String get masterCategorySubtitle =>
      isId ? 'Kelola dan atur kategori aset' : 'Manage and customize asset categories';
  String get addCategory => isId ? 'Tambah Kategori' : 'Add Category';
  String get deleteCategory => isId ? 'Hapus Kategori' : 'Delete Category';
  String get categoryNameLabel => isId ? 'Nama Kategori Baru' : 'New Category Name';
  String get categoryNameHint => isId ? 'misal: Alat Musik, Hobi, Koleksi' : 'e.g. Music, Hobby, Collection';
  String get categoryDeleteConfirm =>
      isId ? 'Yakin ingin menghapus kategori ini?' : 'Are you sure you want to delete this category?';
  String get categoryDeleteWarning =>
      isId ? 'Kategori ini akan dihapus dari daftar opsi aset.' : 'This category will be removed from asset options.';
  String get photoOptionLabel => isId ? 'Foto / Gambar Aset' : 'Asset Photo / Image';
  String get photoOptionHint =>
      isId ? 'Pilih visual yang sesuai untuk mempermudah identifikasi.' : 'Select a visual to easily identify your asset.';
  String get selectPhoto => isId ? 'Pilih Foto' : 'Select Photo';

  // Checklist Items
  String get checklistTitle => isId ? 'Checklist & Perawatan' : 'Care & Maintenance Checklist';
  String get checklistSubtitle =>
      isId ? 'Daftar hal yang perlu dijaga dan dirawat untuk aset ini.' : 'List of tasks to track and maintain for this asset.';
  String get addChecklistItem => isId ? 'Tambah Item Checklist' : 'Add Checklist Item';
  String get checklistHint => isId ? 'misal: Bayar pajak, Ganti kampas rem' : 'e.g. Pay tax, Brake pads replacement';
  String get quickSuggestions => isId ? 'Saran Cepat' : 'Quick Suggestions';
  String get checklistDone => isId ? 'selesai' : 'completed';

  // Categories
  String categoryName(String id) {
    if (isId) {
      switch (id) {
        case 'vehicle':
          return 'Kendaraan';
        case 'property':
          return 'Properti';
        case 'electronics':
          return 'Elektronik';
        case 'personal':
          return 'Pribadi';
        default:
          return 'Lainnya';
      }
    } else {
      switch (id) {
        case 'vehicle':
          return 'Vehicle';
        case 'property':
          return 'Property';
        case 'electronics':
          return 'Electronics';
        case 'personal':
          return 'Personal';
        default:
          return 'Other';
      }
    }
  }
}

final stringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(appLanguageProvider);
  return AppStrings(lang);
});
