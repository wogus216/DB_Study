--문제1.
--오더 STATUS가 'Canceled' 상태인  사원들이 가장 많이 모시고 있는 매니저를 출력하시오
--출력: 사원번호,이름(퍼스트+라스트),이메일,JOB_TITLE
SELECT E.EMPLOYEE_ID,E.FIRST_NAME || E.LAST_NAME AS FULL_NAME,E.EMAiL,E.job_title
FROM (SELECT E.MANAGER_ID,COUNT(*),
               RANK() OVER(ORDER BY COUNT(*) DESC) AS RNK
        FROM EMPLOYEES E INNER JOIN ORDERS O
                               ON EMPLOYEE_ID = SALESMAN_ID
                               AND O.STATUS IN 'Canceled'
        GROUP BY E.MANAGER_ID ) M RIGHT OUTER JOIN EMPLOYEES E
                                                ON M.MANAGER_ID = E.EMPLOYEE_ID
WHERE M.RNK = 1    
;

-- 문제2)
-- 주문이 취소된 물건이 가장 많이나온 웹사이트 고객의 풀네임과 글자수와
-- 글자수가 같은 사람들을 직원들중에서 출력하시오
-- 출력필드: 사원번호, 사원풀네임, 직업

SELECT C.NAME,COUNT(*),C.CUSTOMER_ID,
        RANK() OVER(ORDER BY COUNT(*) DESC) AS RNK
FROM ORDERS O INNER JOIN CUSTOMERS C 
                      ON O.CUSTOMER_ID = C.CUSTOMER_ID
                      AND O.STATUS IN 'Canceled'
GROUP BY C.NAME,C.CUSTOMER_ID                  
;

SELECT LENGTH(C.FIRST_NAME || C.LAST_NAME) AS NL
FROM CONTACTS C INNER JOIN (SELECT C.NAME,COUNT(*),C.CUSTOMER_ID,
                                RANK() OVER(ORDER BY COUNT(*) DESC) AS RNK
                            FROM ORDERS O INNER JOIN CUSTOMERS C 
                                                  ON O.CUSTOMER_ID = C.CUSTOMER_ID
                                                 AND O.STATUS IN 'Canceled'
                            GROUP BY C.NAME,C.CUSTOMER_ID) W
                       ON C.CUSTOMER_ID = W.CUSTOMER_ID
WHERE W.RNK = 1
;

SELECT E.EMPLOYEE_ID,(E.FIRST_NAME || E.LAST_NAME) AS RESULT,E.JOB_TITLE
FROM EMPLOYEES E INNER JOIN (SELECT LENGTH(C.FIRST_NAME || C.LAST_NAME) AS NL
                             FROM CONTACTS C INNER JOIN (SELECT C.NAME,COUNT(*),C.CUSTOMER_ID,
                                RANK() OVER(ORDER BY COUNT(*) DESC) AS RNK
                                                         FROM ORDERS O INNER JOIN CUSTOMERS C 
                                                                               ON O.CUSTOMER_ID = C.CUSTOMER_ID
                                                                              AND O.STATUS IN 'Canceled'
                                                        GROUP BY C.NAME,C.CUSTOMER_ID) W
                                                     ON C.CUSTOMER_ID = W.CUSTOMER_ID
                             WHERE W.RNK = 1) W2
                    ON 1=1
WHERE W2.NL = LENGTH(E.FIRST_NAME || E.LAST_NAME)
;
--문제3.
-- 제품ID가 200번대이면서 수량이 200개이상인 제품중 마진(판매가격-표준원가)이 가장 큰 제품과 가장 작은 제품의 차이를 구하고 
--그 차이보다 큰 판매가격을 가진 제품들중 가장 많은 카테고리의 카테고리 이름을 구하시오.

SELECT P.PRODUCT_ID,I.QUANTITY,(LIST_PRICE - STANDARD_COST) AS MARGIN
FROM PRODUCTS P INNER JOIN INVENTORIES I 
                       ON P.PRODUCT_ID = I.PRODUCT_ID
                       AND P.PRODUCT_ID >= 200
                       AND I.QUANTITY >= 200
;
SELECT  MAX(R.MARGIN)-MIN(R.MARGIN) AS CHA
FROM (SELECT P.PRODUCT_ID,I.QUANTITY,(LIST_PRICE - STANDARD_COST) AS MARGIN
      FROM PRODUCTS P INNER JOIN INVENTORIES I 
                              ON P.PRODUCT_ID = I.PRODUCT_ID
                             AND P.PRODUCT_ID >= 200
                             AND I.QUANTITY >= 200) R
;

--그 차이보다 큰 판매가격을 가진 제품들중 가장 많은 카테고리의 카테고리 이름을 구하시오.
SELECT p2.CATEGORY_ID,P2.LIST_PRICE,R2.CHA,  CASE WHEN P2.LIST_PRICE > R2.CHA
                                                  THEN P2.LIST_PRICE
                                                  ELSE NULL
                                                  END AS BIG
FROM PRODUCTS P2 INNER JOIN (SELECT  MAX(R.MARGIN)-MIN(R.MARGIN) AS CHA
                             FROM (SELECT P.PRODUCT_ID,I.QUANTITY,(LIST_PRICE - STANDARD_COST) AS MARGIN
                                   FROM PRODUCTS P INNER JOIN INVENTORIES I 
                                                           ON P.PRODUCT_ID = I.PRODUCT_ID
                                                          AND P.PRODUCT_ID >= 200
                                                          AND I.QUANTITY >= 200) R) R2
                        ON 1=1
;
SELECT *
FROM  (SELECT PC.CATEGORY_NAME,RANK()OVER(ORDER BY COUNT(*) DESC) AS RNK2
       FROM PRODUCT_CATEGORIES PC INNER JOIN (SELECT p2.CATEGORY_ID, CASE WHEN P2.LIST_PRICE > R2.CHA
                                                                          THEN P2.CATEGORY_ID
                                                                          ELSE NULL
                                                                          END AS BIG
                                               FROM PRODUCTS P2 INNER JOIN (SELECT  MAX(R.MARGIN)-MIN(R.MARGIN) AS CHA
                                                                            FROM (SELECT P.PRODUCT_ID,I.QUANTITY,(LIST_PRICE - STANDARD_COST) AS MARGIN
                                                                                  FROM PRODUCTS P INNER JOIN INVENTORIES I 
                                                                                                          ON P.PRODUCT_ID = I.PRODUCT_ID
                                                                                                         AND P.PRODUCT_ID >= 200
                                                                                                         AND I.QUANTITY >= 200) R) R2
                                                                        ON 1=1) R3
                                         ON PC.CATEGORY_ID = R3.CATEGORY_ID
                                        AND R3.BIG IS NOT NULL
                     GROUP BY PC.CATEGORY_NAME ) R4
WHERE R4.RNK2=1
 ;
-- 문제4)
-- 주문 기록중에 배송이 완료된 주문 중에서 주문한 물품들의 총 합 지불 금액이 가장 큰 주문(실구매가=소매가)의 
-- 물품들의 총 금액이 원래 원가로 샀을때와 비교해서 얼마만큼의 금액차이가 있는지 구하시오
-- 출력필드: 물품 번호, 물품 이름, 개당 마진, 원가로 샀을때 가격, 실제로 회사가 지불한 소매가, 마진
-- 출력필드: 물품번호, 물품 이름, 실제로 회사가 지불한 소매가, 마진 (7번줄) 

--배송완료 지불금액 실제로 회사가 지불한 소매가 ,원가로 샀을때 가격**
SELECT OI.ORDER_ID,SUM(OI.QUANTITY*OI.UNIT_PRICE) as  REP,SUM(OI.QUANTITY * PR.STANDARD_COST) AS SC_SUM,
    RANK() OVER(ORDER BY SUM(OI.QUANTITY*OI.UNIT_PRICE) DESC) AS RNK  
FROM ORDER_ITEMS OI INNER JOIN ORDERS O
                            ON OI.ORDER_ID = O.ORDER_ID
                            AND O.STATUS IN 'Shipped'      
                    INNER JOIN PRODUCTS PR
                            ON OI.PRODUCT_ID = PR.PRODUCT_ID
GROUP BY OI.ORDER_ID
;
--실구매 1등 오더번호 물품들
SELECT *
FROM ORDER_ITEMS OIS INNER JOIN (SELECT OI.ORDER_ID,SUM(OI.QUANTITY*OI.UNIT_PRICE) as  REP,SUM(OI.QUANTITY * PR.STANDARD_COST) AS SC_SUM,
                                        RANK() OVER(ORDER BY SUM(OI.QUANTITY*OI.UNIT_PRICE) DESC) AS RNK  
                                 FROM ORDER_ITEMS OI INNER JOIN ORDERS O
                                                                ON OI.ORDER_ID = O.ORDER_ID
                                                                AND O.STATUS IN 'Shipped'      
                                                        INNER JOIN PRODUCTS PR
                                                                ON OI.PRODUCT_ID = PR.PRODUCT_ID
                                GROUP BY OI.ORDER_ID) RP
                            ON OIS.ORDER_ID = RP.ORDER_ID
                           AND  RP.RNK = 1
;
-- 출력필드: 물품 번호, 물품 이름, 개당 마진, 원가로 샀을때 가격, 실제로 회사가 지불한 소매가, 마진
SELECT P.PRODUCT_ID,P.PRODUCT_NAME,P.STANDARD_COST,(RP2.UNIT_PRICE - P.STANDARD_COST) AS MARGIN, (P.STANDARD_COST * RP2.QUANTITY) AS PRIME,RP2.REP, (RP2.REP -RP2.SC_SUM) AS RESULT_MARGIN
FROM PRODUCTS P INNER JOIN (SELECT *
                            FROM ORDER_ITEMS OIS INNER JOIN (SELECT OI.ORDER_ID,SUM(OI.QUANTITY*OI.UNIT_PRICE) as  REP,SUM(OI.QUANTITY * PR.STANDARD_COST) AS SC_SUM,
                                                                    RANK() OVER(ORDER BY SUM(OI.QUANTITY*OI.UNIT_PRICE) DESC) AS RNK  
                                                             FROM ORDER_ITEMS OI INNER JOIN ORDERS O
                                                                                            ON OI.ORDER_ID = O.ORDER_ID
                                                                                            AND O.STATUS IN 'Shipped'      
                                                                                    INNER JOIN PRODUCTS PR
                                                                                            ON OI.PRODUCT_ID = PR.PRODUCT_ID
                                                            GROUP BY OI.ORDER_ID) RP
                                                        ON OIS.ORDER_ID = RP.ORDER_ID
                                                       AND  RP.RNK = 1) RP2
                       ON P.PRODUCT_ID = RP2.PRODUCT_ID
;

SELECT OI.ORDER_ID,P.PRODUCT_NAME,(OI.QUANTITY * P.STANDARD_COST) AS P
FROM ORDER_ITEMS OI INNER JOIN PRODUCTS P
                            ON OI.PRODUCT_ID = P.PRODUCT_ID
                           AND OI.ORDER_ID IN '32'
;