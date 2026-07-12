WITH CTE AS
(
    SELECT
        CODCOLIGADA,
        CHAPA,
        DTMUDANCA,
        CODSECAO,
        LEAD(CODSECAO) OVER (
            PARTITION BY CODCOLIGADA, CHAPA
            ORDER BY DTMUDANCA
        ) AS PROXIMA_SECAO
    FROM PFHSTSEC
)
SELECT
    LEFT(CAST(PFUNC.CODFILIAL AS VARCHAR), 4) AS [Código da Unidade, cfe. Tabela de Unidades],
    PFUNC.CHAPA AS [Código do Contrato],
    FORMAT(CTE.DTMUDANCA, 'ddMMyyyy') AS [Data da Transferência],
    CTE.CODSECAO AS [Código do Estabelecimento Origem, cfe. Tabela de Estabelecimentos],
    CTE.PROXIMA_SECAO AS [Código do Estabelecimento Destino, cfe. Tabela de Estabelecimentos]
FROM CTE
LEFT JOIN PFUNC
  ON PFUNC.CODCOLIGADA              = CTE.CODCOLIGADA
  AND PFUNC.CHAPA                   = CTE.CHAPA
WHERE CTE.PROXIMA_SECAO IS NOT NULL
  AND CTE.CODSECAO <> CTE.PROXIMA_SECAO;