WITH EVT AS (
    SELECT
        RIGHT('00000' + 
        LEFT(
            ROW_NUMBER() OVER (ORDER BY EVT_ORI.[Código do Vencimento, Desconto ou Base do sistema de Origem]), 5 
        ), 5) AS [Código do Vencimento, Desconto ou Base Metadados (Destino)],
        EVT_ORI.*
    FROM (
        SELECT DISTINCT
            LEFT(CAST(PEVENTO.CODIGO AS VARCHAR), 7) AS [Código do Vencimento, Desconto ou Base do sistema de Origem],
            LEFT(CAST(PEVENTO.DESCRICAO AS VARCHAR), 30) AS [Descrição do VDB],
            CASE
                WHEN PEVENTO.PROVDESCBASE = 'P' THEN 'V'
                WHEN PEVENTO.PROVDESCBASE = 'D' THEN 'D'
                WHEN PEVENTO.PROVDESCBASE = 'B' THEN 'B'
            END AS [Tipo do VDB]
        FROM PEVENTO
    ) EVT_ORI
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
    FORMAT(EOMONTH(DATEFROMPARTS(PFFINANC.ANOCOMP, PFFINANC.MESCOMP, 1)), 'dd/MM/yyyy') AS [Data Base da Folha de Pagamento],
    '11' AS [Código da Folha de Pagamento],
    ( 
        SELECT TOP 1 [Código do Vencimento, Desconto ou Base Metadados (Destino)] FROM EVT 
        WHERE EVT.[Código do Vencimento, Desconto ou Base do sistema de Origem] = PFFINANC.CODEVENTO
    ) AS [Código do VDB],
    FORMAT(PFFINANC.DTPAGTO, 'dd/MM/yyyy') AS [Data de Pagamento da Folha de Pagamento],
    '0' AS [Tipo de Informação],
    '0' AS [Horas, Dias ou Quantidade, cfe. Tipo de Informação],
    LEFT(CAST(PFFINANC.VALOR AS DECIMAL(15,2)), 15) AS [Valor],
    '' AS [Identificador atribuído pela fonte pagadora para o demonstrativo de valores devidos ao trabalhador, gerado no eSocial.],
    '' AS [Número do recibo do arquivo que contém as informações da rescisão contratual que originou o pagamento, gerado no eSocial.]
FROM PFFINANC
LEFT JOIN PFUNC
  ON PFUNC.CODCOLIGADA          = PFFINANC.CODCOLIGADA
  AND PFUNC.CHAPA               = PFFINANC.CHAPA
LEFT JOIN TB_UNIDADE
  ON TB_UNIDADE.CODIGO			= CAST(PFUNC.CODCOLIGADA AS VARCHAR) + CAST(REPLACE(PFUNC.CODSECAO,'.','') AS VARCHAR)

/* 
ESTRUTURA PARA FAZER O DE-PARA DOS EVENTOS DO SISTMA TOTVS PARA O SISTEMA DE DESTINO, APENAS SUBSTITUIR O CASE MONTADO PELA LINHA DE MESMO NOME
PODE APAGAR LINHAS QUE NÃO PRECISE. DEIXE APENAS O QUE PRECISA.
CASE
    WHEN PFFINANC.CODEVENTO IN ('') THEN '21' --21 – Quinzenal – 1ª Quinzena
    WHEN PFFINANC.CODEVENTO IN ('') THEN '22' --22 – Quinzenal – 2ª Quinzena
    WHEN PFFINANC.CODEVENTO IN ('') THEN '31' --31 – Semanal – 1ª Semana
    WHEN PFFINANC.CODEVENTO IN ('') THEN '32' --32 – Semanal – Semanas Intermediárias
    WHEN PFFINANC.CODEVENTO IN ('') THEN '33' --33 – Semanal – Última Semana
    WHEN PFFINANC.CODEVENTO IN ('') THEN '41' --41 – Adiantamento Quinzenal
    WHEN PFFINANC.CODEVENTO IN ('') THEN '51' --51 – 13° Salário – Antecipação
    WHEN PFFINANC.CODEVENTO IN ('') THEN '52' --52 – 13° Salário - Complementação
    WHEN PFFINANC.CODEVENTO IN ('') THEN '61' --61 – Suplementar
    WHEN PFFINANC.CODEVENTO IN ('') THEN '71' --71 – Avulsa
    WHEN PFFINANC.CODEVENTO IN ('') THEN '81' --81 – Recibos de Férias
    WHEN PFFINANC.CODEVENTO IN ('') THEN '91' --91 – Rescisão de Contrato
    WHEN PFFINANC.CODEVENTO IN ('') THEN '92' --92 – Rescisão Complementar
    ELSE '11' --11 – Mensal
END AS [Código da Folha de Pagamento]
*/

/*
SCRIPT PARA LISTAR TODOS OS EVENTOS DA BASE DE ORIGEM COM CODIGO, NOME E TIPO
SELECT DISTINCT
	PFFINANC.CODEVENTO,
	PEVENTO.DESCRICAO,
	PEVENTO.PROVDESCBASE
FROM PFFINANC
LEFT JOIN PEVENTO
	ON PEVENTO.CODCOLIGADA = PFFINANC.CODCOLIGADA
	AND PEVENTO.CODIGO = PFFINANC.CODEVENTO
*/