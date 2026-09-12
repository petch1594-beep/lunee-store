<?php
require_once __DIR__.'/../config.php';
$configFile = __DIR__.'/../facebook_app.json';
if (!is_file($configFile)) { flash('error', 'ยังไม่ได้ตั้งค่า Facebook App ID/Secret'); redirect('../login.php'); }
$app = json_decode((string)file_get_contents($configFile), true);
if (empty($app['app_id'])) { flash('error', 'ไฟล์ Facebook OAuth ไม่ถูกต้อง'); redirect('../login.php'); }
$redirectUri = app_url('auth/facebook_callback.php');
$_SESSION['facebook_oauth_state'] = bin2hex(random_bytes(24));
$params = ['client_id'=>$app['app_id'], 'redirect_uri'=>$redirectUri, 'state'=>$_SESSION['facebook_oauth_state'], 'scope'=>'public_profile', 'response_type'=>'code'];
header('Location: https://www.facebook.com/v20.0/dialog/oauth?'.http_build_query($params)); exit;
