---
title: Simetrik Çoklu İşlem (SMP)
summary:
  Apple Silicon SoC'ler için ikincil uygulama işlemcisi başlatma prosedürü
---

## SMP'nin devreye girişi

ADT'den:

* `/arm-io/pmgr[reg]` güç yöneticisi kayıtları
    * CPU başlatma bloğu, bu kayıtlara 'cihaza bağlı' bir ofset konumundadır.
        * A7-A8(X) için      - 0x30000
        * A9(X)-A11, T2 için - 0xd4000
        * M1 serisi için     - 0x54000
        * M2 ve M3 için      - 0x34000
        * M2 Pro/Max için    - 0x28000
        * M3 Pro/Max için    - 0x88000
    * Çoklu die (çip parçası) sistemlerinde, her die kendi güç yöneticisi kayıtlarına sahiptir.
      Her die için güç yöneticisi kayıtları, die 0 kayıtlarından 
      `die * 0x2000000000` ofsetinde bulunur.
* `/cpus/cpu<n>[cpu-impl-reg]` CPU implementasyon kayıtları
* `/cpus/cpu<n>[reg]` CPU başlatma bilgileri
     * [0:7] bitleri çekirdek (core) kimliğini içerir
     * [8:10] bitleri küme (cluster) kimliğini içerir
     * [11:14] bitleri die kimliğini içerir

A11 kümeleri düzgün bir şekilde işlemediğinden, hem P hem de E CPU'lar küme 0 olarak kabul edilir.
ECPU'lar 0-3, PCPU'lar ise 4-5'tir.

Eski aygıt yazılımlarında `/cpus/cpu<n>[cpu-impl-reg]` mevcut olmayabilir, bu durumda
`/arm-io/reg[2*n+2]` kullanılarak başlangıç adresinin yazılacağı konum bulunabilir.

PMGR'deki CPU başlatma kayıtları:

```
ofset + 0x4: Sistem genelinde CPU çekirdeği başlatma/aktif bit maskesi
ofset + 0x8: Küme 0 (e) CPU çekirdeği başlatma
ofset + 0xc: Küme 1 (p) CPU çekirdeği başlatma
```

### Startup sırası

* Başlangıç adresini `cpu-impl-reg + 0x00` adresindeki RVBAR'a yazdır.
    * Bu, iBoot tarafından cpu0 için kilitlenmiştir, diğer CPU'lar serbestçe değiştirilebilir.
* `pmgr[offset + 0x4]` adresinde (1 << cpu) değerini yaz.
    * Bu, sistem genelinde bir tür “çekirdek etkin” sinyali gibi görünüyor. Çekirdeğin çalışması için gerekli değildir,
    ancak bu olmadan   AIC kesintileri ve muhtemelen diğer bazı işlevler çalışmaz.
* `pmgr[(offset + 0x8) + 4*cluster]` içinde (1 << core) değerini yaz. (Bu 0-3'ten çekirdek, 0-1'den kümedir)
    * Bu, çekirdeğin kendisini başlatır.

Çekirdek RVBAR'da başlatılır. Chicken bitler[^1] vb. her zamanki gibi uygulanmalıdır.

[^1]: Chicken Bit: Çipte bulunan ve çipin bir özelliğinin arızalı olduğu veya performansı olumsuz etkilediği durumlarda bu özelliği devre dışı bırakmak için kullanılabilen bir bit.
