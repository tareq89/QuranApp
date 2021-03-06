USE [Quran]
GO
/****** Object:  UserDefinedFunction [dbo].[GetBestMeaningsForLemma]    Script Date: 04/07/2015 00:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[GetVersesFromLemma]
(	
	@Root nvarchar(50), @Lemma nvarchar(50)
)
RETURNS @Verses TABLE 
(
	Chapter int,
	Verse int,
	Ayah nvarchar(2014),
	Translation nvarchar(2014)
)
AS
BEGIN
	;with MostFrequentText (Text, Occurences)
	AS
	(
		select [Text] collate Arabic_CI_AS as Text, 
			count([Text]) as Occurences			
		from [Quran].[dbo].[WordInformation] w 
			where w.Root = @Root and w.Lemma = @Lemma  
				and Meaning not like N'*%' 
				and not (Meaning like N'and %' and [Text] like 'وَ%')
				and not (Meaning like N'then %' and [Text] like 'فَ%')
				and not (Meaning like N'and %' and [Text] like 'فَ%')				
				and not (Meaning like N'that %' and [Text] like 'لِ%')
				and not (Meaning like N'for %' and [Text] like 'لِ%')				
			group by [Text]			
	)
	
	, MostFrequentTextAndMeaning (Text, Meaning)
	AS
	(
	select top 5 w.Text, 
		(select top 1 Meaning from WordInformation w2 
		WHERE w2.Text = w.Text
		group by Meaning
		order by count(Meaning) desc) as Meaning
	FROM MostFrequentText w	
	order by w.Occurences desc			
	)

	, TopVerses (Text, Meaning, Chapter, Verse, Ayah, Translation, RN)
	AS
	(
		select m.Text as [Text], m.Meaning, w.Chapter, w.Verse, a.Content as Ayah, b.Content as Translation,
			ROW_NUMBER() OVER (PARTITION BY m.Text, m.Meaning order by len(a.Content)) AS rn
		from MostFrequentTextAndMeaning m
		inner join WordInformation w on w.Text = m.Text and w.Meaning = m.Meaning
		inner join Ayahs a on a.SurahNo = w.Chapter and a.AyahNo = w.Verse
		inner join Ayahs b on b.SurahNo = w.Chapter and b.AyahNo = w.Verse
		where a.TranslatorID = 7 
		and b.TranslatorID = 6
	)

	INSERT INTO @Verses 
	SELECT Chapter, Verse, Ayah, Translation FROM TopVerses
		WHERE RN = 1
		ORDER BY Len(Ayah)

	RETURN;
END;		
