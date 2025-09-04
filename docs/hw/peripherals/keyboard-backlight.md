---
title: Klavye Arka Işığı Denetleyicisi
---

MacBook Pro'da klavye arka ışığı ADT'de şu şekilde görünür:

```
fpwm {
  [...]
  AAPL.phandle = 59
  clock-gates = 37
  device_type = fpwm
  reg = [889470976, 16384]

  kbd-backlight {
    [...]
  }
}
```

Bu, 0x235044000 adresinde, 0x23b7001e0 adresindeki saat kapısı tarafından etkinleştirilen ve klavye arka ışığını kontrol eden bir PWM olduğunu gösteriyor. Durum gerçekten de öyle görünüyor :-)

Anladığım kadarıyla kayıtlar şöyle:

```
+0x00: etkinleştirmek veya sayaç değerleri değiştiğinde 0x4239 yazar
+0x04: bilinmiyor, etkisi yok
+0x08: durum bitleri: ışık yandığında 0x01 biti, ışık söndüğünde 0x02 biti ayarlanır. Yazarak silinir.
+0x0c: bilinmiyor, etkisi yok
+0x18: kapalı süre, 24 MHz tiklerde
+0x1c: açık süre, 24 MHz tiklerde
```

Örneğin klavye arka ışığının rahatsız edici ve muhtemelen epilepsi nöbetine neden olabilecek şekilde yanıp sönmesini sağlayacak tam bir m1n1 dizisi şöyledir:

```
>>> write32(0x23b7001e0, 0xf)
>>> write32(0x23504401c, 1200000)
>>> write32(0x235044018, 1200000)
>>> write32(0x235044000, 0x4239)
```

%50 görev döngüsünü koruyarak frekansı değiştirme:

```
>>> write32(0x235044018, 4000)
>>> write32(0x23504401c, 4000)
>>> write32(0x235044000, 0x4239)
```

PR https://github.com/AsahiLinux/linux/pull/5 adresinde
