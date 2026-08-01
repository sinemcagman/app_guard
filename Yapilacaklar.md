# Uygulama Dili ve Yerelleştirme

Uygulama içerisindeki kullanıcıya görünen bütün metinler **Türkçe** olmalıdır.

Buna aşağıdakiler dahildir:

* Sayfa başlıkları
* Alt başlıklar ve açıklamalar
* Buton yazıları
* Filtre isimleri
* Arama alanı metinleri
* Modal ve diyalog içerikleri
* Hata mesajları
* Uyarılar
* Başarı bildirimleri
* Boş durum mesajları
* Yükleniyor durumları
* Biyometrik doğrulama açıklamaları
* PIN oluşturma ve doğrulama metinleri
* Erişilebilirlik ve `Semantics` açıklamaları
* Android tarafından Flutter'a dönen ve kullanıcıya gösterilen mesajlar

Kod içerisindeki sınıf, değişken, metot, enum ve dosya isimleri temiz kod standartlarına uygun olarak İngilizce kalabilir. Ancak kullanıcı arayüzünde İngilizce bir metin bulunmamalıdır.

Örnek metin karşılıkları:

```text
AppGuard
Misafir ve Uygulama Kilidi

Search apps
Uygulamalarda ara

All Apps
Tüm Uygulamalar

Social
Sosyal

System
Sistem

Media
Medya

Utility
Araçlar

Launch in Pinned Mode
Sabitlenmiş Modda Başlat

Set Master PIN
Ana PIN Oluştur

Confirm PIN
PIN'i Doğrula

Enable Biometric Unlock
Biyometrik Kilit Açmayı Etkinleştir

Fingerprint or face authentication
Parmak izi veya yüz doğrulaması

Unauthorized Exit Detected
Yetkisiz Çıkış Algılandı

Authentication is required to continue
Devam etmek için kimliğinizi doğrulamanız gerekiyor

Tap to Scan
Taramak İçin Dokun

Incorrect PIN
PIN hatalı

PINs do not match
PIN'ler eşleşmiyor

Try Again
Tekrar Dene

Cancel
İptal

Save
Kaydet

Refresh
Yenile

No applications found
Uygulama bulunamadı

No matching applications found
Aramanızla eşleşen bir uygulama bulunamadı

Biometric authentication is unavailable
Biyometrik doğrulama kullanılamıyor

No biometric credential is enrolled
Cihazda kayıtlı parmak izi veya yüz verisi bulunmuyor

Application could not be launched
Uygulama başlatılamadı

This feature is available only on Android
Bu özellik yalnızca Android cihazlarda kullanılabilir
```

Metinleri widget dosyalarının içine dağınık şekilde sabit olarak yazma.

Aşağıdaki gibi merkezi bir metin sınıfı oluştur:

```text
lib/localization/app_strings.dart
```

Örnek yapı:

```dart
abstract final class AppStrings {
  static const appName = 'AppGuard';
  static const appSubtitle = 'Misafir ve Uygulama Kilidi';
  static const searchApps = 'Uygulamalarda ara';
  static const allApps = 'Tüm Uygulamalar';
  static const social = 'Sosyal';
  static const system = 'Sistem';
  static const media = 'Medya';
  static const utility = 'Araçlar';
  static const launchPinnedMode = 'Sabitlenmiş Modda Başlat';
  static const unauthorizedExit = 'Yetkisiz Çıkış Algılandı';
  static const tapToScan = 'Taramak İçin Dokun';
}
```

Dinamik metinler için parametre alan metotlar kullanılabilir:

```dart
static String failedAttempts(int count) =>
    '$count başarısız deneme yapıldı';

static String remainingLockout(int seconds) =>
    '$seconds saniye sonra tekrar deneyebilirsiniz';

static String selectedApp(String appName) =>
    '$appName seçildi';
```

Şimdilik uygulamanın desteklenen dili yalnızca Türkçe olabilir. Ancak metin altyapısını ileride Flutter'ın resmi yerelleştirme sistemi olan `flutter_localizations` ve `intl` paketlerine geçirilebilecek şekilde merkezi ve modüler tasarla.

Aşağıdaki yerelleştirme ayarlarını uygulamaya ekle:

```dart
locale: const Locale('tr', 'TR'),
supportedLocales: const [
  Locale('tr', 'TR'),
],
```

Gerekli Flutter yerelleştirme delegelerini ekle:

```dart
localizationsDelegates: const [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
```

Gerekirse `pubspec.yaml` içerisine şunu ekle:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
```

Türkçe tarih, saat, sayı ve çoğul ifadelerinde mümkün olduğunca cihazın `tr_TR` yerel ayarını kullan.

Biyometrik doğrulamada `localizedReason` metni Türkçe olmalıdır. Örnek:

```dart
localizedReason:
    'AppGuard kilidini açmak için kimliğinizi doğrulayın.',
```

Native Kotlin tarafındaki dahili hata kodları İngilizce ve makine tarafından işlenebilir kalmalıdır:

```text
LOCK_TASK_STARTED
APP_NOT_FOUND
PINNING_NOT_PERMITTED
```

Ancak bu kodların kullanıcıya gösterilen Türkçe karşılıkları Flutter tarafında `AppStrings` veya merkezi bir hata eşleştirme katmanı üzerinden üretilmelidir.

Kullanıcıya doğrudan aşağıdaki gibi ham teknik mesajlar gösterme:

```text
PlatformException
SecurityException
PackageManager.NameNotFoundException
LOCK_TASK_NOT_PERMITTED
```

Bunları anlaşılır Türkçe metinlere dönüştür:

```text
Bu cihazda sabitlenmiş mod başlatılamadı.
Seçilen uygulama cihazda bulunamadı.
Cihaz güvenlik politikası bu işleme izin vermiyor.
Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.
```

Türkçe karakterlerin tamamı doğru kullanılmalıdır:

```text
ç, Ç, ğ, Ğ, ı, İ, ö, Ö, ş, Ş, ü, Ü
```

`PIN'i`, `uygulamayı`, `kilidi` gibi Türkçe ek ve kesme işareti kullanımlarını düzgün yaz.

README teknik geliştirici dokümantasyonu olduğu için İngilizce veya Türkçe hazırlanabilir; ancak uygulamanın ekran görüntülerinde, kullanıcı akışlarında ve cihaz üzerinde görünen bütün içerikler Türkçe olmalıdır.

Testlerde de Türkçe UI metinleri doğrulanmalıdır. İngilizce kullanıcı arayüzü metni kalmadığını kontrol eden en az bir widget testi ekle.
