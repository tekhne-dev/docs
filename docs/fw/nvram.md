---
title: NVRAM
summary:
  Apple Silicon Mac'ler Tarafından Kullanılan NVRAM Değişkenleri
---

# Türler

* `string`: Standart bir dizi (string). 
* `binary`: Binary veri içeren ve URL ile kodlanmış bir dizi.
* `boolean`: Değeri `true` veya `false` olan bir dizi.
* `int`: Onluk bir tamsayı.
* `bin-int(n)`: `binary` ile kodlanmış bir tamsayı, little-endian (sağdan okumalı), `n` bayt.
* `hex-int`: Onaltılık bir tamsayı.
* `volume`: `<gpt-partition-type-uuid>:<gpt-partition-uuid>:<volume-group-uuid>` biçiminde bir dizi. GPT bölüm UUID'si, ilk üç bileşeninin baytlarının  değiştirilmiş olması nedeniyle biraz garip görünüyor.

# Değerler

## Önyükleme

* `auto-boot`: `boolean`: Otomatik olarak önyükleme yapılıp yapılmayacağı. Özellikle Mac M1 mini'de bunu `false` olarak ayarlamak önyükleme hatasına neden olur;
* `boot-args`: `string`: Kernele aktarılacak önyükleme argümanları. Muhtemelen önyükleme poliçesi tarafından filtreleniyor.
* `boot-command`: `string`: Örnek: `fsboot`.
* `boot-info-payload`: `binary`: Bir çeşit belirsiz, yüksek entropili payload.
* `boot-note`: `binary`: Bilinmiyor. Örnek: `%00%00%00%00%00%00%00%bb%0ez%e5%00%00%00%00%a0q%d4%07%08%00%00%00`.
* `boot-volume`: `volume`: Varsayılan önyükleme birimi.
* `failboot-breadcrumbs`: `string`: Önyükleme sürecinin çeşitli aşamalarında oluşturulan, boşluklarla ayrılmış kodlar. Örnek: `3000c(706d7066) 3000d 30010 f0200 f0007(706d7066) 3000c(0) 3000d 40038(958000) 40039(1530000) 4003a(0) 3000f(64747265) 3000c(64747265) 40029 3000d 30010 3000f(69626474) 3000c(69626474) 40029 3000d 30010 3000f(69737973) 3000c(69737973) 3000d 30010 3000f(63737973) 3000c(63737973) 3000d 30010 3000f(62737463) 3000c(62737463) 3000d 30010 3000f(74727374) 3000c(74727374) 3000d 30010 3000f(66756f73) 40060004 30011 30007 <COMMIT> 401d000c <COMMIT> <BOOT> 1c002b(2006300) 3000f(0) 3000c(0) 3000d 30010 3000f(69626f74) 3000c(69626f74) 40040204 40040023 4003000e 30011 30007 401d000f(ffffffff) <COMMIT> `.
* `nonce-seeds`: `binary`
* `panicmedic-timestamps`: `hex-int`: Nanosaniye hassasiyetinde UNIX zaman damgası, muhtemelen son kernel panik durumunun meydana geldiği zamanı kaydediyor.
* `policy-nonce-digests`: `binary`
* `upgrade-boot-volume`: `volume`

## Güncellemeler

* `IDInstallerDataV1`: `binary:lzvn:bin-plist`: En son yükleyici işlemiyle ilgili bilgileri içeren sıkıştırılmış ikili plist. MacOS 10.12 ile 11.0 arasında bir yerde kullanılmamaya başlandığı anlaşılıyor.
* `IDInstallerDataV2`: `binary:lzvn:bin-plist`: `IDInstallerDataV1` ile aynı formatta bir dizi bilgi öğesi içeren sıkıştırılmış ikili plist.
* `ota-updateType`: `string`: Uygulanacak internetten güncelleme tipi. Örnek: `incremental`.
* `update-volume`: `volume`

## Donanım

* `bluetoothActiveControllerInfo`: `binary`
* `bluetoothInternalControllerInfo`: `binary`
* `ota-controllerVersion`: `string`: İnternetten güncelleme denetleyicisinin tanımlayıcısı. Örnekler: `SUMacController-1.10` (Mac Mini M1), `SUS-1.0` (iPhone, iPad).
* `usbcfwflasherResult`: `string`: Örnek: `No errors`.

## Ayarlar

* `backlight-nits`: `hex-int`: Muhtemelen ekran arka aydınlatmasının gücü. Mac Mini M1 örneği: `0x008c0000`.
* `current-network`: `binary`: En son bağlanılan Wi-Fi ağı.
* `fmm-computer-name`: `string`: Bilgisayar adı.
* `good-samaritan-message`: `string`: Cihazın kaybolması ve bulunması durumunda önyükleme/parola ekranında gösterilecek mesaj.
* `preferred-networks`: `binary`: Kaydedilmiş Wi-Fi ağlarının listesi.
* `preferred-count`: `int`: `preferred-networks` içindeki ağların sayısı (eğer 1 değilse.)
* `prev-lang:kbd`: `string`: Klavye düzeni, biçim: `<lang>:<locale-id>`, [referans](https://github.com/acidanthera/OpenCorePkg/blob/master/Utilities/AppleKeyboardLayouts/AppleKeyboardLayouts.txt). Örnek: `en-GB:26`.
* `prev-lang-diags:kbd`: `string`: Tanılama sırasındaki klavye düzeni: Örnek: `en-GB`.
* `SystemAudioVolume`: `bin-int(8)`: Ses seviyesi. Örnek: `%80` (128).
* `SystemAudioVolumeExtension`: `bin-int(16)`: Örnek: `%ff%7f` (32767).

## Diğerleri

* `_kdp_ipstr`: `string`: Şu an tanımlanmış IPV4.
* `lts-persistance`: `binary`

# Örnekler

## `IDInstallerDataV2`

<details>
<summary>Başarıyla tamamlanan Big Sur 11.2 beta 1 (20D5029f) sürüm güncellemesinden örnek</summary>

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
	<dict>
		<key>505</key>
		<string>auth not needed</string>
		<key>6</key>
		<string>key recovery assistant</string>
	</dict>
	<dict>
		<key>505</key>
		<string>auth not needed</string>
		<key>6</key>
		<string>key recovery assistant</string>
	</dict>
	<dict>
		<key>0</key>
		<string>20D5029f</string>
		<key>100</key>
		<string>passed</string>
		<key>6</key>
		<string>upgrade</string>
	</dict>
	<dict>
		<key>505</key>
		<string>auth not needed</string>
		<key>6</key>
		<string>key recovery assistant</string>
	</dict>
	<dict>
		<key>505</key>
		<string>auth not needed</string>
		<key>6</key>
		<string>key recovery assistant</string>
	</dict>
	<dict>
		<key>505</key>
		<string>auth not needed</string>
		<key>6</key>
		<string>key recovery assistant</string>
	</dict>
	<dict>
		<key>6</key>
		<string>key recovery assistant</string>
	</dict>
	<dict>
		<key>6</key>
		<string>key recovery assistant</string>
	</dict>
</array>
</plist>
```

</details>

<details>
  <summary>Başarısız bir güncelleme girişiminden örnek</summary>

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
	<dict>
		<key>100</key>
		<string>crashed</string>
		<key>102</key>
		<string>initializer</string>
		<key>103</key>
		<string>1</string>
		<key>7</key>
		<string>NO</string>
	</dict>
</array>
</plist>
```

</details>

<details>
  <summary>Başarıyla tamamlanan Sierra 10.12.2 (16C67) sürüm güncellemesinden örnek</summary>

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
	<dict>
		<key>0</key>
		<string>16C67</string>
		<key>100</key>
		<string>passed</string>
		<key>103</key>
		<string>1</string>
		<key>202</key>
		<string>832.499040</string>
		<key>203</key>
		<string>41.700535</string>
		<key>205</key>
		<string>30.318743</string>
		<key>206</key>
		<string>0.003648</string>
		<key>207</key>
		<string>0.156793</string>
		<key>208</key>
		<string>2.215885</string>
		<key>209</key>
		<string>8.130921</string>
		<key>299</key>
		<string>0.212016</string>
		<key>3</key>
		<string>solid state</string>
		<key>4</key>
		<string>unencrypted</string>
		<key>5</key>
		<string>case sensitive</string>
		<key>6</key>
		<string>clean</string>
		<key>7</key>
		<string>NO</string>
	</dict>
	<dict>
		<key>0</key>
		<string>16C67</string>
		<key>100</key>
		<string>passed</string>
		<key>103</key>
		<string>2</string>
		<key>202</key>
		<string>802.017327</string>
		<key>203</key>
		<string>29.902674</string>
		<key>205</key>
		<string>4.379149</string>
		<key>206</key>
		<string>0.003310</string>
		<key>207</key>
		<string>0.156726</string>
		<key>208</key>
		<string>2.214545</string>
		<key>209</key>
		<string>10.050913</string>
		<key>299</key>
		<string>0.184676</string>
		<key>3</key>
		<string>solid state</string>
		<key>4</key>
		<string>unencrypted</string>
		<key>5</key>
		<string>case insensitive</string>
		<key>6</key>
		<string>clean</string>
		<key>7</key>
		<string>NO</string>
	</dict>
	<dict>
		<key>0</key>
		<string>16C67</string>
		<key>100</key>
		<string>passed</string>
		<key>103</key>
		<string>3</string>
		<key>6</key>
		<string>software update</string>
	</dict>
	<dict>
		<key>0</key>
		<string>16C67</string>
		<key>100</key>
		<string>passed</string>
		<key>103</key>
		<string>4</string>
		<key>202</key>
		<string>582.532387</string>
		<key>203</key>
		<string>11.511343</string>
		<key>205</key>
		<string>1.900536</string>
		<key>206</key>
		<string>0.005585</string>
		<key>207</key>
		<string>0.101757</string>
		<key>208</key>
		<string>2.142859</string>
		<key>209</key>
		<string>3.942741</string>
		<key>299</key>
		<string>0.122528</string>
		<key>3</key>
		<string>solid state</string>
		<key>4</key>
		<string>unencrypted</string>
		<key>5</key>
		<string>case insensitive</string>
		<key>6</key>
		<string>clean</string>
		<key>7</key>
		<string>YES</string>
	</dict>
</array>
</plist>
```

</details>
