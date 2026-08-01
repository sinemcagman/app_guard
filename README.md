# AppGuard

AppGuard, Android cihazlarda seçilen uygulamalara erişimi ekran sabitleme, dört haneli Ana PIN ve isteğe bağlı biyometrik doğrulama ile sınırlandıran Türkçe bir Flutter uygulamasıdır.

## Özellikler

- Cihazdaki başlatılabilir Android uygulamalarını listeleme
- Yalnızca cihazda gerçekten kurulu uygulamaları gösterme
- Uygulama adıyla arama ve kategoriye göre filtreleme
- Korunacak uygulamaları seçme
- Android ekran sabitleme (lock task) oturumu
- SHA-256 özetli dört haneli Ana PIN
- Ayarlar sekmesinden çıkış PIN'i oluşturma ve doğrulayarak değiştirme
- Parmak izi veya yüz doğrulamasıyla kilit açma
- Yetkisiz çıkış algılandığında tam ekran güvenlik katmanı
- Tamamen merkezi Türkçe arayüz metinleri
- Obsidian Shield tasarım sistemi ve platformlara özel AppGuard ikonları

## Gereksinimler

- Flutter 3.41 veya üzeri
- Dart 3.11 veya üzeri
- Android SDK 21 veya üzeri

Sabitlenmiş mod ve cihazdaki uygulamaları başlatma yalnızca Android'de çalışır. Diğer platformlarda arayüz önizlemesi için örnek uygulama listesi gösterilir.

## Kurulum

```shell
flutter pub get
flutter run
```

Android debug APK oluşturmak için:

```shell
flutter build apk --debug
```

## Kalite kontrolleri

```shell
flutter analyze
flutter test
```

Widget testleri; ana ekranın Türkçe açılmasını, arama davranışını, güvenlik kurulum akışını ve görünür sistem metinlerinde İngilizce ifade kalmamasını doğrular.

## Proje yapısı

```text
lib/
  features/       Ekranlar ve kullanıcı akışları
  localization/   Merkezi Türkçe metinler
  models/         Uygulama ve kategori modelleri
  services/       PIN, biyometri ve Android yöntem köprüleri
  theme/          Obsidian Shield renk ve tema sistemi
  widgets/        Paylaşılan logo ve PIN bileşenleri
```

Tasarım referansları `HatunumunTasarimi/`, ürün ve yerelleştirme gereksinimleri `Yapilacaklar.md` altında tutulur.
