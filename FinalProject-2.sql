/* ===================================================================
   FinalProject.sql
   Library Management System Database
   SQL Server Management Studio 22

   Running this entire script fully recreates the database --
   no manual steps required.
   =================================================================== */

-- #1 Create the database
IF DB_ID('LibraryDB') IS NOT NULL
BEGIN
    ALTER DATABASE LibraryDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LibraryDB;
END
GO

CREATE DATABASE LibraryDB;
GO

USE LibraryDB;
GO

-- #2 Create a meaningful schema (avoid the default "dbo")
CREATE SCHEMA lib;
GO

-- #3 Table: lib.Authors
CREATE TABLE lib.Authors (
    AuthorID     INT IDENTITY(1,1) PRIMARY KEY,
    FirstName    NVARCHAR(50) NOT NULL,
    LastName     NVARCHAR(50) NOT NULL,
    Nationality  NVARCHAR(50) NULL
);
GO

-- #4 Table: lib.Genres
CREATE TABLE lib.Genres (
    GenreID      INT IDENTITY(1,1) PRIMARY KEY,
    GenreName    NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- #5 Table: lib.Books
--    FK #1: Books.AuthorID -> Authors.AuthorID
--    FK #2: Books.GenreID  -> Genres.GenreID
CREATE TABLE lib.Books (
    BookID          INT IDENTITY(1,1) PRIMARY KEY,
    Title           NVARCHAR(150) NOT NULL,
    ISBN            NVARCHAR(20)  NULL UNIQUE,
    AuthorID        INT NOT NULL,
    GenreID         INT NOT NULL,
    PublishedYear   INT NULL,
    CopiesAvailable INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Books_Authors FOREIGN KEY (AuthorID) REFERENCES lib.Authors(AuthorID),
    CONSTRAINT FK_Books_Genres  FOREIGN KEY (GenreID)  REFERENCES lib.Genres(GenreID)
);
GO

-- #6 Table: lib.Members
CREATE TABLE lib.Members (
    MemberID     INT IDENTITY(1,1) PRIMARY KEY,
    FirstName    NVARCHAR(50) NOT NULL,
    LastName     NVARCHAR(50) NOT NULL,
    Email        NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- #7 Table: lib.Checkouts
--    FK: Checkouts.BookID   -> Books.BookID
--    FK: Checkouts.MemberID -> Members.MemberID
--    ReturnDate NULL = still checked out
CREATE TABLE lib.Checkouts (
    CheckoutID   INT IDENTITY(1,1) PRIMARY KEY,
    BookID       INT NOT NULL,
    MemberID     INT NOT NULL,
    CheckoutDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    DueDate      DATE NOT NULL,
    ReturnDate   DATE NULL,
    CONSTRAINT FK_Checkouts_Books   FOREIGN KEY (BookID)   REFERENCES lib.Books(BookID),
    CONSTRAINT FK_Checkouts_Members FOREIGN KEY (MemberID) REFERENCES lib.Members(MemberID)
);
GO

-- #8 Sample data: lib.Authors
INSERT INTO lib.Authors (FirstName, LastName, Nationality) VALUES
('George', 'Orwell', 'British'),
('Gabriel', 'Garcia Marquez', 'Colombian'),
('Isaac', 'Asimov', 'American'),
('Agatha', 'Christie', 'British');
GO

-- #9 Sample data: lib.Genres
INSERT INTO lib.Genres (GenreName) VALUES
('Dystopian'),
('Magical Realism'),
('Science Fiction'),
('Mystery');
GO

-- #10 Sample data: lib.Books
INSERT INTO lib.Books (Title, ISBN, AuthorID, GenreID, PublishedYear, CopiesAvailable) VALUES
('1984', '9780451524935', 1, 1, 1949, 3),
('Animal Farm', '9780451526342', 1, 1, 1945, 2),
('One Hundred Years of Solitude', '9780060883287', 2, 2, 1967, 2),
('Foundation', '9780553293357', 3, 3, 1951, 4),
('I, Robot', '9780553294385', 3, 3, 1950, 1),
('Murder on the Orient Express', '9780062693662', 4, 4, 1934, 2);
GO

-- #11 Sample data: lib.Members
INSERT INTO lib.Members (FirstName, LastName, Email) VALUES
('Ana', 'Torres', 'ana.torres@example.com'),
('Luis', 'Ramirez', 'luis.ramirez@example.com'),
('Sofia', 'Chen', 'sofia.chen@example.com'),
('Marcus', 'Lee', 'marcus.lee@example.com');
GO

-- #12 Sample data: lib.Checkouts
INSERT INTO lib.Checkouts (BookID, MemberID, CheckoutDate, DueDate, ReturnDate) VALUES
(1, 1, '2026-06-01', '2026-06-15', '2026-06-14'),  -- Ana borrowed 1984, returned on time
(3, 2, '2026-06-20', '2026-07-04', NULL),          -- Luis still has One Hundred Years of Solitude
(5, 3, '2026-07-01', '2026-07-15', NULL),          -- Sofia still has I, Robot
(4, 1, '2026-07-05', '2026-07-19', '2026-07-18'),  -- Ana borrowed Foundation, returned
(6, 4, '2026-07-10', '2026-07-24', NULL);          -- Marcus still has Murder on the Orient Express
GO

-- #13 Stored procedure: check out a book
--     Decrements available copies and logs the checkout.
CREATE PROCEDURE lib.CheckOutBook
    @BookID INT,
    @MemberID INT,
    @DueDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF (SELECT CopiesAvailable FROM lib.Books WHERE BookID = @BookID) < 1
    BEGIN
        RAISERROR('No copies available for this book.', 16, 1);
        RETURN;
    END

    INSERT INTO lib.Checkouts (BookID, MemberID, DueDate)
    VALUES (@BookID, @MemberID, @DueDate);

    UPDATE lib.Books
    SET CopiesAvailable = CopiesAvailable - 1
    WHERE BookID = @BookID;
END
GO

-- #14 Stored procedure: return a book
--     Marks the checkout as returned and increments available copies.
CREATE PROCEDURE lib.ReturnBook
    @CheckoutID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @BookID INT;

    SELECT @BookID = BookID FROM lib.Checkouts WHERE CheckoutID = @CheckoutID;

    UPDATE lib.Checkouts
    SET ReturnDate = CAST(GETDATE() AS DATE)
    WHERE CheckoutID = @CheckoutID AND ReturnDate IS NULL;

    UPDATE lib.Books
    SET CopiesAvailable = CopiesAvailable + 1
    WHERE BookID = @BookID;
END
GO

-- #15 Sanity check queries (optional, run manually -- not part of recreate)
-- SELECT * FROM lib.Books;
-- SELECT * FROM lib.Authors;
-- SELECT * FROM lib.Checkouts;

-- Example JOIN + GROUP BY report: how many books each member currently has checked out
-- SELECT m.FirstName + ' ' + m.LastName AS Member, COUNT(*) AS BooksCheckedOut
-- FROM lib.Checkouts c
-- JOIN lib.Members m ON c.MemberID = m.MemberID
-- WHERE c.ReturnDate IS NULL
-- GROUP BY m.FirstName, m.LastName;
