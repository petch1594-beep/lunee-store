-- นำเข้าไฟล์นี้หลังจากคลิกฐานข้อมูล workshop_db ใน phpMyAdmin
-- ไฟล์นี้ไม่สร้างฐานข้อมูลใหม่ จึงไม่ต้องใช้สิทธิ์ CREATE DATABASE
USE workshop_db;

CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('member','admin') NOT NULL DEFAULT 'member',
  is_verified TINYINT(1) NOT NULL DEFAULT 0,
  verification_code VARCHAR(6) DEFAULT NULL,
  code_expires_at DATETIME DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
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

INSERT INTO products (name,category,brand,color,sizes,price,stock,image_url,description)
SELECT name,category,brand,color,sizes,price,stock,image_url,description FROM (
  SELECT 'เสื้อยืด Essential Cotton' name,'men' category,'Urban Basic' brand,'ขาว' color,'S,M,L,XL' sizes,490 price,18 stock,'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=700&q=80' image_url,'เสื้อยืดคอตตอนทรงสบาย ใส่ได้ทุกวัน' description
  UNION ALL SELECT 'เสื้อเชิ้ต Linen Breeze','women','Luna','ฟ้า','S,M,L',890,11,'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?auto=format&fit=crop&w=700&q=80','ผ้าลินินน้ำหนักเบา ลุคเรียบสะอาดตา'
  UNION ALL SELECT 'เสื้อฮู้ด Mini Day','kids','Little Joy','เหลือง','100,110,120,130',650,8,'https://images.unsplash.com/photo-1519238360530-4b3f1d4e8e47?auto=format&fit=crop&w=700&q=80','ฮู้ดดี้นุ่มสำหรับวันที่คล่องตัว'
  UNION ALL SELECT 'กางเกง Chino Everyday','men','Northline','เบจ','30,32,34,36',990,6,'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?auto=format&fit=crop&w=700&q=80','ทรงตรงแมตช์ง่ายสำหรับทุกโอกาส'
  UNION ALL SELECT 'เดรส Soft Midi','women','Luna','ดำ','S,M,L',1290,14,'https://images.unsplash.com/photo-1566174053879-31528523f8ae?auto=format&fit=crop&w=700&q=80','เดรสมิดี้ทรงพลิ้ว เรียบแต่มีรายละเอียด'
  UNION ALL SELECT 'เสื้อยืด Playful','kids','Little Joy','ชมพู','100,110,120',390,22,'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?auto=format&fit=crop&w=700&q=80','เสื้อยืดนุ่มลายสนุกสำหรับเจ้าตัวเล็ก'
) AS sample_products
WHERE NOT EXISTS (SELECT 1 FROM products LIMIT 1);
