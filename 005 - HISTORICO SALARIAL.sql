SELECT
    LEFT(CAST(PFUNC.CODFILIAL AS VARCHAR), 4) AS [Código da Unidade, cfe. Tabela de Unidades],
    '' AS [Código do Contrato],
    FORMAT(PFHSTSAL.DTMUDANCA, 'ddMMyyyy') AS [Data da Alteração],
    CASE
        WHEN PFUNC.CODRECEBIMENTO LIKE 'M' THEN '1'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'D' THEN '4'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'H' THEN '5'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'O' THEN '7'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'Q' THEN '2'
    END AS [Tipo de Salário],
    LEFT(REPLACE(PFUNC.SALARIO,'.',','), 11) AS [Salário Contratual, cfe. Tipo de Salário],
    LEFT(CAST(PFUNC.JORNADA AS INTEGER), 5) AS [Horas Contratuais, cfe. Tipo de Salário. Informar Horas/Mês nos contratos de horistas (tipo de salário “5”).],
    LEFT(CAST(PFUNC.CODCOLIGADA AS VARCHAR) + CAST(PFUNC.CODFUNCAO AS VARCHAR),8) AS [Código do Cargo, cfe. Tabela de Cargos],
    '' AS [Motivo de Alteração Salarial, cfe. Tabela de Motivos de Reajustes Salariais],
    CASE
        WHEN PFUNC.CODRECEBIMENTO LIKE 'M' THEN '1'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'D' THEN '4'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'H' THEN '5'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'O' THEN '7'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'Q' THEN '2'
    END AS [Tipo de Salário Anterior (Se não houve alteração repita a informação atual)],
    LEFT(CAST(PFHSTSAL.SALARIO AS INTEGER), 11) AS [Salário Contratual Anterior (Se não houve alteração repita a informação atual) ],
    LEFT(CAST(PFHSTSAL.JORNADA AS INTEGER), 5) AS [Horas Contatuais Anterior (Se não houve alteração repita a informação atual) ],
    ISNULL(LEFT(CAST(PFHSTFCO.CODCOLIGADA AS VARCHAR) + CAST(PFHSTFCO.CODFUNCAO AS VARCHAR), 8),
    	LEFT(CAST(PFUNC.CODCOLIGADA AS VARCHAR) + CAST(PFUNC.CODFUNCAO AS VARCHAR), 8)
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
WHERE PFHSTSAL.MOTIVO NOT LIKE '01'