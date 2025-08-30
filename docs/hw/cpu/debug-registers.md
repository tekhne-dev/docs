---
title: Uygulama İşlemcisi Hata Ayıklama Kayıtları
summary:
  Apple tasarımı ARM çekirdeklerinde bulunan hata ayıklama kayıtları
---

Farklı CPU çekirdekleri, [ADT](../../fw/adt.md) içinde bulunan ve hata ayıklama kayıtlarının varlığını ima eden girdileri dışa aktarır. “coresight” dizisi görünür ve coresight kayıt dosyaların, `0xfb0` ofset etmek için `0xc5acce55` yazılarak kilidi açılır ki bu, Corellium CPU başlatma kodunun da yaptığı şeydir. Kilit durumu kaydı, CPU0 için `0x210030fb4` adresindedir.

CPU0'ın PC'si `0x210040090` adresinde okunabilir (diğer çekirdekler için normal ofsetler geçerlidir), ancak diğer kayıtlar belirgin bir şekilde görünmemektedir.
