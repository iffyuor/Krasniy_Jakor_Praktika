USE ProductionVeneer;
GO

-- =====================================================
-- ЗАПОЛНЕНИЕ БД - ВСЕГО 1600 ЗАПИСЕЙ СУММАРНО
-- (без TRUNCATE, только INSERT)
-- =====================================================

-- =====================================================
-- 1. Справочники (удаляем старые данные, если есть)
-- =====================================================
DELETE FROM ProductionFlow;
DELETE FROM StockBalance;
DELETE FROM FinishedBatch;
DELETE FROM SemiFinishedBatch;
DELETE FROM VeneerBatch;
DELETE FROM LogBatch;
DELETE FROM AppUser;
DELETE FROM Employee;
DELETE FROM Supplier;
DELETE FROM DefectType;
DELETE FROM ProductGrade;
DELETE FROM TimberType;
DELETE FROM Unit;
DELETE FROM Role;

-- Role
INSERT INTO Role (RoleName) VALUES ('Admin'), ('Technologist'), ('Operator'), ('Storekeeper');

-- Unit
INSERT INTO Unit (UnitName, ShortName) VALUES ('Кубический метр', 'м³'), ('Лист', 'шт');

-- TimberType
INSERT INTO TimberType (TypeName, Description) VALUES 
('Берёза', 'Берёзовая древесина'),
('Ольха', 'Ольховая древесина'),
('Сосна', 'Хвойная древесина');

-- ProductGrade
INSERT INTO ProductGrade (GradeName, GradeDescription) VALUES 
('E', 'Элитный сорт'), ('I', 'Первый сорт'), ('II', 'Второй сорт'), ('III', 'Третий сорт'), ('IV', 'Четвёртый сорт');

-- DefectType
INSERT INTO DefectType (DefectName, SeverityLevel) VALUES 
('Трещина', 2), ('Коробление', 1), ('Пузыри', 2), ('Скол', 3), ('Сучок', 3), ('Гниль', 1),
('Неровная кромка', 3), ('Неравномерная толщина', 2), ('Отслоение', 1), ('Непроклей', 1);

-- Supplier
INSERT INTO Supplier (SupplierName, ContactPerson, Phone, Email) VALUES 
('ЛесПром', 'Иванов И.И.', '+7(912)123-45-67', 'lesprom@mail.ru'),
('ДревСнаб', 'Петров П.П.', '+7(912)234-56-78', 'drevsnab@mail.ru'),
('ЛесХоз', 'Сидоров С.С.', '+7(912)345-67-89', 'leshoz@mail.ru'),
('ЛесТорг', 'Волков В.В.', '+7(912)456-78-90', 'tor@mail.ru'),
('СеверЛес', 'Медведев М.М.', '+7(912)567-89-01', 'sever@mail.ru');

-- Employee
INSERT INTO Employee (FullName, Position, Phone, Email) VALUES 
('Администраторов А.А.', 'Администратор', '+7(901)111-11-11', 'admin@veneer.ru'),
('Технологов Т.Т.', 'Технолог', '+7(901)222-22-22', 'tech@veneer.ru'),
('Операторов О.О.', 'Оператор', '+7(901)333-33-33', 'oper@veneer.ru'),
('Кладовщиков К.К.', 'Кладовщик', '+7(901)444-44-44', 'store@veneer.ru'),
('Петров П.П.', 'Оператор', '+7(901)555-55-55', 'petrov@veneer.ru'),
('Сидоров С.С.', 'Технолог', '+7(901)666-66-66', 'sidorov@veneer.ru');

-- AppUser
INSERT INTO AppUser (EmployeeID, RoleID, Login, PasswordHash, IsActive, CreatedDate) VALUES 
(1, 1, 'admin', HASHBYTES('SHA2_256', 'admin123'), 1, GETDATE()),
(2, 2, 'tech', HASHBYTES('SHA2_256', 'tech123'), 1, GETDATE()),
(3, 3, 'operator1', HASHBYTES('SHA2_256', 'oper123'), 1, GETDATE()),
(4, 4, 'store1', HASHBYTES('SHA2_256', 'store123'), 1, GETDATE()),
(5, 3, 'operator2', HASHBYTES('SHA2_256', 'oper456'), 1, GETDATE()),
(6, 2, 'tech2', HASHBYTES('SHA2_256', 'tech456'), 1, GETDATE());

-- =====================================================
-- 2. LogBatch (брёвна) - 250 записей
-- =====================================================
DECLARE @i INT = 1;
WHILE @i <= 250
BEGIN
    INSERT INTO LogBatch (BatchNumber, SupplierID, TimberTypeID, UnitID, QuantityReceived, QualityClass, ReceiptDate, DefectTypeID, DefectQuantity, Status, Notes)
    VALUES (
        N'БРЕВНО-' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        1 + (@i % 5),
        1 + (@i % 3),
        1,
        15 + (@i % 50),
        1 + (@i % 3),
        DATEADD(DAY, -(@i % 365), GETDATE()),
        CASE WHEN @i % 7 = 0 THEN 1 + (@i % 10) ELSE NULL END,
        CASE WHEN @i % 7 = 0 THEN (15 + (@i % 50)) * 0.05 ELSE 0 END,
        CASE WHEN DATEADD(DAY, -(@i % 365), GETDATE()) < DATEADD(DAY, -60, GETDATE()) THEN 'Переработано' ELSE 'На складе' END,
        N'Поставка №' + CAST(@i AS VARCHAR)
    );
    SET @i = @i + 1;
END;

-- =====================================================
-- 3. VeneerBatch (шпон) - 300 записей
-- =====================================================
SET @i = 1;
DECLARE @LogCount INT = (SELECT COUNT(*) FROM LogBatch);

WHILE @i <= 300
BEGIN
    INSERT INTO VeneerBatch (BatchNumber, LogBatchID, UnitID, Thickness_mm, SheetsProduced, ProductionDate, DefectTypeID, DefectQuantity, OperatorID, Status, Notes)
    VALUES (
        N'ШПОН-' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        1 + (@i % @LogCount),
        2,
        CASE @i % 5 WHEN 0 THEN 0.8 WHEN 1 THEN 1.0 WHEN 2 THEN 1.2 WHEN 3 THEN 1.5 ELSE 2.0 END,
        300 + (@i % 500),
        DATEADD(DAY, -(@i % 300), GETDATE()),
        CASE WHEN @i % 8 = 0 THEN 1 + (@i % 10) ELSE NULL END,
        CASE WHEN @i % 8 = 0 THEN 10 + (@i % 50) ELSE 0 END,
        1 + (@i % 5),
        CASE WHEN DATEADD(DAY, -(@i % 300), GETDATE()) < DATEADD(DAY, -30, GETDATE()) THEN 'Использован' ELSE 'Произведён' END,
        N'Толщина: ' + CAST(CASE @i % 5 WHEN 0 THEN 0.8 WHEN 1 THEN 1.0 WHEN 2 THEN 1.2 WHEN 3 THEN 1.5 ELSE 2.0 END AS VARCHAR) + N'мм'
    );
    SET @i = @i + 1;
END;

-- =====================================================
-- 4. SemiFinishedBatch (полуфабрикат) - 400 записей
-- =====================================================
SET @i = 1;
DECLARE @VeneerCount INT = (SELECT COUNT(*) FROM VeneerBatch);

WHILE @i <= 400
BEGIN
    INSERT INTO SemiFinishedBatch (BatchNumber, VeneerBatchID, UnitID, PressingDateTime, LayersCount, GlueType, Pressure_atm, Temperature_C, SheetsProduced, DefectTypeID, DefectQuantity, OperatorID, Status, Notes)
    VALUES (
        N'ПОЛУ-' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        1 + (@i % @VeneerCount),
        2,
        DATEADD(DAY, -(@i % 200), GETDATE()),
        3 + (@i % 12),
        CASE @i % 3 WHEN 0 THEN N'СФК' WHEN 1 THEN N'КФ-Ж' ELSE N'МУФ' END,
        8 + (@i % 7),
        110 + (@i % 40),
        250 + (@i % 400),
        CASE WHEN @i % 6 = 0 THEN 1 + (@i % 10) ELSE NULL END,
        CASE WHEN @i % 6 = 0 THEN 5 + (@i % 60) ELSE 0 END,
        1 + (@i % 5),
        CASE WHEN @i % 6 = 0 THEN 'Брак' ELSE 'Готов' END,
        N'Слоёв: ' + CAST(3 + (@i % 12) AS VARCHAR)
    );
    SET @i = @i + 1;
END;

-- =====================================================
-- 5. FinishedBatch (готовая фанера) - 500 записей
-- =====================================================
SET @i = 1;
DECLARE @SemiCount INT = (SELECT COUNT(*) FROM SemiFinishedBatch);

WHILE @i <= 500
BEGIN
    DECLARE @HasDefect BIT = CASE WHEN @i % 5 = 0 THEN 1 ELSE 0 END;
    DECLARE @ProcessDate DATETIME = DATEADD(DAY, -(@i % 150), GETDATE());
    
    INSERT INTO FinishedBatch (BatchNumber, SemiFinishedID, GradeID, UnitID, ProcessingDateTime, SandingType, FinalThickness_mm, SheetsProduced, DefectTypeID, DefectQuantity, ShippingDate, Customer, Status, Notes)
    VALUES (
        N'ФАНЕРА-' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        1 + (@i % @SemiCount),
        CASE WHEN @HasDefect = 1 THEN 3 + (@i % 3) WHEN @i % 10 = 0 THEN 1 WHEN @i % 10 <= 3 THEN 2 WHEN @i % 10 <= 7 THEN 3 ELSE 4 END,
        2,
        @ProcessDate,
        CASE @i % 3 WHEN 0 THEN N'Мелкая' WHEN 1 THEN N'Средняя' ELSE N'Крупная' END,
        CASE @i % 5 WHEN 0 THEN 4 WHEN 1 THEN 6 WHEN 2 THEN 9 WHEN 3 THEN 12 ELSE 15 END,
        200 + (@i % 300),
        CASE WHEN @HasDefect = 1 THEN 1 + (@i % 10) ELSE NULL END,
        CASE WHEN @HasDefect = 1 THEN 3 + (@i % 40) ELSE 0 END,
        CASE WHEN @ProcessDate < DATEADD(DAY, -20, GETDATE()) AND @HasDefect = 0 THEN DATEADD(DAY, -(@i % 19), @ProcessDate) ELSE NULL END,
        CASE @i % 5 WHEN 0 THEN N'ООО "МебельПром"' WHEN 1 THEN N'ИП "СтройМастер"' WHEN 2 THEN N'ООО "ТараПлюс"' ELSE N'АО "ДомСтрой"' END,
        CASE 
            WHEN @ProcessDate < DATEADD(DAY, -20, GETDATE()) AND @HasDefect = 0 THEN 'Отгружена'
            WHEN @HasDefect = 1 THEN 'Брак'
            ELSE 'На складе'
        END,
        N'Готовая фанера'
    );
    SET @i = @i + 1;
END;

-- =====================================================
-- 6. StockBalance (остатки) - 100 записей
-- =====================================================
INSERT INTO StockBalance (BatchType, BatchID, Quantity, UnitID, Status, LastUpdated)
SELECT TOP 50 'LogBatch', LogBatchID, QuantityReceived - ISNULL(DefectQuantity, 0), 1, 'На складе', GETDATE()
FROM LogBatch WHERE Status = 'На складе' AND (QuantityReceived - ISNULL(DefectQuantity, 0)) > 0;

INSERT INTO StockBalance (BatchType, BatchID, Quantity, UnitID, Status, LastUpdated)
SELECT TOP 50 'FinishedBatch', FinishedID, SheetsProduced - ISNULL(DefectQuantity, 0), 2, 'На складе', GETDATE()
FROM FinishedBatch WHERE Status = 'На складе' AND (SheetsProduced - ISNULL(DefectQuantity, 0)) > 0;

-- =====================================================
-- 7. ProductionFlow (движение) - 50 записей
-- =====================================================
INSERT INTO ProductionFlow (FromBatchType, FromBatchID, ToBatchType, ToBatchID, TransferDate, QuantityTransferred, AuthorizedBy, Notes)
SELECT TOP 50 'LogBatch', LogBatchID, 'VeneerBatch', VeneerBatchID, ProductionDate, SheetsProduced - ISNULL(DefectQuantity, 0), 3, N'Переработка'
FROM VeneerBatch WHERE LogBatchID IS NOT NULL;

-- =====================================================
-- ИТОГО: 250 + 300 + 400 + 500 + 100 + 50 = 1600 записей
-- =====================================================