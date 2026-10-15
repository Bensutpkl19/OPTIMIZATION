$TITLE Geri Donusum Kutulari Yerlesim Problemi - P-Median
$OFFLISTING

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

Parameter toplamTalep toplam talep agirligi;
toplamTalep = sum(i, w(i));

Scalar p  acilacak kutu sayisi /10/;

Binary Variables
   x(i,j)  mahalle i, lokasyon j'ye atanirsa 1
   y(j)    lokasyon j'de kutu acilirsa 1
;

Free Variable z_pm  p-median amac fonksiyonu degeri;

Equations
   obj_pm       amac fonksiyonu (agirlikli toplam mesafe)
   assign_pm(i) her mahalle tam olarak bir kutuya atanir
   link_pm(i,j) atama sadece acik kutuya yapilabilir
   numfac_pm    acilacak kutu sayisi p'ye esittir
;

obj_pm..        z_pm =e= sum((i,j), w(i)*d(j,i)*x(i,j));
assign_pm(i)..  sum(j, x(i,j)) =e= 1;
link_pm(i,j)..  x(i,j) =l= y(j);
numfac_pm..     sum(j, y(j)) =e= p;

Model pmedian /obj_pm, assign_pm, link_pm, numfac_pm/;

* --- Tek senaryo cozumu (p=5) ---
Solve pmedian using mip minimizing z_pm;

Display y.l, x.l, z_pm.l;

*==============================================================
* EXCEL CIKTISI
*==============================================================
Execute_Unload 'pmedian_sonuclar.gdx' y.l, x.l, z_pm.l;
Execute 'gdxxrw.exe pmedian_sonuclar.gdx o=pmedian_sonuclar.xlsx var=y.l rng=Kutular!A1 var=x.l rng=Atamalar!A1';
