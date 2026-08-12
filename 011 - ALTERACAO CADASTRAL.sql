SELECT
    RIGHT('00' + CAST(PFUNC.CODCOLIGADA AS VARCHAR), 2) + RIGHT('00' + CAST(PFUNC.CODFILIAL AS VARCHAR), 2) AS [Código da Unidade, cfe. Tabela de Unidades],
	CAST(PFUNC.CODCOLIGADA AS VARCHAR) + RIGHT(PFUNC.CHAPA, 8 - LEN(CAST(PFUNC.CODCOLIGADA AS VARCHAR))) AS [Código do Contrato],
    FORMAT(PFUNC.DTTRANSFERENCIA, 'dd/MM/yyyy') AS [Data da Alteração],
    'CCON' AS [Variável], --CCON – Código do Contrato
    'CCON' AS [Novo Código, cfe. Variável acima],
    CAST(
        PFUNC.CODCOLIGADA AS VARCHAR) + RIGHT(PFUNC.CHAPA, 8 - LEN(CAST(PFUNC.CODCOLIGADA AS VARCHAR))
    ) AS [Novo Conteúdo. Descrição do Novo Código na época da alteração. Caso não seja informada, será gravada a atual.],
    'CCON' AS [Código Antigo, cfe. Variável acima. OBS. Campo obrigatório nas conversões para o Darwin.],
    CAST(
        PFUNC.COLIGADAANTERIORTRANSF AS VARCHAR) + RIGHT(PFUNC.CHAPAANTERIORTRANSF, 8 - LEN(CAST(PFUNC.COLIGADAANTERIORTRANSF AS VARCHAR))
    ) AS [Conteúdo Antigo. Descrição do Código Antigo na época da alteração]
FROM PFUNC
WHERE PFUNC.CHAPAANTERIORTRANSF IS NOT NULL