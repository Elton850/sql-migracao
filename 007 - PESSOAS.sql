WITH DEPENDENTES AS (
    SELECT 
        CODCOLIGADA,
        CHAPA,
        NOME,
        GRAUPARENTESCO 
    FROM PFDEPEND
),
FUNCIONARIO_PRIORIZADO AS (
    SELECT
        PF.CODCOLIGADA,
        PF.CHAPA,
        PF.CODPESSOA,
        ROW_NUMBER() OVER (
            PARTITION BY LTRIM(RTRIM(CAST(P.CPF AS VARCHAR(20))))
            ORDER BY
                CASE 
                    WHEN PF.CODTIPO <> 'A' THEN 0
                    ELSE 1
                END,
                PF.DATAADMISSAO DESC,
                PF.CODCOLIGADA DESC,
                PF.CHAPA DESC
        ) AS ORDEM
    FROM PFUNC PF
    INNER JOIN PPESSOA P
        ON P.CODIGO = PF.CODPESSOA
    WHERE P.CPF IS NOT NULL
      AND LTRIM(RTRIM(CAST(P.CPF AS VARCHAR(20)))) <> ''
)
SELECT DISTINCT
    RIGHT('0000' + CAST(PFUNC.CODCOLIGADA AS VARCHAR), 4) AS [Código da Empresa, cfe. Tabela de Empresas],
    LEFT(CAST(PPESSOA.CODIGO AS INTEGER), 8) AS [Código da Pessoa],
    LEFT(CAST(PPESSOA.NOME AS VARCHAR), 40) AS [Nome da Pessoa],
    LEFT(CASE
        WHEN EXISTS(SELECT 1 FROM DEPENDENTES WHERE CODCOLIGADA = PFUNC.CODCOLIGADA AND CHAPA = PFUNC.CHAPA AND GRAUPARENTESCO = '6')
        THEN (SELECT TOP 1 NOME FROM DEPENDENTES WHERE CODCOLIGADA = PFUNC.CODCOLIGADA AND CHAPA = PFUNC.CHAPA AND GRAUPARENTESCO = '6')
        ELSE 'NAO DECLARADO'
    END, 40) AS [Nome do Pai],
    LEFT(CASE
        WHEN EXISTS(SELECT 1 FROM DEPENDENTES WHERE CODCOLIGADA = PFUNC.CODCOLIGADA AND CHAPA = PFUNC.CHAPA AND GRAUPARENTESCO = '7')
        THEN (SELECT TOP 1 NOME FROM DEPENDENTES WHERE CODCOLIGADA = PFUNC.CODCOLIGADA AND CHAPA = PFUNC.CHAPA AND GRAUPARENTESCO = '7')
        ELSE 'NAO DECLARADO'
    END, 40) AS [Nome da Mãe],
    FORMAT(PPESSOA.DTNASCIMENTO, 'dd/MM/yyyy') AS [Data de Nascimento],
    UPPER(LEFT(CAST(PPESSOA.CIDADE AS VARCHAR), 20)) AS [Local do Nascimento],
    UPPER(LEFT(CAST(PPESSOA.ESTADO AS VARCHAR), 2)) AS [UF do Nascimento],
    LEFT(CAST(PPESSOA.SEXO AS VARCHAR), 1) AS [Sexo],
    CASE
        WHEN PPESSOA.CORRACA IN ('0')               THEN '1' --1 – Indígena
        WHEN PPESSOA.CORRACA IN ('2')               THEN '2' --2 – Branca
        WHEN PPESSOA.CORRACA IN ('4')               THEN '4' --4 – Preta
        WHEN PPESSOA.CORRACA IN ('6')               THEN '6' --6 – Amarela
        WHEN PPESSOA.CORRACA IN ('8')               THEN '8' --8 – Parda
        WHEN PPESSOA.CORRACA IN ('9', '10')         THEN '9' --9 - Não Informada
    END AS [Raça/Cor],
    CASE
        WHEN (
                CASE WHEN PPESSOA.DEFICIENTEFISICO > 0          THEN 1 ELSE 0 END + 
                CASE WHEN PPESSOA.DEFICIENTEVISUAL > 0          THEN 1 ELSE 0 END + 
                CASE WHEN PPESSOA.DEFICIENTEAUDITIVO > 0        THEN 1 ELSE 0 END + 
                CASE WHEN PPESSOA.DEFICIENTEINTELECTUAL > 0     THEN 1 ELSE 0 END
            ) > 1 THEN '5'
        WHEN PPESSOA.DEFICIENTEFISICO > 0           THEN '1'
        WHEN PPESSOA.DEFICIENTEVISUAL > 0           THEN '2'
        WHEN PPESSOA.DEFICIENTEAUDITIVO > 0         THEN '3'
        WHEN PPESSOA.DEFICIENTEINTELECTUAL > 0      THEN '4'
        ELSE '0'
    END AS [Deficiente Físico],
    UPPER(LEFT(CAST(PPESSOA.RUA AS VARCHAR), 40)) AS [Rua (endereço)],
    LEFT(CAST(PPESSOA.NUMERO AS VARCHAR), 8) AS [Número (endereço)],
    '' AS [Complemento (endereço)],
    UPPER(LEFT(CAST(PPESSOA.BAIRRO AS VARCHAR), 20)) AS [Bairro],
    UPPER(LEFT(CAST(PPESSOA.CIDADE AS VARCHAR), 20)) AS [Cidade],
    LEFT(CAST(PPESSOA.CEP AS VARCHAR), 10) AS [CEP],
    UPPER(LEFT(CAST(PPESSOA.ESTADO AS VARCHAR), 2)) AS [UF],
    '' AS [DDD],
    RIGHT(CAST(CASE
        WHEN PPESSOA.TELEFONE1 IS NOT NULL THEN PPESSOA.TELEFONE1
        WHEN PPESSOA.TELEFONE2 IS NOT NULL THEN PPESSOA.TELEFONE2
        ELSE PPESSOA.TELEFONE3
    END AS VARCHAR), 9) AS [Telefone],
    LEFT(CAST(PPESSOA.EMAIL AS VARCHAR), 40) AS [Email],
    LEFT(CAST(PFUNC.PISPASEP AS VARCHAR), 11) AS [PIS],
    '' AS [Data do Cadastramento do PIS],
    LEFT(CAST(PPESSOA.CPF AS VARCHAR), 11) AS [CPF],
    LEFT(CAST(PPESSOA.CARTIDENTIDADE AS VARCHAR), 15) AS [Identidade (RE ou RG)],
    FORMAT(PPESSOA.DTEMISSAOIDENT, 'dd/MM/yyyy') AS [Data da Emissão da Identidade],
    LEFT(CAST(PPESSOA.ORGEMISSORIDENT AS VARCHAR), 8) AS [Órgão Emissor da Identidade],
    LEFT(CAST(PPESSOA.UFCARTIDENT AS VARCHAR), 2) AS [UF da Identidade],
    LEFT(CAST(PPESSOA.TITULOELEITOR AS VARCHAR), 15) AS [Título Eleitoral],
    LEFT(CAST(PPESSOA.ZONATITELEITOR AS VARCHAR), 4) AS [Zona Eleitoral],
    LEFT(CAST(PPESSOA.SECAOTITELEITOR AS VARCHAR), 4) AS [Seção Eleitoral],
    '' AS [Aposentado],
    '' AS [Data da Aposentadoria],
    CASE
        WHEN PPESSOA.ESTADOCIVIL IN ('E','O','S')       THEN '01' --01 – Solteiro
        WHEN PPESSOA.ESTADOCIVIL IN ('C')               THEN '02' --02 – Casado
        WHEN PPESSOA.ESTADOCIVIL IN ('V')               THEN '03' --03 – Viúvo
        WHEN PPESSOA.ESTADOCIVIL IN ('D','P')           THEN '04' --04 – Separado
        WHEN PPESSOA.ESTADOCIVIL IN ('I')               THEN '05' --05 – Divorciado
    END AS [Estado Civil],
    CASE
        WHEN PPESSOA.GRAUINSTRUCAO IN ('1')             THEN '01' --01 – Analfabeto
        WHEN PPESSOA.GRAUINSTRUCAO IN ('2')             THEN '02' --02 – Até o 5º Ano Incompleto do Ensino Fundamental
        WHEN PPESSOA.GRAUINSTRUCAO IN ('3')             THEN '03' --03 – 5º Ano Completo do Ensino Fundamental
        WHEN PPESSOA.GRAUINSTRUCAO IN ('4')             THEN '04' --04 – Do 6º ao 9º Ano do Ensino Fundamental Incompleto
        WHEN PPESSOA.GRAUINSTRUCAO IN ('5')             THEN '05' --05 – Ensino Fundamental Completo
        WHEN PPESSOA.GRAUINSTRUCAO IN ('6')             THEN '06' --06 - Ensino Médio Incompleto
        WHEN PPESSOA.GRAUINSTRUCAO IN ('7')             THEN '07' --07 – Ensino Médio Completo
        WHEN PPESSOA.GRAUINSTRUCAO IN ('8')             THEN '09' --09 – Educação Superior Incompleta
        WHEN PPESSOA.GRAUINSTRUCAO IN ('9','A','C')     THEN '10' --10 – Educação Superior Completa
        WHEN PPESSOA.GRAUINSTRUCAO IN ('B')             THEN '11' --11 – Pós-Graduado
        WHEN PPESSOA.GRAUINSTRUCAO IN ('D')             THEN '12' --12 – Mestrado Completo
        WHEN PPESSOA.GRAUINSTRUCAO IN ('F')             THEN '13' --13 – Doutorado Completo
    END AS [Grau de Instrução],
    LEFT(CAST(PPESSOA.NACIONALIDADE AS VARCHAR), 2) AS [Nacionalidade (cfe. Tabela da Rais)],
    '' AS [DDD do Telefone Celular],
    '' AS [Número do Telefone Celular],
    LEFT(CAST(PPESSOA.CERTIFRESERV AS VARCHAR), 20) AS [Certificado de Reservista],
    LEFT(CAST(PPESSOA.CARTMOTORISTA AS VARCHAR), 15) AS [Registro da Carteira de Habilitação],
    LEFT(CAST(PPESSOA.TIPOCARTHABILIT AS VARCHAR), 3) AS [Categoria da Carteira de Habilitação],
    FORMAT(PPESSOA.DTVENCHABILIT, 'dd/MM/yyyy') AS [Data de Validade da Carteira de Habilitação],
    LEFT(CAST(PPESSOA.ORGEMISSORCNH AS VARCHAR), 20) AS [Órgão Emissor da Carteira de Habilitação],
    LEFT(CAST(PPESSOA.UFCNH AS VARCHAR), 2) AS [UF da Carteira de Habilitação],
    LEFT(CAST(PFUNC.NUMEROCARTAOSUS AS VARCHAR), 20) AS [Número do Cartão do SUS],
    '' AS [Número do Registro de Identidade Civil (RIC)],
    '' AS [Data de Expedição do Registro de Identidade Civil (RIC)],
    '' AS [Órgão Emissor do Registro de Identidade Civil (RIC)],
    LEFT(CAST(PPESSOA.CARTEIRATRAB AS VARCHAR), 10) AS [Número da Carteira de Trabalho],
    LEFT(CAST(PPESSOA.SERIECARTTRAB AS VARCHAR), 5) AS [Série da Carteira de Trabalho],
    FORMAT(PPESSOA.DTCARTTRAB, 'dd/MM/yyyy') AS [Data de Emissão da Carteira de Trabalho],
    LEFT(CAST(PPESSOA.UFCARTTRAB AS VARCHAR), 2) AS [UF da Carteira de Trabalho],
    LEFT(CAST(PPESSOA.NOME AS VARCHAR), 70) AS [Nome Completo],
    FORMAT(PPESSOA.DTEMISSAOCNH, 'dd/MM/yyyy') AS [Data de Expedição da Carteira de Habilitação]
FROM PPESSOA
INNER JOIN PFUNC
    ON PFUNC.CODPESSOA = PPESSOA.CODIGO

LEFT JOIN FUNCIONARIO_PRIORIZADO FP
    ON FP.CODCOLIGADA = PFUNC.CODCOLIGADA
   AND FP.CHAPA       = PFUNC.CHAPA
   AND FP.CODPESSOA   = PFUNC.CODPESSOA
   AND FP.ORDEM       = 1

WHERE
    FP.ORDEM = 1

    OR (
        PFUNC.CODTIPO <> 'A'
        AND (
            PPESSOA.CPF IS NULL
            OR LTRIM(RTRIM(CAST(PPESSOA.CPF AS VARCHAR(20)))) = ''
        )
    )