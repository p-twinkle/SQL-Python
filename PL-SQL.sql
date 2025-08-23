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

-- Control Flow
