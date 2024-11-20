
SELECT MIN(SALE_DATE), MAX(SALE_DATE) FROM CRM.SALE_TXN st ;

-- Create #CleanTxn table for removing non-customer data, setting date range, etc.
DROP TABLE #CleanTxn;
CREATE TABLE #CleanTxn (
	VHIDX INT PRIMARY KEY
	);

INSERT INTO #CleanTxn (VHIDX)
SELECT DISTINCT VHIDX
FROM (
	SELECT ST.VHIDX
			, SUM(NET_PRICE_IN_VAT) AS sales
	FROM CRM.SALE_TXN st
	LEFT JOIN CRM.PRODUCT p 
	ON st.SKUIDX = p.SKUIDX
	LEFT JOIN CRM.STORE_WH sw
	ON st.WHIDX = sw.WHIDX
	WHERE 1 = 1
	AND p.prod_brand_name != 'General'
	AND sw.store_wh_code != 'QRC'
	AND st.SALE_DATE BETWEEN '2021-06-01' AND '2023-06-30'
	AND RETURN_REASON IS NULL
	GROUP BY st.VHIDX) a 
	WHERE sales > 0;

SELECT st.VHIDX, st.NET_PRICE_IN_VAT
FROM CRM.SALE_TXN st
RIGHT JOIN #CleanTxn ct ON st.VHIDX = ct.VHIDX
GROUP BY st.VHIDX, st.NET_PRICE_IN_VAT
ORDER BY NET_PRICE_IN_VAT;

-- Create member metrics table: format data for RFM processing
DROP TABLE #Temp_Member_Metrics;
CREATE TABLE #Temp_Member_Metrics (
MEMBER_ID VARCHAR(25)
,total_sales DECIMAL(10,2)
,member_txns INT
,member_QTYs INT
,last_purch_dt DATE
,recency INT
);

INSERT INTO #Temp_Member_Metrics (MEMBER_ID, total_sales, member_txns, member_QTYs, last_purch_dt, recency)
SELECT A.*
		--, ROUND(CASE WHEN member_txns = 0 THEN 0 ELSE total_sales/member_txns END, 2) AS ATV
		, DATEDIFF(day, last_purch_dt, '2023-07-01') AS recency
FROM (
		SELECT 
			mi.MEMBER_ID
			, SUM(NET_PRICE_IN_VAT) AS total_sales
			, COUNT(DISTINCT CASE WHEN QTY >= 0 THEN st.VHIDX END) AS member_txns
			, SUM(QTY) AS member_QTYs
			, MAX(SALE_DATE) AS last_purch_dt
		FROM CRM.SALE_TXN st
		INNER JOIN CRM.MEMBER_INFO mi
		ON st.PERIDX = mi.PERIDX
		LEFT JOIN CRM.PRODUCT p
		ON st.SKUIDX = p.SKUIDX
		LEFT JOIN CRM.STORE_WH sw
		ON st.WHIDX = sw.WHIDX
		RIGHT JOIN #CleanTxn cl
		ON st.VHIDX = cl.VHIDX
		WHERE 1=1
		AND p.prod_brand_name <> 'General'
		AND sw.STORE_WH_CODE <> 'QRC'
		AND SUBSTRING(UPPER(Member_ID), 1, 3) IN ('LM*', 'LM0', 'LM1')
		GROUP BY mi.member_id
		) A;
	
SELECT * FROM #Temp_Member_Metrics
ORDER BY last_purch_dt DESC;
-- Create cut off 98.5% criteria
DROP TABLE #TempCutoff1;
CREATE TABLE #TempCutoff1(
		PCT_98_5_Sales DECIMAL (10,2)
		, PCT_98_5_QTYs INT
		, PCT_98_5_Txns INT );
	
SELECT * FROM #TempCutoff1;

INSERT INTO #TempCutoff1 (PCT_98_5_Sales, PCT_98_5_QTYs, PCT_98_5_Txns)
SELECT DISTINCT 
	PERCENTILE_CONT(0.985) WITHIN GROUP (ORDER BY total_sales) OVER (PARTITION BY '1') AS PCT_98_5_Sales
	, PERCENTILE_CONT(0.985) WITHIN GROUP (ORDER BY member_QTYs) OVER (PARTITION BY '1') AS PCT_98_5_QTYs
	, PERCENTILE_CONT(0.985) WITHIN GROUP (ORDER BY member_txns) OVER (PARTITION BY '1') AS PCT_98_5_txns
FROM #Temp_Member_Metrics A;

SELECT * FROM #TempCutoff1;

-- Create cut off 1.5% criteria
DROP TABLE #TempCutoff2;
CREATE TABLE #TempCutoff2(
		PCT_1_5_Sales DECIMAL (10,2)
		, PCT_1_5_QTYs INT
		, PCT_1_5_Txns INT );
	
SELECT * FROM #TempCutoff2;

INSERT INTO #TempCutoff2 (PCT_1_5_Sales, PCT_1_5_QTYs, PCT_1_5_Txns)
SELECT DISTINCT 
	PERCENTILE_CONT(0.015) WITHIN GROUP (ORDER BY total_sales) OVER (PARTITION BY '1') AS PCT_1_5_Sales
	, PERCENTILE_CONT(0.015) WITHIN GROUP (ORDER BY member_QTYs) OVER (PARTITION BY '1') AS PCT_1_5_QTYs
	, PERCENTILE_CONT(0.015) WITHIN GROUP (ORDER BY member_txns) OVER (PARTITION BY '1') AS PCT_1_5_txns
FROM #Temp_Member_Metrics A;

SELECT * FROM #TempCutoff2;

-- Determine if the member is eligible for RFM (not extreme outliers)
DROP TABLE #TempAbusive;
CREATE TABLE #TempAbusive(
	member_id VARCHAR(20)
	, Final_abuse VARCHAR(20));

INSERT INTO #TempAbusive(member_id, Final_abuse)
SELECT DISTINCT member_id
		, CASE WHEN CONCAT(abuse_Sales, abuse_QTYs, abuse_Txns) IN ('YYY', 'YYN', 'NYY', 'YNY') THEN 'Y' ELSE 'N' END AS final_abuse
FROM (
		SELECT a.*
				, b.*
				, CASE WHEN total_sales > PCT_98_5_Sales OR total_sales < PCT_1_5_Sales THEN 'Y' ELSE 'N' END AS abuse_Sales
				, CASE WHEN member_QTYs > PCT_98_5_QTYs OR total_sales < PCT_1_5_Sales THEN 'Y' ELSE 'N' END AS abuse_QTYs
				, CASE WHEN member_txns > PCT_98_5_Txns OR total_sales < PCT_1_5_Sales THEN 'Y' ELSE 'N' END AS abuse_Txns
		FROM #Temp_Member_Metrics a
		LEFT JOIN #TempCutoff1 b
		ON 1 = 1
		LEFT JOIN #TempCutoff2 d
		ON 1 = 1
		) C;
	
SELECT * FROM #TempAbusive;
SELECT COUNT(member_id), Final_abuse
FROM #TempAbusive
GROUP BY Final_abuse;
	
-- Create member RFM segment
DROP TABLE #Temp_Member_RFM;
CREATE TABLE #Temp_Member_RFM (
		MEMBER_ID VARCHAR(25)
		, total_sales DECIMAL (10,2)
		, member_txns INT
		, member_QTYs INT
		, last_purch_dt DATE
		, recency INT
		, r_score INT
		, f_score INT 
		, m_score INT
		, RFM_score VARCHAR(3)
		, FM_score INT
		, RFM_segment VARCHAR (30)
		);
		
SELECT * FROM #Temp_Member_RFM;
	
INSERT INTO #Temp_Member_RFM (MEMBER_ID, total_sales, member_txns, member_QTYs, last_purch_dt, recency, r_score, f_score, m_score, RFM_score, FM_score, RFM_segment)
	select 	aaa.* 
		, case when RFM_Score in (555, 554, 544, 545, 454, 455, 445) 		then 'Champion' 
		       when RFM_Score in (543, 444, 435, 355, 354, 345, 344, 335) 	then 'Loyal' 
		       when RFM_Score in (553, 551, 552, 541, 542, 533, 532, 531
		       					 ,452, 451, 442, 441, 431, 453, 433, 432
		       					 ,423, 353, 352, 351, 342, 341, 333, 323) 	then 'Potential Loyalists' 
		       when RFM_Score in (512, 511, 422, 421, 412, 411, 311) 		then 'Recent Customer' 
		       when RFM_Score in (525, 524, 523, 522, 521, 515, 514, 513
		         				 ,425, 424, 413, 414, 415, 315, 314, 313) 	then 'Promising' 
		       when RFM_Score in (535, 534, 443, 434, 343, 334, 325, 324) 	then 'Need Attention' 
		       when RFM_Score in (331, 321, 312, 221, 213, 231, 241, 251) 	then 'About To Sleep' 
		       when RFM_Score in (255, 254, 245, 244, 253, 252, 243, 242
		       					, 235, 234, 225, 224, 153, 152, 145, 143
		       					, 142, 135, 134, 133, 125, 124) 			then 'At Risk' 
		       when RFM_Score in (155, 154, 144, 214,215,115, 114, 113) 	then 'Cannot Lose Them' 
		       when RFM_Score in (332, 322, 233, 232, 223, 222, 132, 123
		       					, 122, 212, 211) 							then 'Hibernating customers' 
		       when RFM_Score in (111, 112, 121, 131,141,151) 				then 'Lost' 
		   													 				else 'error' end as RFM_Segment
	FROM (SELECT aa.*, CONCAT(r_score, f_score, m_score) AS RFM_score, (f_score + m_score)/2 AS FM_score
			FROM (SELECT a.*
						, NTILE(5) OVER (ORDER BY recency DESC) AS r_score
						, NTILE(5) OVER (ORDER BY member_txns ASC) AS f_score
						, NTILE(5) OVER (ORDER BY total_sales ASC) AS m_score
					FROM #Temp_Member_Metrics a
					RIGHT JOIN #TempAbusive b 
					ON a.MEMBER_ID = b.MEMBER_ID
					WHERE b.Final_abuse = 'N'
					) aa
		) aaa ORDER BY MEMBER_ID;
		
SELECT * FROM #Temp_Member_RFM;
SELECT COUNT(*) FROM #Temp_Member_RFM

-- Test 3 -> Official
DROP TABLE #Temp_Fav_Brand;
CREATE TABLE #Temp_Fav_Brand (
	MEMBER_ID VARCHAR(25)
	, prod_brand_name VARCHAR(25)
	, total_sales DECIMAL(10,1)
	, txns INT
	, recency INT
	, QTYs INT
	, fav_brand_rank INT );

-- For brand-wise RFM segmentation
INSERT INTO #Temp_Fav_Brand (MEMBER_ID, prod_brand_name, total_sales, txns, recency, QTYs, fav_brand_rank)
SELECT a.MEMBER_ID
		, prod_brand_name
		, total_sales
		, txns
		, recency
		, QTYs
		, ROW_NUMBER() OVER (PARTITION BY MEMBER_ID ORDER BY txns DESC, QTYs DESC, total_sales DESC, prod_brand_name DESC) AS fav_brand_rank
FROM ( 
		SELECT mi.MEMBER_ID
				, p.prod_brand_name
				, SUM(NET_PRICE_IN_VAT) AS total_sales
				, COUNT(DISTINCT CASE WHEN QTY > 0 THEN st.VHIDX END) AS txns
				, DATEDIFF(day, MAX(st.sale_date),'2023-07-01') AS recency
				, SUM(QTY) AS QTYs		
		FROM CRM.SALE_TXN st 
		INNER JOIN CRM.MEMBER_INFO mi 
		ON st.PERIDX = mi.PERIDX 
		LEFT JOIN CRM.PRODUCT p 
		ON st.SKUIDX = p.SKUIDX 
		LEFT JOIN CRM.STORE_WH sw 
		ON st.WHIDX = sw.WHIDX 
		WHERE st.sale_date BETWEEN '2021-06-01' AND '2023-06-30'
		AND p.prod_brand_name <> 'General'
		GROUP BY mi.Member_ID, p.PROD_BRAND_NAME 
		) a;
	
SELECT * FROM #Temp_Fav_brand;	
SELECT COUNT(*) FROM #Temp_Fav_Brand; --796,509

SELECT COUNT(*)
FROM #Temp_Fav_Brand fb
INNER JOIN CRM.MEMBER_INFO mi ON fb.MEMBER_ID = mi.MEMBER_ID
INNER JOIN CRM.SALE_TXN st ON mi.PERIDX = st.PERIDX
INNER JOIN #CleanTxn ct ON st.VHIDX = ct.VHIDX
WHERE fb.MEMBER_ID IN (SELECT MEMBER_ID FROM #TempAbusive WHERE Final_abuse = 'N')
  AND fb.prod_brand_name != 'General';
 
SELECT COUNT(DISTINCT MEMBER_ID)
FROM #Temp_Fav_Brand fb
WHERE MEMBER_ID IN 
	(SELECT MEMBER_ID
		FROM CRM.MEMBER_INFO mi 
		LEFT JOIN CRM.SALE_TXN st ON mi.PERIDX = st.PERIDX 
		RIGHT JOIN #CleanTxn ct ON st.VHIDX = ct.VHIDX) -- 939,430 DSTNCT: 444,813
AND MEMBER_ID IN (SELECT MEMBER_ID FROM #TempAbusive WHERE Final_abuse = 'N'); --431,933

--export: 1m4s 
SELECT COUNT(*)
FROM #Temp_Fav_Brand fb
WHERE MEMBER_ID IN 
	(SELECT MEMBER_ID
		FROM CRM.MEMBER_INFO mi 
		LEFT JOIN CRM.SALE_TXN st ON mi.PERIDX = st.PERIDX 
		RIGHT JOIN #CleanTxn ct ON st.VHIDX = ct.VHIDX) -- 939,430 DSTNCT: 444,813
AND MEMBER_ID IN (SELECT MEMBER_ID FROM #TempAbusive WHERE Final_abuse = 'N'); --431,933
--ORDER BY total_sales DESC;

-- Export for brand RFM segmentation : 12 m 
SELECT *
FROM #Temp_Fav_Brand fb
WHERE MEMBER_ID IN 
	(SELECT MEMBER_ID
		FROM CRM.MEMBER_INFO mi 
		LEFT JOIN CRM.SALE_TXN st ON mi.PERIDX = st.PERIDX 
		RIGHT JOIN #CleanTxn ct ON st.VHIDX = ct.VHIDX) -- 939,430 DSTNCT: 444,813
AND MEMBER_ID NOT IN (SELECT MEMBER_ID FROM #TempAbusive WHERE Final_abuse = 'Y')
ORDER BY total_sales DESC;
	
	
SELECT COUNT(*)
FROM #Temp_Fav_Brand; -- 965,715

SELECT *
FROM #Temp_Fav_Brand
ORDER BY total_sales DESC;


