-- Basic Blocks

DECLARE
var_fname   HR.EMPLOYEES.FIRST_NAME%TYPE;
var_lname   HR.EMPLOYEES.LAST_NAME%TYPE;
var_sal     HR.EMPLOYEES.SALARY%TYPE;
var_id      NUMBER:= 103;

BEGIN 
    SELECT  FIRST_NAME, LAST_NAME, SALARY
    INTO    var_fname,  var_lname, var_sal
    FROM HR.EMPLOYEES
    WHERE EMPLOYEE_ID IN (var_id);

    DBMS_OUTPUT.PUT_LINE('Employee - '|| var_fname || ' ' || var_lname || ' earns:' ||TO_CHAR(var_sal, '$999,999.00'));

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No Employee Found');
    WHEN TOO_MANY_ROWS THEN 
        DBMS_OUTPUT.PUT_LINE('Too many records returned');

END;
/

-- Control Flow --
-- 1. IF/ELSE
    
DECLARE 
v_band  VARCHAR(20);
v_sal   HR.EMPLOYEES.SALARY%TYPE;
v_emp   HR.EMPLOYEES.EMPLOYEE_ID%TYPE := 104;

BEGIN
    SELECT SALARY INTO v_sal
    FROM HR.EMPLOYEES
    WHERE EMPLOYEE_ID = v_emp;

    IF v_sal < 6000 THEN v_band := 'LOW';
    ELSIF v_sal < 10000 THEN v_band := 'MID';
    ELSE v_band := 'HIGH';
    END IF;

    DBMS_OUTPUT.PUT_LINE('Emp: ' || v_emp || ', Band: ' || v_band || ' with Salary: ' || TO_CHAR(v_sal, '$999,999.00'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('No Data.');
    WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('Too many records returned.');

END;
/

-- 2. CASE..WHEN 
    
DECLARE 
v_band  VARCHAR(20);
v_sal   HR.EMPLOYEES.SALARY%TYPE;
v_emp   HR.EMPLOYEES.EMPLOYEE_ID%TYPE := 104;

BEGIN
    SELECT SALARY INTO v_sal
    FROM HR.EMPLOYEES
    WHERE EMPLOYEE_ID = v_emp;

    v_band := CASE  WHEN v_sal < 6000 THEN 'LOW'
                    WHEN v_sal < 1000 THEN 'MID'
                    ELSE 'HIGH'
                END;

    DBMS_OUTPUT.PUT_LINE('Emp: ' || v_emp || ', Band: ' || v_band || ' with Salary: ' || TO_CHAR(v_sal, '$999,999.00'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('No Data.');
    WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('Too many records returned.');

END;
/

-- 3. LOOP / WHILE / FOR (counter loops)
-- Show the top N salaries in a department (here 60) using a counter.
    
DECLARE 
n           PLS_INTEGER := 5;
dept_id     HR.EMPLOYEES.DEPARTMENT_ID%TYPE := 60;

emp         HR.EMPLOYEES.EMPLOYEE_ID%TYPE;
fname       HR.EMPLOYEES.FIRST_NAME%TYPE;
sal         HR.EMPLOYEES.SALARY%TYPE;

BEGIN
    FOR i in 1..n LOOP
        BEGIN
            SELECT EMPLOYEE_ID, FIRST_NAME, SALARY
            INTO   emp, fname, sal
            FROM  (
                SELECT EMPLOYEE_ID, FIRST_NAME, SALARY
                , ROW_NUMBER() OVER(ORDER BY SALARY DESC) rn
                FROM HR.EMPLOYEES
                WHERE DEPARTMENT_ID = dept_id
                )
            WHERE rn = i;
            DBMS_OUTPUT.PUT_LINE('' ||i|| ': ' ||emp|| ' ' ||fname|| ', salary: '||TO_CHAR(sal,'$999,999.00'));       
        END;
    END LOOP;
END;
/






















