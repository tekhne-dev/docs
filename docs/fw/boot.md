---
title: Apple Silicon Önyükleme Süreci   
summary:
  SoC ile tümleşik ROM'dan kullanıcı koduna kadar Apple Silicon cihazları tarafından kullanılan tüm önyükleme süreci
---

Apple Silicon cihazları, modern iOS cihazlarına çok benzer bir önyükleme sürecini takip ediyor gibi görünmektir.

# Aşama 0 (SecureROM)

Bu aşama önyükleme [ROM](../project/glossary.md#r) içinde bulunur. Diğer işlevlerinin yanı sıra, [NOR](../project/glossary.md#n)'dan normal aşama 1'i doğrular, yükler ve yürütür. Bu başarısız olursa, [DFU](../project/glossary.md#d)'ya geri döner ve [iBSS](../project/glossary.md#i) yükleyicisinin gönderilmesini bekler. Ardından aşama 1'deki [DFU](../project/glossary.md#d) akışına devam eder.

# Normal süreç

## Aşama 1 (LLB/iBoot1)

Bu aşama, yerleşik [NOR](../project/glossary.md#n) içinde bulunan ana başlangıç yükleyicisidir. Bu önyükleme aşaması en genel hatlarıyla şu şekilde gerçekleşir:

* [NVRAM](../project/glossary.md#n)'den `boot-volume` değişkenini oku: formatı `<gpt-partition-type-uuid>:<gpt-partition-uuid>:<volume-group-uuid>` şeklindedir. Diğer ilgili değişkenler `update-volume` ve `upgrade-boot-volume` gibi görünmektedir ve muhtemelen `boot-info-payload` değişkeni içindeki meta veriler tarafından seçilmektedir;
* Yerel  hash'ini alın:   
  - Önce yerel proposed hash'i deneyin ([SEP](../project/glossary.md#s) komut 11);   
  - Bu mevcut değilse, yerel blessed hash'i alın ([SEP](../project/glossary.md#s) komut 14)
* iSCPreboot disk bölümünde `/<volume-group-uuid>/LocalPolicy/<policy-hash>.img4` konumunda bulunan yerel önyükleme poliçesini oku. Bu önyükleme poliçesi aşağıdaki özel meta veri anahtarlarına sahiptir:
 - `vuid`: UUID: Birim grubu UUID'si - yukarıdaki ile aynı
  - `kuid`: UUID: KEK grubu UUID'si
  - `lpnh`: SHA384: Yerel poliçe nonce hash'i
  - `rpnh`: SHA384: Uzaktan poliçe nonce hash'i
  - `nsih`: SHA384: Sonraki aşama IMG4 hash'i
  - `coih`: SHA384: fuOS (özel kernelcache) IMG4 hash'i
  - `auxp`: SHA384: Yardımcı kullanıcı yetkilendirmeli çekirdek uzantıları hash'i
  - `auxi`: SHA384: Yardımcı kernel önbelleği IMG4 hash'i
  - `auxr`: SHA384: Yardımcı kernel uzantısı alıcı hash'i
  - `prot`: SHA384: Eşleştirilmiş Kurtarma manifestosu hash'i
  - `lobo`: bool: Yerel önyükleme politikası
  - `smb0`: bool: Azaltılmış güvenlik etkin
  - `smb1`: bool: Seçmeli güvenlik etkin
  - `smb2`: bool: Üçüncü taraf kernel uzantıları etkin
  - `smb3`: bool: Manuel mobil cihaz yönetimi (MDM) kaydı
  - `smb4`: bool?: MDM cihaz kayıt programı devre dışı
  - `sip0`: u16: Özelleştirilmiş SIP
  - `sip1`: bool: İmzalı sistem birimi (`csrutil authenticated-boot`) devre dışı
  - `sip2`: bool: CTRR ([yapılandırılabilir metin bölgesi - salt okunur](https://keith.github.io/xcode-man-pages/bputil.1.html)) devre dışı
  - `sip3`: bool: `boot-args` filtreleme devre dışı

  Ve opsiyonel olarak aşağıdaki bağlantılı manifestolar. Her biri `/<volume-group-uuid>/LocalPolicy/<policy-hash>.<id>.im4m` konumunda bulunur.
  - `auxk`: AuxKC (üçüncü taraf kext) manifestosu
  - `fuos`: fuOS (özel kernelcache) manifestosu

* Bir sonraki aşamayı yükleniyorsa:

  - Önyükleme dizini, hedef bölüm olan Preboot alt biriminde, `/<volume-uuid>/boot/<local-policy.metadata.nsih>` adresinde bulunur;
  - `<boot-dir>/usr/standalone/firmware/iBoot.img4` dosyasının, aynı dizindeki aygıt ağacı ve diğer aygıt yazılımı dosyalarıyla birlikte şifresini çöz, doğrula ve çalıştır. Henüz diğer meta veri tanımlayıcılarına ilişkin bir bulgu bulunmamaktadır.

* Özel bir aşama yükleniyorsa ([fuOS](../project/glossary.md#f)):

  - ...

Bu işlem sırasında herhangi bir noktada hata oluşursa, hata mesajı verilir veya [DFU](../project/glossary.md#d) aşamasına geri dönülerek bir iBEC yükleyicinin gönderilmesi beklenir. Ardından 2. aşamadaki [DFU](../project/glossary.md#d) sürecine devam edilir.

## Aşama 2 (iBoot2)

Bu aşama, işletim sistemi bölümünün içinde bulunan ve macOS'un bir parçası olarak gelen işletim sistemi düzeyinde bir yükleyicidir. Sistemin geri kalanını yükler.

# [DFU](../project/glossary.md#d) süreci

## Aşama 1 (iBSS)

Bu aşama, “canlandıran” ana bilgisayar tarafından cihaza gönderilir. İkinci aşama olan iBEC'i önyükler, doğrular ve çalıştırır.

## Aşama 2 (iBEC)

# Modlar

Önyükleme yapıldıktan sonra [AP](../project/glossary.md#a), [SEP](../project/glossary.md#s) tarafından onaylandığı üzere birkaç önyükleme modundan birinde olabilir:

|  ID | Name                                      |
|----:|-------------------------------------------|
|   0 | macOS                                     |
|   1 | 1TR ("one true" recoveryOS)               |
|   2 | recoveryOS ("ordinary" recoveryOS)        |
|   3 | kcOS                                      |
|   4 | restoreOS                                 |
| 255 | unknown                                   |

[SEP](../project/glossary.md#s) yalnızca [1TR](../project/glossary.md#1) içinde belirli komutların (örneğin önyükleme poliçesini düzenleme) yürütülmesine izin verir, aksi takdirde 11 numaralı “AP önyükleme modu” hatasıyla başarısız olur.
