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
),
TB_UNIDADE AS (
	SELECT
		RIGHT('0000' + CAST(ROW_NUMBER() OVER(ORDER BY CODIGO) AS VARCHAR), 4) AS CODSEQ,
		SECAO.*
	FROM (
	SELECT DISTINCT
		CAST(CODCOLIGADA AS VARCHAR) + CAST(REPLACE(CODIGO,'.','') AS VARCHAR) AS CODIGO,
		DESCRICAO
	FROM PSECAO
	) SECAO
)

SELECT
    TB_UNIDADE.CODSEQ AS [Código da Unidade, cfe. Tabela de Unidades],
    CAST(PFUNC.CODCOLIGADA AS VARCHAR) + RIGHT(PFUNC.CHAPA, 8 - LEN(CAST(PFUNC.CODCOLIGADA AS VARCHAR))) AS [Código do Contrato],
    FORMAT(PFHSTSAL.DTMUDANCA, 'dd/MM/yyyy') AS [Data da Alteração],
    CASE
        WHEN PFUNC.CODRECEBIMENTO LIKE 'M' THEN '1' --1 – Mensal
        WHEN PFUNC.CODRECEBIMENTO LIKE 'Q' THEN '2' --2 – Por Quinzena
        WHEN PFUNC.CODRECEBIMENTO LIKE 'D' THEN '4' --4 – Por Dia
        WHEN PFUNC.CODRECEBIMENTO LIKE 'H' THEN '5' --5 – Por Hora
        WHEN PFUNC.CODRECEBIMENTO LIKE 'O' THEN '7' --7 – Outros
    END AS [Tipo de Salário],
    LEFT(REPLACE(PFUNC.SALARIO,'.',','), 11) AS [Salário Contratual, cfe. Tipo de Salário],
    LEFT(CAST(PFUNC.JORNADA AS INTEGER), 5) AS [Horas Contratuais, cfe. Tipo de Salário. Informar Horas/Mês nos contratos de horistas (tipo de salário “5”).],
    TB_CARGOS.CODIGO AS [Código do Cargo, cfe. Tabela de Cargos],
    '' AS [Motivo de Alteração Salarial, cfe. Tabela de Motivos de Reajustes Salariais],
    CASE
        WHEN PFUNC.CODRECEBIMENTO LIKE 'M' THEN '1' --1 – Mensal
        WHEN PFUNC.CODRECEBIMENTO LIKE 'Q' THEN '2' --2 – Por Quinzena
        WHEN PFUNC.CODRECEBIMENTO LIKE 'D' THEN '4' --4 – Por Dia
        WHEN PFUNC.CODRECEBIMENTO LIKE 'H' THEN '5' --5 – Por Hora
        WHEN PFUNC.CODRECEBIMENTO LIKE 'O' THEN '7' --7 – Outros
    END AS [Tipo de Salário Anterior (Se não houve alteração repita a informação atual)],
    LEFT(CAST(PFHSTSAL.SALARIO AS INTEGER), 11) AS [Salário Contratual Anterior (Se não houve alteração repita a informação atual) ],
    LEFT(CAST(PFHSTSAL.JORNADA AS INTEGER), 5) AS [Horas Contatuais Anterior (Se não houve alteração repita a informação atual) ],
    ISNULL(
      ( SELECT TOP 1 CODIGO
        FROM TB_CARGOS
        WHERE CARGO = (SELECT TOP 1 
        TRANSLATE(
          NOME, 
          'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüç',
          'AAAAAEEEEIIIIOOOOOUUUUCaaaaaeeeeiiiiooooouuuuc'
        )
        FROM PFUNCAO WHERE CODIGO = PFHSTFCO.CODFUNCAO)
      ),
    	TB_CARGOS.CODIGO
    ) AS [Código Antigo de Cargo. (Se não houve alteração repita o cargo atual) ]
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
LEFT JOIN TB_UNIDADE
  ON TB_UNIDADE.CODIGO			= CAST(PFUNC.CODCOLIGADA AS VARCHAR) + CAST(REPLACE(PFUNC.CODSECAO,'.','') AS VARCHAR)
WHERE PFHSTSAL.MOTIVO NOT LIKE '01'