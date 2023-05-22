-- Tao 1 user cho admin
DECLARE
  user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO user_exists FROM DBA_USERS WHERE USERNAME = 'MYADMIN';

  IF user_exists > 0 THEN
    EXECUTE IMMEDIATE 'DROP USER MYADMIN CASCADE';
  END IF;
END;
/
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
CREATE USER MYADMIN IDENTIFIED BY 123;

-- Cap quyen can thiet cho admin
GRANT DBA TO MYADMIN;
GRANT ALL PRIVILEGES TO MYADMIN WITH ADMIN OPTION;
GRANT EXECUTE ANY PROCEDURE TO MYADMIN;
GRANT ALTER SESSION TO MYADMIN;

-- Ket noi bang connection myadmin
CONNECT MYADMIN/123;
-- Tao database
---- Xoa cac bang neu da ton tai
BEGIN
  FOR table_name IN (
    SELECT table_name FROM user_tables WHERE table_name 
    IN ('NHANVIEN', 'PHONGBAN', 'DEAN', 'PHANCONG')
  ) LOOP
    -- Xoa cac rang buoc khoa ngoai sau khi xoa bang
    FOR c IN (
      SELECT constraint_name, table_name, owner
      FROM all_constraints
      WHERE constraint_type = 'R'
      AND r_constraint_name IN (
        SELECT constraint_name
        FROM all_constraints
        WHERE constraint_type in ('P', 'U')
        AND table_name = table_name.table_name
        AND owner = USER
      )
    ) LOOP
      EXECUTE IMMEDIATE 'ALTER TABLE ' || c.owner || '.' || c.table_name ||
                        ' DROP CONSTRAINT ' || c.constraint_name;
    END LOOP;
    
    -- Xoa bang sau khi da xoa cac rang buoc khoa ngoai
    BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE ' || table_name.table_name;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
          RAISE;
        END IF;
    END;
  END LOOP;
END;
/

CREATE TABLE NHANVIEN (
  MANV VARCHAR2(10), 
  TENNV VARCHAR2(50) NOT NULL,
  PHAI VARCHAR2(10),
  NGAYSINH DATE,
  DIACHI VARCHAR2(100),
  SODT VARCHAR2(20),
  LUONG NUMBER(18,2),
  PHUCAP NUMBER(18,2),
  VAITRO VARCHAR2(50),
  MANQL VARCHAR2(10),
  PHG VARCHAR2(50),
  CONSTRAINT PK_NHANVIEN PRIMARY KEY (MANV)
);

/
CREATE TABLE PHONGBAN (
  MAPB VARCHAR2(10), 
  TENPB VARCHAR2(50) NOT NULL,
  TRPHG VARCHAR2(10),
  CONSTRAINT PK_PHONGBAN PRIMARY KEY (MAPB)
);

/
CREATE TABLE DEAN(
  MADA VARCHAR2(10),
  TENDA VARCHAR2(100) UNIQUE,
  NGAYBD DATE,
  PHONG VARCHAR2(10),
  CONSTRAINT PK_DEAN PRIMARY KEY (MADA)
);
/
CREATE TABLE PHANCONG (
  MANV VARCHAR2(10),
  MADA VARCHAR2(10),
  THOIGIAN DATE,
  CONSTRAINT PK_PHANCONG PRIMARY KEY (MANV, MADA)
);
/
-- Nhap du lieu cho bang
INSERT INTO NHANVIEN VALUES ('NV01', 'A1', 'NAM', TO_DATE('01/01/1980','dd/mm/yyyy'), 'A', '0123456', 1000, 100, 'TP', 'NV09', 'PH01');
INSERT INTO NHANVIEN VALUES ('NV02', 'A2', 'NAM', TO_DATE('01/01/1980','dd/mm/yyyy'), 'A', '0123456', 1000, 100, 'TP', 'NV09', 'PH02');
INSERT INTO NHANVIEN VALUES ('NV03', 'A3', 'NAM', TO_DATE('01/01/1980','dd/mm/yyyy'), 'A', '0123456', 1000, 100, 'TP', 'NV09', 'PH03');
INSERT INTO NHANVIEN VALUES ('NV04', 'A4', 'NAM', TO_DATE('01/01/1980','dd/mm/yyyy'), 'A', '0123456', 1000, 100, 'TP', 'NV010', 'PH04');
INSERT INTO NHANVIEN VALUES ('NV05', 'A5', 'NAM', TO_DATE('01/01/1980','dd/mm/yyyy'), 'A', '0123456', 1000, 100, 'TP', 'NV09', 'PH05');
INSERT INTO NHANVIEN VALUES ('NV06', 'A6', 'NAM', TO_DATE('01/01/1980','dd/mm/yyyy'), 'A', '0123456', 1000, 100, 'TP', 'NV010', 'PH06');
INSERT INTO NHANVIEN VALUES ('NV07', 'A7', 'NAM', TO_DATE('01/01/1980','dd/mm/yyyy'), 'A', '0123456', 1000, 100, 'TP', 'NV09', 'PH07');
INSERT INTO NHANVIEN VALUES ('NV08', 'A8', 'NAM', TO_DATE('01/01/1980','dd/mm/yyyy'), 'A', '0123456', 1000, 100, 'TP', 'NV09', 'PH08');
INSERT INTO NHANVIEN VALUES ('NV09', 'A9', 'NAM', TO_DATE('01/01/1980','dd/mm/yyyy'), 'A', '0123456', 1000, 100, 'QLTT', 'NV010', 'PH08');
INSERT INTO NHANVIEN VALUES ('NV010', 'A10', 'NAM', TO_DATE('01/01/1980','dd/mm/yyyy'), 'A', '0123456', 1000, 100, 'QLTT', 'NV09', 'PH08');


INSERT INTO PHONGBAN VALUES ('PH01', 'Phong ke toan', 'NV01');
INSERT INTO PHONGBAN VALUES ('PH02', 'Phong kiem toan', 'NV02');
INSERT INTO PHONGBAN VALUES ('PH03', 'Phong nhan su', 'NV03');
INSERT INTO PHONGBAN VALUES ('PH04', 'Phong hanh chinh', 'NV04');
INSERT INTO PHONGBAN VALUES ('PH05', 'Phong cham soc khach hang', 'NV05');
INSERT INTO PHONGBAN VALUES ('PH06', 'Phong Cong nghe thong tin', 'NV06');
INSERT INTO PHONGBAN VALUES ('PH07', 'Phong Marketing', 'NV07');
INSERT INTO PHONGBAN VALUES ('PH08', 'Phong kinh doanh', 'NV08');

INSERT INTO DEAN VALUES ('DA01', 'San pham X', TO_DATE('01/01/1980','dd/mm/yyyy'), 'PH08');
INSERT INTO DEAN VALUES ('DA02', 'San pham Y', TO_DATE('01/01/1980','dd/mm/yyyy'), 'PH08');
INSERT INTO DEAN VALUES ('DA03', 'San pham Z', TO_DATE('01/01/1980','dd/mm/yyyy'), 'PH08');
INSERT INTO DEAN VALUES ('DA04', 'Tin hoc hoa', TO_DATE('01/01/1980','dd/mm/yyyy'), 'PH07');
INSERT INTO DEAN VALUES ('DA05', 'Dao tao', TO_DATE('01/01/1980','dd/mm/yyyy'), 'PH03');

INSERT INTO PHANCONG VALUES ('NV01', 'DA01', TO_DATE('01/01/1980','dd/mm/yyyy'));
INSERT INTO PHANCONG VALUES ('NV01', 'DA02', TO_DATE('01/01/1980','dd/mm/yyyy'));
INSERT INTO PHANCONG VALUES ('NV02', 'DA01', TO_DATE('01/01/1980','dd/mm/yyyy'));
INSERT INTO PHANCONG VALUES ('NV04', 'DA01', TO_DATE('01/01/1980','dd/mm/yyyy'));
INSERT INTO PHANCONG VALUES ('NV09', 'DA01', TO_DATE('01/01/1980','dd/mm/yyyy'));
-- Tao khoa ngoai cho cac bang
ALTER TABLE NHANVIEN
ADD CONSTRAINT FK_MANQL 
FOREIGN KEY(MANQL) REFERENCES NHANVIEN(MANV);

ALTER TABLE NHANVIEN
ADD CONSTRAINT FK_PHG 
FOREIGN KEY(PHG) REFERENCES PHONGBAN(MAPB);

ALTER TABLE PHONGBAN
ADD CONSTRAINT FK_PHONGBAN_NHANVIEN 
FOREIGN KEY(TRPHG) REFERENCES NHANVIEN(MANV);

ALTER TABLE DEAN
ADD CONSTRAINT FK_DEAN_PHONGBAN 
FOREIGN KEY(PHONG) REFERENCES PHONGBAN(MAPB);

ALTER TABLE PHANCONG
ADD CONSTRAINT FK_PHANCONG_NHANVIEN 
FOREIGN KEY(MANV) REFERENCES NHANVIEN(MANV);

ALTER TABLE PHANCONG
ADD CONSTRAINT FK_PHANCONG_DEAN 
FOREIGN KEY(MADA) REFERENCES DEAN(MADA);


-- Cac thu tuc cho admin
CREATE OR REPLACE PROCEDURE sp_addUser
(
    username VARCHAR2,
    password VARCHAR2
)
AS
    strSQL VARCHAR(2000);
    
    BEGIN
    
    strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
    EXECUTE IMMEDIATE (strSQL);
        
    strSQL := 'CREATE USER '||username||' IDENTIFIED BY '||password;
    EXECUTE IMMEDIATE (strSQL);
    
    strSQL := 'GRANT CONNECT TO '||username;
    EXECUTE IMMEDIATE (strSQL);

    strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT"=FALSE';
    EXECUTE IMMEDIATE (strSQL);
    
    END;
   
/
CREATE OR REPLACE PROCEDURE sp_deleteUser
(
    username VARCHAR2
)
AS
    strSQL VARCHAR(2000);
    
    BEGIN
    
    strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
    EXECUTE IMMEDIATE (strSQL);
        
    strSQL := 'DROP USER '||username;
    EXECUTE IMMEDIATE (strSQL);

    strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT"=FALSE';
    EXECUTE IMMEDIATE (strSQL);
    
    END;
  
/
CREATE OR REPLACE PROCEDURE sp_updateUser
(
    username VARCHAR2,
    newpassword VARCHAR2 DEFAULT NULL
)
AS
    strSQL VARCHAR2(2000);
    BEGIN
    
    strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
    EXECUTE IMMEDIATE (strSQL);
    
    -- Update password
    IF newpassword IS NOT NULL THEN
        strSQL := 'ALTER USER '||username||' IDENTIFIED BY '||newpassword;
        EXECUTE IMMEDIATE (strSQL);
    END IF;
    
    strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT"=FALSE';
    EXECUTE IMMEDIATE (strSQL);
    
    END;

/
CREATE OR REPLACE PROCEDURE sp_getListUsers
AS
    strSQL VARCHAR(2000);
    BEGIN
    strSQL := 'SELECT * FROM ALL_USERS';
    EXECUTE IMMEDIATE (strSQL);
    END;
    
/
CREATE OR REPLACE PROCEDURE sp_checkLogin (
    username IN VARCHAR2,
    password IN VARCHAR2,
    login_success OUT NUMBER
)
AS
BEGIN
    login_success := 1;
    
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
        EXCEPTION
            WHEN OTHERS THEN NULL;
    END;

    EXECUTE IMMEDIATE 'BEGIN IF sys.dbms_assert.enquote_name('''||username||''') IS NULL THEN RAISE_APPLICATION_ERROR(-20001, ''Invalid username''); END IF; END;';

    BEGIN
        SELECT 1 INTO login_success
        FROM dual
        WHERE SYS_CONTEXT('USERENV', 'AUTHENTICATED_IDENTITY') = username
        AND DBMS_ASSERT.SQL_OBJECT_NAME(password) = 'USER$.' || SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') || '.PASSWORD'
        AND DBMS_ASSERT.ENQUOTE_NAME(password) = SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') || '.' || SYS_CONTEXT('USERENV', 'CURRENT_USER')
        AND SYS_CONTEXT('USERENV', 'SESSION_USER') = SYS_CONTEXT('USERENV', 'CURRENT_USER');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN login_success := 0;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=FALSE';
        EXCEPTION
            WHEN OTHERS THEN NULL;
    END;
END;

/
CREATE OR REPLACE PROCEDURE sp_connect(
    username IN VARCHAR2,
    password IN VARCHAR2,
    success OUT NUMBER
)
AS
    c       INTEGER;
    cur_val NUMBER;
    strSQL VARCHAR(2000);
BEGIN
  -- M? k?t n?i
    strSQL := 'CONNECT ' || username ||'/' ||password;
    c := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(c, strSQL, DBMS_SQL.NATIVE);
    cur_val := DBMS_SQL.EXECUTE(c);
    DBMS_SQL.CLOSE_CURSOR(c);
  
  -- Ki?m tra k?t n?i th�nh c�ng
  IF cur_val <> 0 THEN
    success := 1;
  ELSE
    success := 0;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    cur_val := 0;
END;

/
CREATE OR REPLACE PROCEDURE sp_sysPrivileges
(
    name VARCHAR2
)
AS
    strSQL VARCHAR(2000);
    
    BEGIN
    IF (name = 'MYADMIN') THEN
        strSQL := 'SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = '||name;
        EXECUTE IMMEDIATE (strSQL);
    ELSE
        strSQL := 'SELECT * FROM USER_SYS_PRIVS WHERE USERNAME = '||name;
        EXECUTE IMMEDIATE (strSQL);
    END IF;
    END;
    
/
CREATE OR REPLACE PROCEDURE sp_createRole (
    role_name IN VARCHAR2
)
AS
BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
    EXECUTE IMMEDIATE 'CREATE ROLE ' || role_name;
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=FALSE';
END;

/
CREATE OR REPLACE PROCEDURE sp_dropRole (
    role_name IN VARCHAR2
)
AS

BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
    EXECUTE IMMEDIATE 'DROP ROLE ' || role_name;
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=FALSE';
END;

/
CREATE OR REPLACE PROCEDURE grantTablePrivilegeWGO(
    p_username  IN VARCHAR2,
    p_privilege IN VARCHAR2,
    p_table     IN VARCHAR2
)
AS
BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
    EXECUTE IMMEDIATE 'GRANT ' || p_privilege || ' ON MYADMIN.' || p_table || ' TO ' || p_username || ' WITH GRANT OPTION';
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=FALSE';
END;

/
CREATE OR REPLACE PROCEDURE grantTablePrivilege(
    p_username  IN VARCHAR2,
    p_privilege IN VARCHAR2,
    p_table     IN VARCHAR2
)
AS
BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
    EXECUTE IMMEDIATE 'GRANT ' || p_privilege || ' ON MYADMIN.' || p_table || ' TO ' || p_username;
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=FALSE';
END;

/
CREATE OR REPLACE PROCEDURE revokeUserPrivilege (
  p_username IN VARCHAR2,
  p_privilege IN VARCHAR2,
  p_object_name IN VARCHAR2
)
IS
v_count NUMBER;
BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
    
    SELECT COUNT(*)
    INTO v_count
    FROM user_tab_privs
    WHERE GRANTEE = p_username
    AND table_name = p_object_name
    AND privilege = p_privilege;
    
    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'REVOKE '||p_privilege||' ON MYADMIN.'||p_object_name||' FROM '||p_username;
    END IF;
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=FALSE';
END;
/



