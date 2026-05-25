CREATE DATABASE ProductionVeneer;
GO

USE ProductionVeneer;
GO


-- Справочник видов древесины
CREATE TABLE TimberType (
    TimberTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(20) NOT NULL UNIQUE,
    Description NVARCHAR(100) NULL
);

-- Справочник поставщиков
CREATE TABLE Supplier (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(100) NOT NULL,
    ContactPerson NVARCHAR(100) NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL
);

-- Справочник сортов продукции
CREATE TABLE ProductGrade (
    GradeID INT IDENTITY(1,1) PRIMARY KEY,
    GradeName NVARCHAR(10) NOT NULL UNIQUE,
    GradeDescription NVARCHAR(200) NULL
);

-- Справочник видов брака
CREATE TABLE DefectType (
    DefectTypeID INT IDENTITY(1,1) PRIMARY KEY,
    DefectName NVARCHAR(100) NOT NULL,
    SeverityLevel INT DEFAULT 1 CHECK (SeverityLevel IN (1,2,3))
);

-- Справочник единиц измерения
CREATE TABLE Unit (
    UnitID INT IDENTITY(1,1) PRIMARY KEY,
    UnitName NVARCHAR(20) NOT NULL UNIQUE,
    ShortName NVARCHAR(10) NOT NULL
);


CREATE TABLE Role (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(30) NOT NULL UNIQUE
);


CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    Position NVARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NULL,
    Email VARCHAR(100) NULL
);


CREATE TABLE AppUser (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    RoleID INT NOT NULL,
    Login VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
);


CREATE TABLE LogBatch (
    LogBatchID INT IDENTITY(1,1) PRIMARY KEY,
    BatchNumber NVARCHAR(50) NOT NULL UNIQUE,
    SupplierID INT NOT NULL,
    TimberTypeID INT NOT NULL,
    UnitID INT NOT NULL,
    QuantityReceived DECIMAL(10,2) NOT NULL CHECK (QuantityReceived > 0),
    QualityClass INT NULL CHECK (QualityClass BETWEEN 1 AND 3),
    ReceiptDate DATE NOT NULL,
    DefectTypeID INT NULL,
    DefectQuantity DECIMAL(10,2) NULL DEFAULT 0,
    Status NVARCHAR(30) DEFAULT 'На складе',
    Notes NVARCHAR(500) NULL,
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID),
    FOREIGN KEY (TimberTypeID) REFERENCES TimberType(TimberTypeID),
    FOREIGN KEY (UnitID) REFERENCES Unit(UnitID),
    FOREIGN KEY (DefectTypeID) REFERENCES DefectType(DefectTypeID)
);


CREATE TABLE VeneerBatch (
    VeneerBatchID INT IDENTITY(1,1) PRIMARY KEY,
    BatchNumber NVARCHAR(50) NOT NULL UNIQUE,
    LogBatchID INT NOT NULL,
    UnitID INT NOT NULL,
    Thickness_mm DECIMAL(5,2) NOT NULL CHECK (Thickness_mm > 0),
    SheetsProduced INT NOT NULL CHECK (SheetsProduced >= 0),
    ProductionDate DATETIME NOT NULL,
    DefectTypeID INT NULL,
    DefectQuantity INT NULL DEFAULT 0,
    OperatorID INT NULL,
    Status NVARCHAR(30) DEFAULT 'Произведён',
    Notes NVARCHAR(500) NULL,
    FOREIGN KEY (LogBatchID) REFERENCES LogBatch(LogBatchID),
    FOREIGN KEY (UnitID) REFERENCES Unit(UnitID),
    FOREIGN KEY (DefectTypeID) REFERENCES DefectType(DefectTypeID),
    FOREIGN KEY (OperatorID) REFERENCES Employee(EmployeeID)
);


CREATE TABLE SemiFinishedBatch (
    SemiFinishedID INT IDENTITY(1,1) PRIMARY KEY,
    BatchNumber NVARCHAR(50) NOT NULL UNIQUE,
    VeneerBatchID INT NOT NULL,
    UnitID INT NOT NULL,
    PressingDateTime DATETIME NOT NULL,
    LayersCount INT NOT NULL CHECK (LayersCount BETWEEN 3 AND 15),
    GlueType NVARCHAR(50) NOT NULL,
    Pressure_atm DECIMAL(5,2) NOT NULL,
    Temperature_C INT NOT NULL,
    SheetsProduced INT NOT NULL CHECK (SheetsProduced >= 0),
    DefectTypeID INT NULL,
    DefectQuantity INT NULL DEFAULT 0,
    OperatorID INT NULL,
    Status NVARCHAR(30) DEFAULT 'На проверке',
    Notes NVARCHAR(500) NULL,
    FOREIGN KEY (VeneerBatchID) REFERENCES VeneerBatch(VeneerBatchID),
    FOREIGN KEY (UnitID) REFERENCES Unit(UnitID),
    FOREIGN KEY (DefectTypeID) REFERENCES DefectType(DefectTypeID),
    FOREIGN KEY (OperatorID) REFERENCES Employee(EmployeeID)
);

CREATE TABLE FinishedBatch (
    FinishedID INT IDENTITY(1,1) PRIMARY KEY,
    BatchNumber NVARCHAR(50) NOT NULL UNIQUE,
    SemiFinishedID INT NOT NULL,
    GradeID INT NOT NULL,
    UnitID INT NOT NULL,
    ProcessingDateTime DATETIME NOT NULL,
    SandingType NVARCHAR(50) NULL,
    FinalThickness_mm DECIMAL(5,2) NOT NULL,
    SheetsProduced INT NOT NULL CHECK (SheetsProduced >= 0),
    DefectTypeID INT NULL,
    DefectQuantity INT NULL DEFAULT 0,
    ShippingDate DATE NULL,
    Customer NVARCHAR(200) NULL,
    Status NVARCHAR(30) DEFAULT 'На складе',
    Notes NVARCHAR(500) NULL,
    FOREIGN KEY (SemiFinishedID) REFERENCES SemiFinishedBatch(SemiFinishedID),
    FOREIGN KEY (GradeID) REFERENCES ProductGrade(GradeID),
    FOREIGN KEY (UnitID) REFERENCES Unit(UnitID),
    FOREIGN KEY (DefectTypeID) REFERENCES DefectType(DefectTypeID)
);

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

CREATE TABLE StockBalance (
    StockID INT IDENTITY(1,1) PRIMARY KEY,
    BatchType NVARCHAR(30) NOT NULL,
    BatchID INT NOT NULL,
    Quantity DECIMAL(12,3) NOT NULL CHECK (Quantity >= 0),
    UnitID INT NOT NULL,
    LastUpdated DATETIME NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(30) DEFAULT 'На складе',
    FOREIGN KEY (UnitID) REFERENCES Unit(UnitID)
);
