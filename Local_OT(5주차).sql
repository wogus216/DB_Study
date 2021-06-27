UPDATE ORDERS SET MSG = '모두 수고 많았어요, 다들 프로젝트 화이팅입니다.'
;

SELECT *
FROM ORDERS
;
--[5주차 문제2]
--주문 상태가 'Canceled' 면  0번 'Shipped'이면 1번  Pending' 이면  2번 으로 상태번호 테이블 생성하고, msg에 메시지 자유롭게 넣어주시면 됩니다.

-- [5주차 문제1]
-- 분기별로 가장 빠르게 입사한 사람들중에서 입사한 월이 해당 분기의 첫 번째 달인 사람들의 직업을
-- 구하여 아래와 같이 출력하시오
-- 출력필드: 회원 번호, 풀네임, 직업, 입사 날짜

SELECT EMPLOYEE_ID, FIRST_NAME || LAST_NAME AS FULLNAME, JOB_TITLE,TO_CHAR(HIRE_DATE, 'Q') AS QUARTER, TO_CHAR(HIRE_DATE,' YYYY"년" MM"월" DD"일" ')
FROM EMPLOYEES
WHERE TO_CHAR(HIRE_DATE, 'MM') IN (1,4,7,10)
ORDER BY HIRE_DATE ASC
;

-- [5주차 문제3]
-- 창고중에서 'Samsung'제품이 가장 많은 창고를 구하고 그 창고는 어느 나라에 있는 창고 인지 구하시오.
-- 출력 : WAREHOUSE_ID(창고번호), WAREHOUSE_NAME, COUNTRY, QSUM(제품수량합계)

SELECT I.WAREHOUSE_ID,SUM(I.QUANTITY) AS QSUM,
       RANK() OVER (ORDER BY SUM(I.QUANTITY) DESC) AS RNK
FROM PRODUCTS P INNER JOIN INVENTORIES I
                        ON P.PRODUCT_ID = I.PRODUCT_ID
                       AND P.PRODUCT_NAME LIKE 'Sam%'
GROUP BY I.WAREHOUSE_ID
;
-- 출력 : WAREHOUSE_ID(창고번호), WAREHOUSE_NAME, COUNTRY, QSUM(제품수량합계)
SELECT W.WAREHOUSE_ID,W.WAREHOUSE_NAME,C.COUNTRY_ID,Q.QSUM
FROM  WAREHOUSES W INNER JOIN  LOCATIONS L
                           ON W.LOCATION_ID = L.LOCATION_ID
                   INNER JOIN COUNTRIES C
                           ON L.COUNTRY_ID = C.COUNTRY_ID
                   INNER JOIN(SELECT I.WAREHOUSE_ID,SUM(I.QUANTITY) AS QSUM,
                                       RANK() OVER (ORDER BY SUM(I.QUANTITY) DESC) AS RNK
                              FROM PRODUCTS P INNER JOIN INVENTORIES I
                                                        ON P.PRODUCT_ID = I.PRODUCT_ID
                                                       AND P.PRODUCT_NAME LIKE 'Sam%'
                              GROUP BY I.WAREHOUSE_ID) Q
                           ON W.WAREHOUSE_ID = Q.WAREHOUSE_ID
                          AND Q.RNK = 1
;
