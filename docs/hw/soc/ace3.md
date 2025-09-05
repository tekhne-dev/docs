---
title: ACE3
---

ACE3, M3 ürünlerinde bulunan yeni USB-C / USB-PD denetleyicisidir. ADT'de sn201202x uyumlu bir değere sahiptir.

## SPMI aktarımı

Önceki modellerden farklı olarak, ACE3'e I2C yerine SPMI üzerinden erişilir. Ancak temel arayüz değişmemiştir. İnce bir aktarım katmanı, daha önce I2C kayıtları olan (buna “lojik kayıtlar” diyeceğiz) kayıtlara SPMI kayıtları üzerinden erişilmesini sağlar.

- **0x00 (logical register address) [RW]:** Bu SPMI kaydına `0x80 | logical_register_address` yazmak, lojik kayıt seçim sürecini başlatarak aşağıdaki SPMI kayıtlarını günceller. Seçim tamamlandığında, MSB silinir.

  Not 1: “register 0 write” SPMI komutu da kullanılabilir, çünkü 7 bitlik değer MSB=1 ile tamamlanır ve bu nedenle lojik kayıt seçimi tetiklenir.  
  Not 2: MSB=0 ile yazma işlemleri kaydın değerini günceller, ancak yeni bir kayıt seçmez.

- **0x1F (logical register size) [RO]:** bir lojik kayıt seçildiğinde, boyutu bit halinde buraya yazılır.

- **0x20..0x5F (logical register data) [RW]:** bir lojik kayıt seçildiğinde, verileri okunur, sıfırlarla doldurulur ve buraya yazılır. Bu alandaki herhangi bir yere yazma işlemi, alanın içeriğinin (uygun şekilde kesilerek) son seçilen lojik kayda yazılmasına neden olur.

  Not 1: Lojik kayıt yazma işleminin tamamlanmasını takip etmenin bir yolu yok gibi görünse de, daha sonraki seçimleri engellediği anlaşılıyor.
  Not 2: Lojik kayıt yazma işlemini daha sonraya ertelemek için bir yol bulunmadığından, yalnızca ≤ 16 boyutundaki lojik kayıtlar atomik olarak yazılabilir.

Diğer gözlemler:

- Yalnızca ilk 0x60 adresleri eşlenir, ancak adres bitleri 7 ve üstü göz ardı edilir gibi görünür ve bu da bloğun her 0x80 baytta bir takma adla adlandırılmasına neden olur. Genişletilmiş (veya genişletilmiş uzun) komutlar kullanılarak birçok ardışık SPMI kaydına aynı anda erişilebilir.

- Cihaz ayrıca uyku ve uyandırma komutlarını da destekler ve önyükleme sırasında uyku modundadır. Uyku modundayken, yazma işlemleri tanınır ancak yok sayılır. Cihazın komutu aldıktan sonra uyanması biraz zaman alır.

- Kesintiler artık GPIO pini üzerinden değil, SPMI denetleyicisinin kesinti işlevi üzerinden iletilir. (Bunun veri yolu düzeyinde nasıl çalıştığını bilmiyorum. Belki de kesintiler bir ana yazma komutu aracılığıyla tetikleniyordur.)

- Nedense, her cihazın iki SPMI bağımlısı var gibi görünüyor (biri ADT'deki adreste, diğeri bir sonraki adreste dinliyor). Her bağımlı kendi seçimini korur ve ikisinden birine uyku/uyandırma komutları gönderildiğinde, bu komutlar her ikisinde de yansıtılır. Ancak ikinci bağımlı uyku komutlarını yok sayıyor gibi görünüyor.

Bu gözlemler J516c, SN2012024 HW00A1 FW002.062.00 üzerinde yapılmıştır.
