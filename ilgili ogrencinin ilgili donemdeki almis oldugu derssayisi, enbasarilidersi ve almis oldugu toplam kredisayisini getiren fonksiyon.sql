USE [Okul]


--ilgili ogrencinin ilgili donemdeki almis oldugu derssayisi, enbasarilidersi ve almis oldugu toplam kredisayisini getiren fonksiyon:


ALTER FUNCTION [dbo].[FN$OgrencininTumBilgileriniGetir]
(
  @Ogrenci_Id int,
  @Donem_Id int
)
    RETURNS @table TABLE (
       AdiSoyadi nvarchar(64),
	   AldigiDersSayisi tinyint,
	   EnBasariliDers nvarchar(16),
	   KrediSayisi tinyint
    )
AS
BEGIN
   declare  @AdiSoyadi nvarchar(64),
	        @AldigiDersSayisi tinyint,
	        @EnBasariliDers nvarchar(16),
	        @KrediSayisi tinyint

 
 select @AdiSoyadi = Adi+' '+SoyAdi from dbo.Ogrenci 
 where Id = @Ogrenci_Id and Statu = 1

 select @AldigiDersSayisi = 
 COUNT(*) from dbo.OgrenciOgretmenDers as ood
 inner join dbo.OgretmenDers as od on od.Id = ood.OgretmenDers_Id and od.Statu = 1
 where Ogrenci_Id = @Ogrenci_Id
 and od.Donem_Id = @Donem_Id
 and ood.Statu = 1
 group by ood.Ogrenci_Id



 select @KrediSayisi = (select  sum(b.KrediSayisi)
from

(select d.KrediSayisi,d.Adi
from dbo.OgrenciOgretmenDers as ood
inner join dbo.Ogrenci as o on o.Id=ood.Ogrenci_Id and o.Statu=1
inner join dbo.OgretmenDers  as og on og.Id=ood.OgretmenDers_Id and og.Statu=1
inner join dbo.Ders as d on d.Id=og.Ders_Id and d.Statu=1
inner join dbo.Donem as do on do.Id=og.Donem_Id and do.Statu=1
where ood.Statu=1
and o.Id = @Ogrenci_Id
and do.Id = @Donem_Id
group by d.KrediSayisi,d.Adi)b
)


select   @EnBasariliDers =(select a.Adi from   (select top 1 d.Adi  ,(ood.Vize*0.4)+(ood.Final*0.6) as ortalama
 from dbo.[OgrenciOgretmenDers] as ood
 inner join dbo.OgretmenDers as od on od.Id = ood.OgretmenDers_Id and od.Statu = 1
 inner join dbo.Ders as d on d.Id=od.Ders_Id and d.statu=1
 where ood.Statu=1
 and ood.Ogrenci_Id= @Ogrenci_Id
 and od.Donem_Id = @Donem_Id
 order by ortalama desc)a
 )
       INSERT INTO @table(AdiSoyadi,AldigiDersSayisi,EnBasariliDers,KrediSayisi)
        SELECT 
		    @AdiSoyadi ,
	        @AldigiDersSayisi ,
	        @EnBasariliDers ,
	        @KrediSayisi 
    RETURN;
END;








--cagiralim:
select * from dbo.FN$OgrencininTumBilgileriniGetir(2,1)


