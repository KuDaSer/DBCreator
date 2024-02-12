USE [master]
GO

CREATE DATABASE [MedSoft]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'MedSoft', FILENAME = N'F:\Diploma\Data Base\MedSoft.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'MedSoft_log', FILENAME = N'F:\Diploma\Data Base\MedSoft_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

USE [MedSoft]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE CreateDbObject
	@Object_Type nvarchar(25), -- ������� ��� ���� ��� ������......
	@Object_Name nvarchar(100), -- �������� ������� ��� ���� ��� ������
	@Object_params nvarchar(max), -- ������� ��������� (ID int � ��.)
	@Key nvarchar(100) -- 
	
AS
BEGIN
	declare @SQL 			nvarchar(max)
	declare @SQL_key 			nvarchar(max)
	declare @SQL_Ind 			nvarchar(150)
	declare @Result 			int

		-- ���������� �������
	IF @Object_Type = 'TABLE'
	BEGIN
		-- �������� �� ������� ������� � ����
		IF OBJECT_ID (@Object_Name) is null
		Begin
			Select @SQL = 'CREATE TABLE ' + @Object_Name + ' (' + @Object_params

			IF @Key != ''
			Begin
				Select @SQL_key = ', CONSTRAINT [PK_' + @Object_Name + '] PRIMARY KEY CLUSTERED ([' + @Key + '] ASC) ' +
								  'WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ' +
								  'ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]'
				Select @SQL = @SQL + @SQL_key
			end

			Select @SQL = @SQL + ') ON [PRIMARY]'

			exec (@SQL)
		end
	END
	ElSE
	-- ���������� �������
		IF @Object_Type = 'COLUMN'
		Begin
			declare @Column_Name	nvarchar(150)

			SELECT @Column_Name = SUBSTRING(@Object_params,1,CHARINDEX(' ', @Object_params) - 1)

				-- �������� �� ������� ������� � �������
			SELECT @Result = COUNT(object_id) FROM sys.all_columns
			WHERE name = @Column_Name AND object_id = OBJECT_ID(@Object_Name)

			IF @Result = 0
			Begin
				Select @SQL = 'ALTER TABLE ' + @Object_Name + ' ADD ' + @Object_params 
				exec (@SQL)
			end
		end

	ElSE
		-- ���������� �������
		IF @Object_Type = 'INDEX'
		Begin
			Select @SQL_Ind = 'IDX_' + @Object_Name + '_' + @Object_params

			-- �������� �� ������� �������
			SELECT @Result = COUNT(object_id) FROM sys.indexes WHERE name = @SQL_Ind
			
			IF @Result = 0
			Begin
				Select @SQL = 'CREATE INDEX ' + @SQL_Ind + ' ON ' + @Object_Name + ' (' + @Object_params + ')'
				exec (@SQL)
			end
		end

	ELSE
		-- ���������� �������
		IF @Object_Type = 'RULE'
		Begin
			-- �������� �� ������� �������
			SELECT @Result =  Count(OBJECT_ID) from sys.all_objects where name = @Object_Name
			
			IF @Result = 0
			Begin
				Select @SQL = 'CREATE RULE ' + @Object_Name + ' as ' + @Object_params
				exec (@SQL)
			end
		end

	ELSE
		-- ���������� �������� �� ���������
		IF @Object_Type = 'DEFAULT'
		Begin
			-- �������� �� ������� �������� �� ���������
			SELECT @Result =  Count(OBJECT_ID) from sys.all_objects where name = @Object_Name
			
			IF @Result = 0
			Begin
				Select @SQL = 'CREATE DEFAULT ' + @Object_Name + ' AS ' + @Object_params
				exec (@SQL)
			end
		end

	ELSE
		-- ���������� ����
		IF @Object_Type = 'TYPE'
		Begin
			-- �������� �� ������� ����
			SELECT @Result =  Count(system_type_id) from sys.types where is_user_defined = 1 and name = @Object_Name
			
			IF @Result = 0
			Begin
				Select @SQL = 'CREATE TYPE ' + @Object_Name + ' FROM ' + @Object_params
				exec (@SQL)
			end
		end


END
GO
