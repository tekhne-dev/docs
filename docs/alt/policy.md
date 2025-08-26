---
title: Asahi Linux Dağıtım Yönergeleri
---

Asahi Linux, Apple Silicon platformu için Linux desteğini tersine mühendislik ile geliştirmek, belgelemek ve nihayetinde hayata geçirmek amacıyla kurulmuştur. [Fedora Asahi Remix](https://fedora-asahi-remix.org) bizim en gelişmiş dağıtımımız olup, Apple Silicon üzerinde Linux desteğinin en son teknolojisini temsil etmektedir. Bununla birlikte, biz her zaman diğer dağıtımları temsil eden tarafları (ve hatta [OpenBSD](https:/www.openbsd.org/) gibi diğer FLOSS (Özgür ve Açık Kaynaklı Yazılım) işletim sistemlerini) bu platformu desteklemeleri için teşvik ettik.

Eskiden bu girişimlerin Asahi Linux projesi tarafından resmi olarak onaylanıp onaylanmadığı belirsizdi. Bu durum, kullanıcılar, dağıtım yöneticileri ve Asahi geliştiricileri arasında hayal kırıklığı ve kafa karışıklığına yol açtı. Bazı dağıtımlar, geliştiricilerimizin tercih ettiği dağıtımlar oldukları için projeye yarı tümleşik hale getirilmişken, diğerleri ise, uzun zaman önce projeden vazgeçmiş tek bir kişinin yönettiği geçici destek girişimleri olmalarına rağmen belgelerimizde “destekleniyor” olarak listelenmiştir.

Bu durumu düzeltmek için, Apple Silicon desteğini hayata geçirmek isteyen dağıtımlar için bir dizi yönerge hazırladık. Tüm dağıtımların, tercih ettikleri dağıtımdan bağımsız olarak tüm Apple Silicon kullanıcıları için tutarlı bir şekilde iyi bir deneyim sağlamak amacıyla bu kılavuzlara uymalarını kuvvetle tavsiye ediyoruz.

Bu kriterler tamamen isteğe bağlıdır. Elbette herkesin Apple Silicon platformunda en sevdiği dağıtımı denemesi ve keyfini çıkarmasını memnuniyetle karşılıyoruz ve bunu her zaman destekleyeceğiz. Bu kılavuzlar, Apple Silicon'u resmi veya yarı resmi olarak desteklemek isteyen olgun/ana akım dağıtımlara yöneliktir. Bu kılavuzlara uyduğunu gösteren dağıtımlar, Fedora Asahi Remix'e alternatif olarak belgelerimizde listelenmeye hak kazanacaktır.

## Okunması gerekenler
Devam etmeden önce [Apple Silicon'a Giriş](../platform/introduction.md), [Open OS Platform Tümleştirmesi](../platform/open-os-interop.md) ve [Önyükleme Süreci Kılavuzu](boot-process-guide.md) belgelerini inceleyin.

## Resmi destek
Seçtiğiniz dağıtımda Apple Silicon desteğini uygulamaya yönelik projeniz, dağıtımın resmi sorumluları tarafından doğrudan desteklenmeli veya onaylanmalıdır. Bu, dağıtımınızın politikasına ve organizasyon yapısına göre değişebilir, ancak genellikle dağıtım tarafından onaylanan resmi bir çalışma grubu/kurumunun oluşturulması şeklinde olur. Örneğin [Fedora Asahi SIG](https://fedoraproject.org/wiki/SIGs/Asahi), [Gentoo Asahi Project](https://wiki.gentoo.org/wiki/Project:Asahi) veya Debian'ın [Team Bananas'ı](https://wiki.debian.org/Teams/Bananas) gibi.

## Eksiksiz ve güncel paketler
Dağıtımınızda aşağıdaki paketlerin bulunması gerekir. Tercihen, bunlar resmi paket depolarında bulunmalıdır. Ancak, dağıtımınızın resmi sorumluları tarafından onaylanmış olması koşuluyla, bunların üçüncü taraf depolarında (ör. Fedora COPR, Portage Overlay) bulunması da kabul edilebilir.

* [Linux Kernel'inin Asahi Linux fork'u](https://github.com/AsahiLinux/linux)
* [m1n1](https://github.com/AsahiLinux/m1n1)
* [Das U-Boot'un Asahi Linux fork'u](https://github.com/AsahiLinux/u-boot)
* [asahi-scripts](https://github.com/AsahiLinux/asahi-scripts) veya eşdeğer ön ayar/kod dizileri
* [tiny-dfr](https://github.com/AsahiLinux/tiny-dfr)
* [asahi-firmware](https://github.com/AsahiLinux/asahi-installer) (gereksinimi olan lzfse dahil)
* [speakersafetyd](https://github.com/AsahiLinux/speakersafetyd)
* [asahi-audio](https://github.com/AsahiLinux/asahi-audio) (LV2 plugin gereksinimleri dahil)

Yukarıdaki yazılımların yeni sürümleri, yukarı akışta kullanıma sunulduktan sonra 2 hafta içinde dağıtımınızın en yeni sürümünde (örneğin Fedora Rawhide veya Gentoo'nun değişken paket akışında) paketlenmelidir.

## Kurulum Süreci
Asahi Linux, Das U-Boot'un UEFI ortamını kullanarak GRUB ve systemd-boot gibi standart UEFI önyükleyicileri zincirleme olarak yüklemektedir. Asahi Yükleyicisi (Asahi Installer), çıkarılabilir belleklerde UEFI çalıştırabilir dosyalarını önyükleyebilen minimal bir UEFI ortamı kurabilir. Bu, kullanıcılara standart amd64 tabanlı bir iş istasyonuyla neredeyse aynı kurulum deneyimini sunar. Dağıtımınızın mevcut AArch64 önyüklenebilir belleğine Apple Silicon desteği eklemek (örneğin, UEFI önyükleyicide seçilebilen ikincil bir Asahi kernel aracılığıyla), dağıtımınızın mevcut tüm AArch64 kaynaklarının yeniden kullanılmasını sağlar ve Asahi Yükleyicisi'ni fork etme ihtiyacını ortadan kaldırır.

Minimal UEFI ile kurulum seçeneği seçildiğinde, Asahi Yükleyicisi gelecekteki root dosya sistemi için boş alan yaratacak şekilde yönlendirilebilir. Kılavuzunuzda, kullanıcıların yükleyiciniz aracılığıyla APFS konteynerlerini elle küçültmeye veya değiştirmeye çalışmak yerine, dağıtımınız için disklerini hazırlamak üzere bu özelliği kullanmaları gerektiği belirtilmelidir.

Yükleme işleminiz, dağıtımınızın standart yükleme sürecine mümkün olduğunca yakın olmalıdır. Dağıtımınızın resmi olarak onaylanmış bir otomatik yükleyicisi varsa (ör. Anaconda), bu yükleyici kullanılmalıdır. Dağıtımınız manuel kılavuzlu kurulum yöntemini kullanıyorsa (ör. Gentoo El Kitabı), Apple Silicon'a özel, açık ve takip etmesi kolay bir kılavuzunuz olmalıdır. Kullanıcılarınıza, dağıtımınızın öngördüğü resmi kurulum prosedüründen önemli ölçüde sapmalar yapmalarını söylememelisiniz.

Yükleyiciniz kullanıcının diskini otomatik olarak bölümlemeye çalışırsa ve APFS kapsayıcılarını yok sayması mümkün değilse, kullanıcılarınızı bunu kullanmamaları konusunda açıkça uyarmalısınız. Diskteki APFS kapsayıcılarından herhangi birini değiştirmek veya yok etmek, kullanıcılarınızın Mac'lerini DFU ile geri yüklemelerini gerektirecektir.

Bunun yerine, kurulum süreciniz elle bölümlemeyi teşvik etmelidir ve kılavuzunuzda disk bölümlendirme tablosunu dikkatsizce değiştirmenin tehlikelerini açıklayan bir bölüm bulunmalıdır. Kullanıcılar, Asahi Yükleyicisi tarafından bırakılan boş alan dışında _herhangi_ bir disk yapılandırmasını değiştirme veya yeniden düzenleme işlemlerinin _asla_ güvenli olmadığı hakkında bilgilendirmelidir.

_Not: Sık kullanılan disk bölümlendirme ve kurulum araçlarının güvenliğini iyileştirmek için aktif olarak çalışıyoruz. cfdisk, blivet, Anaconda vb. araçlar Apple Silicon cihazlarını otomatik olarak güvenli bir şekilde yönetebilecek hale geldikçe, gelecekte bu gereksinimleri daha da sıkılaştırabiliriz._

Kurulumunuz, kurulum sürecinin bir parçası olarak yukarıda listelenen Asahi'ye özgü paketleri veya kurulum türüne uygun bir alt kümeyi yüklemelidir. Örneğin, sunucu işletim sistemleri ses etkinleştirme paketlerini otomatik olarak yüklemekten vazgeçebilir.

## Altyapı ve hosting
Asahi Installer dışında gerekli olan tüm hosting
veya altyapı sorumluluğu size veya dağıtımınıza aittir. Buna dokümentasyon, paketler, paketleri oluşturmak için CI çalıştırıcıları, CDN'ler vb. dahildir. Asahi Linux projesi bunu sizin için yapamaz.

## Destek
Dağıtımınız, AArch64/ARM64 upstream için birinci sınıf, olgun bir desteğe sahip olmalıdır.

Siz veya dağıtımınız, Apple Silicon platformuyla ilgili dağıtımınız özelindeki sorunlar için resmi destek sağlayacaktır. Bu, kullanıcıların herhangi bir paketlenmiş yazılımda hata veya başka sorunlarla karşılaştıklarında ilk başvuru noktası olarak hareket etmeyi de içerir. Apple Silicon, dağıtımınızın daha geniş AArch64/ARM64 desteği içinde birinci sınıf bir platform olmalıdır.

## Forklanmış yükleyici ve disk imajı kullanma
Apple Silicon Mac'lere Linux yüklemek için desteklenen iki mekanizma vardır. Yukarıda açıklanan standart UEFI medya yöntemine alternatif olarak, Asahi Installer NVMe sürücüsünde yer açabilir ve ardından önceden oluşturulmuş bir işletim sistemi imajını bu alana yükleyebilir. Bu, Raspberry Pi gibi diğer AArch64 gömülü platformları taklit eder ve Linux yüklemeye aşina olmayan veya bu konuda kendine güvenmeyen kullanıcılara, özelleştirilebilirlikten ödün vererek kolay bir başlangıç yolu sunar. Bunun nasıl çalıştığına dair daha fazla ayrıntı için lütfen [AsahiLinux/asahi-installer](https://github.com AsahiLinux/asahi-installer) sayfasına bakın.

Bu yolu seçmeyi tercih eden dağıtımların, referans Asahi Yükleyiciyi kendileri forklamalarını, değiştirmelerini ve internet sitelerinde sunmalarını bekliyoruz. İmajlarınızı biz sitemizde sunamayız veya referans yükleyicimizde dağıtımlara özgü değişiklikler yapamayız.

Disk imajı tabanlı kurulumunuz şu yönergeleri izlemelidir:

* Yükleyici ve disk imajları resmi olarak dağıtım tarafından oluşturulur ve host edilir  
* Disk imajları ZIP formatında paketlenir ve internet üzerinden akış olarak indirilebilir
* İşletim sistemi, ilk açılışta root bölümünün UUID'sini karıştırır 
* İşletim sistemi, ilk açılışta root bölümünü artan boş alana doğru genişletir
* Disk imajı, Asahi'ye özgü tüm paketleri içerir
* Desteklenen tüm donanımlar, ilk açılıştan itibaren etkinleştirilir ve çalışır
* Disk imajları olabildiğince günceldir
* Tüm imajlar için yükleme süreci, yayınlanmadan önce test edilir
* Tüm disk imajları, yayınlanmadan önce birden fazla cihazda kapsamlı bir şekilde test edilir

Disk imajı kurulum sürecinin, erken aşamadaki çalışmaların bir sonucu olarak ortaya çıkan ve sonunda kalıcı hale gelen bir özellik olduğu unutulmamalıdır. Bu kurulum yönteminin avantajları olsa da, iş istasyonu sınıfı donanımlar için ileriye dönük bir çözüm değildir ve AArch64 cihazlarının tuhaf geliştiricilerin oyuncakları olarak görülmesine katkıda bulunur. Dağıtımların, Apple Silicon desteğine sahip AArch64 önyüklenebilir bellek oluşturmaya zaman ayırmalarını ve referans yükleyicinin minimal UEFI ortamından yararlanmalarını şiddetle tavsiye ediyoruz. Yukarıda belirtildiği gibi, bu, iş istasyonu sınıfı donanımlarla çalışırken kullanıcı beklentilerine ve 40 yıllık teamüllere daha yakındır.

Kullanıcılar için önyüklenebilir bellek kurulumlarını daha güvenli hale getirmek için gerekli araçları iyileştirmek üzere aktif olarak çalışıyoruz. Ana akım disk bölümleme yazılımı ve canlı bellek yükleme araçlarının Apple Silicon cihazlarda yeterince hatasız olduğunu düşündüğümüzde, imaj tabanlı yükleme akışını destekleme ihtiyacını yeniden gözden geçirebiliriz.

## Onayın Geri Çekilmesi
Titiz kalite kontrolümüz ve detaylara gösterdiğimiz özenimiz sayesinde, Asahi Linux günümüzün en iyi masaüstü Linux deneyimlerinden biri olarak kabul görmüştür. Bu bizim için büyük bir gurur kaynağıdır ve bu saygınlığın getirdiği yüksek kullanıcı beklentilerini karşılamaya kararlıyız. Resmi olarak onaylanmış dağıtımların da aynı beklentileri karşılamaya çalışmasını bekliyoruz.

Bunu yapmak zorunda kalmamayı umuyoruz, ancak kullanıcıların veya Asahi Linux'un beklentilerini karşılamayan dağıtımların onayını geri çekmemiz gerekebilir. Onayı geri çekilen dağıtımlar, dokümantasyonumuzdan kaldırılacaktır. Koşullara bağlı olarak, onayı geri çekilen dağıtımın kullanımını dahi önermeyebiliriz.

Onayın geri çekilmesinin nedenleri şunlar olabilir:

* Apple Silicon platformu için resmi dağıtım desteğinin olmaması
* Fedora Asahi Remix'te yeniden üretilemeyen, özellikle de bu tür sorunlar zamanında çözülmediğinde sık sık veya tekrar tekrar ortaya çıkan dağıtım kaynaklı sorunlar 
* Asahi paketlerinin güncel tutulmasında mükerrer başarısızlık 
* Yükleyici disk imajlarının güncel tutulmasında başarısızlık (imaj tabanlı yükleme sunuluyorsa)
