# H2Z2 - Zombie Survival Game

H2Z2, Godot 4.5.1 ile geliştirilmiş 3D zombi hayatta kalma oyunudur. Day-Z tarzında single-player bir deneyim sunar.

## Özellikler

### Oynanış
- **First Person Shooter (FPS)** kontrol sistemi
- **Zombi AI** - NavigationAgent3D ile akıllı takip sistemi
- **Loot Sistemi** - Silah ve sağlık çantası toplayabilme
- **Otomatik Zombi Spawn** - Sürekli zombi tehdidi
- **Hayatta Kalma Mekaniği** - Sağlık ve cephane yönetimi

### Harita
- **100x100 metre** kapalı alan
- **4 adet bina** - Loot bulmak için
- **Çevre duvarları** - Oyun alanını sınırlar
- **Dinamik loot spawn** noktaları

### Sistemler
- **Sağlık Sistemi** (0-100 HP)
- **Silah Sistemi** - Ateş etme ve yeniden yükleme
- **Muzzle Flash** - Particle effect ile ateş efekti
- **Envanter Sistemi** - TAB/I ile açılır envanter UI
- **Item Slot Sistemi** - Toplanan itemleri görsel olarak gösterir
- **Etkileşim Sistemi** - Loot toplama
- **HUD** - Sağlık, cephane, silah bilgisi, envanter listesi
- **Crosshair** - Nişan alma
- **Zombi Spawn Sistemi** - Max 10 zombi aynı anda

## Kontroller

### Hareket
- **W** - İleri git
- **S** - Geri git
- **A** - Sola git
- **D** - Sağa git
- **Space** - Zıpla
- **Left Shift** - Koş
- **C** - Çömel

### Savaş
- **Sol Fare Tuşu** - Ateş et
- **R** - Silahı yeniden yükle

### Etkileşim
- **E** - Loot topla (silah, sağlık çantası)
- **TAB veya I** - Envanter aç/kapat
- **Mouse** - Kamera hareketi
- **ESC** - Fare imlecini serbest bırak/yakala

## Oyun Mekaniği

### Loot Türleri
1. **Silah (Pistol)** - Gri kutu
   - 30 mermi ile gelir
   - Her atış 25 hasar verir
   - R tuşu ile yeniden yükleme

2. **Sağlık Çantası** - Kırmızı kutu
   - 30 HP iyileştirir
   - Max 100 HP

### Zombiler
- **50 HP** sağlık
- **10 hasar** per saldırı
- **20 metre** algılama menzili
- **1.5 metre** saldırı menzili
- **2.0 m/s** hareket hızı
- **1.5 saniye** saldırı bekleme süresi

### Oyuncu
- **100 HP** maksimum sağlık
- **5.0 m/s** yürüme hızı
- **8.0 m/s** koşma hızı
- **2.5 m/s** çömelme hızı
- **4.5 m/s** zıplama gücü

## Kurulum ve Çalıştırma

### Gereksinimler
- Godot Engine 4.5.1

### Adımlar
1. Godot Engine 4.5.1'i indirin ve kurun
2. Godot'u açın
3. "İçe Aktar" (Import) butonuna tıklayın
4. Bu projenin `project.godot` dosyasını seçin
5. Projeyi açın
6. **F5** tuşuna basarak oyunu başlatın

## Proje Yapısı

```
H2Z2/
├── project.godot                 # Ana proje dosyası
├── icon.svg                      # Proje ikonu
├── README.md                     # Bu dosya
│
├── scenes/                       # Tüm sahneler
│   ├── player/
│   │   └── Player.tscn          # Oyuncu karakteri sahnesi
│   ├── zombie/
│   │   └── Zombie.tscn          # Zombi karakteri sahnesi
│   ├── loot/
│   │   ├── WeaponPickup.tscn    # Silah pickup sahnesi
│   │   └── HealthPack.tscn      # Sağlık çantası sahnesi
│   ├── ui/
│   │   └── HUD.tscn             # Oyun içi UI sahnesi
│   └── world/
│       └── Main.tscn            # Ana oyun sahnesi
│
├── scripts/                      # Tüm GDScript dosyaları
│   ├── player/
│   │   └── Player.gd            # Oyuncu kontrol script'i
│   ├── zombie/
│   │   └── Zombie.gd            # Zombi AI script'i
│   ├── loot/
│   │   ├── LootBase.gd          # Temel loot sınıfı
│   │   ├── WeaponPickup.gd      # Silah pickup script'i
│   │   └── HealthPack.gd        # Sağlık çantası script'i
│   ├── systems/
│   │   ├── GameManager.gd       # Oyun yöneticisi
│   │   └── ZombieSpawner.gd     # Zombi spawn sistemi
│   └── ui/
│       └── HUD.gd               # HUD kontrol script'i
│
└── assets/                       # Asset klasörleri
    ├── models/                   # 3D modeller (şu an boş)
    ├── textures/                 # Dokular (şu an boş)
    └── sounds/                   # Sesler (şu an boş)
```

## Teknik Detaylar

### Motor ve Versiyonlar
- **Motor**: Godot 4.5.1
- **Dil**: GDScript
- **Render**: Forward Plus
- **Çözünürlük**: 1920x1080 (Fullscreen)

### Fizik
- **3D Physics Layers**:
  - Layer 1: Player
  - Layer 2: World
  - Layer 3: Zombie
  - Layer 4: Loot
  - Layer 5: Interactable
- **Gravity**: 9.8 m/s²

### AI ve Navigasyon
- **NavigationAgent3D** ile zombi yol bulma
- **NavigationRegion3D** ile navigasyon mesh
- **Dinamik hedef takibi**

### Performans
- **Max Zombi**: 10 aynı anda
- **Spawn Interval**: 10 saniye
- **Spawn Radius**: 30-40 metre

## Geliştirme Notları

### Referans Kaynaklar
Bu proje aşağıdaki GitHub kaynaklarından esinlenilerek geliştirilmiştir:
- **FPS Controller**: Jeh3no/Godot-Advanced-FPS-Controller-Template
- **AI System**: LimboAI (Behavior Trees)
- **Inventory**: expressobits/inventory-system

### Ücretsiz Asset Kaynakları (CC0)
Oyunu geliştirmek için kullanabileceğiniz ücretsiz asset'ler:

**3D Modeller:**
- **Kenney FPS Starter Kit**: https://github.com/KenneyNL/Starter-Kit-FPS (3D modeller, silahlar, CC0)
- **GDQuest 3D Characters**: https://github.com/gdquest-demos/godot-4-3D-Characters (Karakter modelleri, Godot 4 uyumlu)
- **itch.io Godot Assets**: https://itch.io/game-assets/free/tag-godot (Ücretsiz zombi ve karakter modelleri)
- **Sketchfab**: https://sketchfab.com/tags/godot (CC0 ve CC-BY zombi modelleri)

**Ses Efektleri:**
- **Weapon Sound Library**: https://github.com/PanderMusubi/sound-effects-library-weapons (CC0 silah sesleri)
- **Kenney FPS Kit**: https://github.com/KenneyNL/Starter-Kit-FPS (CC0 oyun sesleri)
- **OpenGameArt Pistol Sounds**: https://opengameart.org/content/pistol-animations-sounds-for-godot (CC0 ateş sesleri)
- **Freesound.org**: https://freesound.org (CC0 çeşitli ses efektleri)

**Asset Kullanım Notu:**
Asset'leri indirip `assets/models/` ve `assets/sounds/` klasörlerine yerleştirin ve Godot'ta import edin.

### Gelecek Geliştirmeler
Projeye eklenebilecek özellikler:

**Tamamlananlar:**
- [x] Temel envanter sistemi (TAB ile açılır)
- [x] Muzzle flash particle effect
- [x] Item slot görsel sistemi

**Yapılacaklar:**
- [ ] Daha fazla silah türü (rifle, shotgun)
- [ ] Farklı zombi türleri
- [ ] Bina içi loot spawn
- [ ] Ses efektlerini entegre et (asset linkler README'de)
- [ ] 3D modelleri entegre et (asset linkler README'de)
- [ ] Zombi ve silah animasyonları
- [ ] Gece/gündüz döngüsü
- [ ] Açlık ve susuzluk sistemi
- [ ] Craft sistemi
- [ ] Kaydetme/yükleme sistemi
- [ ] Farklı haritalar

## İpuçları

1. **Zombilerden kaçın!** - Çok fazla zombi varsa koşarak uzaklaşın
2. **Cephaneyi koru** - Her atış sayılır, boşa mermi harcamayın
3. **Sağlık çantalarını topla** - Düşük HP ile oyun zorlaşır
4. **Binalar arkasını kullan** - Zombilerden saklanmak için
5. **İlk silahı hemen bul** - Silahsız zombi öldürmek imkansız
6. **Spawn noktalarını öğren** - Loot her zaman aynı yerlerde

## Lisans

Bu proje eğitim ve eğlence amaçlı geliştirilmiştir. Serbestçe kullanabilir ve geliştirebilirsiniz.

## Katkıda Bulunma

Bu bir açık kaynak eğitim projesidir. Geliştirmeler için:
1. Projeyi fork edin
2. Yeni bir branch oluşturun
3. Değişikliklerinizi yapın
4. Pull request gönderin

---

**H2Z2** - Survive the Zombie Apocalypse!
Godot 4.5.1 ile geliştirildi.
