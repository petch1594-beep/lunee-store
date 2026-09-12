<?php
require_once __DIR__.'/../config.php';
if (!isset($_GET['state'], $_SESSION['facebook_oauth_state']) || !hash_equals($_SESSION['facebook_oauth_state'], (string)$_GET['state'])) { flash('error', 'การยืนยัน Facebook ไม่ถูกต้อง กรุณาลองใหม่'); redirect('../login.php'); }
unset($_SESSION['facebook_oauth_state']);
if (!empty($_GET['error'])) { flash('error', 'ยกเลิกการเข้าสู่ระบบด้วย Facebook'); redirect('../login.php'); }
$configFile = __DIR__.'/../facebook_app.json'; $app = is_file($configFile) ? json_decode((string)file_get_contents($configFile), true) : null;
if (!$app || empty($app['app_id']) || empty($app['app_secret']) || empty($_GET['code'])) { flash('error', 'ยังไม่ได้ตั้งค่า Facebook OAuth ครบ'); redirect('../login.php'); }
$redirectUri = app_url('auth/facebook_callback.php');
$ch = curl_init('https://graph.facebook.com/v20.0/oauth/access_token'); curl_setopt_array($ch, [CURLOPT_POST=>true, CURLOPT_POSTFIELDS=>http_build_query(['client_id'=>$app['app_id'],'client_secret'=>$app['app_secret'],'redirect_uri'=>$redirectUri,'code'=>$_GET['code']]), CURLOPT_RETURNTRANSFER=>true, CURLOPT_TIMEOUT=>15]); $token = json_decode((string)curl_exec($ch), true); curl_close($ch);
if (empty($token['access_token'])) { flash('error', 'Facebook ไม่อนุญาตการเข้าสู่ระบบ หรือ redirect URI ไม่ตรง'); redirect('../login.php'); }
$query = http_build_query(['fields'=>'id,name,email','access_token'=>$token['access_token']]); $ch = curl_init('https://graph.facebook.com/v20.0/me?'.$query); curl_setopt_array($ch, [CURLOPT_RETURNTRANSFER=>true, CURLOPT_TIMEOUT=>15]); $profile = json_decode((string)curl_exec($ch), true); curl_close($ch);
$facebookEmail = !empty($profile['email']) ? strtolower($profile['email']) : 'facebook_'.$profile['id'].'@facebook.local';
if (empty($profile['id'])) { flash('error', 'Facebook ไม่ส่งข้อมูลโปรไฟล์กลับมา'); redirect('../login.php'); }
$s = db()->prepare('SELECT * FROM users WHERE email=?'); $s->execute([$facebookEmail]); $u = $s->fetch();
if (!$u) { $name = $profile['name'] ?? 'Facebook member'; $pass = password_hash(bin2hex(random_bytes(24)), PASSWORD_DEFAULT); $s = db()->prepare('INSERT INTO users(name,email,phone,password_hash,is_verified) VALUES(?,?,?, ?,1)'); $s->execute([$name,$facebookEmail,'',$pass]); $u = ['id'=>db()->lastInsertId(),'name'=>$name,'email'=>$facebookEmail,'role'=>'member']; } else { db()->prepare('UPDATE users SET is_verified=1 WHERE id=?')->execute([$u['id']]); }
$_SESSION['user'] = ['id'=>$u['id'],'name'=>$u['name'],'email'=>$u['email'],'role'=>$u['role']]; flash('success', 'เข้าสู่ระบบด้วย Facebook สำเร็จ'); redirect('../index.php');
