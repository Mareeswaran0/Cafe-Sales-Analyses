Create table Cafe_1(
ID int identity(1,1) primary key not null,
Product varchar(155) not null,
[Date] date not null,
PurchasedPrice int not null,
InStock int not null,
SoldQuantity int not null,
SoldPrice int not null,
BalanceQuantity int not null,
TotalPP int not null,
TotalSP int not null, 
Difference int not null,
SumTotalPP int not null,
SumTotalSp int not null,
OverallprofitLoss varchar(55) not null
)

-- Set up a temporary table to hold random data
CREATE TABLE #RandomData (
    Product varchar(155),
    [Date] date,
    PurchasedPrice int,
    InStock int,
    SoldQuantity int,
    SoldPrice int,
    BalanceQuantity int,
    TotalPP int,
    TotalSP int,
    Difference int,
    SumTotalPP int,
    SumTotalSP int,
    OverallprofitLoss varchar(55)
);

-- Loop to insert 1000 random records
DECLARE @i INT = 1;
WHILE @i <= 1000
BEGIN
    -- Generate random values for each column
    DECLARE @Product varchar(155);
    DECLARE @Date date;
    DECLARE @PurchasedPrice int;
    DECLARE @InStock int;
    DECLARE @SoldQuantity int;
    DECLARE @SoldPrice int;

    -- Generate a unique product for each date
    WHILE 1 = 1
    BEGIN
        SET @Product = (SELECT TOP 1 Product FROM (VALUES
            ('Donut'),('Hot Coffee'),('Cold Coffee'),('Hot Beverages'),('Bottle Beverages'),
            ('Iced Teas'),('Hot Teas'),('Coffee Frappuccino'),('Creme Frappuccino'),('Burger'),
            ('Pizza'),('French fries'),('Sandwich'),('Cutlet'),('Smiles'),('Cocouny milk Collection'),
            ('Spicy Lemonades'),('Frozen Lemonades'),('Cakes'),('Sundaes'),('Smooties'),('Fruit cocktail'),('Desserts'),('Pafe')
        ) AS Products(Product) ORDER BY NEWID());

        SET @Date = DATEADD(day, -FLOOR(RAND() * 365), '2023-01-01'); -- Random date within 2023

        -- Check if this product has already been used on this date
        IF NOT EXISTS (SELECT 1 FROM #RandomData WHERE Product = @Product AND [Date] = @Date)
            BREAK; -- Break out of the loop if product is unique for this date
    END;

    SET @PurchasedPrice = FLOOR(RAND() * 100) + 151; -- Random purchased price between 151 and 250
    SET @InStock = FLOOR(RAND() * 100) + 10; -- Random instock quantity between 10 and 109
    SET @SoldQuantity = FLOOR(RAND() * @InStock); -- Random sold quantity less than instock
    SET @SoldPrice = @PurchasedPrice + FLOOR(RAND() * 20) + 1; -- Random sold price 1 to 20 more than purchased price

    -- Calculate TotalPP, TotalSP, Difference
    DECLARE @TotalPP int, @TotalSP int, @Difference int;
    SET @TotalPP = @InStock * @PurchasedPrice;
    SET @TotalSP = @SoldQuantity * @SoldPrice;
    SET @Difference = @TotalPP - @TotalSP;

    -- Insert the random data into the temporary table
    INSERT INTO #RandomData (Product, [Date], PurchasedPrice, InStock, SoldQuantity, SoldPrice, BalanceQuantity, TotalPP, TotalSP, Difference)
    VALUES (@Product, @Date, @PurchasedPrice, @InStock, @SoldQuantity, @SoldPrice, @InStock - @SoldQuantity, @TotalPP, @TotalSP, @Difference);

    SET @i = @i + 1;
END

-- Calculate SumTotalPP and SumTotalSP for each date
UPDATE #RandomData
SET SumTotalPP = (SELECT SUM(TotalPP) FROM #RandomData WHERE [Date] = RD.[Date]),
    SumTotalSP = (SELECT SUM(TotalSP) FROM #RandomData WHERE [Date] = RD.[Date])
FROM #RandomData RD;

-- Determine OverallprofitLoss for each row based on SumTotalPP and SumTotalSP
UPDATE #RandomData
SET OverallprofitLoss = CASE WHEN SumTotalPP >= SumTotalSP THEN 'Profit' ELSE 'Loss' END;

-- Insert data from temporary table into Cafe_1 table
INSERT INTO Cafe_1 (Product, [Date], PurchasedPrice, InStock, SoldQuantity, SoldPrice, BalanceQuantity, TotalPP, TotalSP, Difference, SumTotalPP, SumTotalSP, OverallprofitLoss)
SELECT Product, [Date], PurchasedPrice, InStock, SoldQuantity, SoldPrice, BalanceQuantity, TotalPP, TotalSP, Difference, SumTotalPP, SumTotalSP, OverallprofitLoss
FROM #RandomData;

-- Clean up temporary table
DROP TABLE #RandomData;



select * from Cafe_1 where Date='2022-01-29'

drop table Cafe_1


select count(ID) from Cafe_1 where OverallProfitLoss='Profit'
select count(ID) from Cafe_1 where OverallProfitLoss='Loss'

