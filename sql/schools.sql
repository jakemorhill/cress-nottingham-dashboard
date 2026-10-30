WITH lines AS (
 SELECT t.storeTransactionId, t.userId, t.transactionDate, s.storeId, s.storeName, ti.quantity, ti.lineTotal, ti.conditionName,
  ti.lineCO2Saved, ti.lineWaterSaved, ti.lineWasteDiverted,
  CASE WHEN ti.productId = 7020 THEN 30.0 ELSE (SELECT MAX(m.recommendedPrice) FROM swapshop.tblProductPricingMatrix m
    WHERE m.productId = ti.productId AND m.storePhaseId = s.storePhaseId AND m.isActive = 1
    AND m.isBranded = CASE WHEN si.isBranded = 1 OR (ti.storeItemName LIKE '%Branded%' AND ti.storeItemName NOT LIKE '%Unbranded%') THEN 1 ELSE 0 END) END AS newPrice
 FROM Cress.tblStoreTransaction t
 JOIN Cress.tblStore s ON s.storeId = t.storeId
 JOIN Cress.tblStoreTransactionStatus st ON st.storeTransactionId = t.storeTransactionId
 JOIN Cress.tblStoreTransactionItem ti ON ti.storeTransactionId = t.storeTransactionId
 LEFT JOIN Cress.tblStoreItem si ON si.storeItemId = ti.storeItemId
 WHERE s.storeGroupId = 166 AND st.isPaid = 1 AND ISNULL(st.isCancelled, 0) = 0
   AND t.transactionDate >= '2026-07-01' AND ti.storeItemName NOT LIKE 'Test%'
)
SELECT storeName AS school, COUNT(DISTINCT userId) AS families, CAST(SUM(quantity) AS int) AS items,
 CAST(SUM(CASE WHEN lineTotal = 0 AND conditionName <> 'New' THEN quantity ELSE 0 END) AS int) AS freeItems,
 CAST(SUM(CASE WHEN conditionName <> 'New' AND ISNULL(newPrice,0)*quantity > lineTotal THEN ISNULL(newPrice,0)*quantity - lineTotal ELSE 0 END) AS decimal(10,2)) AS saved
FROM lines GROUP BY storeName HAVING SUM(quantity) > 0 ORDER BY saved DESC
