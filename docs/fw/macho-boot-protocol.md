---
title: MachO Önyükleme Protokolü
summary:
  Apple Silicon cihazları tarafından m1n1'i MachO binary olarak önyüklerken kullanılan önyükleme protokolü
---

## Önyükleme protokolü

### Bellek

Bellek 0x8_0000_0000'de başlar.

iBoot tarafından bize yapılan çağrılarda bellek şu şekilde görünür:

```
+==========================+ <-- RAM tabanı (0x8_0000_0000)
| Ortak işlemci bölmeleri, |
| iBoot öğeleri vb.        |
+==========================+ <-- boot_args->phys_base, VM = boot_args->virt_base
| kASLR slide bşlğu(<32MiB)|
+==========================+
| Aygıt Ağacı (ADT)        | /chosen/memory-map.DeviceTree
+--------------------------+
| Trust Önbelleği          | /chosen/memory-map.TrustCache
+==========================+  <-- Mach-O'nun en düşük vmaddr'ı buraya eşleştirildi (+ slide!)
| Mach-O tabanı (header)   | /chosen/memory-map.Kernel-mach_header
+--                      --+
| Mach-O segmentleri...    | /chosen/memory-map.Kernel-(segment ID)...
+--                      --+
| m1n1: Payload bölgesi    | /chosen/memory-map.Kernel-PYLD (şu anda 64MB)
+==========================+
| SEP Aygıt Yazılımı       | /chosen/memory-map.SEPFW
+--------------------------+ <-- boot_args
| BootArgs                 | /chosen/memory-map.BootArgs
+==========================+ <-- boot_args->top_of_kdata
|                          |
|      (Boş bellek)        |
| (iBoot trampoline dahil) |
|                          |
+==========================+ <-- boot_args->top_of_kdata + boot_args->mem_size
| Video belleği, SEP       |
| bölmesi, ve dahası       |
+==========================+ <-- 0x8_0000_0000 + boot_args.mem_size_actual
```

### Göstergeler hakkında

Karşılaşabileceğiniz dört tür adres vardır:

* Fiziksel adresler
* m1n1 yer değiştirmemiş ofsetler (0'a göre)
* Mach-O sanal adresler
* kASLR-slid sanal adresler

Fiziksel adresler, dikkat etmeniz gereken tek şeydir.

m1n1 yeri değiştirilmemiş ofsetleri, yalnızca yer değiştirmeler çalıştırılmadan önce m1n1 başlangıç kodu ve
ilgili bağlayıcı komut dosyası bilgileri tarafından kullanılır. C ortamı bunlardan sonra uygun şekilde konum ayarlaması yapar, bu nedenle bunları orada hiç görmemelisiniz bile. Ancak, m1n1'de hata ayıklıyor ve göstergeyi yazdırıyorsanız ve bunları ham ELF dosyasına geri döndürmek istiyorsanız, yeri değiştirilmemiş ofseti elde etmek için m1n1 yükleme ofsetini çıkarmalısınız.

Sanal adreslerin hiçbir önemi yoktur. Bu adresler sadece Mach-O'nun fiziksel adres diye bir kavramı olmadığı için ve tüm yapı Darwin'in kendisini belirli bir şekilde haritalandırıcağını varsaydığı için kullanılır. Bizim kullanım amaçlarımız için bir vaddr sadece `paddr + ba.virt_base - ba.phys_base`'dir. m1n1 en üstteki sanal adresleri kullanmaz ve Linux, Darwin ile hiçbir ilgisi olmayan kendi işini yapar.

Ek olarak, iki sanal adres haritası vardır: Mach-O'da bulunanlar ve iBoot'un bize aktardığı göstergeler. İkincisi, vaddr'leri de etkileyen kASLR slaytı tarafından kaydırılmıştır. Bu da her şeyi daha da kafa karıştırıcı hale getirir.

Bu nedenle, iBoot'tan alınan herhangi bir Darwin kASLR-slid sanal göstergesi için, `vaddr - ba.virt_base + ba.phys_base` hesaplarız ve tek ilgilendiğimiz budur. Öte yandan yalnızca bağlayıcı komut dosyası (ve içindeki Mach-O header) Mach-O unslid sanal adresleriyle ilgilenir. m1n1 kodu yazıyorsanız, bunları asla görmeyeceksiniz. Gerçekten. Bunu çok fazla düşünmeye çalışmayın,
sadece kafanızı karıştıracaksınız.

### Giriş

iBoot, Mach-O'nun saçmasapan veri yapısında tanımlanan giriş noktasına kaydırılmamış bir vaddr olarak girer.
Giriş MMU kapalıyken yapılır. `x0`, [boot_args yapısını](https://github.com/AsahiLinux/m1n1/blob/main/src/xnuboot.h) gösterir.

Ek olarak, iBoot önyükleme CPU'sunun RVBAR'ını giriş noktasının bulunduğu sayfanın en üstüne ayarlar ve kilitler.
Bu, önyüklemeden sonra değiştirilemez. Bu nedenle bu adres her zaman özel bir öneme sahip olup, daimi önyükleyici kodu olarak ele alınmalıdır. Şu anda bunun pratikteki önemi belirsizdir, ancak muhtemelen derin uykudan çıktıktan sonra, önyükleme CPU'su buradan kodu çalıştırmaya başlayacaktır. Bunun, gerçek CPU vektörlerini kilitlemediğini (bunlar `VBAR_EL2` içinde serbestçe değiştirilebilir) ve ikincil CPU'ların RVBAR'ını etkilemediğini (bu, başlatma komutu verilmeden önce serbestçe ayarlanabilir) unutmayın.

## m1n1 bellek düzeni

m1n1 ilk çalıştırıldığında, ilgili bellek şöyle görünür:

```
+==========================+
| Aygıt Ağacı (ADT)        | /chosen/memory-map.DeviceTree
+--------------------------+
| Trust Cache              | /chosen/memory-map.TrustCache
+==========================+ <-- _base
| Mach-O header            | /chosen/memory-map.Kernel-_HDR
+--                      --+ <-- _text_start, _vectors_start
| m1n1 .text               | /chosen/memory-map.Kernel-TEXT
+--                      --+
| m1n1 .rodata             | /chosen/memory-map.Kernel-RODA
+--                      --+ <-- _data_start
| m1n1 .data & .bss        | /chosen/memory-map.Kernel-DATA
+--                      --+ <-- _payload_start
| m1n1 Payload bölgesi     | /chosen/memory-map.Kernel-PYLD (64MB currently)
+==========================+ <-- _payload_end
| SEP Aygıt Yazılımı       | /chosen/memory-map.SEPFW
+--------------------------+ <-- boot_args
| BootArgs                 | /chosen/memory-map.BootArgs
+==========================+ <-- boot_args->top_of_kdata, heap_base
| m1n1 heapblock           | (>=128MB)
+--                      --+ <-- ProxyUtils.heap_base (m1n1 heapblock in use end + 128MB)
| Python heap              | (1 GiB)
+--                      --+
|  (kullanılmayan bellek)  |
+==========================+ <-- boot_args->top_of_kdata + boot_args->mem_size
```

m1n1'in heapblock alanı (malloc için backend olarak ve payloadları yüklemek için kullanılır) `boot_args.top_of_kdata`'da başlar ve şu anda herhangi bir sınırlaması yoktur. Proxyclient kullanıldığında, ProxyUtils mevcut heapblock üst kısmının 128 MiB üzerinde bir Python heap tabanı kurar. Bu da m1n1'in Python tarafındaki yapılara ulaşmadan önce 128 MiB'ye kadar ek bellek kullanabileceği anlamına gelir. Python tarafının yeni yürütmeleri, mevcut m1n1 sonundan başlayarak yığınlarını yeniden başlatacaktır. Bu nedenle örneğin her Python yürütmesinde m1n1 tarafındaki bellek sızıntıları, toplam RAM'iniz bitene kadar acil bir sorun oluşturmaz. 

Başka bir Mach-O payload'unu zincirleme olarak yüklerken, bir sonraki aşama ise m1n1 kendi yerindeyken onun üzerine yazar. Chainload.py Mach-O yükleme kodu, m1n1 payload bölümünün padding ucunu atlar (işaretleyici olarak 4 sıfır bayt hariç). Böylece SEP aygıt yazılımı ve BootArgs, aksi takdirde m1n1 payload alanı olacak olan yerde doğrudan yer alır ve RAM'den tasarruf sağlar. SEP aygıt yazılımının yeniden konumlandırılması isteğe bağlıdır. Etkinleştirilmezse, olduğu yerde kalır ve top_of_kdata dokunulmadan korunur. m1n1, kendi payload bölgesinin boyutundan daha fazla büyümedikçe, bu işlem güvenli olmalıdır.
