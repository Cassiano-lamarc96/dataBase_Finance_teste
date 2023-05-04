
DROP TABLE IF EXISTS tbParcela ;
DROP TABLE IF EXISTS tbFinanciamento ;
DROP TABLE IF EXISTS tbCliente;

CREATE TABLE tbCliente (
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) NOT NULL PRIMARY KEY,
    uf VARCHAR(2) NOT NULL,
    celular VARCHAR(15) NOT NULL
)


CREATE TABLE tbFinanciamento (
    id INT IDENTITY(1,1) PRIMARY KEY,
    cpf VARCHAR(11) NOT NULL,
    tipoFinanciamento VARCHAR(50) NOT NULL,
    valorTotal DECIMAL(18,2) NOT NULL,
    dataUltimoVencimento DATE NOT NULL,
    CONSTRAINT FK_Financiamento_tbCliente FOREIGN KEY (cpf) REFERENCES tbCliente (cpf)
)

CREATE TABLE tbParcela (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idFinanciamento INT NOT NULL,
    numeroParcela INT NOT NULL,
    valorParcela DECIMAL(18,2) NOT NULL,
    dataVencimento DATE NOT NULL,
    dataPagamento DATE NULL,
    CONSTRAINT FK_Parcela_Financiamento FOREIGN KEY (idFinanciamento) REFERENCES tbFinanciamento (id)
)


INSERT INTO tbCliente (nome, cpf, uf, celular) VALUES
    ('Cassiano Lamarc', '12345678901', 'SP', '(11)99999-9999'),
    ('Lima de Oliveira', '23456789012', 'RJ', '(21)95454-8888'),
    ('Arias Cano Ganso', '34567890123', 'MG', '(31)96666-7777')

INSERT INTO tbFinanciamento (cpf, tipoFinanciamento, valorTotal, dataUltimoVencimento) VALUES
    ('12345678901', 'Casa', 48569.00, '2028-02-05'),
    ('23456789012', 'PF', 22123.00, '2024-11-12'),
    ('34567890123', 'Carro', 15000.00, '2024-03-02')	

INSERT INTO tbParcela (idFinanciamento, numeroParcela, valorParcela, dataVencimento, dataPagamento) VALUES
    (1, 1, 1000.00, '2022-07-31', '2022-07-15'),
    (1, 2, 1000.00, '2022-08-31', '2022-08-20'),
    (1, 3, 1000.00, '2022-09-30', NULL),
    (2, 1, 500.00, '2023-01-31', '2023-01-25'),
    (2, 2, 500.00, '2023-02-28', '2023-02-20'),
    (2, 3, 500.00, '2023-03-31', '2023-03-31'),
    (3, 1, 1000.00, '2024-03-31', NULL),
    (3, 2, 1000.00, '2024-04-30', NULL),
    (3, 3, 1000.00, '2024-05-31', NULL);

--Listar todos os clientes do estado de SP que possuem mais de 60% das parcelas pagas
SELECT 
	c.Nome, 
	c.CPF, 
	c.UF, 
	c.Celular
FROM 
	tbCliente c
JOIN 
	tbFinanciamento f ON c.CPF = f.CPF
JOIN (
    SELECT 
		IdFinanciamento, 
		COUNT(*) AS NumParcelasPagas
    FROM 
		tbParcela
    WHERE 
		DataPagamento IS NOT NULL
    GROUP BY 
		IdFinanciamento
) pPaga ON f.id = pPaga.IdFinanciamento
JOIN (
    SELECT 
		IdFinanciamento, 
		COUNT(*) AS NumParcelas
    FROM 
		tbParcela
    GROUP BY 
		IdFinanciamento
) pTotais ON f.id = pTotais.IdFinanciamento
WHERE 
	c.UF = 'SP'  
and 
	CAST(pPaga.NumParcelasPagas AS FLOAT) / CAST(pTotais.NumParcelas AS FLOAT) >= 0.6

--Listar os primeiros quatro clientes que possuem alguma parcela com mais de cinco dia sem atraso (Data Vencimento maior que data atual E data pagamento nula);
--Obs.: Eu acho que a questão era pra listar como mais de cinco dias em atraso (data atual maior que data de vencimento), ou talvez eu não entendi exatamente;
SELECT 
	DISTINCT
	TOP 4 
	c.nome, 
	c.cpf, 
	c.uf, 
	c.celular
FROM 
	tbCliente c
JOIN 
	tbFinanciamento f ON c.CPF = f.CPF
JOIN 
	tbParcela p ON f.id = p.idFinanciamento
WHERE 
	p.DataVencimento > GETDATE() AND p.DataPagamento IS NULL AND DATEDIFF(day, GETDATE(), p.DataVencimento) > 5



	
	
