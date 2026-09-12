<?php
// คัดลอกไฟล์นี้เป็น config.local.php แล้วแก้ค่าให้ตรงกับเครื่องปลายทาง
return [
    'DB_HOST' => '127.0.0.1',
    'DB_NAME' => 'clothing_store',
    'DB_USER' => 'root',
    'DB_PASS' => '',
    'STORE_NAME' => 'LUNEÉ',
    // URL เต็มของเว็บ เช่น http://localhost/DDDD หรือ https://shop.example.com
    'APP_URL' => 'http://localhost/DDDD',
    // ถ้าไม่ตั้งค่า ระบบจะใช้ mail() และแสดงรหัสสำหรับทดสอบ Local ตามเดิม
    'MAIL_USERNAME' => '',
    'MAIL_APP_PASSWORD' => '',
    'MAIL_FROM_NAME' => 'LUNEÉ',
];
