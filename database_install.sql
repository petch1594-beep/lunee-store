-- LUNEÉ clothing store single-import installer
-- Import this file once in phpMyAdmin. It creates and fills clothing_store.
CREATE DATABASE IF NOT EXISTS clothing_store CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE clothing_store;

-- ===== database.sql =====
-- นำเข้าไฟล์นี้หลังจากเลือกฐานข้อมูล clothing_store ใน phpMyAdmin
-- การสร้างฐานข้อมูลและกำหนดสิทธิ์อยู่ใน create_clothing_store_admin.sql

CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  phone VARCHAR(30) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('member','admin') NOT NULL DEFAULT 'member',
  is_verified TINYINT(1) NOT NULL DEFAULT 0,
  verification_code VARCHAR(6) DEFAULT NULL,
  code_expires_at DATETIME DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(180) NOT NULL,
  category ENUM('men','women','kids') NOT NULL,
  brand VARCHAR(80) NOT NULL,
  color VARCHAR(50) NOT NULL,
  sizes VARCHAR(120) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  image_url VARCHAR(500) DEFAULT NULL,
  description TEXT,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL UNIQUE,
  slug VARCHAR(80) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_variants (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id INT UNSIGNED NOT NULL,
  size VARCHAR(20) NOT NULL,
  color VARCHAR(50) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  sku VARCHAR(80) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_variant_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE orders (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  order_number VARCHAR(30) NOT NULL UNIQUE,
  status ENUM('pending','paid','packing','shipped','completed','cancelled') NOT NULL DEFAULT 'pending',
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  shipping_name VARCHAR(120) NOT NULL,
  shipping_address TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
);

CREATE TABLE order_items (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id INT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  product_name VARCHAR(180) NOT NULL,
  size VARCHAR(20) DEFAULT NULL,
  color VARCHAR(50) DEFAULT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  quantity INT UNSIGNED NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_item_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_item_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

INSERT INTO categories (name, slug) VALUES ('ผู้ชาย','men'),('ผู้หญิง','women'),('เด็ก','kids');

INSERT INTO products (name,category,brand,color,sizes,price,stock,image_url,description) VALUES
('เสื้อยืด Essential Cotton','men','Urban Basic','ขาว','S,M,L,XL',490,18,'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=700&q=80','เสื้อยืดคอตตอนทรงสบาย ใส่ได้ทุกวัน'),
('เสื้อเชิ้ต Linen Breeze','women','Luna','ฟ้า','S,M,L',890,11,'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?auto=format&fit=crop&w=700&q=80','ผ้าลินินน้ำหนักเบา ลุคเรียบสะอาดตา'),
('เสื้อฮู้ด Mini Day','kids','Little Joy','เหลือง','100,110,120,130',650,8,'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?auto=format&fit=crop&w=700&q=80','ฮู้ดดี้นุ่มสำหรับวันที่คล่องตัว'),
('กางเกง Chino Everyday','men','Northline','เบจ','30,32,34,36',990,6,'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?auto=format&fit=crop&w=700&q=80','ทรงตรงแมตช์ง่ายสำหรับทุกโอกาส'),
('เดรส Soft Midi','women','Luna','ดำ','S,M,L',1290,14,'https://images.unsplash.com/photo-1566174053879-31528523f8ae?auto=format&fit=crop&w=700&q=80','เดรสมิดี้ทรงพลิ้ว เรียบแต่มีรายละเอียด'),
('เสื้อยืด Playful','kids','Little Joy','ชมพู','100,110,120',390,22,'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?auto=format&fit=crop&w=700&q=80','เสื้อยืดนุ่มลายสนุกสำหรับเจ้าตัวเล็ก');



-- ===== database_more_products.sql =====
INSERT INTO products (name,category,brand,color,sizes,price,stock,image_url,description,is_active) VALUES
('เสื้อยืด Airy Relax','men','Northline','เขียวมะกอก','S,M,L,XL',590,12,'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=700&q=85','เสื้อยืดทรง relaxed ผ้านุ่ม ใส่สบายทั้งวัน',1),
('เสื้อเชิ้ต Oversized Studio','men','Urban Basic','ขาว','S,M,L,XL',790,9,'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?auto=format&fit=crop&w=700&q=85','เสื้อเชิ้ตทรงโอเวอร์ไซซ์สำหรับลุคเรียบเท่',1),
('แจ็กเก็ต Everyday Light','men','Northline','ดำ','M,L,XL',1490,7,'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?auto=format&fit=crop&w=700&q=85','แจ็กเก็ตน้ำหนักเบา ใส่ได้ทุกฤดูกาล',1),
('กางเกง Relaxed Taper','men','Urban Basic','กรมท่า','30,32,34,36',1090,8,'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=700&q=85','กางเกงทรง taper เคลื่อนไหวคล่องตัว',1),
('เสื้อโปโล Soft Knit','men','Mellow Studio','ครีม','S,M,L,XL',690,14,'https://images.unsplash.com/photo-1627225924765-552d49cf47ad?auto=format&fit=crop&w=700&q=85','โปโลผ้าถักเนื้อนุ่มสำหรับวันสบาย ๆ',1),
('เดรส Cotton Day','women','Luna','ชมพูอ่อน','S,M,L',1190,10,'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=700&q=85','เดรสคอตตอนทรงสวย ใส่ได้ตั้งแต่เช้าถึงเย็น',1),
('เสื้อเบลาส์ Calm Line','women','Luna','ฟ้า','S,M,L',850,13,'https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?auto=format&fit=crop&w=700&q=85','เสื้อเบลาส์เส้นสายสะอาดตา แมตช์ง่าย',1),
('กระโปรง Midi Flow','women','Mellow Studio','เบจ','S,M,L',990,8,'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=700&q=85','กระโปรงมิดี้ทรงพลิ้วสำหรับทุกโอกาส',1),
('คาร์ดิแกน Cloud Touch','women','Luna','เหลือง','S,M,L',1090,11,'https://images.unsplash.com/photo-1576566588028-4147f3842f27?auto=format&fit=crop&w=700&q=85','คาร์ดิแกนน้ำหนักเบา สัมผัสนุ่มเป็นพิเศษ',1),
('กางเกง Wide Leg Linen','women','Luna','ขาว','S,M,L',1290,6,'https://images.unsplash.com/photo-1506629905607-d9b1bdbf9c27?auto=format&fit=crop&w=700&q=85','กางเกงลินินขากว้าง ใส่สบายและดูดี',1),
('เสื้อฮู้ด Cozy Junior','kids','Little Joy','ฟ้า','100,110,120,130',690,15,'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=700&q=85','เสื้อฮู้ดนุ่มสำหรับวันเล่นสนุก',1),
('เสื้อยืด Rainbow Kids','kids','Little Joy','เหลือง','100,110,120,130',420,20,'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=700&q=85','เสื้อยืดสีสดใสสำหรับเจ้าตัวเล็ก',1),
('กางเกง Jogger Junior','kids','Little Joy','เทา','100,110,120,130',590,12,'https://images.unsplash.com/photo-1519457431-44ccd64a579b?auto=format&fit=crop&w=700&q=85','จ็อกเกอร์เอวยืด ใส่สบายตลอดวัน',1),
('เสื้อเชิ้ต Mini Classic','kids','Mellow Studio','ขาว','100,110,120,130',620,9,'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=700&q=85','เสื้อเชิ้ตคลาสสิกสำหรับวันพิเศษ',1),
('ชุดเดรส Little Bloom','kids','Little Joy','ชมพู','100,110,120',780,7,'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?auto=format&fit=crop&w=700&q=85','เดรสลายดอกไม้แสนสดใส',1),
('เสื้อแขนยาว Daily Layer','men','Mellow Studio','เทา','S,M,L,XL',720,16,'https://images.unsplash.com/photo-1523398002811-999ca8dec234?auto=format&fit=crop&w=700&q=85','เสื้อแขนยาวสำหรับเลเยอร์ลุคประจำวัน',1),
('เสื้อยืด Graphic Mood','men','Urban Basic','ดำ','S,M,L,XL',550,19,'https://images.unsplash.com/photo-1503341504253-dff4815485f1?auto=format&fit=crop&w=700&q=85','เสื้อยืดกราฟิกดีไซน์มินิมอล',1),
('เสื้อกั๊ก Utility Soft','women','Northline','เขียว','S,M,L',890,8,'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=700&q=85','เสื้อกั๊ก utility น้ำหนักเบา สวมทับได้ง่าย',1),
('เสื้อแขนกุด Minimal Form','women','Mellow Studio','ดำ','S,M,L',620,14,'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=700&q=85','เสื้อแขนกุดทรงเรียบสำหรับวันสบาย',1),
('กางเกงขาสั้น Weekend','kids','Little Joy','กรมท่า','100,110,120,130',450,17,'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=700&q=85','กางเกงขาสั้นคล่องตัวสำหรับวันหยุด',1);



-- ===== database_product_types.sql =====
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



-- ===== database_features.sql =====
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token_hash VARCHAR(128) DEFAULT NULL, ADD COLUMN IF NOT EXISTS reset_expires_at DATETIME DEFAULT NULL;
CREATE TABLE IF NOT EXISTS wishlists (
  user_id INT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, product_id),
  CONSTRAINT fk_wishlist_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_wishlist_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);



-- ===== database_sizes.sql =====
-- มาตรฐานไซซ์ของร้าน: ใช้เฉพาะ S, M, L, XL และ 2XL
UPDATE products SET sizes='S,M,L,XL,2XL';




