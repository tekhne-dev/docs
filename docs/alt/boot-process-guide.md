---
title: Asahi Önyükleme Süreci
summary:
  Asahi Linux'un Apple Silicon Mac'lerde nasıl önyüklendiğini
  anlatır. Dağıtım/işletim sistemi tümleştiricileri içindir.
---

Bu sayfa, önyüklenebilir bir Asahi Linux sisteminde yer alan paketleri/bileşenleri ve bunların birbirleriyle nasıl etkileşime girdiğini açıklamaktadır. Bu sayfa, dağıtım paketleyicileri ve paketleri kullanmak yerine kendi derlemelerini oluşturmak/bakımını yapmak isteyen kişilere yöneliktir. Arch Linux ARM tabanlı referans dağıtımında kullanılan kurulum temel alınarak hazırlanmıştır, fakat çoğu sistemde uygulanabilir.

Bu uygulamaya açık bir rehberdir. Üretici yazılımını nasıl ele aldığımız da dahil olmak üzere daha resmi bir açıklama veya teknik özellikler için [Apple Silicon Mac'lerde Açık İşletim Sistemleri Ekosistemi](../platform/open-os-interop.md) bölümüne bakın. Fedora Asahi Remix'te her şeyin nasıl çalıştığına dair ayrıntılı bilgi için, [Nasıl Yapılır](https://docs.fedoraproject.org/en-US/fedora-asahi-remix/how-its-made/) sayfasına bakın.

## Önyükleme zincirine genel bakış

[Apple'ın aşamaları] → m1n1 aşama 1 → m1n1 aşama 2 → DT + U-Boot → GRUB → Linux

m1n1 aşama 1, kurtarma modundayken (step2.sh dosyasında) Asahi Linux yükleyicisi tarafından kurulur, bu süreçte (Apple'ın güvenli önyükleme kuralının bir parçası olarak) makineye özgü bir iç anahtarla imzalanır ve değişmez olarak kabul edilebilir. Bunu yükseltmeye nadiren ihtiyaç duyulacaktır. Biz de gerektiğinde bunun için araçlar geliştireceğiz. Bu işletim sistemine atanan EFI sistem bölümünün PARTUUID'si (yükleme sırasında ayarlanan) sabit olarak kodlanmıştır ve m1n1 aşama 2'yi `<ESP>/m1n1/boot.bin` adresinden zincirlemesine yükler (ESP, dahili NVMe depolama alanında olmalıdır, harici depolama desteklenmemektedir). Ayrıca bu PARTUUID'yi bir sonraki aşamaya aktarır (‘ayarlanacak/seçilecek bir özellik’ olarak; aşağıya bakınız), böylece bir sonraki aşama hangi disk bölümünden önyükleme yapıldığını bilir.

Geri kalan önyükleme bileşenlerinin bakımı ve yükseltilmesinden işletim sistemi/dağıtım sorumludur.

m1n1 aşama 2, daha fazla donanımı başlatmak, bu platform için uygun DT'yi seçmek, dinamik özellikleri eklemek ve U-Boot'u yüklemekle sorumludur.

U-Boot da daha fazla şeyi başlatır (ör. klavye, USB), UEFI hizmetleri sağlar ve (varsayılan olarak, yayınlanan yapılandırmamızda) `<ESP>/EFI/BOOT/BOOTAA64.EFI` konumundan bir UEFI ikili dosyasını yükler, böylelikle sihirli değeri (magic) korur. U-Boot'un DT'yi hem kullandığını, hem de hafifçe değiştirdiğini* ve yönlendirdiğini unutmayın.

GRUB tamamen standarttır, hiçbir özelliği yoktur. Başka herhangi bir arm64 EFI ikili dosyasını da kullanabilirsiniz.

\* Büyük ölçüde, fiziksel/klavye konsolu mu yoksa UART konsolu mu kullanmanız gerektiğini düşünerek stdout yolunu ayarlamaktadır.

### Sihirli ESP özellikleri

Asahi için, her işletim sistemi kurulumunun kendi EFI sistem bölümüne sahip olduğu standart dışı bir yapılandırmamız var. Bu, Apple'ın önyükleme seçici modeline uyum sağlamayı kolaylaştırmaktadır, çünkü Apple EFI hakkında bir şey bilmemektedir. Apple'ın bakış açısından, kurulan her Asahi örneği kendi ayrı işletim sistemidir ve bu nedenle ilerleyen kısımlarda her biri için ayrı bir ESP kullanıyoruz. Böyle bir konteyner/ESP içinde birden fazla önyükleyici veya işletim sistemi kurmanızı engelleyen hiçbir şey yoktur, ancak:

* Güvenlikle ilgili platform özellikleriyle (ör. SEP) bütünleşmeye başladığımızda, bunun gelecekte sorunlara yol açacağından şüpheleniyoruz. Zira “şu anda önyüklü işletim sistemi kimliği” gibi bir kavram söz konusu olabilir.
* Her konteyner/ESP için yalnızca bir DT, U-Boot ve m1n1 aşama 2 sürümü olabileceğinden, birden fazla dağıtım bir konteyneri paylaşıyorsa, güncellemeleri yönetmek için işbirliği yapmanın makul bir yolu yoktur.
* Kalıcı EFI değişkeni depolama birimimiz yok (ve bunu runtime hizmetlerinde nasıl yapacağımıza dair iyi bir fikrimiz de yok), bu da EFI önyükleme sırasını yönetmenin bir yolu olmadığı anlamına geliyor. Dolayısıyla, yalnızca varsayılanla yetinmek zorunda kalıyorsunuz.

Bu nedenle, nihai kullanıcılar için dağıtım desteği ekliyorsanız, lütfen bu modele sadık kalın. Bir istisna, USB önyüklenebilir kurtarma/yükleyici imajlarıdır. Bunlar, Asahi Linux yükleyicisinin düz UEFI konteyner modunda yüklediği vanilla m1n1.bin paketi ile, `/EFI/BOOT/BOOTAA64.EFI` (`m1n1/boot.bin` yok) içeren USB sürücüsündeki kendi ESP'lerinden önyüklenebilir olmalıdır. Bunlar, dahili ESP'deki `boot.bin` dosyasını asla kendileri yönetmeye çalışmamalıdır (uygun şekilde yüklenmedikçe ve bu şekilde o konteynerin sahibi olmadıkça). Umarız DT durumu USB önyükleme için uygun hale gelir.

Şu anda önyüklenen işletim sistemine atanan EFI sistem bölümünün PARTUUID'si, m1n1 tarafından `/chosen` aygıt ağacı nodunun `asahi,efi-system-partition` özelliği olarak ayarlanır ve Linux'ta `/proc/device-tree/chosen/asahi,efi-system-partition` adresinden okunabilir. U-Boot branch'imiz de doğru ESP'yi bulmak için bunu kullanır.

## Sürüm etkileşimleri

İşte burada işler biraz karışmaktadır. m1n1, u-boot, Linux ve aygıt ağaçları arasında biraz karmaşık ve incelikli sürüm bağıntıları bulunmaktadır.

 * m1n1 aşama 2, bazı donanım başlatma işlemlerinden ve aygıt ağaçlarına değişken değerlerin girilmesinden sorumludur. Bu, yeni kernel donanım desteğinin genellikle bir şeyleri başlatmak, daha fazla aygıt ağacı verisi eklemek ya da her ikisini birden yapmak için m1n1 güncellemelerine bağlı olduğu anlamına gelir.
    * Genel olarak, Linux sürücülerini basit tutmayı ve “sihirli” init'i (örneğin, Apple'ın bir DT türevinde tanımlamayı sevdiği rastgele sihirli kayıt yazma kümeleri) m1n1'de tutmayı tercih ediyoruz. Bellek denetleyicisiyle ilgili şeyler, makul olarak statik bırakabileceğimiz hız yapılandırmaları vb. için de aynı şey geçerlidir. İstisna, Linux'un bunu çalışma zamanında dinamik olarak yapmak zorunda kaldığı durumlardır. Apple, sistem düzeyinde L3 önbelleği açmak gibi saçmalıklar da dahil olmak üzere, çok fazla şeyi XNU çekirdeğine (m1n1'in yerini aldığı) bırakmayı sevse de biz Linux'un bununla uğraşmasını istemiyoruz. Bu aynı zamanda mevcut kernellerin sadece DT değişiklikleriyle yeni SoC'lerde/platformlarda (en azından kısmen) çalışması olasılığını da büyük ölçüde artırıyor, ki bu da örneğin dağıtım yükleme imajlarının geleceğe dönük uyumluluğu açısından avantajlıdır. Örneğin, M2'deki PCIe, sürücü düzeyinde değişiklik gerektirmedi, sadece m1n1 başlangıcında değişiklikler yapıldı.
* U-Boot, herhangi bir SoC üzerinde düzgün bir şekilde oluşturulduğunda genellikle fazla değişiklik yapmaz ve yalnızca DT bilgilerinin bir alt kümesiyle ilgilenir.
* Linux, donanımı çalıştırmak için DT verilerine ihtiyaç duyar, bu nedenle yeni donanımların da DT güncellemelerine gereksinimi vardır. Standart DT depomuz Linux ağacımızın bir parçasıdır, ancak buradaki değişikliklerin gerçekten çalışması için genellikle m1n1 (aşama 2) güncellemelerine ihtiyaç duyulduğunu unutmayın.

Her şeyin yukarı akışta olduğu ve tüm donanımı anladığımız ideal bir dünyada, DT'ler yazılım sürümleriyle hem ileriye hem de geriye dönük uyumlu olmalıdır. Yani yeni özellikler her şeyin güncel olmasını gerektirir, aksi takdirde bu yeni özellikler kullanılamaz.

Gerçek dünyada, 
* Henüz yukarı akışa aktarılmamış DT bağlamaları, inceleme sürecindeyken uyumsuz değişikliklere maruz kalabilir. Bunu önlemeye çalışsak da, bu durum bazen yaşanabilmektedir (örneğin, AIC2 IRQ denetleyici bağlaması değiştirildiğinde, t600x'teki eski kernellerde önyükleme tamamen bozuldu). Bazen uyumluluğu korumak için her iki veri stilini de içeren geçici DT'ler kullanabiliriz.
* m1n1, düzeltmek istediği değişiklikler için eksik DT yapıları ile karşılaştığında (yani m1n1 sürümü > DT sürümü) *olağan bir şekilde* bozulmalıdır, ancak bu kod hatları çok fazla test edilmemiştir. Gereksiz yere durakladığını veya çöktüğünü görürseniz lütfen bir hata raporu oluşturun.
* Herhangi bir SoC'de U-Boot'un ilk günlerinde DT gereksinimlerinde bazı değişiklikler görülebilir (örneğin, M2 platformları için MTP klavye desteği DT değişiklikleriyle paralel ilerler, ancak eksik olduğunda olağan bir şekilde bozulacaktır).
* Prensip olarak, m1n1 donanımı düzgün bir şekilde başlatmak için güncellenmemişse, Linux sürücüsü ciddi şekilde çökebilir (ve DT destekleyicilerini enjekte etmiyorsa sürücü bunların eksikliği nedeniyle çökmez). Elbette hataları incelikle ele almaya çalışıyoruz, ancak örneğin güç veya bellek denetleyicisiyle ilgili init'in eksik olması, Linux bağımlı donanımı başlatmaya çalıştığında SoC'nin sert bir şekilde sıkışmasına neden olabilir. Belki de m1n1 sürümünü DT'ye eklemeye başlamalıyız, böylece sürücüler eski sürümlerde güvenli olmadığı bilinen bir şey olursa kurtulabilirler?
* “Tam uyumluluk” idealinde uç noktalardaki bazı sorunlara sebep olan ve düzeltilmesi çok kolay olmayan bazı DT değişiklikleri vardır. Örneğin, bir DT nodunun başka bir noda bağımlılık yaratması durumunda (örneğin üretici-tüketici ilişkisi), prensipte isteğe bağlı olsa bile, üreticinin sürücüsü mevcut değilse veya uygun üretici işlevini uygulamıyorsa, sürücü tarama yapamayabilir (veya tarama yapmaya bile kalkışmayabilir). Güç alanlarıyla da sorunlarımız var. Bazıları şu anda “her zaman açık” olarak işaretlenmektedir, çünkü kapatıldıklarında ciddi sorunlara neden olmaktadırlar. Ancak gelecekte bunu doğru şekilde nasıl ele alacağımızı öğrenebiliriz. Bu ibare yeni DT'lerde kaldırılırsa, eski kernellerde sorunlar yaşanabilir.

Birden fazla kernel yüklemeniz *mümkün olduğu* için, DT'lerinizi nereden alacağınızı bir şekilde seçmeniz gerekir. Mantıklı seçim, en yeni kernel olacaktır. Arch için, standart paketle yalnızca bir kernel yüklendiğinden, bu sorunu (tipik kullanıcılar için) göz ardı edebilir ve paket güncellemelerinde DT'leri her zaman o sürüme güncelleyebiliriz.

Kısacası, kernel'inizi güncellediğinizde DT'lerinizi de güncelleyin (değiştirilmediklerini biliyorsanız gerekli değil) ve ayrıca m1n1'inizi de güncelleyin, böylece büyük yenilikler çalışsın.

## Derleme talimatları  

Her şeyin yerel olarak yapıldığını varsayarsak (çapraz derlemesiz):

### m1n1

```shell
git clone --recursive https://github.com/AsahiLinux/m1n1
cd m1n1
make ARCH= RELEASE=1
```
Not: RELEASE=1 şu anda varsayılan olarak ayrıntılı log çıktısını kapatmaktadır. Kurtarma işletim sisteminden `nvram boot-args=-v` komutunu kullanarak sürüm derlemelerinde bunu etkinleştirebilirsiniz.

Çıktı `build/m1n1.bin` dosyasında bulunur.

### U-Boot

```shell
git clone https://github.com/AsahiLinux/u-boot
cd u-boot
git checkout asahi-releng # bu branch, kullanıcılara gönderdiğimiz şeydir, EFI bölümünü otomatik olarak algılama öğelerine sahiptir.
make apple_m1_defconfig
make
```

Çıktı `u-boot-nodtb.bin` içindedir.

### Aygıt Ağaçları

Kanonik DT'ler, [Linux kernel ağacımızdaki](https://github.com/AsahiLinux/linux) DT'lerdir. Kernel oluşturma, bu belgenin kapsamı dışındadır.

Çıktı `arch/arm64/boot/dts/apple/*.dtb` içindedir.

## Kurulum

m1n1, aygıt ağaçları kümesi ve U-Boot, tek bir dosyada paketlenir ve bu dosya m1n1 aşama 2 olarak `<ESP>/m1n1/boot.bin` adresinden yüklenir. Bu, ['update-m1n1' (m1n1 güncelleme)](https://github.com/AsahiLinux/asahi-scripts/blob/main/update-m1n1) kod dizisi kullanılarak basit bir zincirleme işlemiyle yapılır.

Kolaylaştırılmış haliyle,
```shell
m1n1_dir="/boot/efi/m1n1"
src=/usr/lib/asahi-boot/
target="$m1n1_dir/boot.bin"
dtbs=/lib/modules/*-ARCH/dtbs/*

cat "$src/m1n1.bin" \
    $dtbs \
    <(gzip -c "$src/u-boot-nodtb.bin") \
    >"${target}"
```

Notlar:   
* m1n1'in güvenilir bir şekilde yükleyebilmesi için U-boot'un gzip ile sıkıştırılması gerekir (bu, imaj biçiminin kendi kendini sınırlamamasıyla ilgilidir).  
* Tüm aygıt ağaçları dahildir. m1n1, verilen platform için uygun olanı seçecektir.
Asahi Linux kernel paketleri, DTB'leri `/lib/modules/$ver/dtbs/` konumuna yükler. Bu standart dışı bir durumdur.
* m1n1'de bazı şeyleri yapılandırmak için .bin dosyasına `var=value\n` satırlarını ekleyebilirsiniz. Gelecekte bunun için daha iyi araçlarımız olacak, şimdilik sadece çok özel durumlar için kullanılabilir.

Güncellemeden sonra eski `m1n1.bin` dosyasının adını değiştirmek isteyebilirsiniz. Önyükleme başarısız olursa, macOS FAT32 ESP'ye sorunsuz bir şekilde erişebildiğinden (`diskutil list` komutunu çalıştırıp `diskutil mount` komutuyla bağlayın), macOS veya kurtarma moduna girip eski dosyayı geri yükleyebilirsiniz.

## Ekstra şeyler

m1n1, Apple klavye kodunu `/proc/device-tree/chosen/asahi,kblang-code` içine yerleştirir (DT için standart olan big-endian u32 hücresi olarak). Eşleme [burada](https://github.com/AsahiLinux/asahi-calamares-configs/blob/main/bin/first-time-setup.sh#L109) bulunur. Bunun için uygun bir bağlamayı nasıl standart hale getirebileceğimiz konusunda özgürce fikirlerinizi paylaşabilirsiniz.

Satıcı aygıt yazılımının (yani, dağıtım paketi olarak yeniden dağıtılamayan, ancak yükleme sırasında hazırlanan aygıt yazılımı) nasıl işlendiğine dair derin bir açıklamamız var. Bunun nasıl çalıştığı [burada](../platform/open-os-interop.md#firmware-provisioning) ayrıntılı olarak anlatılmıştır.
