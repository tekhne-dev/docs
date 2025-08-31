---
title: SPRR ve GXF
summary:
    SPRR ve GXF, macOS/Darwin'i daha güvenli yapmak için kullanılan silikon içi güvenlik özellikleridir.
---


# Korumalı yürütme

Korumalı yürütme modu, EL1 ve EL2'nin yanında yer alan ve aynı pagetable'ları fakat farklı izinleri kullanan (bknz. SPRR) bir yanal istisna düzeyidir. Bu düzeyler GL1 ve GL2 olarak adlandırılır. S3_6_C15_1_2'deki bit 1 ile etkinleştirilir.

`0x00201420` komutu 'genter' olup EL'den GL'ye geçer ve PC'yi `S3_6_C15_C8_1` olarak ayarlar.
`0x00201420` 'gexit' olup EL'ye geri döner.

```
#define SYS_GXF_ENTER_EL1 sys_reg(3, 6, 15, 8, 1)
```

Korumalı modda, tıpkı EL1/2 gibi ayrı ayrı ELR, FAR, ESR, SPSR, VBAR ve TPIDR kayıtları bulunur.
Ek olarak, ASPSR kaydı gexit'in GL'ye mi yoksa EL'ye mi dönmesi gerektiğini gösterir.

```
#define SYS_TPIDR_GL1 sys_reg(3, 6, 15, 10, 1)
#define SYS_VBAR_GL1 sys_reg(3, 6, 15, 10, 2)
#define SYS_SPSR_GL1 sys_reg(3, 6, 15, 10, 3)
#define SYS_ASPSR_GL1 sys_reg(3, 6, 15, 10, 4)
#define SYS_ESR_GL1 sys_reg(3, 6, 15, 10, 5)
#define SYS_ELR_GL1 sys_reg(3, 6, 15, 10, 6)
#define SYS_FAR_GL1 sys_reg(3, 6, 15, 10, 7)
```


# SPRR  

SPRR, pagetable girişlerinden izin bitlerini alır ve bunları MAIR'ın çalışma şekline benzer şekilde bir öznitelik dizini haline dönüştürür:

```
   3      2      1     0
 AP[1]  AP[0]   UXN   PXN
```

UXN ve PXN'nin APRR'ye göre tersine çevrildiğine dikkat edin!

Sonrasında bu, her girdinin dört bitlik olduğu bir sistem kaydına indekslemek için kullanılır:


```
    3     2     1     0
  GL[1] GL[0] EL[1] EL[0]
```

GL/EL çoğunlukla ayrı olarak ele alınabilir, ancak belirli bir GL izninin iki EL bitinin genel anlamını değiştirdiği iki istisna vardır.


| register value | EL page permissions | GL page permissions |
|-|-|-|
| `0000` | `---` | `---` |
| `0001` | `r-x` | `---` |
| `0010` | `r--` | `---` |
| `0011` | `rw-` | `---` |
| `0100` | `---` | `r-x` |
| `0101` | `r-x` | `r-x` |
| `0110` | `r--` | `r-x` |
| `0111` | `---` | `r-x` |
| `1000` | `---` | `r--` |
| `1001` | `--x` | `r--` |
| `1010` | `r--` | `r--` |
| `1011` | `rw-` | `r--` |
| `1100` | `---` | `rw-` |
| `1101` | `r-x` | `rw-` |
| `1110` | `r--` | `rw-` |
| `1111` | `rw-` | `rw-` |


Bu dört bit, EL veya GL modunda çalışırken gerçek izinleri gösterir.
EL0 ve EL1, izinlerin ayrıştırılması için ayrı kayıtlara sahiptir.

S3_6_C15_C1_0 / SPRR_CONFIG_EL1'deki bit 1, SPRR'yi ve yeni sistem kayıtlarına erişimi etkinleştirir.

S3_6_C15_1_5, EL0 için izin kaydıdır. S3_6_C15_1_6 ise EL1/GL1 içindir.

```
#define SYS_SPRR_CONFIG_EL1       sys_reg(3, 6, 15, 1, 0)
#define SPRR_CONFIG_EN            BIT(0)
#define SPRR_CONFIG_LOCK_CONFIG   BIT(1)
#define SPRR_CONFIG_LOCK_PERM_EL0 BIT(4)
#define SPRR_CONFIG_LOCK_PERM_EL1 BIT(5)

#define SYS_SPRR_PERM_EL0 sys_reg(3, 6, 15, 1, 5)
#define SYS_SPRR_PERM_EL1 sys_reg(3, 6, 15, 1, 6)
```
