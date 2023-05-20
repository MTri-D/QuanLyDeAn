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


GRANT ALL ON NHANVIEN TO MYADMIN WITH GRANT OPTION;
GRANT ALL ON PHONGBAN TO MYADMIN WITH GRANT OPTION;
GRANT ALL ON DEAN TO MYADMIN WITH GRANT OPTION;
GRANT ALL ON PHANCONG TO MYADMIN WITH GRANT OPTION;


CONNECT MYADMIN/123;
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
    EXECUTE IMMEDIATE 'GRANT ' || p_privilege || ' ON SYS.' || p_table || ' TO ' || p_username || ' WITH GRANT OPTION';
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
    EXECUTE IMMEDIATE 'GRANT ' || p_privilege || ' ON SYS.' || p_table || ' TO ' || p_username;
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
    FROM dba_tab_privs
    WHERE owner = p_username
    AND table_name = p_table_name
    AND privilege = p_privilege;
    
    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'REVOKE '||p_privilege||' ON SYS.'||p_object_name||' FROM '||p_username;
    END IF;
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT"=FALSE';
END;
/


--AN changes here
CREATE OR REPLACE PROCEDURE sp_addDepartment
(
    departmentID VARCHAR2,
    departmentName VARCHAR2,
    departmentHeadID NUMBER
)
AS
    strSQL VARCHAR(2000);
    
    BEGIN
    
    strSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE';
    EXECUTE IMMEDIATE (strSQL);

    strSQL := 'INSERT INTO SYS.PHONGBAN VALUES ('|| departmentName ||', '|| departmentID ||', '|| TO_CHAR(departmentHeadID) ||')';
    EXECUTE IMMEDIATE (strSQL);
    
    END;
   
/

EXECUTE sp_addDepartment('PB05', 'PHONG BAN SO 5', 5);
/*
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
*/



