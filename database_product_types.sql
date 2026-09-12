USE clothing_store;
ALTER TABLE products ADD COLUMN IF NOT EXISTS product_type VARCHAR(40) NOT NULL DEFAULT 'tops';
UPDATE products SET product_type='shorts' WHERE name LIKE '%ขาสั้น%';
UPDATE products SET product_type='pants' WHERE name LIKE '%กางเกง%' AND name NOT LIKE '%ขาสั้น%';
UPDATE products SET product_type='dresses' WHERE name LIKE '%เดรส%';
UPDATE products SET product_type='outerwear' WHERE name LIKE '%แจ็กเก็ต%' OR name LIKE '%คาร์ดิแกน%' OR name LIKE '%กั๊ก%' OR name LIKE '%ฮู้ด%';
INSERT INTO products (name,category,brand,color,sizes,price,stock,image_url,description,is_active,product_type) VALUES
('กางเกงขาสั้น City Walk','men','Northline','เบจ','S,M,L,XL,2XL',790,12,'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=700&q=85','กางเกงขาสั้นทรงสบายสำหรับวันหยุด','1','shorts'),
('กางเกงขายาว Essential Straight','men','Urban Basic','ดำ','S,M,L,XL,2XL',990,10,'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=700&q=85&sat=-15','กางเกงขายาวทรงตรงใส่ได้ทุกวัน','1','pants'),
('กางเกงยีนส์ Classic Blue','men','Northline','น้ำเงิน','S,M,L,XL,2XL',1290,9,'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=700&q=85','ยีนส์สีน้ำเงินทรงคลาสสิก','1','jeans'),
('กางเกงยีนส์ Wide Fit','women','Luna','ฟ้า','S,M,L,XL,2XL',1390,8,'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=700&q=85','ยีนส์ขากว้างที่ใส่สบายและแมตช์ง่าย','1','jeans'),
('รองเท้าผ้าใบ Everyday','men','Mellow Studio','ขาว','S,M,L,XL,2XL',1590,7,'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=700&q=85','รองเท้าผ้าใบคู่โปรดสำหรับทุกวัน','1','shoes'),
('รองเท้าผ้าใบ Soft Step','women','Luna','ครีม','S,M,L,XL,2XL',1490,11,'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=700&q=85','รองเท้าน้ำหนักเบา เดินสบายตลอดวัน','1','shoes'),
('กางเกงขาสั้น Junior Move','kids','Little Joy','กรมท่า','S,M,L,XL,2XL',490,15,'https://images.unsplash.com/photo-1506629905607-d9b1bdbf9c27?auto=format&fit=crop&w=700&q=85&sat=-20','กางเกงขาสั้นคล่องตัวสำหรับเด็ก','1','shorts'),
('รองเท้าผ้าใบ Little Step','kids','Little Joy','ชมพู','S,M,L,XL,2XL',790,8,'https://images.unsplash.com/photo-1514989940723-e8e51635b782?auto=format&fit=crop&w=700&q=85','รองเท้าผ้าใบสำหรับวันเล่นสนุก','1','shoes');
