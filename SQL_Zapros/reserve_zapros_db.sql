-- =====================================================
-- БАЗА ДАННЫХ: ProductionVeneer
-- ПОЛНАЯ ВЕРСИЯ СО ВСЕМИ ТАБЛИЦАМИ И ДАННЫМИ
-- =====================================================

-- Создаём базу данных
CREATE DATABASE ProductionVeneer;
GO

USE ProductionVeneer;
GO

-- =====================================================
-- 1. ОСНОВНЫЕ ТАБЛИЦЫ
-- =====================================================

-- Роли
CREATE TABLE Role (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(30) NOT NULL UNIQUE
);

-- Единицы измерения
CREATE TABLE Unit (
    UnitID INT IDENTITY(1,1) PRIMARY KEY,
    UnitName NVARCHAR(20) NOT NULL UNIQUE,
    ShortName NVARCHAR(10) NOT NULL
);

-- Виды древесины
CREATE TABLE TimberType (
    TimberTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(20) NOT NULL UNIQUE,
    Description NVARCHAR(100) NULL
);

-- Сорта продукции
CREATE TABLE ProductGrade (
    GradeID INT IDENTITY(1,1) PRIMARY KEY,
    GradeName NVARCHAR(10) NOT NULL UNIQUE,
    GradeDescription NVARCHAR(200) NULL
);

-- Виды брака
CREATE TABLE DefectType (
    DefectTypeID INT IDENTITY(1,1) PRIMARY KEY,
    DefectName NVARCHAR(100) NOT NULL,
    SeverityLevel INT DEFAULT 1
);

-- Марки клея
CREATE TABLE GlueBrand (
    GlueBrandID INT IDENTITY(1,1) PRIMARY KEY,
    BrandName NVARCHAR(50) NOT NULL
);

-- Поставщики
CREATE TABLE Supplier (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(100) NOT NULL,
    ContactPerson NVARCHAR(100) NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL
);

-- Сотрудники
CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    Position NVARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL
);

-- Пользователи
CREATE TABLE AppUser (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    RoleID INT NOT NULL,
    Login VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    FullName NVARCHAR(150) NULL,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
);

-- =====================================================
-- 2. ПРОИЗВОДСТВЕННЫЕ ТАБЛИЦЫ
-- =====================================================

-- Брёвна
CREATE TABLE LogBatch (
    LogBatchID INT IDENTITY(1,1) PRIMARY KEY,
    BatchNumber NVARCHAR(50) NOT NULL UNIQUE,
    SupplierID INT NOT NULL,
    TimberTypeID INT NOT NULL,
    UnitID INT NOT NULL,
    QuantityReceived DECIMAL(10,2) NOT NULL,
    QualityClass INT NULL,
    ReceiptDate DATE NOT NULL,
    DefectTypeID INT NULL,
    DefectQuantity DECIMAL(10,2) NULL DEFAULT 0,
    Status NVARCHAR(50) DEFAULT 'На складе',
    Notes NVARCHAR(500) NULL,
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID),
    FOREIGN KEY (TimberTypeID) REFERENCES TimberType(TimberTypeID),
    FOREIGN KEY (UnitID) REFERENCES Unit(UnitID),
    FOREIGN KEY (DefectTypeID) REFERENCES DefectType(DefectTypeID)
);

-- Шпон
CREATE TABLE VeneerBatch (
    VeneerBatchID INT IDENTITY(1,1) PRIMARY KEY,
    BatchNumber NVARCHAR(50) NOT NULL UNIQUE,
    LogBatchID INT NOT NULL,
    UnitID INT NOT NULL,
    Thickness_mm DECIMAL(5,2) NOT NULL,
    SheetsProduced INT NOT NULL,
    ProductionDate DATETIME NOT NULL,
    DefectTypeID INT NULL,
    DefectQuantity INT NULL DEFAULT 0,
    OperatorID INT NULL,
    Status NVARCHAR(50) DEFAULT 'На складе',
    Notes NVARCHAR(500) NULL,
    FOREIGN KEY (LogBatchID) REFERENCES LogBatch(LogBatchID),
    FOREIGN KEY (UnitID) REFERENCES Unit(UnitID),
    FOREIGN KEY (DefectTypeID) REFERENCES DefectType(DefectTypeID),
    FOREIGN KEY (OperatorID) REFERENCES Employee(EmployeeID)
);

-- Полуфабрикат
CREATE TABLE SemiFinishedBatch (
    SemiFinishedID INT IDENTITY(1,1) PRIMARY KEY,
    BatchNumber NVARCHAR(50) NOT NULL UNIQUE,
    VeneerBatchID INT NOT NULL,
    UnitID INT NOT NULL,
    PressingDateTime DATETIME NOT NULL,
    LayersCount INT NOT NULL,
    GlueType NVARCHAR(50) NOT NULL,
    Pressure_atm DECIMAL(5,2) NOT NULL,
    Temperature_C INT NOT NULL,
    SheetsProduced INT NOT NULL,
    DefectTypeID INT NULL,
    DefectQuantity INT NULL DEFAULT 0,
    OperatorID INT NULL,
    Status NVARCHAR(50) DEFAULT 'На складе',
    Notes NVARCHAR(500) NULL,
    FOREIGN KEY (VeneerBatchID) REFERENCES VeneerBatch(VeneerBatchID),
    FOREIGN KEY (UnitID) REFERENCES Unit(UnitID),
    FOREIGN KEY (DefectTypeID) REFERENCES DefectType(DefectTypeID),
    FOREIGN KEY (OperatorID) REFERENCES Employee(EmployeeID)
);

-- Готовая фанера
CREATE TABLE FinishedBatch (
    FinishedID INT IDENTITY(1,1) PRIMARY KEY,
    BatchNumber NVARCHAR(50) NOT NULL UNIQUE,
    SemiFinishedID INT NOT NULL,
    GradeID INT NOT NULL,
    UnitID INT NOT NULL,
    ProcessingDateTime DATETIME NOT NULL,
    SandingType NVARCHAR(50) NULL,
    FinalThickness_mm DECIMAL(5,2) NOT NULL,
    SheetsProduced INT NOT NULL,
    DefectTypeID INT NULL,
    DefectQuantity INT NULL DEFAULT 0,
    ShippingDate DATE NULL,
    Customer NVARCHAR(200) NULL,
    Status NVARCHAR(50) DEFAULT 'На складе',
    Notes NVARCHAR(500) NULL,
    FOREIGN KEY (SemiFinishedID) REFERENCES SemiFinishedBatch(SemiFinishedID),
    FOREIGN KEY (GradeID) REFERENCES ProductGrade(GradeID),
    FOREIGN KEY (UnitID) REFERENCES Unit(UnitID),
    FOREIGN KEY (DefectTypeID) REFERENCES DefectType(DefectTypeID)
);

-- =====================================================
-- 3. ОБОРУДОВАНИЕ
-- =====================================================

CREATE TABLE Equipment (
    EquipmentID INT IDENTITY(1,1) PRIMARY KEY,
    EquipmentName NVARCHAR(100) NOT NULL,
    WorkshopID INT NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Работает',
    LastCheckDate DATETIME NULL,
    ProblemDescription NVARCHAR(500) NULL
);

-- =====================================================
-- 4. ПЛАН ПРОИЗВОДСТВА
-- =====================================================

CREATE TABLE ProductionPlan (
    PlanID INT IDENTITY(1,1) PRIMARY KEY,
    TargetVeneerSheets INT DEFAULT 0,
    TargetSemiSheets INT DEFAULT 0,
    TargetFinishedSheets INT DEFAULT 0,
    PlanDate DATE DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

-- =====================================================
-- 5. ЖУРНАЛ ДВИЖЕНИЯ
-- =====================================================

CREATE TABLE ProductionFlow (
    FlowID INT IDENTITY(1,1) PRIMARY KEY,
    FromBatchType NVARCHAR(30) NOT NULL,
    FromBatchID INT NOT NULL,
    ToBatchType NVARCHAR(30) NOT NULL,
    ToBatchID INT NOT NULL,
    TransferDate DATETIME NOT NULL DEFAULT GETDATE(),
    QuantityTransferred DECIMAL(12,3) NOT NULL,
    AuthorizedBy INT NOT NULL,
    Notes NVARCHAR(500) NULL,
    FOREIGN KEY (AuthorizedBy) REFERENCES Employee(EmployeeID)
);

-- =====================================================
-- 6. ОСТАТКИ
-- =====================================================

CREATE TABLE StockBalance (
    StockID INT IDENTITY(1,1) PRIMARY KEY,
    BatchType NVARCHAR(30) NOT NULL,
    BatchID INT NOT NULL,
    Quantity DECIMAL(12,3) NOT NULL,
    UnitID INT NOT NULL,
    LastUpdated DATETIME NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(30) DEFAULT 'На складе',
    FOREIGN KEY (UnitID) REFERENCES Unit(UnitID)
);

-- =====================================================
-- 7. НАЧАЛЬНЫЕ ДАННЫЕ (СПРАВОЧНИКИ)
-- =====================================================

-- Роли
INSERT INTO Role (RoleName) VALUES ('Admin'), ('Technologist'), ('Operator'), ('Storekeeper');

-- Единицы измерения
INSERT INTO Unit (UnitName, ShortName) VALUES ('Кубический метр', 'м³'), ('Лист', 'шт');

-- Виды древесины
INSERT INTO TimberType (TypeName, Description) VALUES 
('Берёза', 'Берёзовая древесина, высокое качество'),
('Ольха', 'Ольховая древесина, среднее качество'),
('Сосна', 'Хвойная древесина, низкое качество');

-- Сорта продукции
INSERT INTO ProductGrade (GradeName, GradeDescription) VALUES 
('E', 'Элитный сорт, без дефектов'),
('I', 'Первый сорт, минимальные дефекты'),
('II', 'Второй сорт, допустимые дефекты'),
('III', 'Третий сорт, значительные дефекты'),
('IV', 'Четвёртый сорт, технические цели');

-- Виды брака
INSERT INTO DefectType (DefectName, SeverityLevel) VALUES 
('Трещина', 2),
('Коробление', 1),
('Пузыри', 2),
('Скол', 3),
('Сучок', 3),
('Гниль', 1),
('Неровная кромка', 3),
('Неравномерная толщина', 2),
('Отслоение', 1),
('Непроклей', 1),
('Пересушка', 2),
('Недосушка', 2),
('Заусенцы', 3),
('Механическое повреждение', 2),
('Пятна смолы', 3);

-- Марки клея
INSERT INTO GlueBrand (BrandName) VALUES ('СФК'), ('КФ-Ж'), ('МУФ'), ('ФР-12'), ('ЭКО-КЛЕЙ');

-- Поставщики
INSERT INTO Supplier (SupplierName, ContactPerson, Phone, Email) VALUES 
('ЛесПром', 'Иванов И.И.', '+7(912)123-45-67', 'lesprom@mail.ru'),
('ДревСнаб', 'Петров П.П.', '+7(912)234-56-78', 'drevsnab@mail.ru'),
('ЛесХоз', 'Сидоров С.С.', '+7(912)345-67-89', 'leshoz@mail.ru'),
('СеверЛес', 'Медведев М.М.', '+7(912)567-89-01', 'sever@mail.ru'),
('ВяткаЛес', 'Лебедев Л.Л.', '+7(912)901-23-45', 'vyatka@mail.ru'),
('ЛесТорг', 'Волков В.В.', '+7(912)456-78-90', 'tor@mail.ru'),
('УралДрев', 'Михайлов М.А.', '+7(912)789-01-23', 'ural@mail.ru'),
('СибирьЛес', 'Кузнецова К.И.', '+7(912)890-12-34', 'sibir@mail.ru'),
('ЛесРесурс', 'Новикова Н.Н.', '+7(912)012-34-56', 'resurs@mail.ru'),
('ДревПром', 'Морозов М.В.', '+7(912)123-56-78', 'drevprom@mail.ru');

-- Сотрудники
INSERT INTO Employee (FullName, Position, Phone, Email) VALUES 
('Администраторов А.А.', 'Администратор', '+7(901)111-11-11', 'admin@veneer.ru'),
('Технологов Т.Т.', 'Технолог', '+7(901)222-22-22', 'tech@veneer.ru'),
('Операторов О.О.', 'Оператор', '+7(901)333-33-33', 'oper@veneer.ru'),
('Кладовщиков К.К.', 'Кладовщик', '+7(901)444-44-44', 'store@veneer.ru'),
('Петров П.П.', 'Оператор', '+7(901)555-55-55', 'petrov@veneer.ru'),
('Сидоров С.С.', 'Технолог', '+7(901)666-66-66', 'sidorov@veneer.ru'),
('Кузнецов К.К.', 'Оператор', '+7(901)777-77-77', 'kuznetsov@veneer.ru'),
('Новикова Н.Н.', 'Инженер ОТК', '+7(901)888-88-88', 'novikova@veneer.ru');

-- Пользователи (пароль: admin123, tech123, oper123, store123)
INSERT INTO AppUser (EmployeeID, RoleID, Login, PasswordHash, FullName, IsActive) VALUES 
(1, 1, 'admin', 'admin123', 'Администраторов А.А.', 1),
(2, 2, 'tech', 'tech123', 'Технологов Т.Т.', 1),
(3, 3, 'operator1', 'oper123', 'Операторов О.О.', 1),
(4, 4, 'store1', 'store123', 'Кладовщиков К.К.', 1),
(5, 3, 'operator2', 'oper456', 'Петров П.П.', 1),
(6, 2, 'tech2', 'tech456', 'Сидоров С.С.', 1),
(7, 3, 'operator3', 'oper789', 'Кузнецов К.К.', 1);

-- =====================================================
-- 8. ОБОРУДОВАНИЕ (15 СТАНКОВ, 4 НЕ РАБОТАЮТ)
-- =====================================================

INSERT INTO Equipment (EquipmentName, WorkshopID, Status, ProblemDescription) VALUES 
-- Цех 1 (5 станков)
('Лущильный станок №1', 1, 'Работает', NULL),
('Лущильный станок №2', 1, 'Не работает', 'Замена ножей'),
('Сушильная камера №1', 1, 'Работает', NULL),
('Сушильная камера №2', 1, 'Работает', NULL),
('Транспортёр ленточный', 1, 'Не работает', 'Порван ремень'),
-- Цех 2 (5 станков)
('Нанесение клея', 2, 'Работает', NULL),
('Пресс горячий №1', 2, 'Работает', NULL),
('Пресс горячий №2', 2, 'Не работает', 'Перегрев'),
('Сборочный стол', 2, 'Работает', NULL),
('Рубильная машина', 2, 'Работает', NULL),
-- Цех 3 (5 станков)
('Шлифовальный станок №1', 3, 'Работает', NULL),
('Шлифовальный станок №2', 3, 'Работает', NULL),
('Обрезной станок', 3, 'Не работает', 'Затупились пилы'),
('Сортировочная линия', 3, 'Работает', NULL),
('Упаковочная машина', 3, 'Работает', NULL);

-- =====================================================
-- 9. ПЛАН ПРОИЗВОДСТВА
-- =====================================================

INSERT INTO ProductionPlan (TargetVeneerSheets, TargetSemiSheets, TargetFinishedSheets, PlanDate, IsActive)
VALUES (5000, 500, 480, GETDATE(), 1);

-- =====================================================
-- 10. ТЕСТОВЫЕ ДАННЫЕ (50 БРЁВЕН С РАЗНЫМИ СТАТУСАМИ)
-- =====================================================

-- Брёвна (50 штук с разными статусами)
DECLARE @i INT = 1;
WHILE @i <= 50
BEGIN
    DECLARE @status NVARCHAR(50) = CASE 
        WHEN @i <= 15 THEN 'На складе'
        WHEN @i <= 25 THEN 'В обработке'
        WHEN @i <= 35 THEN 'Обработано'
        ELSE 'На складе'
    END;
    
    INSERT INTO LogBatch (BatchNumber, SupplierID, TimberTypeID, UnitID, QuantityReceived, QualityClass, ReceiptDate, Status)
    VALUES (
        'БРЕВНО-' + RIGHT('00' + CAST(@i AS VARCHAR), 3),
        1 + (@i % 10),
        1 + (@i % 3),
        1,
        30 + (@i % 70),
        1 + (@i % 3),
        DATEADD(DAY, -@i, GETDATE()),
        @status
    );
    SET @i = @i + 1;
END;

-- Шпон (40 штук с разными статусами)
SET @i = 1;
WHILE @i <= 40
BEGIN
    DECLARE @veneerStatus NVARCHAR(50) = CASE 
        WHEN @i <= 10 THEN 'На складе'
        WHEN @i <= 20 THEN 'В обработке'
        WHEN @i <= 30 THEN 'Обработано'
        ELSE 'На складе'
    END;
    
    INSERT INTO VeneerBatch (BatchNumber, LogBatchID, UnitID, Thickness_mm, SheetsProduced, ProductionDate, OperatorID, Status)
    VALUES (
        'ШПОН-' + RIGHT('00' + CAST(@i AS VARCHAR), 3),
        1 + (@i % 50),
        2,
        1.2 + ((@i % 5) * 0.2),
        500 + (@i * 10),
        DATEADD(DAY, -@i, GETDATE()),
        3 + (@i % 5),
        @veneerStatus
    );
    SET @i = @i + 1;
END;

-- Полуфабрикат (30 штук с разными статусами)
SET @i = 1;
WHILE @i <= 30
BEGIN
    DECLARE @semiStatus NVARCHAR(50) = CASE 
        WHEN @i <= 8 THEN 'На складе'
        WHEN @i <= 16 THEN 'В обработке'
        WHEN @i <= 24 THEN 'Обработано'
        ELSE 'На складе'
    END;
    
    INSERT INTO SemiFinishedBatch (BatchNumber, VeneerBatchID, UnitID, PressingDateTime, LayersCount, GlueType, Pressure_atm, Temperature_C, SheetsProduced, OperatorID, Status)
    VALUES (
        'ПОЛУ-' + RIGHT('00' + CAST(@i AS VARCHAR), 3),
        1 + (@i % 40),
        2,
        DATEADD(DAY, -@i, GETDATE()),
        5 + (@i % 10),
        CASE @i % 5 WHEN 0 THEN 'СФК' WHEN 1 THEN 'КФ-Ж' WHEN 2 THEN 'МУФ' WHEN 3 THEN 'ФР-12' ELSE 'ЭКО-КЛЕЙ' END,
        10 + (@i % 6),
        120 + (@i % 40),
        400 + (@i * 8),
        3 + (@i % 5),
        @semiStatus
    );
    SET @i = @i + 1;
END;

-- Готовая фанера (25 штук с разными статусами)
SET @i = 1;
WHILE @i <= 25
BEGIN
    DECLARE @finishedStatus NVARCHAR(50) = CASE 
        WHEN @i <= 8 THEN 'На складе'
        WHEN @i <= 16 THEN 'Отгружена'
        ELSE 'На складе'
    END;
    
    DECLARE @customer NVARCHAR(200) = CASE 
        WHEN @i % 5 = 0 THEN 'ООО "МебельПром"'
        WHEN @i % 5 = 1 THEN 'ИП "СтройМастер"'
        WHEN @i % 5 = 2 THEN 'ООО "ТараПлюс"'
        WHEN @i % 5 = 3 THEN 'АО "ДомСтрой"'
        ELSE 'ЗАО "ФанераЭкспорт"'
    END;
    
    DECLARE @shippingDate DATE = CASE 
        WHEN @finishedStatus = 'Отгружена' THEN DATEADD(DAY, -(@i % 10), GETDATE())
        ELSE NULL
    END;
    
    INSERT INTO FinishedBatch (BatchNumber, SemiFinishedID, GradeID, UnitID, ProcessingDateTime, SandingType, FinalThickness_mm, SheetsProduced, ShippingDate, Customer, Status)
    VALUES (
        'ФАНЕРА-' + RIGHT('00' + CAST(@i AS VARCHAR), 3),
        1 + (@i % 30),
        1 + (@i % 5),
        2,
        DATEADD(DAY, -@i, GETDATE()),
        CASE @i % 3 WHEN 0 THEN 'Мелкая' WHEN 1 THEN 'Средняя' ELSE 'Крупная' END,
        4 + (@i % 12),
        350 + (@i * 5),
        @shippingDate,
        @customer,
        @finishedStatus
    );
    SET @i = @i + 1;
END;

-- =====================================================
-- 11. ЖУРНАЛ ДВИЖЕНИЯ (ЗАПИСИ О ПЕРЕДАЧАХ)
-- =====================================================

INSERT INTO ProductionFlow (FromBatchType, FromBatchID, ToBatchType, ToBatchID, TransferDate, QuantityTransferred, AuthorizedBy, Notes)
SELECT TOP 30
    'LogBatch',
    LogBatchID,
    'VeneerBatch',
    VeneerBatchID,
    DATEADD(DAY, -LogBatchID, GETDATE()),
    QuantityReceived * 200,
    3,
    'Переработка бревна в шпон'
FROM LogBatch
WHERE LogBatchID <= 30;

INSERT INTO ProductionFlow (FromBatchType, FromBatchID, ToBatchType, ToBatchID, TransferDate, QuantityTransferred, AuthorizedBy, Notes)
SELECT TOP 20
    'VeneerBatch',
    VeneerBatchID,
    'SemiFinishedBatch',
    SemiFinishedID,
    DATEADD(DAY, -VeneerBatchID, GETDATE()),
    SheetsProduced / 10,
    3,
    'Переработка шпона в полуфабрикат'
FROM VeneerBatch
WHERE VeneerBatchID <= 20;

INSERT INTO ProductionFlow (FromBatchType, FromBatchID, ToBatchType, ToBatchID, TransferDate, QuantityTransferred, AuthorizedBy, Notes)
SELECT TOP 15
    'SemiFinishedBatch',
    SemiFinishedID,
    'FinishedBatch',
    FinishedID,
    DATEADD(DAY, -SemiFinishedID, GETDATE()),
    SheetsProduced,
    3,
    'Переработка полуфабриката в фанеру'
FROM SemiFinishedBatch
WHERE SemiFinishedID <= 15;

-- =====================================================
-- 12. ОСТАТКИ НА СКЛАДЕ
-- =====================================================

INSERT INTO StockBalance (BatchType, BatchID, Quantity, UnitID, Status, LastUpdated)
SELECT 'LogBatch', LogBatchID, QuantityReceived, 1, 'На складе', GETDATE()
FROM LogBatch WHERE Status = 'На складе';

INSERT INTO StockBalance (BatchType, BatchID, Quantity, UnitID, Status, LastUpdated)
SELECT 'VeneerBatch', VeneerBatchID, SheetsProduced, 2, 'На складе', GETDATE()
FROM VeneerBatch WHERE Status = 'На складе';

INSERT INTO StockBalance (BatchType, BatchID, Quantity, UnitID, Status, LastUpdated)
SELECT 'SemiFinishedBatch', SemiFinishedID, SheetsProduced, 2, 'На складе', GETDATE()
FROM SemiFinishedBatch WHERE Status = 'На складе';

INSERT INTO StockBalance (BatchType, BatchID, Quantity, UnitID, Status, LastUpdated)
SELECT 'FinishedBatch', FinishedID, SheetsProduced, 2, 'На складе', GETDATE()
FROM FinishedBatch WHERE Status = 'На складе';

-- =====================================================
-- 13. ПРОВЕРКА
-- =====================================================

SELECT 'База данных ProductionVeneer успешно создана!' AS Status;
SELECT 'Роли: ' + CAST(COUNT(*) AS VARCHAR) AS Result FROM Role
UNION ALL
SELECT 'Пользователи: ' + CAST(COUNT(*) AS VARCHAR) FROM AppUser
UNION ALL
SELECT 'Брёвна: ' + CAST(COUNT(*) AS VARCHAR) FROM LogBatch
UNION ALL
SELECT 'Шпон: ' + CAST(COUNT(*) AS VARCHAR) FROM VeneerBatch
UNION ALL
SELECT 'Полуфабрикат: ' + CAST(COUNT(*) AS VARCHAR) FROM SemiFinishedBatch
UNION ALL
SELECT 'Готовая фанера: ' + CAST(COUNT(*) AS VARCHAR) FROM FinishedBatch
UNION ALL
SELECT 'Оборудование: ' + CAST(COUNT(*) AS VARCHAR) FROM Equipment;

-- =====================================================
-- КОНЕЦ СКРИПТА
-- =====================================================