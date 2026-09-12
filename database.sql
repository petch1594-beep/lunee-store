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
