USE [Quran]
GO
/****** Object:  UserDefinedFunction [dbo].[GetLemmaMeanings]    Script Date: 04/07/2015 10:05:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [dbo].[GetLemmaUsage] 
(
	-- Add the parameters for the function here
	@Root nvarchar(50), @Lemma nvarchar(50), @n_percent int
)
RETURNS nvarchar(2048)
AS
BEGIN
	DECLARE @listStr NVARCHAR(MAX)
	
	;with LemmaUsage (Text)
	AS
	(		
		select top (@n_percent) [Text] + ', ' AS 'data()' 
		FROM WordInformation w
		where w.Lemma = @Lemma and w.Root = @Root 
		AND [text] != N'بِ'+Lemma
		AND [text] != Lemma+N'ًا'
		AND [text] != Lemma+N'ٍ'
		AND [text] != Lemma+N'ٌ'
		AND [text] != Lemma+N'َ'
		AND [text] != Lemma+N'ُ'
		AND [text] != Lemma+N'ِ'
		AND [text] != N'وَ'+Lemma
		AND [text] != N'فَ'+Lemma
		AND [text] != N'لِ'+Lemma
		group by w.Text
		order by count(w.Text) desc	
	)
	
	SELECT @listStr = COALESCE(@listStr,',') + Text
	FROM LemmaUsage
	
	return @listStr 

END
