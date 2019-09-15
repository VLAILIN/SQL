--6.	Определить временной интервал между двумя произвольно заданными датами (возможно и до нашей эры). 
--Результат вывести в виде: хх лет хх мес хх дней, где хх обозначает цифру. 

SELECT TO_CHAR(TRUNC(MONTHS_BETWEEN(TO_DATE('&&DATE1','DD.MM.SYYYY'), TO_DATE('&&DATE2','DD.MM.SYYYY'))/12))||' лет '
||TO_CHAR(TRUNC(MONTHS_BETWEEN(TO_DATE('&DATE1','DD.MM.SYYYY'), TO_DATE('&DATE2','DD.MM.SYYYY'))-12*TRUNC(MONTHS_BETWEEN(TO_DATE('&DATE1','DD.MM.SYYYY'), TO_DATE('&DATE2','DD.MM.SYYYY'))/12)))||' мес '
||TO_CHAR(TO_DATE('&DATE1','DD.MM.SYYYY')- ADD_MONTHS(TO_DATE('&DATE2','DD.MM.SYYYY'), TRUNC(MONTHS_BETWEEN(TO_DATE('&DATE1','DD.MM.SYYYY'),TO_DATE('&DATE2','DD.MM.SYYYY'))))) || ' дней' RAZNICA
FROM dual;

--7.	В названии отдела вывести только второе слово, если название состоит из двух или более слов. Иначе вывести первое слово.
SELECT CASE 
WHEN INSTR(DEPARTMENT_NAME,' ',1,1)<>0 AND INSTR(DEPARTMENT_NAME,' ',1,2)<>0 THEN SUBSTR(DEPARTMENT_NAME,INSTR(DEPARTMENT_NAME,' ')+1,(INSTR(DEPARTMENT_NAME,' ',1,2) - INSTR(DEPARTMENT_NAME,' ',1,1)))
WHEN INSTR(DEPARTMENT_NAME,' ',1,1)<>0 AND INSTR(DEPARTMENT_NAME,' ',1,2)=0 THEN SUBSTR(DEPARTMENT_NAME,INSTR(DEPARTMENT_NAME,' ')+1)
ELSE DEPARTMENT_NAME END DEPARTMENT_NAME 
FROM departments;

--11.	Определить сумму цифр в произвольной символьной строке.
SELECT 
(NVL(LENGTH('&&stroka'),0)-NVL(LENGTH(REPLACE('&stroka','1','')),0))*1+
(NVL(LENGTH('&stroka'),0)-NVL(LENGTH(REPLACE('&stroka','2','')),0))*2+
(NVL(LENGTH('&stroka'),0)-NVL(LENGTH(REPLACE('&stroka','3','')),0))*3+
(NVL(LENGTH('&stroka'),0)-NVL(LENGTH(REPLACE('&stroka','4','')),0))*4+
(NVL(LENGTH('&stroka'),0)-NVL(LENGTH(REPLACE('&stroka','5','')),0))*5+
(NVL(LENGTH('&stroka'),0)-NVL(LENGTH(REPLACE('&stroka','6','')),0))*6+
(NVL(LENGTH('&stroka'),0)-NVL(LENGTH(REPLACE('&stroka','7','')),0))*7+
(NVL(LENGTH('&stroka'),0)-NVL(LENGTH(REPLACE('&stroka','8','')),0))*8+
(NVL(LENGTH('&stroka'),0)-NVL(LENGTH(REPLACE('&stroka','9','')),0))*9 SUMMA
FROM dual;

/*10.	Создать запрос для определения списка городов, в которых расположены департаменты, суммарная заработная плата в которых выше средней суммарной заработной платы в департаментах этого города. В результат вывести:  
название города;
название департамента;
средняя суммарная зарплата в городе;
суммарная зарплата в департаменте;*/
SELECT CITY, a.DEPARTMENT_NAME, b.AVG_SUM_SALARY, a.SUM_SALARY
 FROM (SELECT d.DEPARTMENT_NAME, AVG(e.SALARY) AVG_SALARY, SUM(e.SALARY) SUM_SALARY, l.CITY
    FROM employees e JOIN departments d
    ON (e.DEPARTMENT_ID = d.DEPARTMENT_ID)
    JOIN locations l
    ON d.LOCATION_ID = l.LOCATION_ID
    GROUP BY d.DEPARTMENT_NAME, l.CITY) a
 NATURAL JOIN
    (SELECT CITY, AVG(SUM_SALARY) AVG_SUM_SALARY
    FROM(SELECT d.DEPARTMENT_NAME, AVG(e.SALARY) AVG_SALARY, SUM(e.SALARY) SUM_SALARY, l.CITY
        FROM employees e JOIN departments d
        ON (e.DEPARTMENT_ID = d.DEPARTMENT_ID)
        JOIN locations l
        ON d.LOCATION_ID = l.LOCATION_ID
        GROUP BY d.DEPARTMENT_NAME, l.CITY)
    GROUP BY CITY) b
 WHERE a.SUM_SALARY > b.AVG_SUM_SALARY;

--12.	Выведите фамилии сотрудников, их зарплату и накопленную сумму зарплат (от наибольшей к наименьшей).

SELECT e.LAST_NAME, e.SALARY, SUM(m.SALARY) SUMSAL
FROM employees e
JOIN employees m
ON e.EMPLOYEE_ID >= m.EMPLOYEE_ID
GROUP BY e.EMPLOYEE_ID, e.LAST_NAME, e.SALARY
ORDER BY SUMSAL DESC;

--13.	Вывести фамилии сотрудников, их зарплату и плотный ранг зарплаты (от наибольшей к наименьшей).

SELECT e.LAST_NAME, e.SALARY, s.RANK 
FROM (SELECT SALARY, ROWNUM RANK 
        FROM (SELECT DISTINCT SALARY 
                FROM EMPLOYEES 
                ORDER BY SALARY DESC)) s 
JOIN EMPLOYEES e 
ON e.SALARY = s.SALARY 
ORDER BY RANK;

--15
/*
Из таблицы Employees необходимо выбрать такие
пары окладов, суммы которых также содержатся в этой таблице.
Также необходимо вывести идентификаторы сотрудников, с
окладами, удовлетворяющими условию задачи.
*/
SELECT TO_CHAR(SAL1)||','||TO_CHAR(SAL2)||'->'||TO_CHAR(SALARY) "Оклады",
TO_CHAR(ID1)||','||TO_CHAR(ID2)||'->'||TO_CHAR(EMPLOYEE_ID) "Сотрудники"
FROM
(SELECT emp1.EMPLOYEE_ID ID1, emp1.SALARY SAL1, emp2.EMPLOYEE_ID ID2, emp2.SALARY SAL2
FROM EMPLOYEES emp1
CROSS JOIN EMPLOYEES emp2
WHERE emp1.EMPLOYEE_ID<>emp2.EMPLOYEE_ID) e1
JOIN 
(SELECT EMPLOYEE_ID, SALARY
FROM EMPLOYEES )e2
ON e1.SAL1 + e1.SAL2 = e2.SALARY;
