abstract final class AppStrings {
  static const appName = 'AppGuard';
  static const appSubtitle = 'Misafir ve Uygulama Kilidi';
  static const secure = 'Güvende';
  static const active = 'Aktif';
  static const searchApps = 'Uygulamalarda ara';
  static const allApps = 'Tüm Uygulamalar';
  static const social = 'Sosyal';
  static const system = 'Sistem';
  static const media = 'Medya';
  static const utility = 'Araçlar';
  static const gallery = 'Galeri';
  static const other = 'Diğer';
  static const apps = 'Uygulamalar';
  static const vault = 'Kasa';
  static const history = 'Geçmiş';
  static const settings = 'Ayarlar';
  static const securitySettings = 'Güvenlik Ayarları';
  static const securitySettingsDescription =
      'Sabitlenmiş oturum ve çıkış doğrulama seçeneklerini yönetin.';
  static const exitPin = 'Çıkış PIN\'i';
  static const exitPinDescription =
      'Sabitlenmiş modu bitirmek için istenecek 4 haneli PIN.';
  static const exitPinSet = 'Çıkış PIN\'i ayarlı';
  static const exitPinNotSet = 'Çıkış PIN\'i henüz ayarlanmadı';
  static const setExitPin = 'Çıkış PIN\'i Belirle';
  static const changeExitPin = 'Çıkış PIN\'ini Değiştir';
  static const currentExitPin = 'Mevcut Çıkış PIN\'ini Girin';
  static const currentExitPinDescription =
      'Güvenlik ayarını değiştirmek için mevcut PIN\'inizi doğrulayın.';
  static const exitPinSaved = 'Çıkış PIN\'i kaydedildi.';
  static const pinRequiredForActivation =
      'Sabitlenmiş mod etkinleştirilmeden önce çıkış PIN\'i belirlenmelidir.';
  static const biometricUnlock = 'Biyometrik Kilit Açma';
  static const enabled = 'Etkin';
  static const disabled = 'Devre Dışı';
  static const configured = 'Ayarlı';
  static const notConfigured = 'Ayarlanmadı';
  static const privateVault = 'Özel Kasa';
  static const secureStorage = 'Güvenli Depolama';
  static const launchPinnedMode = 'Sabitlenmiş Modda Başlat';
  static const stopPinnedMode = 'Sabitlenmiş Modu Bitir';
  static const pinnedModeActive = 'Sabitlenmiş mod etkinleştirildi.';
  static const chooseAtLeastOneApp = 'En az bir uygulama seçin.';
  static const comingSoon = 'Bu bölüm yakında kullanıma açılacak.';
  static const setSecurityMethod = 'Kilit Açma Yöntemini Belirleyin';
  static const createPinDescription =
      'Etkin uygulama oturumunuzu korumak için 4 haneli bir PIN oluşturun.';
  static const confirmPinDescription =
      'Devam etmek için PIN\'inizi yeniden girin.';
  static const setMasterPin = 'Ana PIN Oluştur';
  static const confirmPin = 'PIN\'i Doğrula';
  static const enableBiometricUnlock = 'Biyometrik kilit açmayı etkinleştir';
  static const biometricDescription = 'Parmak izi veya yüz doğrulaması';
  static const activateAndLock = 'Etkinleştir ve Uygulamayı Kilitle';
  static const cancelAndReturn = 'İptal Et ve Ana Ekrana Dön';
  static const unauthorizedExit = 'Yetkisiz Çıkış Algılandı';
  static const authenticationRequired =
      'Tam erişimi geri yüklemek için Ana PIN\'inizi girin veya biyometrik doğrulamayı kullanın.';
  static const tapToScan = 'Taramak İçin Dokun';
  static const securityLayer = 'GÜVENLİK KATMANI';
  static const incorrectPin = 'PIN hatalı';
  static const pinsDoNotMatch = 'PIN\'ler eşleşmiyor';
  static const tryAgain = 'Tekrar Dene';
  static const cancel = 'İptal';
  static const save = 'Kaydet';
  static const refresh = 'Yenile';
  static const deleteDigit = 'Son haneyi sil';
  static const pinDigit = 'PIN hanesi';
  static const lockedApp = 'Uygulama kilitli';
  static const unlockedApp = 'Uygulama kilitli değil';
  static const noApplications = 'Uygulama bulunamadı';
  static const noMatchingApplications =
      'Aramanızla eşleşen bir uygulama bulunamadı';
  static const loadingApplications = 'Uygulamalar yükleniyor';
  static const biometricUnavailable = 'Biyometrik doğrulama kullanılamıyor';
  static const biometricDisabled =
      'Biyometrik kilit açma bu oturum için etkin değil.';
  static const noBiometricCredential =
      'Cihazda kayıtlı parmak izi veya yüz verisi bulunmuyor';
  static const biometricReason =
      'AppGuard kilidini açmak için kimliğinizi doğrulayın.';
  static const applicationLaunchFailed = 'Uygulama başlatılamadı.';
  static const unsupportedPlatform =
      'Bu özellik yalnızca Android cihazlarda kullanılabilir.';
  static const pinningNotPermitted =
      'Cihaz güvenlik politikası bu işleme izin vermiyor.';
  static const pinnedModeFailed = 'Bu cihazda sabitlenmiş mod başlatılamadı.';
  static const appNotFound = 'Seçilen uygulama cihazda bulunamadı.';
  static const unexpectedError =
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
  static const reload = 'Yeniden yükle';
  static const phone = 'Telefon';
  static const photos = 'Fotoğraflar';
  static const selected = 'Seçili';

  static String selectedApp(String appName) => '$appName seçildi';
  static String selectedAppCount(int count) => '$count uygulama seçildi';
  static String failedAttempts(int count) => '$count başarısız deneme yapıldı';
  static String remainingLockout(int seconds) =>
      '$seconds saniye sonra tekrar deneyebilirsiniz';
  static String appLockSemantics(String appName, bool locked) =>
      '$appName, ${locked ? lockedApp : unlockedApp}';
}
