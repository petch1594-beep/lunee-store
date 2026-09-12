<?php
require_once __DIR__.'/config.php';
if (!current_user()) redirect('login.php');
$items = cart_items();
if (!$items) { flash('error', 'กรุณาเลือกสินค้าก่อนสั่งซื้อ'); redirect('cart.php'); }
$error = null;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $shippingName = trim((string)($_POST['shipping_name'] ?? ''));
    $shippingAddress = trim((string)($_POST['shipping_address'] ?? ''));
    if ($shippingName === '' || $shippingAddress === '') $error = 'กรุณากรอกชื่อผู้รับและที่อยู่จัดส่ง';
    else {
        try {
            $pdo = db(); $pdo->beginTransaction(); $total = 0; $locked = [];
            foreach ($items as $key => $item) {
                $stmt = $pdo->prepare('SELECT * FROM products WHERE id=? AND is_active=1 FOR UPDATE'); $stmt->execute([(int)$item['product_id']]); $product = $stmt->fetch();
                if (!$product || (int)$product['stock'] < (int)$item['quantity']) throw new RuntimeException('สินค้า '.$item['name'].' มีจำนวนไม่พอแล้ว');
                $total += (float)$product['price'] * (int)$item['quantity']; $locked[] = [$item, $product];
            }
            $orderNumber = 'MW'.date('ymdHis').strtoupper(bin2hex(random_bytes(2)));
            $stmt = $pdo->prepare('INSERT INTO orders (user_id,order_number,status,total,shipping_name,shipping_address) VALUES (?,?,?,?,?,?)');
            $stmt->execute([(int)current_user()['id'],$orderNumber,'pending',$total,$shippingName,$shippingAddress]); $orderId = (int)$pdo->lastInsertId();
            $addItem = $pdo->prepare('INSERT INTO order_items (order_id,product_id,product_name,size,color,unit_price,quantity) VALUES (?,?,?,?,?,?,?)');
            $reduce = $pdo->prepare('UPDATE products SET stock=stock-? WHERE id=?');
            foreach ($locked as [$item,$product]) { $addItem->execute([$orderId,$product['id'],$product['name'],$item['size'],$item['color'],$product['price'],$item['quantity']]); $reduce->execute([$item['quantity'],$product['id']]); }
            $pdo->commit(); cart_clear(); flash('success', 'สั่งซื้อสำเร็จ เลขที่คำสั่งซื้อ '.$orderNumber); redirect('member.php');
        } catch (Throwable $e) { if (isset($pdo) && $pdo->inTransaction()) $pdo->rollBack(); $error = $e->getMessage(); }
    }
}
$total = array_sum(array_map(static fn($i) => (float)$i['price'] * (int)$i['quantity'], $items)); $page_title='ยืนยันคำสั่งซื้อ | '.STORE_NAME; require __DIR__.'/partials_header.php';
?>
<main class="container checkout-page"><div class="eyebrow">CHECKOUT</div><h1>ยืนยันคำสั่งซื้อ</h1><?php if($error): ?><div class="notice error" role="alert"><span>!</span><?=e($error)?></div><?php endif; ?><form method="post" class="checkout-layout"><section class="panel"><h2>ข้อมูลจัดส่ง</h2><label class="checkout-field">ชื่อผู้รับ<input name="shipping_name" required value="<?=e($_POST['shipping_name'] ?? current_user()['name'])?>"></label><label class="checkout-field">ที่อยู่จัดส่ง<textarea name="shipping_address" rows="5" required placeholder="บ้านเลขที่ ถนน แขวง/ตำบล เขต/อำเภอ จังหวัด รหัสไปรษณีย์"><?=e($_POST['shipping_address'] ?? '')?></textarea></label><button class="button" type="submit">ยืนยันและบันทึกคำสั่งซื้อ →</button></section><aside class="panel checkout-summary"><h2>รายการของคุณ</h2><?php foreach($items as $item): ?><div class="checkout-line"><span><?=e($item['name'])?> × <?=$item['quantity']?></span><b>฿<?=number_format($item['price']*$item['quantity'],2)?></b></div><?php endforeach; ?><div class="summary-total"><span>ยอดรวม</span><b>฿<?=number_format($total,2)?></b></div></aside></form></main><link rel="stylesheet" href="assets/cart.css"><style>.checkout-page{padding:42px 24px 75px}.checkout-page h1{font-size:38px;margin:8px 0 25px}.checkout-layout{display:grid;grid-template-columns:1fr 360px;gap:20px}.checkout-layout .panel{margin:0;padding:26px}.checkout-layout h2{font-size:21px;margin-top:0}.checkout-field{display:grid;gap:7px;font-weight:600;font-size:13px;margin:17px 0}.checkout-field textarea{resize:vertical}.checkout-line{display:flex;justify-content:space-between;gap:12px;padding:13px 0;border-bottom:1px solid var(--line);font-size:13px}@media(max-width:750px){.checkout-layout{grid-template-columns:1fr}.checkout-summary{order:-1}}</style><?php require __DIR__.'/partials_footer.php'; ?>
