/*
7.	Вывести все даты за заданный при выполнении запроса период времени и соответствующие дни недели (без использования иерархических запросов и Model). 
Запрос написать в предположении, что интервал не будет превышать 1000 дней, а даты могут принимать любые значения, допустимые в СУБД Oracle.
*/

SELECT z2 "Дата" , z3 "День недели"
FROM
(SELECT TO_CHAR(z1 + ROWNUM, 'DD.MM.SYYYY') z2, TO_CHAR(z1 + ROWNUM, 'fmDay') z3
FROM
(SELECT TO_DATE('&date1', 'DD.MM.SYYYY') z1, 1
FROM dual
GROUP BY CUBE (1, 1, 1, 1, 1, 1, 1, 1, 1, 1))
WHERE ((z1 + ROWNUM) - TO_DATE('&date2', 'DD.MM.SYYYY')) <=0)
WHERE ROWNUM < 1001;

/*
12.	Для заданного отдела выведите фамилии и зарплаты трех самых высокооплачиваемых сотрудников. 
Если сотрудников в отделе меньше трех, выведите информацию по всем сотрудникам. 
Результат отсортировать по убыванию зарплаты. Номер отдела должен отображаться только у сотрудника с наибольшей зарплатой в отделе.
*/

WITH SUPPORT_TABLE
AS (SELECT e1.DEPARTMENT_ID, e1.EMP_COUNT, e2.EMPLOYEE_ID 
    FROM
    (SELECT DEPARTMENT_ID, COUNT(EMPLOYEE_ID) EMP_COUNT, MAX(SALARY) MAX_SAL
    FROM employees
    GROUP BY DEPARTMENT_ID) e1
    JOIN
    (SELECT EMPLOYEE_ID, DEPARTMENT_ID, SALARY
    FROM employees) e2
    ON ((e2.SALARY = e1.MAX_SAL) AND (e2.DEPARTMENT_ID = e1.DEPARTMENT_ID)))
SELECT CASE WHEN emp.EMPLOYEE_ID IN (SELECT EMPLOYEE_ID
                                     FROM SUPPORT_TABLE
                                     WHERE DEPARTMENT_ID = emp.DEPARTMENT_ID)
            THEN TO_CHAR(DEPARTMENT_ID)
            ELSE ' ' END DEPARTMENT_ID,
LAST_NAME, SALARY
FROM
    (SELECT DEPARTMENT_ID, LAST_NAME, EMPLOYEE_ID, SALARY
    FROM employees
    WHERE DEPARTMENT_ID = &dept_no
    ORDER BY SALARY DESC) emp
WHERE ROWNUM < 4;

--5.	Создать запрос для вывода списка дат и дней недели, начиная с заданной даты до конца месяца. Заданная дата может быть любой допустимой в СУБД датой.

define date1 = '30.12.-0001'

SELECT CASE WHEN TO_CHAR(TO_DATE('&&date1', 'DD.MM.SYYYY'),'SYYYY') < 0 THEN TO_CHAR(TO_DATE('&date1', 'DD.MM.SYYYY') + LEVEL-1, 'DD.MM.SYYYY')
            ELSE TO_CHAR(TO_DATE('&date1', 'DD.MM.SYYYY') + LEVEL-1, 'DD.MM.YYYY') END "Дата", 
       
       CASE WHEN TO_CHAR(TO_DATE('&&date1', 'DD.MM.SYYYY'),'SYYYY') < 0 THEN TO_CHAR(TO_DATE('&date1', 'DD.MM.SYYYY')+ LEVEL-1-5, 'fmDay')
       ELSE TO_CHAR(TO_DATE('&date1', 'DD.MM.SYYYY')+ LEVEL-1, 'fmDay') END "День недели"
FROM dual
CONNECT BY LEVEL<=(LAST_DAY(TO_DATE('&date1', 'DD.MM.SYYYY'))-TO_DATE('&date1', 'DD.MM.SYYYY'))+1;

/*
6.	Создать запрос для вывода только правильно написанных выражений со скобками (количество открывающих и закрывающих скобок должно быть одинаково, 
каждой открывающей скобке должна соответствовать закрывающая, первая скобка в выражении не должна быть закрывающей). Примеры неправильных выражений:
((((a)g)q)
z)(s)(
(((f)e)w))(h(g(w))
*/
SELECT CASE WHEN LENGTH('&&string1') IS NULL THEN 'Пустая строка'
        ELSE CASE WHEN NVL(LENGTH(REPLACE('&string1','(','')),0) = NVL(LENGTH(REPLACE('&string1',')','')),0)
                       AND NVL(LENGTH('&string1'),0)-NVL(LENGTH(REPLACE('&string1','(','')),0) = 0
                  THEN 'В строке нет открывающих и закрывающих скобок'
                  WHEN NVL(LENGTH(REPLACE('&string1','(','')),0) <> NVL(LENGTH(REPLACE('&string1',')','')),0)
                       AND NVL(LENGTH('&string1'),0)-NVL(LENGTH(REPLACE('&string1','(','')),0) = 0
                  THEN 'В строке нет открывающих скобок'
                   WHEN NVL(LENGTH(REPLACE('&string1','(','')),0) <> NVL(LENGTH(REPLACE('&string1',')','')),0)
                       AND NVL(LENGTH('&string1'),0)-NVL(LENGTH(REPLACE('&string1',')','')),0) = 0
                  THEN 'В строке нет закрывающих скобок'
             ELSE CASE WHEN (LENGTH('&string1')-NVL(LENGTH(REPLACE('&string1','(','')),0))<>(LENGTH('&string1')-NVL(LENGTH(REPLACE('&string1',')','')),0))
                       THEN 'Разное количество открывающих и закрывающих скобок'
                       WHEN 0 > ANY (SELECT (LENGTH(SUBSTR('&string1', 1, level)) - NVL(LENGTH(REPLACE(SUBSTR('&string1', 1, level),'(','')),0)) - (LENGTH(SUBSTR('&&string1', 1, level)) - NVL(LENGTH(REPLACE(SUBSTR('&string1', 1, level),')','')),0))
                                      FROM dual
                                      CONNECT BY level <= LENGTH('&string1')) 
                       THEN 'Нарушен порядок скобок'
                       ELSE 'В строке '||'&string1'||' нет нарушений' END             
             END        
        END "Анализ строки"
FROM dual;

/*8.	В произвольной строке, состоящей из символьных элементов, разделенных запятыми, отсортировать элементы по алфавиту. Например, символьную строку
abc,cde,ef,gh,mn,test,ss,df,fw,ewe,wwe
преобразовать к виду:
abc,cde,df,ef,ewe,fw,gh,mn,ss,test,wwe.
*/

SELECT CASE WHEN LENGTH('&&string2') IS NULL THEN 'Введена пустая строка'
            WHEN INSTR('&string2', ',', 1, 1) = 0 THEN '&string2'
        ELSE (SELECT LTRIM(SYS_CONNECT_BY_PATH(str, ','), ',')
                FROM 
                    (SELECT str, ROWNUM R
                    FROM
                        (SELECT str
                        FROM
                            (SELECT CASE WHEN LEVEL = 1 
                                        THEN SUBSTR('&string2', 1, INSTR('&string2', ',', 1, LEVEL) - 1)
                                        WHEN LEVEL = LENGTH('&string2')-NVL(LENGTH(REPLACE('&string2',',','')),0)+1
                                        THEN SUBSTR('&string2', INSTR('&string2', ',', 1, LEVEL-1) + 1, LENGTH('&string2') - INSTR('&string2', ',', 1, LEVEL-1))
                                        ELSE SUBSTR('&string2', INSTR('&string2', ',', 1, LEVEL-1)+1, INSTR('&string2', ',', 1, LEVEL) - INSTR('&string2', ',', 1, LEVEL-1)-1)  END str
                            FROM dual
                            CONNECT BY LEVEL <= LENGTH('&string2')-NVL(LENGTH(REPLACE('&string2',',','')),0)+1)
                        ORDER BY str))
                WHERE R = LENGTH('&string2')-NVL(LENGTH(REPLACE('&string2',',','')),0)+1        
                START WITH R = 1
                CONNECT BY PRIOR R = R-1)   
        END "Сортировка строки"
FROM dual;  

/*
9.	Создать запрос для определения сумм окладов сотрудников от сотрудников, не имеющих начальника, до сотрудников, не имеющих подчиненных. 
Пример результата: 
Номер	Список сотрудников	Сумма зарплат
1	King->Kochhar->Greenberg->Faviet 	62000
	… 	…
30	King->Hartstein->Fay 	43000
Результат отсортировать в порядке убывания Суммы зарплат
*/

SELECT ROWNUM "Номер", EMP "Список сотрудников", SUM_SAL "Сумма зарплат"
FROM
    (SELECT LTRIM(SYS_CONNECT_BY_PATH(LAST_NAME, '->'),'->') EMP, 
        (SELECT SUM(SALARY)  
        FROM employees emp2
        START WITH EMPLOYEE_ID = emp1.EMPLOYEE_ID
        CONNECT BY PRIOR  MANAGER_ID = EMPLOYEE_ID) SUM_SAL
    FROM employees emp1
    WHERE EMPLOYEE_ID NOT IN (SELECT DISTINCT MANAGER_ID
                              FROM employees
                              WHERE MANAGER_ID IS NOT NULL)
    START WITH MANAGER_ID IS NULL
    CONNECT BY PRIOR EMPLOYEE_ID = MANAGER_ID
    ORDER BY SUM_SAL DESC);

/*
3.	Создать запрос для выделения собственно имени файла из полного его имени. 
(Полное имя файла начинается с имени диска или имени сервера. Оно может содержать произвольное количество имен папок. 
Имя файла может иметь или не иметь расширения. Допускаются пробелы в именах  файлов и папок).
*/

define dir = 'D:\soft\sqldeveloper\jviews\jviews-framework-lib.jar'  

SELECT '&&dir' DIR, REGEXP_REPLACE('&dir', '.*[\\\/]|\.[^.]*$', '') AS NAME
FROM dual;

/*
4.	Создать запрос для выделения из символьной строки повторяющихся, стоящих рядом одинаковых слов. Примеры:
Символьная строка	Повторяющиеся слова
Кулон лон слон слон слон Книга     книга  	слон слон слон
	Книга книга
Мама мыла раму раму мыла мама	раму раму */

define str4 = 'rr  r  rrr  rrr  rrr  rr-rr  rr-rr  кк. rr r м м rr rr rr r r r у точь-в-точь точь-в-точь точь-в-точь кое-как  кое-как точь-в-точь у у кк.  rr  rr_  rr_  r  r  rr  rrr  rr  rrr  rrr  rrrr  rrr  rr  rr'

SELECT CASE WHEN LEVEL > 1 THEN ' ' ELSE '&&str4' END "Символьная строка", 
REGEXP_REPLACE(NVL(REGEXP_SUBSTR(REGEXP_REPLACE('&str4', '[ ]+', '  '),'(^|[ ]{1})((([А-ЯЁа-яёa-zA-Z])+([-]{1}[А-ЯЁа-яёa-zA-Z]+){0,})|[А-ЯЁа-яёa-zA-Z]{1})[ ]{1}([ ]{1}\2([ ]|$){1}){1,}',1,LEVEL,'i'),'Нет повторяющихся слов'), '[ ]{2,}', ' ')  "Повторяющиеся слова"
FROM dual
CONNECT BY REGEXP_SUBSTR(REGEXP_REPLACE('&str4', '[ ]+', '  '),'(^|[ ]{1})((([А-ЯЁа-яёa-zA-Z])+([-]{1}[А-ЯЁа-яёa-zA-Z]+){0,})|[А-ЯЁа-яёa-zA-Z]{1})[ ]{1}([ ]{1}\2([ ]|$){1}){1,}',1,LEVEL,'i') IS NOT NULL;


/*
6.	Создать запрос для выделения только правильно написанных адресов электронной почты.
Под правильно написанными адресами почты будем понимать адреса, соответствующие следующим критериям:
a)	содержащие поля имя_пользователя и имя_домена, разделённые одним символом @
b)	полное имя домена может состоять из нескольких уровней, разделённых точкой (например, alias.spb.ru), точки в самом конце адреса быть не должно (например, 123@asd.com. – некорректный). Имя домена любого уровня (и alias, и spb, и ru) должно содержать не менее 2 символов. 
c)	имя пользователя может содержать точку, но не на первой и не на последней позиции
d)	имена пользователя и домена (любого уровня) могут содержать дефис, но не на первой и не на последней позиции.
e)	имена пользователя и домена не должны содержать никаких других символов, кроме букв, цифр, дефиса и точки (адрес 1%#23@asd.com.ua должен определяться как некорректный).
*/

define str5 = 'iva6@a--lias.s-p--b.r--u'

SELECT CASE WHEN REGEXP_SUBSTR('&&str5', '^((([[:alnum:]]){1}([[:alnum:]]|[\.-]){0,}([[:alnum:]]){1})|([[:alnum:]]{1}))@{1}[[:alnum:]]([[:alnum:]]|[-]){0,}[[:alnum:]]([\.][[:alnum:]]([[:alnum:]]|[-]){0,}[[:alnum:]]){0,}$') IS NULL THEN 'Адрес '||'&str5'||' неверный'  
            ELSE 'Адрес '||'&str5'||' правильный' END "Проверка адреса"
FROM dual;

/*
7.	Создать запрос для определения в тексте чисел, за которыми ни в одном месте текста не стоит знак  +. Знак числа не выводить. 
Предположить, что разделителей разрядов в тексте нет. Результат отсортировать по возрастанию. Пример:
Текст	Результат
Результатом вычисления выражения 2.5*3-6*5 будет число -22.5, а результатом вычисления выражения (3+5)-9*4 – число -28	2.5 4 5 6 9 22.5 28
*/

define str6 = 'Результатом вычисления выражения 2.5*3-6*5 будет число -22.5, а результатом выч.исления выражения .(.3+5)-9*4 – ч.исло -28  -0.00700 000000.0987000 0.8+++ 0.00000009 00.00000700800 8976.9998765 100000000.0000000001110006     +++ 56575685  0025000++ +  0';

SELECT '&&str6' "Текст", NUMBERS "Результат"
FROM
(SELECT LTRIM(SYS_CONNECT_BY_PATH(NUMBERS, ' '),' ') NUMBERS
FROM 
    (SELECT NUMBERS, ROWNUM R
    FROM
        (SELECT NUMBERS
         FROM 
            (SELECT DISTINCT CASE WHEN REGEXP_SUBSTR(REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})', 1, LEVEL), '([1-9]\d{0,}|[0]{1})([.]\d{0,}[1-9]){1}', 1, 1) IS NOT NULL 
                            THEN REGEXP_SUBSTR(REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})', 1, LEVEL), '([1-9]\d{0,}|[0]{1})([.]\d{0,}[1-9]){1}', 1, 1)
                            ELSE REGEXP_SUBSTR(REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})', 1, LEVEL), '([1-9]\d{0,})|^[0]{1}$', 1, 1)
                            END NUMBERS  
            FROM dual
            CONNECT BY REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})', 1, LEVEL) IS NOT NULL
            MINUS
            SELECT CASE WHEN REGEXP_SUBSTR(RTRIM(REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})[+]', 1, LEVEL), '+'), '([1-9]\d{0,}|[0]{1})([.]\d{0,}[1-9]){1}', 1, 1) IS NOT NULL 
                        THEN REGEXP_SUBSTR(RTRIM(REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})[+]', 1, LEVEL), '+'), '([1-9]\d{0,}|[0]{1})([.]\d{0,}[1-9]){1}', 1, 1)
                        ELSE REGEXP_SUBSTR(RTRIM(REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})[+]', 1, LEVEL), '+'), '([1-9]\d{0,})|^[0]{1}$', 1, 1)  END  
            FROM dual
            CONNECT BY REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})[+]', 1, LEVEL) IS NOT NULL)            
         ORDER BY TO_NUMBER(REPLACE(NUMBERS, '.', ','))))
WHERE R = (SELECT COUNT(*) 
           FROM ((SELECT NUMBERS
                  FROM 
                    (SELECT DISTINCT CASE WHEN REGEXP_SUBSTR(REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})', 1, LEVEL), '([1-9]\d{0,}|[0]{1})([.]\d{0,}[1-9]){1}', 1, 1) IS NOT NULL 
                     THEN REGEXP_SUBSTR(REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})', 1, LEVEL), '([1-9]\d{0,}|[0]{1})([.]\d{0,}[1-9]){1}', 1, 1)
                     ELSE REGEXP_SUBSTR(REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})', 1, LEVEL), '([1-9]\d{0,})|^[0]{1}$', 1, 1)
                     END NUMBERS  
                    FROM dual
                    CONNECT BY REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})', 1, LEVEL) IS NOT NULL
                    MINUS
                    SELECT CASE WHEN REGEXP_SUBSTR(RTRIM(REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})[+]', 1, LEVEL), '+'), '([1-9]\d{0,}|[0]{1})([.]\d{0,}[1-9]){1}', 1, 1) IS NOT NULL 
                        THEN REGEXP_SUBSTR(RTRIM(REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})[+]', 1, LEVEL), '+'), '([1-9]\d{0,}|[0]{1})([.]\d{0,}[1-9]){1}', 1, 1)
                        ELSE REGEXP_SUBSTR(RTRIM(REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})[+]', 1, LEVEL), '+'), '([1-9]\d{0,})|^[0]{1}$', 1, 1)  END  
                    FROM dual
                    CONNECT BY REGEXP_SUBSTR('&str6','([[:digit:]]+[.]?[[:digit:]]{0,})[+]', 1, LEVEL) IS NOT NULL)            
            ORDER BY TO_NUMBER(REPLACE(NUMBERS, '.', ',')))))
START WITH R = 1
CONNECT BY PRIOR R = R-1);
/*
8.	Создать запрос для выбора из текста дробных чисел с разделителем дробной части в виде точки. Тройки цифр целой части могут разделяться пробелом, запятой или ничем не разделяться. Дробная часть всегда записывается слитно. Совместное использование разных разделителей в одном числе не допускается. Примеры:
Текст	Результат
Пусть имеем 212 45 567.456 789 или 212,13,245.4568	45 567.456
	13,245.4568
Имеется123456.345 567,1723 456.375	123456.345
	723 456.375
*/
define str8 = 'Пусть имеем 212.001 45 567.000 789.000 или 212,13,245.4568 или .567.2892.302.729.000.000.7770 или 0 010 000.000567000900 или 000 000.90100 или 0.1 или 0.000 или 0,000,000.000050';
   
SELECT CASE WHEN LEVEL > 1 THEN ' ' ELSE '&&str8' END "Текст", NVL(REGEXP_SUBSTR('&str8', '([0]|[1-9]\d{0,}|[1-9]\d{1,2}([ ]\d{3})+|[1-9]\d{1,2}([,]\d{3})+)[.]{1}\d{0,}[1-9]', 1, LEVEL),0) "Результат"
FROM dual
CONNECT BY REGEXP_SUBSTR('&str8','([0]|[1-9]\d{0,}|[1-9]\d{1,2}([ ]\d{3})+|[1-9]\d{1,2}([,]\d{3})+)[.]{1}\d{0,}[1-9]', 1, LEVEL) IS NOT NULL;

--9.	Написать запрос к таблице, который вернёт значения столбца, где все пары прямых скобок в строке, внутри которых нет других прямых скобок, заменены на полукруглые скобки.

define str9 = 'A[[B[C][]E[F[J]]H][K]L]M'

SELECT '&&str9' "Значение", REGEXP_REPLACE('&str9', '\[([^][]*)]', '(\1)') "Результат"
FROM dual;
