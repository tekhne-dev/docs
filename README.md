# Asahi Linux dokümantasyon deposu
Burası [Asahi Linux dokümantasyon](https://asahilinux.org/docs/) deposudur.

## Dokümantasyon yapısı
Dokümantasyonumuz aşağıdaki kategorilere ayrılmıştır.

- alt: Alternatif işletim sistemleri ve Linux dağıtımları ile ilgili destek dokümantasyonu buraya eklenmelidir.
- fw: Üretici tarafından kontrol edilen aygıt yazılımı ve bunların arabirimleri ile ilgili dokümantasyon buraya eklenmelidir.
- hw: Donanım ile ilgili tüm dokümantasyon buraya eklenmelidir. Bu da aşağıdaki alt kategorilere ayrılmıştır:
    - cpu: Uygulama işlemcisi ile ilgili dokümantasyon
    - devices: Belirli Mac modelleri ile ilgili dokümantasyon
    - peripherals: SoC'nin kendisi dışında Apple Silicon Mac'lerde bulunan donanım
    - soc: Apple Silicon SoC'lerle tümleşik donanım blokları
- platform: Apple Silicon platformunun tamamında geçerli olan belgeler
- project: Proje yönetimiyle ilgili belgeler ve donanım veya yazılımla ilgisi olmayan diğer belgeler
- sw: Aygıt yazılımı olmayan diğer yazılımlar için belgeler

## Kullanım

Bu derleme [MkDocs](https://www.mkdocs.org/) ile yapılmıştır.

MkDocs cihazınızda yüklü ise, siteyi derlemek için `make build` komutunu çalıştırın veya inceleme için yerel bir web sunucusunu `make test` komutunu ile başlatın. 

 Eğer yüklü değilse, [konteynerimizi](https://github.com/AsahiLinux/docs/pkgs/container/mkdocs-asahi) aşağıdaki gibi kullanabilirsiniz:

[Podman](https://podman.io) kullanıyorsanız:

```
$ podman run -it --pull=newer -p=8000:8000 -v=$(pwd)/:/docs:z ghcr.io/asahilinux/mkdocs-asahi:latest
```

 veya [Docker](https://www.docker.com) kullanıyorsanız:
 
```
$ docker run -it --pull=always -p=8000:8000 -v=$(pwd)/:/docs:z ghcr.io/asahilinux/mkdocs-asahi:latest
```

Bu deponun [Git Alt Modüllerini](https://git-scm.com/book/en/v2/Git-Tools-Submodules) kullandığını dikkate alın. Bu yüzden önce bu alt modülleri `git submodule update --init` ile ayarlamanız gerekecektir.

Web sitesi her commit'te CI tarafından yeniden oluşturulur ve GitHub Pages üzerinden yayınlanır. Konteyner de otomatik olarak güncellenir ve kayıt defterine aktarılır.
