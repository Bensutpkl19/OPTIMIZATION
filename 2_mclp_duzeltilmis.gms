
Sets
   i  talep noktalari (mahalleler)
      / AKKENT, BAHCELIEVLER, BAYAT, BUHARAEVLER, GULABIBEY, KALE,
        KARAKECILI, KUNDUZHAN, MIMARSINAN, ULUKAVAK, YAVRUTURNA,
        YENIYOL, CEPNI, UCTUTLAR /

   j  aday kutu lokasyonlari
      / AHLPARK, STADYUM, KENTPARK, KADESMEYDANI, HKUKAMPUS,
        DTIYATRO, SAATKULESI, VALILIK, DHASTANESI, ADLIYE /
;

Parameter pop(i) 2025 mahalle nufusu
   / AKKENT        9065
     BAHCELIEVLER 45123
     BAYAT           106
     BUHARAEVLER   32549
     GULABIBEY     39460
     KALE          18285
     KARAKECILI     5676
     KUNDUZHAN      2429
     MIMARSINAN    15651
     ULUKAVAK      62482
     YAVRUTURNA     6350
     YENIYOL        1108
     CEPNI          4804
     UCTUTLAR      25681 /;

Parameter w(i) talep agirligi;
w(i) = pop(i);

Table dm(j,i) aday lokasyon - mahalle uzakligi (metre)
                  AKKENT  BAHCELIEVLER   BAYAT  BUHARAEVLER  GULABIBEY    KALE  KARAKECILI  KUNDUZHAN  MIMARSINAN  ULUKAVAK  YAVRUTURNA  YENIYOL   CEPNI  UCTUTLAR
AHLPARK           4530    4120           4300   5290         2170        2610  25600       969.67     1720        2510      1450        972.05    1650   6700
STADYUM           2200    6290           5050   6890         3450        4450  23440       2680       1190        3070      3730        3260      1260   8870
KENTPARK          4540    4580           4060   4960         2540        3160  25330       884.47     1920        2190      1950        1420      1100   7040
KADESMEYDANI      5910    2840           4340   4580         2520        2210  26650       1420       3040        3000      464.99      476.87    2910   5270
HKUKAMPUS         8430    2670           4720   3310         4910        4010  28500       3720       5790        4510      2960        3210      5310   2640
DTIYATRO          6340    2650           4270   4210         2860        2390  26960       1730       3500        3100      792.02      3270      3280   4790
SAATKULESI        5290    3420           4130   4660         2420        2440  26000       895.27     2500        2560      842.71      267.37    2270   5860
VALILIK           6170    2890           4190   4390         2660        2340  26620       1380       3130        2850      628.39      548.34    2890   5200
DHASTANESI        2750    6040           5290   6990         3070        4130  23380       2650       781.29      3320      3520        3090      1440   8790
ADLIYE            5720    3400           3620   3990         3060        2890  26190       1000       3150        2360      1150        825.64    2600   5360
;

Parameter d(j,i) uzaklik (km);
d(j,i) = dm(j,i) / 1000;

* --- Toplam talep (nufus) - tek deklarasyon, tek atama ---
Parameter toplamTalep toplam talep agirligi;
toplamTalep = sum(i, w(i));

* --- Senaryo parametreleri: her yeni senaryoda bu iki degeri degistir ---
Scalar R      kapsama esigi (km)                    /6/;
Scalar pmax   acilabilecek en fazla kutu sayisi      /6/;
Scalar epsilon kucuk ceza terimi (gereksiz kutulari engeller) /0.0001/;

Set cov(j,i) j lokasyonu i mahallesini R km icinde kapsar mi;
cov(j,i) = yes$(d(j,i) <= R);

Binary Variables
   yc(j)  lokasyon j'de kutu acilirsa 1
   zc(i)  mahalle i kapsanirsa 1
;

Free Variable z_mclp  MCLP amac fonksiyonu degeri;

Equations
   obj_mclp         amac fonksiyonu (kapsanan toplam talep)
   coverage_mclp(i) kapsama kosulu
   numfac_mclp      en fazla pmax kutu acilir
;

obj_mclp..           z_mclp =e= sum(i, w(i)*zc(i)) - epsilon*sum(j, yc(j));
coverage_mclp(i)..   zc(i)  =l= sum(j$cov(j,i), yc(j));
numfac_mclp..         sum(j, yc(j)) =l= pmax;

Model mclp /obj_mclp, coverage_mclp, numfac_mclp/;

Solve mclp using mip maximizing z_mclp;

* --- Sonuc ozet parametreleri (toplamTalep YUKARIDA zaten tanimli, burada SADECE yenileri deklare ediliyor) ---
Parameter
   kapsananTalep     kapsanan nufus (z_mclp ile ayni)
   kapsamOrani       kapsama orani (yuzde)
   kapsanmayanMah(i) kapsanmayan mahalleler ve nufuslari
;

kapsananTalep      = z_mclp.l;
kapsamOrani        = 100 * kapsananTalep / toplamTalep;
kapsanmayanMah(i)  = w(i) * (1 - zc.l(i));

Display yc.l, zc.l, z_mclp.l, toplamTalep, kapsananTalep, kapsamOrani, kapsanmayanMah;

Execute_Unload 'mclp_sonuclar.gdx' yc.l, zc.l, z_mclp.l, cov,
               toplamTalep, kapsananTalep, kapsamOrani, kapsanmayanMah;

Execute 'gdxxrw.exe mclp_sonuclar.gdx o=mclp_sonuclar.xlsx var=yc.l rng=Kutular!A1 var=zc.l rng=Atamalar!A1 par=kapsanmayanMah rng=KapsanmayanMahalleler!A1 par=toplamTalep rng=Ozet!A1 par=kapsananTalep rng=Ozet!A3 par=kapsamOrani rng=Ozet!A5';
