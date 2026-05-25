USE ProductionVeneer;
GO

-- Таблица станков/оборудования
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'Equipment')
BEGIN
    CREATE TABLE Equipment (
        EquipmentID INT IDENTITY(1,1) PRIMARY KEY,
        EquipmentName NVARCHAR(100) NOT NULL,
        WorkshopID INT NOT NULL,
        Status NVARCHAR(50) DEFAULT 'Работает',
        LastCheckDate DATETIME NULL,
        ProblemDescription NVARCHAR(500) NULL
    );
END
GO

-- Удаляем старые станки
DELETE FROM Equipment;
GO

-- Добавляем 15 станков
INSERT INTO Equipment (EquipmentName, WorkshopID, Status, ProblemDescription) VALUES
-- Цех 1 (Лущение и сушка) - 5 станков
('Лущильный станок №1', 1, 'Работает', NULL),
('Лущильный станок №2', 1, 'Не работает', 'Замена ножей'),
('Сушильная камера №1', 1, 'Работает', NULL),
('Сушильная камера №2', 1, 'Работает', NULL),
('Транспортёр ленточный', 1, 'Не работает', 'Порван ремень'),

-- Цех 2 (Сборка и прессование) - 5 станков
('Нанесение клея', 2, 'Работает', NULL),
('Пресс горячий №1', 2, 'Работает', NULL),
('Пресс горячий №2', 2, 'Не работает', 'Перегрев'),
('Сборочный стол', 2, 'Работает', NULL),
('Рубильная машина', 2, 'Работает', NULL),

-- Цех 3 (Финишная обработка) - 5 станков
('Шлифовальный станок №1', 3, 'Работает', NULL),
('Шлифовальный станок №2', 3, 'Работает', NULL),
('Обрезной станок', 3, 'Не работает', 'Затупились пилы'),
('Сортировочная линия', 3, 'Работает', NULL),
('Упаковочная машина', 3, 'Работает', NULL);
GO

-- Проверяем
SELECT EquipmentID, EquipmentName, WorkshopID, Status, ProblemDescription FROM Equipment;
GO

-- Таблица производственного плана
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'ProductionPlan')
BEGIN
    CREATE TABLE ProductionPlan (
        PlanID INT IDENTITY(1,1) PRIMARY KEY,
        TargetVeneerSheets INT DEFAULT 0,
        TargetSemiSheets INT DEFAULT 0,
        TargetFinishedSheets INT DEFAULT 0,
        PlanDate DATE DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1
    );
END
GO

-- Вставляем текущий план
DELETE FROM ProductionPlan;
INSERT INTO ProductionPlan (TargetVeneerSheets, TargetSemiSheets, TargetFinishedSheets, PlanDate, IsActive)
VALUES (0, 0, 0, GETDATE(), 1);
GO