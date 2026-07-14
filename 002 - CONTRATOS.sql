SELECT
    PFUNC.CODCOLIGADA AS [Código da Empresa, cfe. Tabela de Empresas],
    PFUNC.CODFILIAL AS [Código do Estabelecimento Atual, cfe. Tabela de Estabelecimentos],
    PFUNC.CODSECAO AS [Código da Unidade, cfe. Tabela de Unidades],
	LEFT(
		RIGHT('00000000' + (CAST(PFUNC.CODCOLIGADA AS VARCHAR) + CAST(PFUNC.CHAPA AS VARCHAR)), 8), 8
	) AS [Código do Contrato],
    LEFT(CAST(PFUNC.CODPESSOA AS INTEGER), 8) AS [Código da Pessoa, cfe. Tabela de Pessoas],
    CASE
        WHEN PFUNC.DATADEMISSAO BETWEEN DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) AND EOMONTH(GETDATE()) THEN '3'
        WHEN PFUNC.DATADEMISSAO < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) THEN '4'
        WHEN PFUNC.CODSITUACAO IN ('E','L','P','T','W','Y','I') THEN '2'
        WHEN PFUNC.CODSITUACAO IN ('A', 'Z') THEN '1'
    END AS [Situação],
    FORMAT(PFUNC.DATAADMISSAO, 'ddMMyyyy') AS [Data de Admissão],
    CASE
        WHEN PFUNC.CODRECEBIMENTO LIKE 'M' THEN '1'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'D' THEN '4'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'H' THEN '5'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'O' THEN '7'
        WHEN PFUNC.CODRECEBIMENTO LIKE 'Q' THEN '2'
    END AS [Tipo de Salário],
    '' AS [Salário Contratual, cfe. Tipo de Salário],
    '' AS [Horas Contratuais, cfe. Tipo de Salário. Informar Horas/Mês nos contratos de Horistas (Tipo de Salário “5”).],
    '' AS [Percentual de Insalubridade],
    '' AS [Percentual de Periculosidade],
    '' AS [Nível de Exposição a Agente Nocivo],
    RIGHT('000' + LEFT(CAST(PFUNC.CODBANCOPAGTO AS INTEGER), 3), 3) AS [Número do Banco do Funcionário (Banco Central)],
    RIGHT('0000' + LEFT(CAST(REPLACE(REPLACE(PFUNC.CODAGENCIAPAGTO, '-',''),' ','') AS INTEGER), 4), 4) AS [Agencia Bancária do Funcionário],
    RIGHT(REPLACE(REPLACE(PFUNC.CODAGENCIAPAGTO, '-',''),' ',''), 1) AS [Dígito da Agência Bancária do Funcionário],
    LEFT(TRY_CAST(REPLACE(REPLACE(REPLACE(PFUNC.CONTAPAGAMENTO, '-',''),' ',''), '.','') AS INTEGER), 15) AS [Número/Dígito da Conta Corrente],
    '' AS [Cadastro do Empregado na CEF (para o FGTS)],
    '' AS [Data de Início do Contrato de Experiência/Temporário],
    '' AS [Data de Término do Contrato de Experiência/Temporário],
    '' AS [Número de Dias do Contrato de Experiência/Temporário],
    '' AS [Data de Início da Prorrogação do Contrato de Experiência],
    '' AS [Data de Término da Prorrogação do Contrato de Experiência],
    '' AS [Número de Dias da Prorrogação do Contrato de Experiência],
    FORMAT(PFUNC.DATADEMISSAO, 'ddMMyyyy') AS [Data da Rescisão],
    LEFT(CAST(PFUNC.CODCOLIGADA AS VARCHAR) + CAST(PFUNC.CODFUNCAO AS VARCHAR), 8) AS [Código do Cargo, cfe. Tabela de Cargos],
    LEFT(CAST(PFUNC.MATRICULAESOCIAL AS VARCHAR), 30) AS [Matrícula para o eSocial],
    2 AS [Tipo de Contrato],
    CASE
        WHEN PFUNC.TIPODEMISSAO = '1' THEN '001' --001 – Demissão com Justa Causa
        WHEN PFUNC.TIPODEMISSAO = '2' THEN '002' --002 – Demissão Sem Justa Causa
        WHEN PFUNC.TIPODEMISSAO = '4' THEN '003' --003 – Pedido de Demissão Sem Justa Causa
        WHEN PFUNC.TIPODEMISSAO = '5' THEN '012' --012 – Transferência de Estab. s/Ônus p/Cedente
        WHEN PFUNC.TIPODEMISSAO = '6' THEN '011' --011 – Transferência de Estab. c/Ônus p/Cedente
        WHEN PFUNC.TIPODEMISSAO = '7' THEN '9999' --9999 - Outros Motivos de Rescisão
        WHEN PFUNC.TIPODEMISSAO = '8' THEN '020' --020 – Falecimento
        WHEN PFUNC.TIPODEMISSAO = '9' THEN '9999' --9999 - Outros Motivos de Rescisão
        WHEN PFUNC.TIPODEMISSAO = 'B' THEN '041' --041 - Rescisão determinada pela Justiça
        WHEN PFUNC.TIPODEMISSAO = 'C' THEN '010' --010 – Rescisão por Culpa Recíproca
        WHEN PFUNC.TIPODEMISSAO = 'D' THEN '032' --032 – Aposentadoria por Invalidez
        WHEN PFUNC.TIPODEMISSAO = 'I' THEN '031' --031 – Aposentadoria por Idade
        WHEN PFUNC.TIPODEMISSAO = 'S' THEN '030' --030 – Aposentadoria por Tempo de Serviço
        WHEN PFUNC.TIPODEMISSAO = 'T' THEN '037' --037 - Termino de Contrato - Estagiário
        WHEN PFUNC.TIPODEMISSAO = 'V' THEN '016' --016 – Rescisão por Acordo Entre as Partes
    END AS [Motivo de Rescisão Darwin],
    '001' AS [Vínculo Empregatício],
    '1' AS [Tipo de Admissão para o eSocial]
FROM PFUNC