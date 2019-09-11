--2 ������
SELECT DEPARTMENT_ID "����� ������", DEPARTMENT_NAME "�������� ������", 
    NVL((SELECT LTRIM(SYS_CONNECT_BY_PATH(LAST_NAME, ','), ',') 
    FROM (SELECT LAST_NAME, ROWNUM R 
          FROM 
          (SELECT LAST_NAME
           FROM EMPLOYEES
            WHERE DEPARTMENT_ID = d.DEPARTMENT_ID
            ORDER BY LAST_NAME))
    WHERE R = (SELECT COUNT(LAST_NAME)
                FROM EMPLOYEES
                WHERE DEPARTMENT_ID = d.DEPARTMENT_ID)       
    START WITH R = 1
    CONNECT BY PRIOR R = R - 1), '����������� � ������ ���') "������� �����������"
FROM DEPARTMENTS d;

-- 1 ������
WITH TABLE_CON AS
 (SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE, CON_NUM
 FROM
    (SELECT uc1.TABLE_NAME, uc1.CONSTRAINT_NAME, uc1.CONSTRAINT_TYPE, COUNT(ucc1.COLUMN_NAME) CON_NUM
    FROM user_cons_columns ucc1
    JOIN user_constraints uc1
    ON ucc1.TABLE_NAME = uc1.TABLE_NAME
    AND ucc1.CONSTRAINT_NAME = uc1.CONSTRAINT_NAME
    GROUP BY uc1.TABLE_NAME, uc1.CONSTRAINT_NAME, uc1.CONSTRAINT_TYPE)
WHERE CON_NUM > 1),
TABLE_TMP AS
(SELECT ut.TABLE_NAME, tc.CONSTRAINT_NAME, tc.CONSTRAINT_TYPE, tc.CON_NUM,
(SELECT COUNT(tc1.CONSTRAINT_TYPE)
FROM TABLE_CON tc1
WHERE TABLE_NAME = ut.TABLE_NAME) CON_CON, ROWNUM R
FROM USER_TABLES ut
LEFT OUTER JOIN TABLE_CON tc
ON ut.TABLE_NAME = tc.TABLE_NAME),
TABLE_TMP_R AS
(SELECT TABLE_NAME, MIN(R) R
FROM TABLE_TMP
GROUP BY TABLE_NAME)
SELECT CASE WHEN R1 = R2 THEN TABLE_NAME
       ELSE ' ' END "�������",
       NVL(CONSTRAINT_NAME, '��� �����������. �����������') "��� �����������",
       CASE CONSTRAINT_TYPE WHEN 'P' THEN '��������� ����'
       WHEN 'U' THEN '����������� UNIQUE'
       WHEN 'C' THEN '����������� CHECK'
       WHEN 'R' THEN '��������� ����'
       ELSE '��� �����������. �����������' END "��� �����������",
       NVL(CON_NUM, 0) "���-�� ��������",
       CASE WHEN R1 = R2 THEN TO_CHAR(NVL(CON_CON, 0))
       ELSE ' ' END "���-�� �����������. ��������"     
FROM 
(SELECT tt.TABLE_NAME, tt.CONSTRAINT_NAME, tt.CONSTRAINT_TYPE, tt.CON_NUM, tt.CON_CON, tt.R R1, ttr.R R2
FROM TABLE_TMP tt
LEFT OUTER JOIN TABLE_TMP_R ttr
ON tt.TABLE_NAME = ttr.TABLE_NAME
AND tt.R = ttr.R);

--3 ������

SELECT n1 "���������", CASE WHEN c1 = '��� ����������' THEN c1
                        ELSE c1||' '||'('||str1||')' END "���������"
FROM
(SELECT e1.FIRST_NAME||' '||e1.LAST_NAME n1, 
CASE TO_CHAR(REGEXP_COUNT(e1.LAST_NAME, '['||e1.FIRST_NAME||']', 1, 'i')) WHEN '1' THEN '��������� ���� �����'
WHEN '2' THEN '��������� ��� �����'
WHEN '3' THEN '��������� ��� �����'
WHEN '4' THEN '��������� ������ �����'
WHEN '5' THEN '��������� ���� ����'
WHEN '6' THEN '��������� ����� ����'
WHEN '7' THEN '��������� ���� ����'
WHEN '8' THEN '��������� ������ ����'
WHEN '9' THEN '��������� ������ ����'
WHEN '0' THEN '��� ����������'
ELSE '��������� ����� ����' END c1,
e1.employee_id,
(SELECT LTRIM(SYS_CONNECT_BY_PATH(SYM, ','), ',') sb1
FROM
    (SELECT REGEXP_SUBSTR(LAST_NAME, '['||FIRST_NAME||']', 1, LEVEL, 'i') SYM, ROWNUM R
    FROM (SELECT FIRST_NAME, LAST_NAME, EMPLOYEE_ID 
          FROM employees
          WHERE EMPLOYEE_ID = e1.employee_id)
    CONNECT BY REGEXP_SUBSTR(LAST_NAME, '['||FIRST_NAME||']', 1, LEVEL, 'i') IS NOT NULL)
WHERE R = (SELECT COUNT(SYM)
                FROM 
                (SELECT REGEXP_SUBSTR(LAST_NAME, '['||FIRST_NAME||']', 1, LEVEL, 'i') SYM, ROWNUM R
                FROM (SELECT FIRST_NAME, LAST_NAME, EMPLOYEE_ID 
                 FROM employees
                WHERE EMPLOYEE_ID = e1.employee_id)
                CONNECT BY REGEXP_SUBSTR(LAST_NAME, '['||FIRST_NAME||']', 1, LEVEL, 'i') IS NOT NULL))       
START WITH R = 1
CONNECT BY PRIOR R = R - 1) str1
FROM employees e1);



