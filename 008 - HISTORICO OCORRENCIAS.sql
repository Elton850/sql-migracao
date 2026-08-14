SELECT *
FROM (
    SELECT
        RIGHT('0000' + CAST(PFUNC.CODCOLIGADA AS VARCHAR), 4) AS [Código da Empresa, cfe. Tabela de Empresas],
        CAST(PFUNC.CODCOLIGADA AS VARCHAR) + RIGHT(PFUNC.CHAPA, 8 - LEN(CAST(PFUNC.CODCOLIGADA AS VARCHAR))) AS [Código do Contrato],
        FORMAT(PFHSTAFT.DTINICIO, 'dd/MM/yyyy') AS [Data de Início da Ocorrência],
        CASE
			WHEN PFHSTAFT.TIPO = 'C' THEN '071' --Suspensão do Contrato MP 936/1045
			WHEN PFHSTAFT.TIPO = 'E' THEN '004' --Licença Maternidade 
			WHEN PFHSTAFT.TIPO = 'I' THEN '035' --Afastamento por invalidez
			WHEN PFHSTAFT.TIPO = 'L' THEN '037' --Licença Não Remunerada
			WHEN PFHSTAFT.TIPO = 'M' THEN '032' --Serviço Militar 
			WHEN PFHSTAFT.TIPO = 'N' THEN '062' --Cedido para o  Sindicato 
			WHEN PFHSTAFT.TIPO = 'O' THEN '012' --Acidente de Trabalho - Típico
			WHEN PFHSTAFT.TIPO = 'P' THEN '022' --Doença não Relacionada ao Trabalho
			WHEN PFHSTAFT.TIPO = 'U' THEN '021' --Doença não Relacionada ao Trabalho
			WHEN PFHSTAFT.TIPO = 'Q' THEN '031' --Auxílio Reclusão 
			WHEN PFHSTAFT.TIPO = 'R' THEN '036' --Licença Remunerada
			WHEN PFHSTAFT.TIPO = 'S' THEN '062' --Cedido para o  Sindicato 
			WHEN PFHSTAFT.TIPO = 'T' THEN '012' --Acidente de Trabalho - Típico
			WHEN PFHSTAFT.TIPO = 'W' THEN '009' --Maternidade Empresa Cidadã
			WHEN PFHSTAFT.TIPO = 'Y' THEN '010' --Licença Paternidade 
			ELSE '!' + PFHSTAFT.TIPO
        END AS [Ocorrência],
        FORMAT(PFHSTAFT.DTFINAL, 'dd/MM/yyyy') AS [Data de Término da Ocorrência],
        '' AS [Horas da ocorrência quando for somente um dia],
        LEFT(CAST(PFHSTAFT.OBSERVAÇÃO AS VARCHAR), 1000) AS [Texto da Ocorrência]
    FROM PFHSTAFT
    LEFT JOIN PFUNC
      ON PFUNC.CODCOLIGADA              = PFHSTAFT.CODCOLIGADA
      AND PFUNC.CHAPA                   = PFHSTAFT.CHAPA
    --WHERE PFHSTAFT.MOTIVO NOT IN ('01','04','07','08','09','10','11','24')
) HIST_AFT
WHERE [Ocorrência] IS NOT NULL