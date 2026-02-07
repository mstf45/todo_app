# 🚀 TaskFlow Pro

Modern, şık ve tam özellikli Flutter görev yönetimi uygulaması. MVVM mimarisi, Provider state management ve Firebase backend ile geliştirilmiştir.

## ✨ Özellikler

### 🔐 Kimlik Doğrulama
- ✅ Email/Şifre ile kayıt ve giriş
- ✅ Şifre sıfırlama
- ✅ Oturum yönetimi
- ✅ Profil fotoğrafı yükleme

### 📝 Görev Yönetimi
- ✅ Görev ekleme, düzenleme, silme
- ✅ Görev tamamlama/açma
- ✅ Kategori bazlı organizasyon (İş, Kişisel, Alışveriş, Sağlık, Diğer)
- ✅ Öncelik seviyeleri (Düşük, Orta, Yüksek, Acil)
- ✅ Son tarih belirleme
- ✅ Arama ve filtreleme
- ✅ Gerçek zamanlı senkronizasyon

### 📊 İstatistikler
- ✅ Pasta grafikleri (kategorilere göre dağılım)
- ✅ İlerleme çubukları (önceliklere göre)
- ✅ Tamamlanma oranı
- ✅ Bugünkü, yaklaşan ve gecikmiş görevler
- ✅ Detaylı performans metrikleri

### 🎨 Kullanıcı Arayüzü
- ✅ Modern, minimal ve şık tasarım
- ✅ Dark/Light mode desteği
- ✅ Yumuşak animasyonlar
- ✅ Responsive tasarım
- ✅ Material Design 3
- ✅ Custom color palette

### 👤 Profil Yönetimi
- ✅ Profil bilgileri
- ✅ Profil fotoğrafı yükleme/güncelleme
- ✅ İstatistikler
- ✅ Ayarlar
- ✅ Bildirim ayarları sayfası
- ✅ Gizlilik politikası sayfası
- ✅ Yardım & Destek sayfası
- ✅ Çıkış yapma

## 🏗️ Mimari

### MVVM (Model-View-ViewModel)

```
lib/
├── models/           # Veri modelleri
│   ├── task.dart
│   └── user_model.dart
├── providers/        # ViewModels (State Management)
│   ├── auth_provider.dart
│   ├── task_provider.dart
│   └── theme_provider.dart
├── services/         # İş mantığı ve API çağrıları
│   ├── auth_service.dart
│   ├── task_service.dart
│   └── storage_service.dart
├── screens/          # Views (UI Ekranları)
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── tasks_screen.dart
│   ├── add_task_screen.dart
│   ├── task_detail_screen.dart
│   ├── statistics_screen.dart
│   ├── profile_screen.dart
│   ├── notifications_screen.dart
│   ├── privacy_screen.dart
│   └── help_support_screen.dart
├── widgets/          # Reusable Widget'lar
│   ├── task_card.dart
│   └── filter_chip_widget.dart
└── main.dart         # Uygulama giriş noktası
```

## 🛠️ Teknolojiler

### State Management
- **Provider** - Lightweight ve kolay state management

### Firebase Services
- **Firebase Auth** - Kullanıcı kimlik doğrulama
- **Cloud Firestore** - NoSQL veritabanı
- **Firebase Storage** - Profil fotoğrafları ve dosya depolama

### UI/UX Kütüphaneleri
- **flutter_animate** - Yumuşak animasyonlar
- **fl_chart** - Güzel grafikler
- **google_fonts** - Modern fontlar
- **font_awesome_flutter** - İkon seti
- **shimmer** - Yükleme animasyonları

### Utilities
- **intl** - Uluslararasılaştırma ve tarih formatı
- **shared_preferences** - Yerel veri saklama
- **image_picker** - Resim seçme ve fotoğraf çekme
- **uuid** - Benzersiz ID oluşturma
- **url_launcher** - E-posta ve web linkleri açma

## 🚀 Kurulum

### 1. Projeyi Klonlayın
```bash
git clone https://github.com/yourusername/taskflow_pro.git
cd taskflow_pro
```

### 2. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 3. Firebase Kurulumu

#### Android için:
1. [Firebase Console](https://console.firebase.google.com/) açın
2. Yeni proje oluşturun veya mevcut projeyi seçin
3. Android uygulaması ekleyin
   - Package name: `com.taskflow.taskflow_pro`
4. `google-services.json` dosyasını indirin
5. Dosyayı `android/app/` klasörüne kopyalayın

#### iOS için:
1. Firebase Console'da iOS uygulaması ekleyin
   - Bundle ID: `com.taskflow.taskflowPro`
2. `GoogleService-Info.plist` dosyasını indirin
3. Xcode'da projeyi açın ve dosyayı ekleyin

### 4. Firebase Authentication'ı Aktifleştirin
1. Firebase Console > Authentication > Sign-in method
2. Email/Password'ü aktifleştirin

### 5. Firestore Database Oluşturun
1. Firebase Console > Firestore Database
2. Create database
3. Test mode ile başlayın (production'da rules güncelleyin)

### 6. Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /tasks/{taskId} {
      allow read, write: if request.auth != null && 
                            request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### 7. Firebase Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_photos/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /task_attachments/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 8. Uygulamayı Çalıştırın
```bash
flutter run
```

## 🔑 Önemli Notlar

### Profil Fotoğrafı İzinleri
Android ve iOS'ta kamera ve galeri erişimi için izinler gereklidir. Bu izinler AndroidManifest.xml ve Info.plist'e eklenmelidir.

**Android:** Kamera ve depolama izinleri
**iOS:** Kamera ve fotoğraf kütüphanesi kullanım açıklamaları

### Yerelleştirme
Uygulama Türkçe dilini desteklemektedir. Tarih formatları `intl` paketi ile sağlanır.

## 📱 Desteklenen Platformlar

- ✅ Android (minSdk 21)
- ✅ iOS (iOS 12+)
- ⏳ Web (yakında)

## 🎨 Ekran Görüntüleri

*(Ekran görüntüleri eklenecek)*

## 📦 Build

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (Google Play için)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🔑 Önemli Notlar

### Profil Fotoğrafı İzinleri
Uygulama Türkçe dilini desteklemektedir. Tarih formatları `intl` paketi ile sağlanır.

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 👨‍💻 Geliştirici

**Your Name**
- Email: your.email@example.com
- GitHub: [@yourusername](https://github.com/yourusername)

## 🙏 Teşekkürler

- Flutter ekibine harika framework için
- Firebase ekibine backend servisleri için
- Açık kaynak topluluğuna kullandığımız kütüphaneler için

## 📝 Yapılacaklar

- [ ] Push notifications
- [ ] Görev paylaşma
- [ ] Görev yorumları
- [ ] Dosya eklentileri
- [ ] Tekrarlayan görevler
- [ ] Alt görevler
- [ ] Etiket sistemi
- [ ] Takım işbirliği
- [ ] Export/Import
- [ ] Widget desteği
- [ ] Wear OS desteği

---

**Not:** Bu uygulama Google Play Store ve App Store'da yayınlanmaya hazırdır. Yayınlamadan önce:
1. Firebase production rules'larını güncelleyin
2. App Store/Play Store listing'lerini hazırlayın
3. Privacy Policy ve Terms of Service oluşturun
4. Uygulama iconunu ve splash screen'i güncelleyin
5. Release keystore oluşturun ve güvenli saklayın