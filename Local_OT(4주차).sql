-- 문제 1번(도헌)_수정
-- 제품 원가 순위중 금액이 높은 2위와 10위의 차를 구하고(소수 1째자리 반올림), 차이보다 낮은 판매가격 금액은 2.7배 증가, 높으면 0.5배감소 시키고,
-- 변경된 판매가격의 2위의 주문수량과 변경된 판매가격와 기존 판매가격의 차를 구하고, 제품회사명을 출력하시오.
-- 출력필드 : 제품번호, 제품회사명, 카테고리명, 주문수량, 판매가격, 변경된판매가격, 차이

SELECT ROUND(MAX(U.STANDARD_COST)-MIN(U.STANDARD_COST)) AS RES
FROM (SELECT PRODUCT_NAME,STANDARD_COST,RANK() OVER(ORDER BY STANDARD_COST DESC) AS URNK 
      FROM PRODUCTS ) U
WHERE U.URNK IN (2,10)
;

SELECT P.*,PC.CATEGORY_NAME,OI.QUANTITY, CASE WHEN P.LIST_PRICE < R.RES
                 THEN P.LIST_PRICE * 2.7
                 ELSE P.LIST_PRICE * 0.5
                 END AS RPRICE,
    RANK() OVER (ORDER BY  CASE WHEN P.LIST_PRICE < R.RES
                                THEN P.LIST_PRICE * 2.7
                                ELSE P.LIST_PRICE * 0.5
                                END DESC ) AS RNK
FROM PRODUCTS P INNER JOIN (SELECT ROUND(MAX(U.STANDARD_COST)-MIN(U.STANDARD_COST)) AS RES
                          FROM (SELECT PRODUCT_NAME,STANDARD_COST,RANK() OVER(ORDER BY STANDARD_COST DESC) AS URNK 
                                FROM PRODUCTS ) U
                          WHERE U.URNK IN (2,10)) R
                     ON 1 = 1
                INNER JOIN PRODUCT_CATEGORIES PC
                     ON P.CATEGORY_ID = PC.CATEGORY_ID
                INNER JOIN ORDER_ITEMS OI
                     ON P.PRODUCT_ID = OI.PRODUCT_ID
;

-- 변경된 판매원가의 2위의 주문수량과 변경된 판매원가와 기존 판매원가의 차를 구하고, 제품회사명을 출력하시오.
-- 출력필드 : 제품번호, 제품회사명, 카테고리명, 주문수량, 판매원가, 변경된판매원가, 차이


SELECT R2.PRODUCT_ID,SUBSTR(R2.PRODUCT_NAME,0,INSTR(R2.PRODUCT_NAME,' ')) AS COMPANY_NAME,
       R2.CATEGORY_NAME,R2.QUANTITY,R2.LIST_PRICE,R2.RPRICE,ABS(R2.LIST_PRICE - R2.RPRICE) AS CHA
FROM (SELECT P.*,PC.CATEGORY_NAME,OI.QUANTITY, CASE WHEN P.LIST_PRICE < R.RES
                                                    THEN P.LIST_PRICE * 2.7
                                                    ELSE P.LIST_PRICE * 0.5
                                                    END AS RPRICE,
            RANK() OVER (ORDER BY  CASE WHEN P.LIST_PRICE < R.RES
                                        THEN P.LIST_PRICE * 2.7
                                        ELSE P.LIST_PRICE * 0.5
                                        END DESC ) AS RNK
    FROM PRODUCTS P INNER JOIN (SELECT ROUND(MAX(U.STANDARD_COST)-MIN(U.STANDARD_COST)) AS RES
                                FROM (SELECT PRODUCT_NAME,STANDARD_COST,RANK() OVER(ORDER BY STANDARD_COST DESC) AS URNK 
                                      FROM PRODUCTS ) U
                                WHERE U.URNK IN (2,10)) R
                         ON 1 = 1
                    INNER JOIN PRODUCT_CATEGORIES PC
                            ON P.CATEGORY_ID = PC.CATEGORY_ID
                    INNER JOIN ORDER_ITEMS OI
                            ON P.PRODUCT_ID = OI.PRODUCT_ID) R2 
WHERE R2.RNK = 1
;
--문제2번(희두)
-- 모든 입사일에 100일을 더한 뒤 월별(연도는 제외합니다) 입사자 수를 구하여 그 중 입사자가 가장 많은 달을 뽑으시오
-- 출력 : 해당 달,해당 달의 마지막 일자
SELECT DISTINCT D2.NDATE,LAST_DAY(E2.HIRE_DATE)
FROM (SELECT TO_CHAR(D.NHD, 'MM') AS NDATE,COUNT(*),
            RANK() OVER (ORDER BY COUNT(*) DESC) AS RNK
      FROM ( SELECT HIRE_DATE + 100 AS NHD
             FROM EMPLOYEES) D
      GROUP BY TO_CHAR(D.NHD, 'MM') )D2 INNER JOIN EMPLOYEES E2
                                                ON 1=1
                                               AND D2.NDATE = TO_CHAR(HIRE_DATE, 'MM')
WHERE D2.RNK = 1
;


--문제3번(시연)
-- 물건 주문을 완료한 고객들은 자신이 주문한 물건이 현재 어디에 있는지 궁금해 합니다.
-- 하지만 그러기 위해선 영어와 숫자가 혼합된 10자리 임시비밀번호가 필요한데요, 
-- 고객들이 자신이 주문한 물건을 조회할 수 있도록 영어와 숫자가 혼합된 10자리 임시비밀번호를 만들어 주세요
-- [고객아이디, 고객이름, 임시비밀번호]

SELECT CONTACT_ID, FIRST_NAME || LAST_NAME AS FULLNAME, DBMS_RANDOM.STRING('X',10) AS TMPPW
FROM CONTACTS
;

--문제4번(건정)
-- first name이 4자 이하인 고객의 주문이 발송된상태와 주소를 구하시오. 
-- 출력 : first_name, address, status

SELECT C.FIRST_NAME,CU.ADDRESS,O.STATUS
FROM CONTACTS C INNER JOIN ORDERS O
                        ON C.CUSTOMER_ID = O.CUSTOMER_ID
                       AND LENGTH(C.FIRST_NAME) <= 4
                INNER JOIN CUSTOMERS CU
                        ON C.CUSTOMER_ID = CU.CUSTOMER_ID
;


