WITH TB_CARGOS AS (
  SELECT 
  RIGHT(
    '00000000' + CAST(ROW_NUMBER() OVER(ORDER BY CARGO) AS VARCHAR), 8
  ) AS CODIGO,
  CARGOS.*
FROM (	
	SELECT DISTINCT
		LEFT(TRANSLATE(
			CAST(PFUNCAO.NOME AS VARCHAR),
			'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüç',
			'AAAAAEEEEIIIIOOOOOUUUUCaaaaaeeeeiiiiooooouuuuc'
		), 40) AS CARGO,
		LEFT(CAST(REPLACE(REPLACE(ISNULL(PFUNCAO.CBO2002, PFUNCAO.CBO),'-',''),' ','') AS VARCHAR), 6) AS CBO
	FROM PFUNCAO
    ) CARGOS
)

SELECT
    CASE
        WHEN PFUNC.CODCOLIGADA <> 1 
        THEN RIGHT('00' + CAST(PFUNC.CODCOLIGADA AS VARCHAR), 2) + RIGHT('00' + CAST(PFUNC.CODFILIAL AS VARCHAR), 2) 
        ELSE RIGHT('0000' + CAST(PFUNC.CODFILIAL AS VARCHAR), 4)
    END AS [Código da Unidade, cfe. Tabela de Unidades],
    CAST(PFUNC.CODCOLIGADA AS VARCHAR) + RIGHT(PFUNC.CHAPA, 8 - LEN(CAST(PFUNC.CODCOLIGADA AS VARCHAR))) AS [Código do Contrato],
    FORMAT(PFHSTSAL.DTMUDANCA, 'dd/MM/yyyy') AS [Data da Alteração],
    CASE
        WHEN PFUNC.CODRECEBIMENTO LIKE 'M' THEN '1' --1 – Mensal
        WHEN PFUNC.CODRECEBIMENTO LIKE 'Q' THEN '2' --2 – Por Quinzena
        WHEN PFUNC.CODRECEBIMENTO LIKE 'D' THEN '4' --4 – Por Dia
        WHEN PFUNC.CODRECEBIMENTO LIKE 'H' THEN '5' --5 – Por Hora
        WHEN PFUNC.CODRECEBIMENTO LIKE 'O' THEN '7' --7 – Outros
    END AS [Tipo de Salário],
    LEFT(REPLACE(CAST(PFHSTSAL.SALARIO AS VARCHAR), '.', ','), 11) AS [Salário Contratual Anterior (Se não houve alteração repita a informação atual) ],
    CASE
    	WHEN PFHSTSAL.JORNADA IS NULL OR PFHSTSAL.JORNADA = 0 THEN '220'
    	ELSE LEFT(CAST(PFHSTSAL.JORNADA / 60 AS VARCHAR), 11)
    END AS [Horas Contratuais, cfe. Tipo de Salário. Informar Horas/Mês nos contratos de horistas (tipo de salário “5”).],
    TB_CARGOS.CODIGO AS [Código do Cargo, cfe. Tabela de Cargos],
    CASE
      WHEN PFHSTSAL.MOTIVO IN ('01')                                      THEN '06' --Admissão
      WHEN PFHSTSAL.MOTIVO IN ('02','14')                                 THEN '04' --Promoção
      WHEN PFHSTSAL.MOTIVO IN ('03','04')                                 THEN '90' --Reajuste de Salário
      WHEN PFHSTSAL.MOTIVO IN ('05','08','09','11','18','19','DC')        THEN '98' --Outros
      WHEN PFHSTSAL.MOTIVO IN ('06','12','21')                            THEN '02' --Acordo / Convenção / Dissídio Coletivo
      WHEN PFHSTSAL.MOTIVO IN ('07')                                      THEN '05' --Enquadramento
      WHEN PFHSTSAL.MOTIVO IN ('10','13','15','16','17','20')             THEN '90' --Reajuste de Salário
      ELSE '!' + PFHSTSAL.MOTIVO
    END AS [Motivo]
FROM PFHSTSAL
LEFT JOIN PFUNC
  ON PFUNC.CODCOLIGADA      = PFHSTSAL.CODCOLIGADA
  AND PFUNC.CHAPA           = PFHSTSAL.CHAPA
LEFT JOIN PFHSTFCO
  ON PFHSTFCO.CODCOLIGADA   = PFHSTSAL.CODCOLIGADA
  AND PFHSTFCO.CHAPA        = PFHSTSAL.CHAPA
  AND PFHSTFCO.DTMUDANCA    = PFHSTSAL.DTMUDANCA
  AND PFHSTFCO.MOTIVO NOT LIKE '01'
LEFT JOIN PFUNCAO
  ON PFUNCAO.CODCOLIGADA            = PFUNC.CODCOLIGADA
  AND PFUNCAO.CODIGO                = PFUNC.CODFUNCAO
LEFT JOIN TB_CARGOS
  ON TB_CARGOS.CARGO                = LEFT(TRANSLATE(CAST(PFUNCAO.NOME AS VARCHAR),
			                            'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüç',
			                            'AAAAAEEEEIIIIOOOOOUUUUCaaaaaeeeeiiiiooooouuuuc'
		                            ), 40)
  AND TB_CARGOS.CBO                 = LEFT(CAST(REPLACE(REPLACE(ISNULL(PFUNCAO.CBO2002, PFUNCAO.CBO),'-',''),' ','') AS VARCHAR), 6)