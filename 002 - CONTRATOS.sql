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
DADOS AS
(
    SELECT
        PFUNC.CODCOLIGADA,
        PFUNC.CHAPA,
        PFUNC.CODPESSOA,
        PFUNC.DATAADMISSAO,
        PFUNC.DATADEMISSAO,
        PPESSOA.CODIGO,
        PPESSOA.CPF
    FROM PFUNC
    INNER JOIN PPESSOA
        ON PPESSOA.CODIGO = PFUNC.CODPESSOA
    WHERE PFUNC.TIPODEMISSAO NOT IN ('5', '6')
       OR PFUNC.TIPODEMISSAO IS NULL
),
DADOS2 AS
(
    SELECT
        DADOS.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                DADOS.CODCOLIGADA,
                DADOS.CODPESSOA
            ORDER BY
                CASE 
                    WHEN DADOS.DATADEMISSAO IS NULL THEN 0
                    ELSE 1
                END,
                DADOS.DATAADMISSAO DESC,
                DADOS.DATADEMISSAO DESC,
                DADOS.CHAPA DESC
        ) AS ORDEM
    FROM DADOS
),
PESSOAS AS (
	SELECT
	    CODCOLIGADA,
	    CHAPA,
	    CODPESSOA,
	    DATAADMISSAO,
	    DATADEMISSAO,
	    CODIGO,
	    CPF,
	    ORDEM
	FROM DADOS2
	WHERE ORDEM = 1
),
CONTRATOS AS (
    SELECT
        RIGHT('0000' + CAST(PFUNC.CODCOLIGADA AS VARCHAR), 4) AS [Código da Empresa, cfe. Tabela de Empresas],
        CASE
            WHEN PFUNC.CODCOLIGADA <> 1 
            THEN RIGHT('00' + CAST(PFUNC.CODCOLIGADA AS VARCHAR), 2) + RIGHT('00' + CAST(PFUNC.CODFILIAL AS VARCHAR), 2) 
            ELSE RIGHT('0000' + CAST(PFUNC.CODFILIAL AS VARCHAR), 4)
        END AS [Código do Estabelecimento Atual, cfe. Tabela de Estabelecimentos],
        CASE
            WHEN PFUNC.CODCOLIGADA <> 1 
            THEN RIGHT('00' + CAST(PFUNC.CODCOLIGADA AS VARCHAR), 2) + RIGHT('00' + CAST(PFUNC.CODFILIAL AS VARCHAR), 2) 
            ELSE RIGHT('0000' + CAST(PFUNC.CODFILIAL AS VARCHAR), 4)
        END AS [Código da Unidade, cfe. Tabela de Unidades],
        CAST(PFUNC.CODCOLIGADA AS VARCHAR) + RIGHT(PFUNC.CHAPA, 8 - LEN(CAST(PFUNC.CODCOLIGADA AS VARCHAR))) AS [Código do Contrato],
        LEFT(CAST(PFUNC.CODPESSOA AS INTEGER), 8) AS [Código da Pessoa, cfe. Tabela de Pessoas],
        CASE
            WHEN PFUNC.CODCATEGORIAESOCIAL = 101 THEN '001'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 102 THEN '010'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 103 THEN '002'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 104 THEN '301'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 105 THEN '007'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 106 THEN '006'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 107 THEN '012'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 108 THEN '013'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 111 THEN '003'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 201 THEN '014'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 202 THEN '015'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 701 THEN '201'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 711 THEN '203'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 712 THEN '202'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 721 THEN '104'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 722 THEN '103'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 731 THEN '204'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 734 THEN '205'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 741 THEN '207'
            WHEN PFUNC.CODCATEGORIAESOCIAL = 901 THEN '004'
            ELSE '001'
        END AS [Vínculo Empregatício],
        '' AS [Crachá],
        CASE
            WHEN PFUNC.CODSITUACAO IN ('A', 'Z', 'F', 'V') THEN '1'
            WHEN PFUNC.CODSITUACAO IN ('E','L','P','T','W','Y','I','Q') THEN '2'
            WHEN PFUNC.DATADEMISSAO IS NULL AND PFUNC.CODSITUACAO = 'D' THEN '4'
            WHEN PFUNC.DATADEMISSAO < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) AND PFUNC.CODSITUACAO = 'D' THEN '4'
            WHEN PFUNC.DATADEMISSAO BETWEEN DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) AND EOMONTH(GETDATE()) AND PFUNC.CODSITUACAO = 'D' THEN '3'
        END AS [Situação],
        '' AS [Causa Afastamento],
        '' AS [Dt.Último Afastamento],
        '' AS [Dt.Último Retorno],
        CASE
            WHEN PFUNC.TIPODEMISSAO = '1' THEN '1' --Demissão com Justa Causa
            WHEN PFUNC.TIPODEMISSAO = '2' THEN '2' --Demissão sem Justa Causa
            WHEN PFUNC.TIPODEMISSAO = '3' THEN '3' --Pedido de Demissão sem Justa Causa
            WHEN PFUNC.TIPODEMISSAO = '4' THEN '4' --Pedido de Demissão sem Justa Causa
            WHEN PFUNC.TIPODEMISSAO = '5' THEN '6' --Transferência de Estab. s/Ônus p/Cedente
            WHEN PFUNC.TIPODEMISSAO = '6' THEN '6' --Transferência de Estab. c/Ônus p/Cedente
            WHEN PFUNC.TIPODEMISSAO = '7' THEN '9' --Outros Motivos de Rescisão
            WHEN PFUNC.TIPODEMISSAO = '8' THEN '8' --Falecimento
            WHEN PFUNC.TIPODEMISSAO = '9' THEN '9' --Outros Motivos de Rescisão
            WHEN PFUNC.TIPODEMISSAO = 'A' THEN '7' --Aposentadoria p/Invalidez Dec.Acid.Trab.
            WHEN PFUNC.TIPODEMISSAO = 'B' THEN '9' --Rescisão determinada pela Justiça
            WHEN PFUNC.TIPODEMISSAO = 'C' THEN '9' --Rescisão por Culpa Recíproca
            WHEN PFUNC.TIPODEMISSAO = 'D' THEN '7' --Aposentadoria p/Invalidez Dec.Doença Pr.
            WHEN PFUNC.TIPODEMISSAO = 'E' THEN '7' --Aposentadoria Especial
            WHEN PFUNC.TIPODEMISSAO = 'F' THEN '8' --Falecimento Decorr. de Acidente do Trab.
            WHEN PFUNC.TIPODEMISSAO = 'G' THEN '9' --Outros Motivos de Rescisão
            WHEN PFUNC.TIPODEMISSAO = 'H' THEN '9' --Outros Motivos de Rescisão
            WHEN PFUNC.TIPODEMISSAO = 'I' THEN '7' --Aposentadoria por Idade
            WHEN PFUNC.TIPODEMISSAO = 'J' THEN '7' --Aposentadoria por Idade
            WHEN PFUNC.TIPODEMISSAO = 'M' THEN '9' --Mudança de Regime Trabalhista
            WHEN PFUNC.TIPODEMISSAO = 'N' THEN '9' --Rescisão por Dispensa Indireta
            WHEN PFUNC.TIPODEMISSAO = 'O' THEN '7' --Aposentadoria por Invalidez
            WHEN PFUNC.TIPODEMISSAO = 'P' THEN '8' --Falecimento Decorr. de Doença Profiss.
            WHEN PFUNC.TIPODEMISSAO = 'R' THEN '7' --Aposentadoria por Tempo de Serviço
            WHEN PFUNC.TIPODEMISSAO = 'S' THEN '7' --Aposentadoria por Tempo de Serviço
            WHEN PFUNC.TIPODEMISSAO = 'T' THEN '5' --Rescisão por Término do Contrato por Prazo Determinado
            WHEN PFUNC.TIPODEMISSAO = 'U' THEN '7' --Aposentadoria Compulsória
            WHEN PFUNC.TIPODEMISSAO = 'V' THEN '9' --Rescisão por Acordo entre Partes
            WHEN PFUNC.TIPODEMISSAO = 'W' THEN '9' --Outros Motivos de Rescisão
            WHEN PFUNC.TIPODEMISSAO = 'X' THEN '9' --Outros Motivos de Rescisão
            ELSE '9'
        END AS [Causa Rescisão],
       
        FORMAT(PFUNC.DATAADMISSAO, 'dd/MM/yyyy') AS [Data de Admissão],
        CASE
            WHEN PFUNC.CODRECEBIMENTO LIKE 'M' THEN '1'
            WHEN PFUNC.CODRECEBIMENTO LIKE 'D' THEN '4'
            WHEN PFUNC.CODRECEBIMENTO LIKE 'H' THEN '5'
            WHEN PFUNC.CODRECEBIMENTO LIKE 'O' THEN '7'
            WHEN PFUNC.CODRECEBIMENTO LIKE 'Q' THEN '2'
        END AS [Tipo de Salário],
        LEFT(REPLACE(CAST(PFUNC.SALARIO AS VARCHAR), '.', ','), 11) AS [Salário Contratual, cfe. Tipo de Salário],
        CASE
            WHEN PFUNC.CODRECEBIMENTO = 'H' THEN '5' 
            ELSE LEFT(CAST(PFUNC.JORNADAMENSAL / 60 AS VARCHAR), 11) 
        END AS [Horas Contratuais, cfe. Tipo de Salário. Informar Horas/Mês nos contratos de Horistas (Tipo de Salário “5”).],
        CASE WHEN PFCODFIX.CODEVENTO = '0108' THEN '0,20' ELSE '0,00' END AS [Percentual de Insalubridade],
        CASE WHEN PFCODFIX.CODEVENTO = '0108' THEN '0,30' ELSE '0,00' END AS [Percentual de Periculosidade],
        '' AS [Nível de Exposição a Agente Nocivo],
        RIGHT('000' + LEFT(CAST(PFUNC.CODBANCOPAGTO AS INTEGER), 3), 3) AS [Número do Banco do Funcionário (Banco Central)],
        RIGHT('0000' + LEFT(CAST(REPLACE(REPLACE(PFUNC.CODAGENCIAPAGTO, '-',''),' ','') AS INTEGER), 4), 4) AS [Agencia Bancária do Funcionário],
        RIGHT(REPLACE(REPLACE(PFUNC.CODAGENCIAPAGTO, '-',''),' ',''), 1) AS [Dígito da Agência Bancária do Funcionário],
        LEFT(TRY_CAST(REPLACE(REPLACE(REPLACE(PFUNC.CONTAPAGAMENTO, '-',''),' ',''), '.','') AS INTEGER), 15) AS [Número/Dígito da Conta Corrente],
        '' AS [Vínculo Previdência],
        '' AS [Cadastro do Empregado na CEF (para o FGTS)],
        '' AS [Número de Registro],
        FORMAT(PFUNC.DATAADMISSAO, 'dd/MM/yyyy') AS [Data de Início do Contrato de Experiência/Temporário],
        FORMAT(PFUNC.FIMPRAZOCONTR, 'dd/MM/yyyy') AS [Data de Término do Contrato de Experiência/Temporário],
        '' AS [Número de Dias do Contrato de Experiência/Temporário],
        '' AS [Data de Início da Prorrogação do Contrato de Experiência],
        '' AS [Data de Término da Prorrogação do Contrato de Experiência],
        '' AS [Número de Dias da Prorrogação do Contrato de Experiência],
        '' AS [Dt.Aviso Prévio],
        '' AS [Dias Aviso Prévio],
        FORMAT(PFUNC.DATADEMISSAO, 'dd/MM/yyyy') AS [Data da Rescisão],
        TB_CARGOS.CODIGO AS [Código do Cargo, cfe. Tabela de Cargos],
        LEFT(CAST(PFUNC.MATRICULAESOCIAL AS VARCHAR), 30) AS [Matrícula para o eSocial],
        CASE
            WHEN PFUNC.TIPODEMISSAO = '1' THEN '001' --Demissão com Justa Causa
            WHEN PFUNC.TIPODEMISSAO = '2' THEN '002' --Demissão sem Justa Causa
            WHEN PFUNC.TIPODEMISSAO = '3' THEN '003' --Pedido de Demissão sem Justa Causa
            WHEN PFUNC.TIPODEMISSAO = '4' THEN '003' --Pedido de Demissão sem Justa Causa
            WHEN PFUNC.TIPODEMISSAO = '5' THEN '012' --Transferência de Estab. s/Ônus p/Cedente
            WHEN PFUNC.TIPODEMISSAO = '6' THEN '011' --Transferência de Estab. c/Ônus p/Cedente
            WHEN PFUNC.TIPODEMISSAO = '7' THEN '9999' --Outros Motivos de Rescisão
            WHEN PFUNC.TIPODEMISSAO = '8' THEN '020' --Falecimento
            WHEN PFUNC.TIPODEMISSAO = '9' THEN '9999' --Outros Motivos de Rescisão
            WHEN PFUNC.TIPODEMISSAO = 'A' THEN '033' --Aposentadoria p/Invalidez Dec.Acid.Trab.
            WHEN PFUNC.TIPODEMISSAO = 'B' THEN '041' --Rescisão determinada pela Justiça
            WHEN PFUNC.TIPODEMISSAO = 'C' THEN '010' --Rescisão por Culpa Recíproca
            WHEN PFUNC.TIPODEMISSAO = 'D' THEN '034' --Aposentadoria p/Invalidez Dec.Doença Pr.
            WHEN PFUNC.TIPODEMISSAO = 'E' THEN '036' --Aposentadoria Especial
            WHEN PFUNC.TIPODEMISSAO = 'F' THEN '021' --Falecimento Decorr. de Acidente do Trab.
            WHEN PFUNC.TIPODEMISSAO = 'G' THEN '9999' --Outros Motivos de Rescisão
            WHEN PFUNC.TIPODEMISSAO = 'H' THEN '9999' --Outros Motivos de Rescisão
            WHEN PFUNC.TIPODEMISSAO = 'I' THEN '031' --Aposentadoria por Idade
            WHEN PFUNC.TIPODEMISSAO = 'J' THEN '031' --Aposentadoria por Idade
            WHEN PFUNC.TIPODEMISSAO = 'M' THEN '013' --Mudança de Regime Trabalhista
            WHEN PFUNC.TIPODEMISSAO = 'N' THEN '009' --Rescisão por Dispensa Indireta
            WHEN PFUNC.TIPODEMISSAO = 'O' THEN '032' --Aposentadoria por Invalidez
            WHEN PFUNC.TIPODEMISSAO = 'P' THEN '022' --Falecimento Decorr. de Doença Profiss.
            WHEN PFUNC.TIPODEMISSAO = 'R' THEN '030' --Aposentadoria por Tempo de Serviço
            WHEN PFUNC.TIPODEMISSAO = 'S' THEN '030' --Aposentadoria por Tempo de Serviço
            WHEN PFUNC.TIPODEMISSAO = 'T' THEN '005' --Rescisão por Término do Contrato por Prazo Determinado
            WHEN PFUNC.TIPODEMISSAO = 'U' THEN '035' --Aposentadoria Compulsória
            WHEN PFUNC.TIPODEMISSAO = 'V' THEN '016' --Rescisão por Acordo entre Partes
            WHEN PFUNC.TIPODEMISSAO = 'W' THEN '9999' --Outros Motivos de Rescisão
            WHEN PFUNC.TIPODEMISSAO = 'X' THEN '9999' --Outros Motivos de Rescisão
        END AS [Motivo de Rescisão Darwin]
    FROM PFUNC
    LEFT JOIN PFUNCAO
    ON PFUNCAO.CODCOLIGADA            = PFUNC.CODCOLIGADA
    AND PFUNCAO.CODIGO                = PFUNC.CODFUNCAO
    LEFT JOIN TB_CARGOS
    ON TB_CARGOS.CARGO                = LEFT(TRANSLATE(CAST(PFUNCAO.NOME AS VARCHAR),
                                            'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüç',
                                            'AAAAAEEEEIIIIOOOOOUUUUCaaaaaeeeeiiiiooooouuuuc'
                                        ), 40)
    AND TB_CARGOS.CBO                 = LEFT(CAST(REPLACE(REPLACE(ISNULL(PFUNCAO.CBO2002, PFUNCAO.CBO),'-',''),' ','') AS VARCHAR), 6)
    LEFT JOIN PFCODFIX
    ON PFCODFIX.CODCOLIGADA            = PFUNC.CODCOLIGADA
    AND PFCODFIX.CHAPA                 = PFUNC.CHAPA
	INNER JOIN PESSOAS
	  ON PESSOAS.CODCOLIGADA = PFUNC.CODCOLIGADA
	  AND PESSOAS.CHAPA = PFUNC.CHAPA
)

SELECT DISTINCT * FROM CONTRATOS
