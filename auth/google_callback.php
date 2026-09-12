<?php
require_once __DIR__.'/../config.php';
if (!isset($_GET['state'], $_SESSION['google_oauth_state']) || !hash_equals($_SESSION['google_oauth_state'], (string)$_GET['state'])) { flash('error', 'การยืนยัน Google ไม่ถูกต้อง กรุณาลองใหม่'); redirect('../login.php'); }
unset($_SESSION['google_oauth_state']);
if (!empty($_GET['error'])) { flash('error', 'ยกเลิกการเข้าสู่ระบบด้วย Google'); redirect('../login.php'); }
$files = glob(__DIR__.'/../client_secret*.json'); $credentials = $files ? json_decode((string)file_get_contents($files[0]), true) : null; $oauth = $credentials['web'] ?? $credentials['installed'] ?? null;
if (!$oauth || empty($_GET['code'])) { flash('error', 'ไม่พบข้อมูลตอบกลับจาก Google'); redirect('../login.php'); }
$redirectUri = app_url('auth/google_callback.php');
$ch = curl_init('https://oauth2.googleapis.com/token'); curl_setopt_array($ch, [CURLOPT_POST=>true, CURLOPT_POSTFIELDS=>http_build_query(['code'=>$_GET['code'],'client_id'=>$oauth['client_id'],'client_secret'=>$oauth['client_secret'],'redirect_uri'=>$redirectUri,'grant_type'=>'authorization_code']), CURLOPT_RETURNTRANSFER=>true, CURLOPT_TIMEOUT=>15]); $token = json_decode((string)curl_exec($ch), true); curl_close($ch);
if (empty($token['access_token'])) { flash('error', 'Google ไม่อนุญาตการเข้าสู่ระบบ หรือ redirect URI ไม่ตรง'); redirect('../login.php'); }
$ch = curl_init('https://openidconnect.googleapis.com/v1/userinfo'); curl_setopt_array($ch, [CURLOPT_HTTPHEADER=>['Authorization: Bearer '.$token['access_token']], CURLOPT_RETURNTRANSFER=>true, CURLOPT_TIMEOUT=>15]); $profile = json_decode((string)curl_exec($ch), true); curl_close($ch);
if (empty($profile['email']) || empty($profile['email_verified'])) { flash('error', 'ไม่สามารถยืนยันอีเมล Google ได้'); redirect('../login.php'); }
$s = db()->prepare('SELECT * FROM users WHERE email=?'); $s->execute([$profile['email']]); $u = $s->fetch();
if (!$u) { $name = $profile['name'] ?? strtok($profile['email'], '@'); $pass = password_hash(bin2hex(random_bytes(24)), PASSWORD_DEFAULT); $s = db()->prepare('INSERT INTO users(name,email,phone,password_hash,is_verified) VALUES(?,?,?, ?,1)'); $s->execute([$name,$profile['email'],'',$pass]); $u = ['id'=>db()->lastInsertId(),'name'=>$name,'email'=>$profile['email'],'role'=>'member']; } else { $u['is_verified'] = 1; db()->prepare('UPDATE users SET is_verified=1 WHERE id=?')->execute([$u['id']]); }
$_SESSION['user'] = ['id'=>$u['id'],'name'=>$u['name'],'email'=>$u['email'],'role'=>$u['role']]; flash('success', 'เข้าสู่ระบบด้วย Google สำเร็จ'); redirect('../index.php');
