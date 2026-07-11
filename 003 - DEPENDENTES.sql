SELECT
    LEFT(CAST(PFDEPEND.CODCOLIGADA AS VARCHAR), 4) AS [Código da Empresa, cfe. Tabela de Empresas],
    LEFT(CAST(PFUNC.CODPESSOA AS INTEGER), 8) AS [Código da Pessoa],
    RIGHT('00' + LEFT(CAST(PFDEPEND.NRODEPEND AS INTEGER), 2), 2) AS [Familiar (Número Sequencial), iniciando em “01” a cada Pessoa],
    LEFT(CAST(PFDEPEND.NOME AS VARCHAR), 40) AS [Nome do Familiar],
    FORMAT(PFDEPEND.DTNASCIMENTO, 'ddMMyyyy') AS [Data de Nascimento],
    '' AS [Local de Nascimento],
    '' AS [UF do Nascimento],
    LEFT(CAST(PFDEPEND.SEXO AS VARCHAR), 1) AS [Sexo],
    CASE
        WHEN PFDEPEND.GRAUPARENTESCO IN ('1','3','D')           THEN '1' --1 – Filho(a) ou Enteado(a)
        WHEN PFDEPEND.GRAUPARENTESCO IN ('5')                   THEN '4' --4 – Esposo(a)
        WHEN PFDEPEND.GRAUPARENTESCO IN ('6','7')               THEN '5' --5 – Pai ou Mãe
        WHEN PFDEPEND.GRAUPARENTESCO IN ('8')                   THEN 'C' --C – Sogro(a)
        WHEN PFDEPEND.GRAUPARENTESCO IN ('9','C','G','P','S')   THEN '9' --9 – Outro Parentesco
        WHEN PFDEPEND.GRAUPARENTESCO IN ('A')                   THEN '6' --6 – Avô ou Avó
        WHEN PFDEPEND.GRAUPARENTESCO IN ('E')                   THEN '0' --0 – Nenhum Parentesco
        WHEN PFDEPEND.GRAUPARENTESCO IN ('I')                   THEN 'A' --A – Irmão(ã)
        WHEN PFDEPEND.GRAUPARENTESCO IN ('T')                   THEN '2' --2 – Neto(a)
    END AS [Grau de Parentesco],
    '0' AS [Grau de Dependência],
    CASE
        WHEN PFDEPEND.INCSALFAM = 1 THEN 'S'
        ELSE 'N'
    END AS [Dependente para Salário Família],
    CASE
        WHEN PFDEPEND.INCIRRF = 1 THEN 'S'
        ELSE 'N'
    END AS [Dependente para o IRF],
    'N' AS [Dependente do Auxílio Creche],
    '' AS [Cartório do Registro de Nascimento],
    '' AS [Número do Registro de Nascimento],
    '' AS [Livro do Registro de Nascimento],
    '' AS [Página do Registro de Nascimento],
    '' AS [Data da Entrega da Certidão de Nascimento],
    '' AS [Data da Baixa da Certidão de Nascimento],
    '' AS [Estado Civil],
    '' AS [CPF],
    '' AS [Grau de Instrução],
    '' AS [Número do Cartão do SUS],
    '' AS [Nome Completo do Familiar]
FROM PFDEPEND
LEFT JOIN PFUNC
ON PFUNC.CODCOLIGADA      = PFDEPEND.CODCOLIGADA
AND PFUNC.CHAPA           = PFDEPEND.CHAPA