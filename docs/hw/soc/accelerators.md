---
title: Apple Silicon Hızlandırıcıları
---

SoC'de birkaç yerleşik hızlandırıcı birim bulunur. Aşağıda, bu birimlerin isimleri ve neyi ifade ettiklerine dair faydalı bir liste yer almaktadır. Hızlandırıcıların çoğu, önyükleme öncesi bölümündeki `/System/Volumes/Preboot/[UUID]/restore/Firmware` içinde ve <https://github.com/19h/ftab-dump/blob/master/rkos.py> ile veya bazı dd komutlarıyla çıkarılabilen im4p dosyaları olarak paketlenmiş olan aygıt yazılımını çalıştırır. 

*Güncelleme: ANE, AVE, ADT im4p'lerin hiç biri onunla çıkarılamaz. Hangilerinin çıkarıldığından da emin değilim. [ADT](../../fw/adt.md) içindeki im4p çıkarma adımlarını takip etmeniz daha iyi olacaktır. Aygıt yazılımları ile ilgili bir ilerleme matrisi oluşturabilir miyiz?

## İsimler

İsimler, resmiyetlerine göre aşağıdaki şekillerde biçimlendirilebilir: 
* “<isim>?” gibi soru işareti ile tırnak içinde verilen isimler sonradan uydurulmuş/kaynağı belirsiz isimlerdir.
* **<isim>** gibi **kalın** yazılmış isimler Apple'ın resmi dokümantasyonunda bulunur.
* *<isim>* gibi *italik* yazılmış isimler ya yaygın olarak kullanılan ancak resmi olmayan isimlerdir, ya da kaynağı belirsiz ancak güvenilir isimlerdir.

### A
* **AGX**: “Apple Graphics? Accel(x)lerator?” (`gfx` aracılığıyla) Apple'ın GPU serisinin şirket içindeki adı.
* **AMX**: *Apple Matrix eXtensions*. ISA ile kısmen tümleştirilmiş bir matris yardımcı işlemcisi.
* **ANE**: **Apple Neural Engine** Evrişimlere dayalı sinir ağı yürütme hızlandırması. Google'ın TPU'su gibi düşünün.
* **AOP**: **Always On Processor**. “hey siri” aktivasyonu ve “diğer sensör işlemleri”
* **APR**: **APR ProRes**. ProRes video kodlama + kod çözme işlemlerini gerçekleştirir.
* **AVE**: **AVE Video Encoder**. Video kodlamasını yönetir. Görünüşe göre A, Apple'ı temsil ediyor [kaynak gerek], ancak ben burada özyinelemeli bir kısaltma görüyorum.
* **AVD**: **AVD Video Decoder**. Video kod çözmeyi yönetir. ^

### D
* **DCP**: "Display Compression Processor?"/"Display Control Processor?". Bir tür Displayport/Ekran kontrolü.

### P
* **PMP**: "Power Management Processor?". Güç işlevlerini yönetir.

### S
* **SEP**: **Secure Enclave Processor**. M1'in yerleşik HSM/TPM/vb. cihazı. Touch ID'yı, çoğu şifreleme işlemlerini ve ayrıca önyükleme politikası kararlarını yönetir. Linux için zararsızdır, ancak istersek özelliklerini kullanabiliriz. AP'ye ters.
