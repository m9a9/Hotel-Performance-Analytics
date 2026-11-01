USE MASTER;

-- ToDO:: CHECK if the database is exist and remove it if found and recreate it again
IF EXISTS (
    SELECT
        1
    from
        sys.databases
    WHERE
        name = 'HotelWarehouse'
) BEGIN Alter DATABASE HotelWarehouse
set
    single_user with ROLLBACK IMMEDIATE;

Drop DATABASE HotelWarehouse;

END;

GO
--? ToDo:: Create the database and schemas
    CREATE DATABASE HotelWarehouse;

GO
    use HotelWarehouse;

GO
    create schema bronze;

GO
    create schema silver;

GO
    create schema gold;


