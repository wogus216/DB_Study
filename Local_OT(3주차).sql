--[3���� ����2](����)
-- �Ǹ� �����麰��(���� ����) �ֹ� ������ 100�� �̻��̸�, ������ �� �ֹ����� �� ���߿��� ���� ū ���� ���������� ���������� ���ϰ�(�Ҽ�������)
-- ��� ������� ������ �ڵ��� ��ȣ�� ���� �������ڸ��� ������ ���� ���� ���� �����߿�(1~5�ڸ�) �ϳ��� ���Ե� ������� ����Ͻÿ�
-- ����ʵ�: ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL (EMPLOYEE�� CUSTOMER�� �����ϱ� ���� ID�տ� EM �Ǵ� CSǥ�ø� �ϰ� CS������� ���� ����Ͻÿ�)
-- EX) ���̰� 65432 ������ �޴���ȭ ������ �ڸ��� 6, 5, 4, 3, 2 �� ������� ����ϸ� �˴ϴ�
-- CS 72�� / EM 54�� ���ɴϴ�


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







-- [3���� ����3]
-- �ѵ��� 3500���� 4500������ ȸ����� ���ϰ�/ ������Ʈ �̸��� ����� �κ��� �����ϰ� ȸ����� ���ڱ���(��������)�� ������Ʈ���� ���� ���̸� ���ؼ�
-- ȸ����� ���ڱ��̰� ������Ʈ���� ���ڱ��̺��� ũ�� �ѵ� 1.3��, ������ 1.5��, ������ 1.7�� ���ص� ��ü ȸ����� �ѵ��� ���Ͽ� 6�������� 300���� ���� ����Ͻÿ�
-- ����ʵ�: �̸�, ������Ʈ �̸�, ũ���� ����Ʈ, ��ŷ
-- EX)https://abcdefg.com -> abcdefg (����� �κ� ����)

SELECT C.NAME,C.WEBSITE,C.CREDIT_LIMIT,REPLACE(C.NAME,' ',''),LENGTH(REPLACE(C.NAME,' ','')) AS CNAME, 
         SUBSTR(SUBSTR(WEBSITE,INSTR(WEBSITE,'.',1)+1),0,INSTR(SUBSTR(WEBSITE,INSTR(WEBSITE,'.',1)+1),'.')-1) AS WNAME
FROM CUSTOMERS C 
WHERE C.CREDIT_LIMIT BETWEEN 3500 AND 4500
;

SELECT  R.NAME,R.WEBSITE,R.CREDIT_LIMIT,
        CASE WHEN R.CNAME > R.WNAME
             THEN R.CREDIT_LIMIT * 1.3
             WHEN R.CNAME = R.WNAME
             THEN R.CREDIT_LIMIT * 1.5
             WHEN R.CNAME < R.WNAME
            THEN R.CREDIT_LIMIT * 1.7
            END AS RLIMIT
FROM (SELECT C.NAME,C.WEBSITE,C.CREDIT_LIMIT,REPLACE(C.NAME,' ',''),LENGTH(REPLACE(C.NAME,' ','')) AS CNAME, 
                 SUBSTR(SUBSTR(WEBSITE,INSTR(WEBSITE,'.',1)+1),0,INSTR(SUBSTR(WEBSITE,INSTR(WEBSITE,'.',1)+1),'.')-1) AS WNAME
      FROM CUSTOMERS C 
      WHERE C.CREDIT_LIMIT BETWEEN 3500 AND 4500) R
;

(SELECT SUBSTR(SUBSTR(WEBSITE,INSTR(WEBSITE,'.',1)+1),0,INSTR(SUBSTR(WEBSITE,INSTR(WEBSITE,'.',1)+1),'.')-1) AS RNAME
                             FROM (SELECT SUBSTR(WEBSITE,INSTR(WEBSITE,'.',1)+1) AS W 
                                   FROM CUSTOMERS) D) D2
SELECT REPLACE(NAME,' ','')
FROM CUSTOMERS     
;

--����
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

-- ����4. (����)
-- 17�⵵ �Ϲݱ⿡ ���簡 �ֹ��� �ֹ��ݾ��� ��(�Ҽ� ù° �ڸ����� �ݿø�)�� ���ϰ�,
-- ���� 5���� ����� �ſ��ѵ��� 30% �λ��ϰ� �� �̿��� ����� 30%�����Ͽ� �ſ��ѵ��� �������� ������ ���Ͻÿ�.
-- ����ʵ� : CUSTOMER_ID, NAME, SUM(�ֹ��ݾ� �հ�), CREDIT_LIMIT, RLMIT(�ſ��ѵ� ���� ��), RNK

SELECT CU.NAME,SUM(OI.QUANTITY*OI.UNIT_PRICE) ,ROUND(SUM(OI.QUANTITY*OI.UNIT_PRICE)) AS OSUM,
        RANK() OVER (ORDER BY ROUND(SUM(OI.UNIT_PRICE),1) DESC) AS RNK
FROM  CUSTOMERS CU INNER JOIN ORDERS O
                           ON CU.CUSTOMER_ID = O.CUSTOMER_ID
                   INNER JOIN ORDER_ITEMS OI
                           ON O.ORDER_ID = OI.ORDER_ID
                          AND O.STATUS NOT IN 'Canceled'
                          AND TO_CHAR(O.ORDER_DATE, 'YY') = 17
                          AND TO_CHAR(O.ORDER_DATE, 'MM') > 6
GROUP BY CU.NAME
;
-- ���� 5���� ����� �ſ��ѵ��� 30% �λ��ϰ� �� �̿��� ����� 30%�����Ͽ� �ſ��ѵ��� �������� ������ ���Ͻÿ�.
SELECT CU2.CUSTOMER_ID,CU2.NAME,S.OSUM,CU2.CREDIT_LIMIT,S.RNK,
        CASE WHEN S.RNK < 6
             THEN CU2.CREDIT_LIMIT *1.3
             ELSE CU2.CREDIT_LIMIT *0.7
             END AS RLIMIT
FROM CUSTOMERS CU2 INNER JOIN (SELECT CU.NAME,SUM(OI.QUANTITY*OI.UNIT_PRICE) ,ROUND(SUM(OI.QUANTITY*OI.UNIT_PRICE)) AS OSUM,
                                        RANK() OVER (ORDER BY ROUND(SUM(OI.UNIT_PRICE),1) DESC) AS RNK
                               FROM  CUSTOMERS CU INNER JOIN ORDERS O
                                                           ON CU.CUSTOMER_ID = O.CUSTOMER_ID
                                                   INNER JOIN ORDER_ITEMS OI
                                                           ON O.ORDER_ID = OI.ORDER_ID
                                                          AND O.STATUS NOT IN 'Canceled'
                                                          AND TO_CHAR(O.ORDER_DATE, 'YY') = 17
                                                          AND TO_CHAR(O.ORDER_DATE, 'MM') > 6
                                GROUP BY CU.NAME) S
                                                           ON CU2.NAME = S.NAME
;

SELECT R.*,RANK() OVER(ORDER BY R.RLIMIT DESC ) AS RNKA
FROM (SELECT CU2.CUSTOMER_ID,CU2.NAME,S.OSUM,CU2.CREDIT_LIMIT,S.RNK,
        CASE WHEN S.RNK < 6
             THEN CU2.CREDIT_LIMIT *1.3
             ELSE CU2.CREDIT_LIMIT *0.7
             END AS RLIMIT
     FROM CUSTOMERS CU2 INNER JOIN (SELECT CU2.CUSTOMER_ID,CU2.NAME,S.OSUM,CU2.CREDIT_LIMIT,S.RNK,
        CASE WHEN S.RNK < 6
             THEN CU2.CREDIT_LIMIT *1.3
             ELSE CU2.CREDIT_LIMIT *0.7
             END AS RLIMIT
FROM CUSTOMERS CU2 INNER JOIN (SELECT CU.NAME,SUM(OI.QUANTITY*OI.UNIT_PRICE) ,ROUND(SUM(OI.QUANTITY*OI.UNIT_PRICE)) AS OSUM,
                                        RANK() OVER (ORDER BY ROUND(SUM(OI.UNIT_PRICE),1) DESC) AS RNK
                               FROM  CUSTOMERS CU INNER JOIN ORDERS O
                                                           ON CU.CUSTOMER_ID = O.CUSTOMER_ID
                                                   INNER JOIN ORDER_ITEMS OI
                                                           ON O.ORDER_ID = OI.ORDER_ID
                                                          AND O.STATUS NOT IN 'Canceled'
                                                          AND TO_CHAR(O.ORDER_DATE, 'YY') = 17
                                                          AND TO_CHAR(O.ORDER_DATE, 'MM') > 6
                                GROUP BY CU.NAME) S
                                                           ON CU2.NAME = S.NAME) S
                           ON CU2.NAME = S.NAME) R
;


