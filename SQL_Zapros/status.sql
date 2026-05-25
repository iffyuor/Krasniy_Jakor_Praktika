USE ProductionVeneer;
GO

-- Добавляем статусы в LogBatch (брёвна)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE name='ProcessStatus' AND object_id=OBJECT_ID('LogBatch'))
    ALTER TABLE LogBatch ADD ProcessStatus NVARCHAR(50) DEFAULT 'На складе';
-- Статусы: На складе, Передано в цех 1, Обработано цехом 1

-- Добавляем статусы в VeneerBatch (шпон)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE name='ProcessStatus' AND object_id=OBJECT_ID('VeneerBatch'))
    ALTER TABLE VeneerBatch ADD ProcessStatus NVARCHAR(50) DEFAULT 'На складе';
-- Статусы: На складе, Передано в цех 2, Обработано цехом 2

-- Добавляем статусы в SemiFinishedBatch (полуфабрикат)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE name='ProcessStatus' AND object_id=OBJECT_ID('SemiFinishedBatch'))
    ALTER TABLE SemiFinishedBatch ADD ProcessStatus NVARCHAR(50) DEFAULT 'На складе';
-- Статусы: На складе, Передано в цех 3, Обработано цехом 3