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