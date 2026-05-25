-- =====================================================
-- ПОЛЕЗНЫЕ ЗАПРОСЫ ДЛЯ БАЗЫ ДАННЫХ ProductionVeneer
-- =====================================================

-- Запрос 1: Статистика по цехам (сколько продукции произведено в каждом цехе)
PRINT '==========================================';
PRINT 'Запрос 1: Статистика по цехам';
PRINT '==========================================';
SELECT 
    'Цех 1' AS Цех,
    'Брёвна' AS Тип_продукции,
    COUNT(*) AS Количество_партий,
    SUM(QuantityReceived) AS Общий_объём_м3
FROM LogBatch
UNION ALL
SELECT 
    'Цех 2',
    'Шпон',
    COUNT(*),
    SUM(SheetsProduced)
FROM VeneerBatch
UNION ALL
SELECT 
    'Цех 3',
    'Полуфабрикат',
    COUNT(*),
    SUM(SheetsProduced)
FROM SemiFinishedBatch
UNION ALL
SELECT 
    'Склад ГП',
    'Готовая фанера',
    COUNT(*),
    SUM(SheetsProduced)
FROM FinishedBatch;
GO

-- Запрос 2: ТОП-5 поставщиков по объёму поставок
PRINT '==========================================';
PRINT 'Запрос 2: ТОП-5 поставщиков';
PRINT '==========================================';
SELECT TOP 5
    s.SupplierName AS Поставщик,
    COUNT(lb.LogBatchID) AS Количество_партий,
    SUM(lb.QuantityReceived) AS Общий_объём_м3,
    AVG(lb.QualityClass) AS Средний_сорт
FROM Supplier s
JOIN LogBatch lb ON s.SupplierID = lb.SupplierID
GROUP BY s.SupplierName
ORDER BY SUM(lb.QuantityReceived) DESC;
GO

-- Запрос 3: Бракованная продукция по видам брака
PRINT '==========================================';
PRINT 'Запрос 3: Бракованная продукция по видам брака';
PRINT '==========================================';
SELECT 
    dt.DefectName AS Вид_брака,
    COUNT(CASE WHEN lb.DefectTypeID = dt.DefectTypeID THEN 1 END) AS Брёвна_брак,
    COUNT(CASE WHEN vb.DefectTypeID = dt.DefectTypeID THEN 1 END) AS Шпон_брак,
    COUNT(CASE WHEN sf.DefectTypeID = dt.DefectTypeID THEN 1 END) AS Полуфабрикат_брак,
    COUNT(CASE WHEN fb.DefectTypeID = dt.DefectTypeID THEN 1 END) AS Фанера_брак
FROM DefectType dt
LEFT JOIN LogBatch lb ON lb.DefectTypeID = dt.DefectTypeID
LEFT JOIN VeneerBatch vb ON vb.DefectTypeID = dt.DefectTypeID
LEFT JOIN SemiFinishedBatch sf ON sf.DefectTypeID = dt.DefectTypeID
LEFT JOIN FinishedBatch fb ON fb.DefectTypeID = dt.DefectTypeID
GROUP BY dt.DefectName
ORDER BY dt.DefectName;
GO

-- Запрос 4: Эффективность переработки (сколько фанеры получилось из брёвен)
PRINT '==========================================';
PRINT 'Запрос 4: Эффективность переработки';
PRINT '==========================================';
SELECT 
    lb.BatchNumber AS Партия_бревна,
    lb.QuantityReceived AS Объём_бревна_м3,
    vb.SheetsProduced AS Листы_шпона,
    sf.SheetsProduced AS Листы_полуфабриката,
    fb.SheetsProduced AS Листы_фанеры,
    ROUND(fb.SheetsProduced / NULLIF(lb.QuantityReceived, 0), 2) AS Коэффициент_выхода_фанеры_из_м3
FROM LogBatch lb
JOIN VeneerBatch vb ON lb.LogBatchID = vb.LogBatchID
JOIN SemiFinishedBatch sf ON vb.VeneerBatchID = sf.VeneerBatchID
JOIN FinishedBatch fb ON sf.SemiFinishedID = fb.SemiFinishedID
ORDER BY Коэффициент_выхода_фанеры_из_м3 DESC;
GO

-- Запрос 5: Отгрузки готовой продукции по клиентам
PRINT '==========================================';
PRINT 'Запрос 5: Отгрузки по клиентам';
PRINT '==========================================';
SELECT 
    Customer AS Клиент,
    COUNT(*) AS Количество_отгрузок,
    SUM(SheetsProduced) AS Всего_листов_фанеры,
    MIN(ShippingDate) AS Первая_отгрузка,
    MAX(ShippingDate) AS Последняя_отгрузка
FROM FinishedBatch
WHERE Customer IS NOT NULL
GROUP BY Customer
ORDER BY SUM(SheetsProduced) DESC;
GO

-- Запрос 6: Состояние оборудования (для технолога)
PRINT '==========================================';
PRINT 'Запрос 6: Состояние оборудования';
PRINT '==========================================';
SELECT 
    EquipmentName AS Название_станка,
    CASE WorkshopID
        WHEN 1 THEN 'Цех 1 (Лущение)'
        WHEN 2 THEN 'Цех 2 (Пресс)'
        WHEN 3 THEN 'Цех 3 (Отделка)'
        ELSE 'Неизвестный цех'
    END AS Цех,
    Status AS Статус,
    LastCheckDate AS Дата_последней_проверки,
    ISNULL(ProblemDescription, 'Нет проблем') AS Описание_проблемы
FROM Equipment
ORDER BY WorkshopID, EquipmentName;
GO

-- Запрос 7: Сводка по выполнению плана производства
PRINT '==========================================';
PRINT 'Запрос 7: Выполнение плана производства';
PRINT '==========================================';
SELECT 
    pp.PlanID AS Номер_плана,
    pp.PlanDate AS Дата_плана,
    pp.TargetVeneerSheets AS План_шпона_листы,
    (SELECT ISNULL(SUM(SheetsProduced), 0) FROM VeneerBatch) AS Факт_шпона_листы,
    pp.TargetSemiSheets AS План_полуфабриката_листы,
    (SELECT ISNULL(SUM(SheetsProduced), 0) FROM SemiFinishedBatch) AS Факт_полуфабриката_листы,
    pp.TargetFinishedSheets AS План_фанеры_листы,
    (SELECT ISNULL(SUM(SheetsProduced), 0) FROM FinishedBatch) AS Факт_фанеры_листы,
    CASE 
        WHEN pp.TargetFinishedSheets > 0 
        THEN ROUND((SELECT ISNULL(SUM(SheetsProduced), 0) FROM FinishedBatch) * 100.0 / pp.TargetFinishedSheets, 1)
        ELSE 0
    END AS Процент_выполнения_плана,
    CASE 
        WHEN pp.TargetFinishedSheets > 0 AND (SELECT ISNULL(SUM(SheetsProduced), 0) FROM FinishedBatch) >= pp.TargetFinishedSheets
        THEN 'План выполнен'
        WHEN pp.TargetFinishedSheets > 0 AND (SELECT ISNULL(SUM(SheetsProduced), 0) FROM FinishedBatch) < pp.TargetFinishedSheets
        THEN 'План не выполнен'
        ELSE 'План не установлен'
    END AS Статус_выполнения
FROM ProductionPlan pp
WHERE pp.IsActive = 1;
GO

-- =====================================================
-- КОНЕЦ ВСЕХ ЗАПРОСОВ
-- =====================================================
PRINT '==========================================';
PRINT 'Все запросы выполнены успешно!';
PRINT '==========================================';
GO