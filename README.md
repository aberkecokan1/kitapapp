# Stephen King - 

Stephen King App, kullanıcıların kitaplarını listeleyebileceği, detaylarını görüntüleyebileceği, favori kitaplarını kaydedebileceği ve bildirimler alabilecekleri Flutter tabanlı bir mobil uygulamadır.

## Özellikler

- 📚 Kitap listesi görüntüleme
- 🔍 Kitap arama
- ⭐ Favori kitapları kaydetme
- 🔔 Günlük kitap okuma hatırlatıcıları
- 🌙 Karanlık/Aydınlık tema desteği
- 🌐 Çoklu dil desteği (İngilizce/Türkçe)


## Proje Yapısı

lib/
  ├── components/         # Yeniden kullanılabilir UI bileşenleri
  ├── db/                 # Veritabanı ve depolama işlemleri
  │   ├── db_imp/         # Depolama implementasyonları
  │   │   └── collection_imp.dart
  │   │   └── crud_imp.dart
  │   ├── collection.dart
  │   ├── favori_books.dart
  │   ├── storage.dart
  │   └── store_factory.dart
  ├── exception/          # Özel istisna sınıfları
  │   └── api_error.dart
  ├── l10n/               # Yerelleştirme dosyaları
  │   ├── app_en.arb      # İngilizce çeviriler
  │   └── app_tr.arb      # Türkçe çeviriler
  ├── models/             # Veri modelleri ve Redux state yönetimi
  │   ├── actions.dart
  │   ├── api_model.dart
  │   ├── api_model.g.dart
  │   ├── reducers.dart
  │   ├── redux_model.dart
  │   └── redux_model.g.dart
  ├── screens/            # Uygulama ekranları
  │   ├── book_detail.dart
  │   ├── book_list.dart
  │   ├── favorites.dart
  │   └── splash_screen.dart
  ├── services/           # API ve bildirim servisleri
  │   ├── services_imp/   # Servis implementasyonları
  │   │   ├── not_services_impl.dart
  │   │   ├── permission_services_impl.dart
  │   │   └── repo_services_impl.dart
  │   ├── notifications.dart
  │   ├── permission.dart
  │   └── repository.dart
  └── main.dart           # Uygulama giriş noktası


## API Kullanımı

Uygulama, kitap verilerini [Stephen King API](https://stephen-king-api.onrender.com/api/books) üzerinden çekmektedir. API çalışmıyorsa, veriler Hive veritabanından yüklenir.

## Notlar
Test klasöründe yazılmış test bulunmaktadır. Oradan test yapılabilir.
