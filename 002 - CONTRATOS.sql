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
    RIGHT('0000' + CAST(PFUNC.CODCOLIGADA AS VARCHAR), 4) AS [Código da Empresa, cfe. Tabela de Empresas],
    RIGHT('0000' + CAST(PFUNC.CODFILIAL AS VARCHAR), 4) AS [Código do Estabelecimento Atual, cfe. Tabela de Estabelecimentos],
   	TB_UNIDADE.CODSEQ AS [Código da Unidade, cfe. Tabela de Unidades],
	CAST(PFUNC.CODCOLIGADA AS VARCHAR) + RIGHT(PFUNC.CHAPA, 8 - LEN(CAST(PFUNC.CODCOLIGADA AS VARCHAR))) AS [Código do Contrato],
    LEFT(CAST(PFUNC.CODPESSOA AS INTEGER), 8) AS [Código da Pessoa, cfe. Tabela de Pessoas],
    '' AS [Interno Sistema],
    '' AS [Interno Sistema],
    CASE
        WHEN PFUNC.DATADEMISSAO BETWEEN DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) AND EOMONTH(GETDATE()) THEN '3'
        WHEN PFUNC.DATADEMISSAO < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) THEN '4'
        WHEN PFUNC.CODSITUACAO IN ('E','L','P','T','W','Y','I') THEN '2'
        WHEN PFUNC.CODSITUACAO IN ('A', 'Z') THEN '1'
    END AS [Situação],
    '' AS [Interno Sistema],
    '' AS [Interno Sistema],
    '' AS [Interno Sistema],
    '' AS [Interno Sistema],
    FORMAT(PFUNC.DATAADMISSAO, 'dd/MM/yyyy') AS [Data de Admissão],
    CASE
        WHEN PFUNC.CODRECEBIMENTO LIKE 'M' THEN '1'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'D' THEN '4'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'H' THEN '5'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'O' THEN '7'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'Q' THEN '2'
    END AS [Tipo de Salário],
    LEFT(CAST(PFUNC.SALARIO AS VARCHAR), 11) AS [Salário Contratual, cfe. Tipo de Salário],
    CASE
        WHEN PFUNC.CODRECEBIMENTO = 'H' THEN '5' 
        ELSE LEFT(CAST(PFUNC.JORNADA_MENSAL AS VARCHAR), 11) 
    END AS [Horas Contratuais, cfe. Tipo de Salário. Informar Horas/Mês nos contratos de Horistas (Tipo de Salário “5”).],
    '' AS [Percentual de Insalubridade],
    '' AS [Percentual de Periculosidade],
    '' AS [Nível de Exposição a Agente Nocivo],
    RIGHT('000' + LEFT(CAST(PFUNC.CODBANCOPAGTO AS INTEGER), 3), 3) AS [Número do Banco do Funcionário (Banco Central)],
    RIGHT('0000' + LEFT(CAST(REPLACE(REPLACE(PFUNC.CODAGENCIAPAGTO, '-',''),' ','') AS INTEGER), 4), 4) AS [Agencia Bancária do Funcionário],
    RIGHT(REPLACE(REPLACE(PFUNC.CODAGENCIAPAGTO, '-',''),' ',''), 1) AS [Dígito da Agência Bancária do Funcionário],
    LEFT(TRY_CAST(REPLACE(REPLACE(REPLACE(PFUNC.CONTAPAGAMENTO, '-',''),' ',''), '.','') AS INTEGER), 15) AS [Número/Dígito da Conta Corrente],
    '' AS [Interno Sistema],
    '' AS [Cadastro do Empregado na CEF (para o FGTS)],
    '' AS [Interno Sistema],
    FORMAT(PFUNC.DATAADMISSAO, 'dd/MM/yyyy') AS [Data de Início do Contrato de Experiência/Temporário],
    FORMAT(PFUNC.FIMPRAZOCONTR, 'dd/MM/yyyy') AS [Data de Término do Contrato de Experiência/Temporário],
    '' AS [Número de Dias do Contrato de Experiência/Temporário],
    '' AS [Data de Início da Prorrogação do Contrato de Experiência],
    '' AS [Data de Término da Prorrogação do Contrato de Experiência],
    '' AS [Número de Dias da Prorrogação do Contrato de Experiência],
    '' AS [Interno Sistema],
    '' AS [Interno Sistema],
    FORMAT(PFUNC.DATADEMISSAO, 'dd/MM/yyyy') AS [Data da Rescisão],
    TB_CARGOS.CODIGO AS [Código do Cargo, cfe. Tabela de Cargos],
    LEFT(CAST(PFUNC.MATRICULAESOCIAL AS VARCHAR), 30) AS [Matrícula para o eSocial],
    CASE
        WHEN PFUNC.TIPOCONTRATOPRAZO = 'D' THEN 1
        WHEN PFUNC.TIPOCONTRATOPRAZO = 'E' THEN 2
    END AS [Tipo de Contrato],
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
        WHEN PFUNC.TIPODEMISSAO = 'V' THEN '016' --Rescisão por Acordo entre as Partes
        WHEN PFUNC.TIPODEMISSAO = 'W' THEN '9999' --Outros Motivos de Rescisão
        WHEN PFUNC.TIPODEMISSAO = 'X' THEN '9999' --Outros Motivos de Rescisão
    END AS [Motivo de Rescisão Darwin],
    CASE
        WHEN PFUNC.CODCATEGORIAESOCIAL = 101 THEN '001' --CLT - Empregador Pessoa Jurídica, categoria e-Social 101 - Empregado – Geral, inclusive o empregado público da administração direta ou indireta contratado pela CLT
        WHEN PFUNC.CODCATEGORIAESOCIAL = 102 THEN '010' --Trabalhador Rural  - Prazo Lei 11.718/2008, categoria e-Social 101 -Empregado – Geral, inclusive o empregado público da administração direta ou indireta contratado pela CLT
        WHEN PFUNC.CODCATEGORIAESOCIAL = 103 THEN '002' --Aprendiz, categoria e-Social 103 - Empregado – Aprendiz
        WHEN PFUNC.CODCATEGORIAESOCIAL = 104 THEN '301' --Empregado(a) Doméstico(a), categoria e-Social 104 - Empregado- Doméstico 
        WHEN PFUNC.CODCATEGORIAESOCIAL = 105 THEN '007' --Trabalhador Temporário - Lei 9.601, categoria e-Social 105 - Empregado – contrato a termo firmado nos termos da Lei 9601/98
        WHEN PFUNC.CODCATEGORIAESOCIAL = 106 THEN '006' --Trabalhador Temporário - Lei 6.019, categoria e-Social 106 - Trabalhador Temporário - contrato nos termos da Lei 6.019/74
        WHEN PFUNC.CODCATEGORIAESOCIAL = 107 THEN '012' --Contrato de Trabalho Verde e Amarelo sem Multa FGTS Mensal, categoria e-Social 107 -Empregado - Contrato de trabalho Verde e Amarelo - sem acordo para antecipação mensal da multa rescisória do FGTS
        WHEN PFUNC.CODCATEGORIAESOCIAL = 108 THEN '013' --Contrato de Trabalho Verde e Amarelo com Multa FGTS Mensal, categoria e-Social 108 -Empregado - Contrato de trabalho Verde e Amarelo - com acordo para antecipação mensal da multa rescisória do FGTS
        WHEN PFUNC.CODCATEGORIAESOCIAL = 111 THEN '003' --Trabalhador Intermitente, categoria e-Social 111 - Empregado - Contrato de trabalho intermitente 
        WHEN PFUNC.CODCATEGORIAESOCIAL = 201 THEN '014' --Trabalhador Avulso Portuário, categoria e-Social 201 - Trabalhador Avulso Portuário
        WHEN PFUNC.CODCATEGORIAESOCIAL = 202 THEN '015' --Trabalhador Avulso Não Portuário, categoria e-Social 202 - Trabalhador Avulso Não Portuário
        WHEN PFUNC.CODCATEGORIAESOCIAL = 701 THEN '201' --Autônomo, categoria e-Social 701 - Contribuinte individual – Autônomo em geral, exceto se enquadrado em uma das demais categorias de contribuinte individual
        WHEN PFUNC.CODCATEGORIAESOCIAL = 711 THEN '203' --Freteiro - Passageiros, categoria e-Social 711 - Contribuinte individual – Transportador autônomo de passageiros
        WHEN PFUNC.CODCATEGORIAESOCIAL = 712 THEN '202' --Freteiro - Carga, categoria e-Social 712 - Contribuinte individual – Transportador autônomo de carga
        WHEN PFUNC.CODCATEGORIAESOCIAL = 721 THEN '104' --Diretor com FGTS - Não Sócio, categoria e-Social 721 - Contribuinte individual – Diretor não empregado, com FGTS
        WHEN PFUNC.CODCATEGORIAESOCIAL = 722 THEN '103' --Diretor sem FGTS - Não Sócio, categoria e-social 722 - Contribuinte individual – Diretor não empregado, sem FGTS
        WHEN PFUNC.CODCATEGORIAESOCIAL = 731 THEN '204' --Cooperado - Presta Serviços à Entidade.Beneficente, categoria e-Social 731 - Contribuinte individual – Cooperado que presta serviços por intermédio de Cooperativa de Trabalho
        WHEN PFUNC.CODCATEGORIAESOCIAL = 734 THEN '205' --Freteiro Cooperado - Presta Serviço Entidade Beneficente, categoria e-Social 734 - Contribuinte individual – Transportador Cooperado que presta serviços por intermédio de cooperativa de trabalho
        WHEN PFUNC.CODCATEGORIAESOCIAL = 741 THEN '207' --MEI - Microempreendedor Individual, categoria e-Social 741 - Contribuinte individual - Microempreendedor Individual
        WHEN PFUNC.CODCATEGORIAESOCIAL = 901 THEN '004' --Estagiário, categoria e-Social 901 - Estagiário
    END AS [Vínculo Empregatício],
    '1' AS [Tipo de Admissão para o eSocial]
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
LEFT JOIN TB_UNIDADE
  ON TB_UNIDADE.CODIGO			    = CAST(PFUNC.CODCOLIGADA AS VARCHAR) + CAST(REPLACE(PFUNC.CODSECAO,'.','') AS VARCHAR)