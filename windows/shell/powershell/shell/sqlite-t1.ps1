#Import the module, create a data source and a table
    Import-Module PSSQLite

    $Database = "D:\Names.db"
#    $Database = "D:\Names.SQLite"
    $Query = "CREATE TABLE NAMES (
        Fullname VARCHAR(20) PRIMARY KEY,
        Surname TEXT,
        Givenname TEXT,
        Birthdate DATETIME)"

    #SQLite will create Names.SQLite for us
    Invoke-SqliteQuery -Query $Query -DataSource $Database

# We have a database, and a table, let's view the table info
    Invoke-SqliteQuery -DataSource $Database -Query "PRAGMA table_info(NAMES)"

# Insert some data, use parameters for the fullname and birthdate
    $query = "INSERT INTO NAMES (Fullname, Surname, Givenname, Birthdate)
                          VALUES (@full, 'Cookie', 'Monster', @BD)"

    Invoke-SqliteQuery -DataSource $Database -Query $query -SqlParameters @{
        full = "Cookie Monster"
        BD   = (get-date).addyears(-3)
    }

# Check to see if we inserted the data:
    Invoke-SqliteQuery -DataSource $Database -Query "SELECT * FROM NAMES"