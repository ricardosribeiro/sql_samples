--O operador APPLY surgiu no SQL Server 2005, e permite a combina��o de duas tabelas, de forma muito semelhante ao operador JOIN. 
--A query chamada pelo operador APPLY � executada para cada linha da tabela referenciada, que foi previamente declarada na query principal.
--Como voc� deve ter imaginado, a query que trata a tabela referenciada � executada primeiro, e s� ent�o a query do operador APPLY � executada 
--para cada linha resultante da query da tabela referenciada. 
--O resultado final contem todas as colunas selecionadas na query principal, seguida de todas as colunas selecionadas na query do operador APPLY.
--O operador APPLY permite a execu��o de uma query para cada linha retornada pela query associada a ela. Para isso, associamos o APPLY com as colunas da query principal.
--O operador APPLY tem duas varia��es: 
	--CROSS APPLY: a query da tabela referenciada s� retorna linhas que correspondam ao resultado da query do operador APPLY.  
	--OUTER APPLY: a query da tabela referenciada retorna todas as linhas, inclusive aquelas que n�o correspondam ao resultado 
	--da query do operador APPLY. As colunas da query do operador APPLY ser�o exibidas com NULL no resultado final da query, se mencionadas. 
--A pergunta agora �: se eu consigo o mesmo resultado usando o operador JOIN, porque e quando devo usar o operador APPLY? 
--Embora o mesmo resultado possa ser alcan�ado com JOIN, utilizamos o APPLY quando temos uma express�o de valor de tabela na parte direita da query. 
--E, em alguns casos, o uso do operador APPLY pode aumentar o desempenho da consulta. Vamos ver alguns exemplos.
--Para come�ar, vamos criar duas tabelas: Aula e Aluno. Cada aluno est� alocado em uma aula, e isso � garantido pelo relacionamento entre as tabelas.


CREATE DATABASE Treinamento
GO

USE Treinamento
GO

IF object_id('Aluno') IS NOT NULL
BEGIN
   DROP TABLE Aluno
END
GO

IF object_id('Aula') IS NOT NULL BEGIN
   DROP TABLE Aula
END

CREATE TABLE Aula
  (Id [int] NOT NULL PRIMARY KEY,
   NomeAula VARCHAR(250) NOT NULL)
GO

INSERT Aula (Id, NomeAula) VALUES (1, N'Portugu�s')
INSERT Aula (Id, NomeAula) VALUES (2, N'Ingl�s')
INSERT Aula (Id, NomeAula) VALUES (3, N'Espanhol')
INSERT Aula (Id, NomeAula) VALUES (4, N'Italiano')
INSERT Aula (Id, NomeAula) VALUES (5, N'Alem�o')
GO

CREATE TABLE Aluno
  (Id [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
   NomeAluno VARCHAR(50) NOT NULL,
   AulaId [int] NOT NULL REFERENCES Aula(Id))
GO

INSERT Aluno (NomeAluno, AulaId) VALUES ('Ana Maria Figueiredo', 1)
INSERT Aluno (NomeAluno, AulaId) VALUES ('Jo�o de Carvalho', 2)
INSERT Aluno (NomeAluno, AulaId) VALUES ('Maria Luiza de Souza', 3)
INSERT Aluno (NomeAluno, AulaId) VALUES ('Paulo Cesar de Oliveira',3)
GO

SELECT * FROM Aluno
SELECT * FROM Aula
GO

-- EXEMPLO 01

-- A primeira query � executada em duas etapas, no entanto os planos de execu��o s�o iguais.
-- para este exemplo o uso do CROSS APPLY tem o mesmo resultado do uso do inner join
SELECT * FROM Aula
CROSS APPLY (SELECT * FROM Aluno WHERE Aluno.AulaId = Aula.Id) AS AulasAluno

SELECT * FROM Aula
INNER JOIN Aluno ON Aluno.AulaId = Aula.Id

-- Exemplo 02
-- Nesse exemplo a consulta com APPLY usou um operador COMPUTE SCALAR antes do operador NESTED LOOPS avaliar e produzir o resultado final
SELECT * FROM Aula
OUTER APPLY (SELECT * FROM Aluno WHERE Aluno.AulaId = Aula.Id) AS AulasAluno

SELECT * FROM Aula
LEFT JOIN Aluno ON Aluno.AulaId = Aula.Id

-- Inser��o de massa para mais testes
INSERT Aluno (NomeAluno, AulaId) VALUES ('Carine Liberato', 1) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Carlota Outeiro', 2) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Cleiton Trindade', 3) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Danilo Paraguai', 4) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Danilo Sanches', 5) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Deolinda Sesimbra', 5) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Diodete Sacadura', 5) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Epaminondas Gir�o', 5) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Gualdim Farias', 5) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Helena Lustosa', 4) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Iara Estrella', 4) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Isaque Amaral', 4) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Leonidas Sequera', 4) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Mariano Capucho', 3) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Maura Nunes', 3) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Monica Garces', 3) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Romano Grangeia', 2) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Rosalina Rabello', 2) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Silverio Carvalhal', 1) 
INSERT Aluno (NomeAluno, AulaId) VALUES ('Valentim SantAnna', 1)
INSERT Aluno (NomeAluno, AulaId) VALUES ('Joao da Silva', 2)  


-- Exemplo 03
-- Retorna lista de aulas e quantidade de alunos, desde que a Aula tenha mais de 4 alunos.
-- Oberver que neste exemplo, o OUTER APPLY n�o teve o mesmo resultado que o INNER JOIN, porque na query com 
-- OUTER APPLY em primeiro lugar s�o selecionados os registros da tabela aula e somente depois a segunda consulta � executada.
-- para obter um resultado equivalente, nesse caso seria necess�rio usar o CROSS APPLY.
SELECT * FROM Aula 
OUTER APPLY (SELECT AulaId, COUNT(*) AS QtdeAlunos
				FROM Aluno
				WHERE Aluno.AulaId = Aula.Id
				GROUP BY AulaId
				HAVING COUNT(*)>4) AS AulasAluno

SELECT Aula.Id, Aula.NomeAula, Aluno.AulaId, COUNT(*) AS QteAlunos
	FROM Aula
	LEFT JOIN Aluno ON Aula.Id = Aluno.AulaId
GROUP BY Aula.Id, Aula.NomeAula, Aluno.AulaId
HAVING COUNT(*) > 4


