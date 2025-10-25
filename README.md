# Simple Platform Game

Godot 4.5.1 için geliştirilmiş basit bir 2D platform oyunu.

## Özellikler

- 2D platform mekaniği
- Karakter kontrolü (hareket ve zıplama)
- Platformlar arası atlama
- Hedef/kazanma sistemi
- Otomatik kamera takibi

## Kontroller

- **Hareket**: A/D veya Sol/Sağ ok tuşları
- **Zıplama**: W/Boşluk/Yukarı ok tuşu

## Oynanış

Mavi kare oyuncuyu kontrol ederek platformlar arasında zıplayın ve sarı hedefe ulaşın. Hedefe ulaştığınızda kazanırsınız ve oyun yeniden başlar.

## Gereksinimler

- Godot Engine 4.5.1

## Nasıl Oynanır

1. Godot Engine 4.5.1'i açın
2. "İçe Aktar" (Import) butonuna tıklayın
3. Bu projenin bulunduğu klasörden `project.godot` dosyasını seçin
4. Projeyi açın
5. F5 tuşuna basarak oyunu başlatın

## Proje Yapısı

```
.
├── project.godot          # Ana proje yapılandırması
├── icon.svg              # Proje ikonu
├── scenes/               # Oyun sahneleri
│   ├── Main.tscn        # Ana oyun sahnesi
│   ├── Player.tscn      # Oyuncu karakteri sahnesi
│   └── Goal.tscn        # Hedef nesnesi sahnesi
└── scripts/             # GDScript dosyaları
    ├── Main.gd          # Ana sahne script'i
    ├── Player.gd        # Oyuncu kontrol script'i
    └── Goal.gd          # Hedef mekanik script'i
```

## Teknik Detaylar

- **Motor**: Godot 4.5.1
- **Dil**: GDScript
- **Çözünürlük**: 1280x720
- **Fizik**: CharacterBody2D ile 2D fizik
- **Yerçekimi**: 980.0 (varsayılan)

## Geliştirme

Bu proje basit bir başlangıç şablonudur. Aşağıdaki özellikler eklenebilir:

- Düşman karakterler
- Toplanabilir objeler (coin, star vb.)
- Birden fazla seviye
- Ses efektleri ve müzik
- Animasyonlar
- Daha gelişmiş seviye tasarımı
- Puan sistemi
- Zamanlayıcı

## Lisans

Bu proje eğitim amaçlı oluşturulmuştur ve serbestçe kullanılabilir.
