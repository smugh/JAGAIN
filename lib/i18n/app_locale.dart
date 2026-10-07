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
  String get editAsset => isId ? 'Edit Aset' : 'Edit Asset';
  String get editFormTitle => isId ? 'Edit Aset' : 'Edit Asset';
  String get editFormSubtitle =>
      isId
          ? 'Perbarui informasi dan checklist perawatan asetmu.'
          : 'Update details and care checklist for your asset.';
  String get cancel => isId ? 'Batal' : 'Cancel';
  String get assetSavedSuccess =>
      isId ? 'Aset berhasil disimpan!' : 'Asset successfully saved!';
  String get assetUpdatedSuccess =>
      isId ? 'Aset berhasil diperbarui!' : 'Asset successfully updated!';
  String get takePhotoCamera => isId ? 'Ambil Foto' : 'Take Photo';
  String get takePhotoCameraDesc => isId ? 'Kamera HP' : 'Device Camera';
  String get pickFromGallery => isId ? 'Dari Galeri' : 'From Gallery';
  String get pickFromGalleryDesc => isId ? 'Pilih Gambar' : 'Choose Picture';
  String get removePhoto => isId ? 'Hapus Foto' : 'Remove Photo';
  String get photoPresetsLabel =>
      isId ? 'Atau gunakan pilihan ikon:' : 'Or choose preset icon:';

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

  // Reminders & Permissions (Feature Update)
  String get reminderSectionTitle => isId ? 'Set Pengingat (Opsional)' : 'Set Reminder (Optional)';
  String get reminderSectionSubtitle =>
      isId ? 'Ingatkan jadwal servis atau pembayaran dengan waktu & tanggal akurat.' : 'Set precise date & time care reminders.';
  String get enableReminder => isId ? 'Aktifkan Pengingat' : 'Enable Reminder';
  String get reminderTargetLabel => isId ? 'Opsi Melekat Pengingat' : 'Reminder Target Option';
  String get reminderTargetAsset => isId ? '📌 Melekat pada Aset' : '📌 Attached to Asset';
  String get reminderTargetChecklist => isId ? '📋 Melekat pada Sub-Item' : '📋 Attached to Sub-Item';
  String get chooseChecklistItemForReminder =>
      isId ? 'Pilih Sub-Item Checklist:' : 'Select Checklist Sub-Item:';
  String get noChecklistForReminderWarning =>
      isId ? 'Belum ada item checklist. Tambahkan item di section Checklist di bawah, atau pilih "Melekat pada Aset".' : 'No checklist items yet. Add one in the Checklist section below or select "Attached to Asset".';
  String get reminderTitleLabel => isId ? 'Judul Pengingat' : 'Reminder Title';
  String get reminderTitleHint => isId ? 'misal: Servis berkala, Bayar STNK' : 'e.g. Regular service, Tax renewal';
  String get reminderDateTimeLabel => isId ? 'Waktu & Tanggal Pengingat' : 'Reminder Date & Time';
  String get reminderPickDate => isId ? 'Pilih Tanggal' : 'Pick Date';
  String get reminderPickTime => isId ? 'Pilih Waktu' : 'Pick Time';
  String get reminderRecurrenceLabel => isId ? 'Pengulangan' : 'Recurrence';
  String get recurrenceOnce => isId ? 'Sekali Saja' : 'Once';
  String get recurrenceMonthly => isId ? 'Bulanan' : 'Monthly';
  String get recurrenceEvery3Months => isId ? 'Setiap 3 Bulan' : 'Every 3 Months';
  String get recurrenceEvery6Months => isId ? 'Setiap 6 Bulan' : 'Every 6 Months';
  String get recurrenceYearly => isId ? 'Tahunan' : 'Yearly';
  String get executeReminderTitle => isId ? 'Selesaikan Pengingat' : 'Complete Reminder';
  String get executeReminderAction => isId ? 'Selesaikan' : 'Complete';
  String get saveToHistoryOption => isId ? 'Simpan aksi ini ke riwayat / log aset' : 'Save this action to asset history log';
  String get actionLogNotesLabel => isId ? 'Catatan Pelaksanaan (Opsional)' : 'Action Execution Notes (Optional)';
  String get actionLogNotesHint =>
      isId ? 'misal: Ganti oli 4L di bengkel resmi, biaya Rp 450.000, kondisi mesin halus.' : 'e.g. Changed 4L synthetic oil at official dealer, Rp 450,000, engine runs smooth.';
  String get confirmAndSaveLog => isId ? 'Selesaikan & Simpan Log' : 'Complete & Save to Log';
  String get reminderExecutedSuccess =>
      isId ? 'Pengingat berhasil diselesaikan dan dicatat ke riwayat aset!' : 'Reminder completed and recorded in asset history!';
  String get addReminderTitle => isId ? 'Tambah Pengingat Baru' : 'Add New Reminder';
  String get assetHistoryTitle => isId ? 'Riwayat & Log Aset' : 'Asset History & Logs';
  String get assetHistorySubtitle =>
      isId ? 'Catatan tindakan, servis, dan pengingat yang telah diselesaikan.' : 'Log of completed actions, maintenance, and reminders.';
  String get addManualLog => isId ? 'Tambah Catatan Log' : 'Add History Log';
  String get noHistoryYet => isId ? 'Belum ada riwayat tercatat untuk aset ini.' : 'No history logs recorded for this asset yet.';
  String get permissionRequestedMsg =>
      isId ? 'Akses notifikasi & pengingat telah diminta untuk perangkat Anda.' : 'Notification & alarm permissions requested for your device.';

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
