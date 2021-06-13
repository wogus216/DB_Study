-- [3주차 문제2](수정)
-- 판매 직원들별로(사장 제외) 주문 수량이 100개 이상이며, 수익을 낸 주문들의 총 합중에서 가장 큰 값을 작은값으로 나머지값을 구하고(소수점제외)
-- 모든 직원들과 고객들의 핸드폰 번호의 제일 마지막자리가 이전에 구한 값의 차의 숫자중에(1~5자리) 하나라도 포함된 사람들을 출력하시오
-- 출력필드: ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL (EMPLOYEE와 CUSTOMER를 구분하기 위해 ID앞에 EM 또는 CS표시를 하고 CS사람들을 먼저 출력하시오)
-- EX) 차이가 65432 나오면 휴대전화 마지막 자리가 6, 5, 4, 3, 2 인 사람들을 출력하면 됩니다
-- CS 72명 / EM 54명 나옵니다

SELECT O.SALESMAN_ID,SUM(OI.QUANTITY * OI.UNIT_PRICE) AS RSUM,RANK() OVER(ORDER BY SUM(OI.QUANTITY * OI.UNIT_PRICE) DESC) AS RNK
FROM ORDERS O INNER JOIN ORDER_ITEMS OI
                     ON O.ORDER_ID = OI.ORDER_ID
                    AND O.STATUS = 'Shipped'
                    AND OI.QUANTITY >= 100
              INNER JOIN EMPLOYEES E
                   ON O.SALESMAN_ID = E.EMPLOYEE_ID
GROUP BY O.SALESMAN_ID
;

-- 모든 직원들과 고객들의 핸드폰 번호의 제일 마지막자리가 이전에 구한 값의 차의 숫자중에(1~5자리) 하나라도 포함된 사람들을 출력하시오
-- 출력필드: ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL (EMPLOYEE와 CUSTOMER를 구분하기 위해 ID앞에 EM 또는 CS표시를 하고 CS사람들을 먼저 출력하시오)
-- EX) 차이가 65432 나오면 휴대전화 마지막 자리가 6, 5, 4, 3, 2 인 사람들을 출력하면 됩니다
-- CS 72명 / EM 54명 나옵니다
SELECT  FLOOR(MOD(MAX(A.RSUM),MIN(A.RSUM))) AS RESULT
FROM (SELECT O.SALESMAN_ID,SUM(OI.QUANTITY * OI.UNIT_PRICE) AS RSUM,RANK() OVER(ORDER BY SUM(OI.QUANTITY * OI.UNIT_PRICE) DESC) AS RNK
      FROM ORDERS O INNER JOIN ORDER_ITEMS OI
                             ON O.ORDER_ID = OI.ORDER_ID
                            AND O.STATUS != 'Shipped'
                            AND OI.QUANTITY >= 100
                      INNER JOIN EMPLOYEES E
                           ON O.SALESMAN_ID = E.EMPLOYEE_ID
      GROUP BY O.SALESMAN_ID)A
;


SELECT  SUBSTR(R2.RESULT,0,5) AS R
FROM   (SELECT  FLOOR(MOD(MAX(A.RSUM),MIN(A.RSUM))) AS RESULT
            FROM (SELECT O.SALESMAN_ID,SUM(OI.QUANTITY * OI.UNIT_PRICE) AS RSUM,RANK() OVER(ORDER BY SUM(OI.QUANTITY * OI.UNIT_PRICE) DESC) AS RNK
      FROM ORDERS O INNER JOIN ORDER_ITEMS OI
                             ON O.ORDER_ID = OI.ORDER_ID
                            AND O.STATUS = 'Shipped'
                            AND OI.QUANTITY >= 100
                      INNER JOIN EMPLOYEES E
                           ON O.SALESMAN_ID = E.EMPLOYEE_ID
      GROUP BY O.SALESMAN_ID)A) R2
;

SELECT ('(EM)' ||FIRST_NAME || LAST_NAME),PHONE,SUBSTR(PHONE,-1,1), EMAIL FROM EMPLOYEES
UNION 
SELECT ('(CS)' ||FIRST_NAME || LAST_NAME),PHONE,SUBSTR(PHONE,-1,1), EMAIL FROM CONTACTS 
;



SELECT *
FROM   (SELECT ('(EM)' ||FIRST_NAME || LAST_NAME),PHONE,SUBSTR(PHONE,-1,1) AS EN, EMAIL FROM EMPLOYEES
        UNION 
        SELECT ('(CS)' ||FIRST_NAME || LAST_NAME),PHONE,SUBSTR(PHONE,-1,1) AS EN, EMAIL FROM CONTACTS ) NA INNER  JOIN (SELECT  FLOOR(MOD(MAX(A.RSUM),MIN(A.RSUM))) AS RESULT
                                                                                                                        FROM (SELECT O.SALESMAN_ID,SUM(OI.QUANTITY * OI.UNIT_PRICE) AS RSUM,
                                                                                                                                RANK() OVER(ORDER BY SUM(OI.QUANTITY * OI.UNIT_PRICE) DESC) AS RNK
                                                                                                                              FROM ORDERS O INNER JOIN ORDER_ITEMS OI
                                                                                                                                                    ON O.ORDER_ID = OI.ORDER_ID
                                                                                                                                                   AND O.STATUS = 'Shipped'
                                                                                                                                                   AND OI.QUANTITY >= 100
                                                                                                                                            INNER JOIN EMPLOYEES E
                                                                                                                                                    ON O.SALESMAN_ID = E.EMPLOYEE_ID
                                                                                                                              GROUP BY O.SALESMAN_ID)A) R
                                                                                                                  ON 1=1
                                                                                                                AND  NA.EN IN( SUBSTR(R.RESULT,0,1),SUBSTR(R.RESULT,1,1),SUBSTR(R.RESULT,2,1))

                                                                                 
;


-- [3주차 문제3]
-- 한도가 3500에서 4500사이인 회사들을 구하고 웹사이트 이름의 공통된 부분을 제외하고 회사명의 글자길이(공백제외)와 웹사이트명의 글자 길이를 비교해서
-- 회사명의 글자길이가 웹사이트명의 글자길이보다 크면 한도 1.3배, 같으면 1.5배, 작으면 1.7배 해준뒤 전체 회사들의 한도와 비교하여 6위까지와 300백위 밑을 출력하시오
-- 출력필드: 이름, 웹사이트 이름, 크레딧 포인트, 랭킹
-- EX)https://abcdefg.com -> abcdefg (공통된 부분 제외)

SELECT  NAME,WEBSITE,CREDIT_LIMIT,REPLACE(NAME,' ','') AS CNAME,SUBSTR(SUBSTR(WEBSITE,INSTR(WEBSITE,'.',1)+1),0,INSTR(SUBSTR(WEBSITE,INSTR(WEBSITE,'.',1)+1),'.',1)-1) AS WNAME
FROM CUSTOMERS 
WHERE CREDIT_LIMIT BETWEEN 3500 AND 4500
;

SELECT R.*, CASE WHEN LENGTH(CNAME) > LENGTH(WNAME)
            THEN R.CREDIT_LIMIT * 1.3
            WHEN LENGTH(CNAME) = LENGTH(WNAME)
            THEN R.CREDIT_LIMIT * 1.5
            ELSE R.CREDIT_LIMIT * 1.7
            END AS RLIMIT
FROM (SELECT  NAME,WEBSITE,CREDIT_LIMIT,
        REPLACE(NAME,' ','') AS CNAME,
        SUBSTR(SUBSTR(WEBSITE,INSTR(WEBSITE,'.',1)+1),0,INSTR(SUBSTR(WEBSITE,INSTR(WEBSITE,'.',1)+1),'.',1)-1) AS WNAME
      FROM CUSTOMERS 
      WHERE CREDIT_LIMIT BETWEEN 3500 AND 4500) R
;



SELECT R3.*
FROM   (SELECT CU.NAME,CU.WEBSITE, CASE WHEN R2.RLIMIT IS NULL
                                            THEN CU.CREDIT_LIMIT
                                            ELSE R2.RLIMIT
                                            END AS LIMIT,
                  RANK() OVER (ORDER BY CASE WHEN R2.RLIMIT IS NULL
                                            THEN CU.CREDIT_LIMIT
                                            ELSE R2.RLIMIT
                                            END DESC) AS RNK
            FROM CUSTOMERS CU LEFT OUTER JOIN (SELECT R.*, CASE WHEN LENGTH(CNAME) > LENGTH(WNAME)
                                                           THEN R.CREDIT_LIMIT * 1.3
                                                           WHEN LENGTH(CNAME) = LENGTH(WNAME)
                                                           THEN R.CREDIT_LIMIT * 1.5
                                                           ELSE R.CREDIT_LIMIT * 1.7
                                                           END AS RLIMIT
                                          FROM (SELECT  NAME,WEBSITE,CREDIT_LIMIT,REPLACE(NAME,' ','') AS CNAME,
                                                    SUBSTR(SUBSTR(WEBSITE,INSTR(WEBSITE,'.',1)+1),0,INSTR(SUBSTR(WEBSITE,INSTR(WEBSITE,'.',1)+1),'.',1)-1) AS WNAME
                                                FROM CUSTOMERS 
                                                WHERE CREDIT_LIMIT BETWEEN 3500 AND 4500) R) R2
                                    ON CU.NAME = R2.NAME ) R3
WHERE R3.RNK  <=6 OR R3.RNK >= 300
;