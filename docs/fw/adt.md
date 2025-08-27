---
title: Apple Device Tree (ADT) / Apple Aygıt Ağacı
summary:
    Apple Device Tree (Apple Aygıt Ağacı), Apple Silicon cihazlarında kullanılan donanım keşif ve başlatma sistemidir.
---

Apple aygıt yazılımı bir kerneli başlattığında, bir aygıt ağacını binary formatında aktarır. Bu format, Linux tarafından beklenen Open Firmware (Açık Aygıt Yazılımı) standardına çok benzer, ancak ondan farklıdır.

Linux aygıt ağaçları (Linux DT) gibi, Apple Device Tree (ADT) de bir dizi türsüz bayt kümesini (verilerini) bir nod hiyerarşisinde kodlar. Bunlar, kullanılabilir donanımı tanımlar veya Apple'ın aygıt yazılımının kernele bildirmesi gerektiğini düşündüğü diğer bilgileri sağlar. Buna seri numaraları ve WiFi anahtarları gibi tanımlayıcı ve gizli bilgiler dahildir.  

ADT'ler ile Linux DT'ler arasındaki temel fark bayt sırasıdır ve verileri türsüz olduğundan bunu otomatik olarak düzeltemeyiz.

## ADT'nizi Edinin

Donanıma dayanarak, ADT'nize çeşitli yollarla erişebilirsiniz.  

### Seçenek 1: m1n1 hata ayıklama konsolu üzerinden.  
En kolay yol muhtemelen adt.py aracılığıyla m1n1'i kullanmaktır.

```
cd m1n1/proxyclient ; python -m m1n1.adt --retrieve dt.bin
```

Bu, ham (binary) ADT içeren “dt.bin” adlı bir dosya oluşturacak ve kodu çözümlenmiş ADT'yi yazdıracaktır.

### Seçenek 2: macOS im4p dosyaları aracılığıyla (Not: bunlar, önyükleme sırasında iBoot tarafından doldurulan eksik ayrıntılardır)
### img4lib
xerub'un img4lib dosyasının bir kopyasını alın

```
git clone https://github.com/xerub/img4lib
cd img4lib
make -C lzfse
make
make install
```

### img4tool
Tihmstar'ın img4tool programının bir kopyasını edinin (ayrıca libgeneral, autoconf, automake, libtool, pkg-config, openssl ve libplist-2.0 programlarına da ihtiyacınız olacaktır).

```
git clone https://github.com/tihmstar/libgeneral.git
git clone https://github.com/tihmstar/img4tool.git
```
sonra her biri için

```
./autogen.sh
make
make install
```
### Aygıt ağacı dosyalarını elde etme
Aşağıdaki dizinden im4p dosyasını kopyalayın. Makine ‘j’ modelinin ayrıntıları için [Aygıtlar](../hw/devices/device-list.md) bölümüne bakın.

`/System/Volumes/Preboot/[UUID]/restore/Firmware/all_flash/DeviceTree.{model}.im4p`

Dizin mevcut değilse, kurtarma modunda csrutil'i devre dışı bırakmayı deneyin, ayarlara gidip terminalin tüm dosyalara erişmesini sağlayın veya `Volumes/Macintosh HD/` konumundan başlayın, çünkü symlink ile sembolik bağlanmış olabilir. Hala erişilemez durumdaysa, eski usül `sudo find . -type f -name ‘*.im4p’` komutunu deneyin.

ardından img4tool kullanarak im4p dosyasını bir .bin dosyasına çıkarın. Örneğin:
```
img4tool -e DeviceTree.j274ap.im4p -o j274.bin
```
Aynı şeyi img4lib için de yapmak için, şöyle yapın:
```
img4 -i DeviceTree.j274ap.im4p -o j274.bin
```

### Seçenek 3: macOS üzerinden

Aşağıdaki komutu çalıştırarak ADT'nin metin olarak gösterimini doğrudan macOS'tan alabilirsiniz:
```
ioreg -p IODeviceTree -l | cat
```
Bu kod çözümleme gerektirmese de, m1n1 kullanmaya kıyasla çok daha az bilgi çıkarır (aşağıya bakınız).

## ADT' nin kodunu çözümleme

m1n1 kurulumundan sonra (bkz. [depo sayfası](https://github.com/AsahiLinux/m1n1))

`cd m1n1/proxyclient`

construct python kütüphanesini edinin (construct.py dosyası değil, kütüphane)

`pip install construct`

j{*}.bin dosyasını proxyclient dizinine kopyalayın ve şu komutla çıkarın:

`python -m m1n1.adt j{*}.bin`

-a seçeneği ile bir bellek haritası da alabilirsiniz:

`python -m m1n1.adt -a j{*}.bin` 
