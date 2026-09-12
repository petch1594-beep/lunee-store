<?php
require_once __DIR__.'/config.php';

$action = $_POST['action'] ?? $_GET['action'] ?? '';
$requestData = $_SERVER['REQUEST_METHOD'] === 'POST' ? $_POST : $_GET;
if ($_SERVER['REQUEST_METHOD'] === 'POST' && !verify_csrf($_POST['csrf'] ?? null)) { http_response_code(403); exit('คำขอไม่ถูกต้อง'); }
if ($action === 'add') {
        $id = (int)($requestData['product_id'] ?? 0);
        $stmt = db()->prepare('SELECT * FROM products WHERE id=? AND is_active=1'); $stmt->execute([$id]); $product = $stmt->fetch();
        if (!$product) { flash('error', 'ไม่พบสินค้านี้แล้ว'); redirect('index.php'); }
        if ((int)$product['stock'] < 1) { flash('error', 'สินค้านี้หมดสต็อกแล้ว'); redirect('index.php'); }
        $size = trim((string)($requestData['size'] ?? '')); $color = trim((string)($requestData['color'] ?? $product['color']));
        $availableSizes = array_values(array_filter(array_map('trim', preg_split('/[,|]/', (string)$product['sizes']))));
        if ($availableSizes && !in_array($size, $availableSizes, true)) $size = $availableSizes[0];
        $before = cart_count(); cart_add($product, (int)($requestData['quantity'] ?? 1), $size, $color);
        if (cart_count() <= $before && (int)$product['stock'] > 0) { flash('error', 'ไม่สามารถเพิ่มสินค้านี้ได้ กรุณาลองใหม่'); redirect('cart.php'); }
        flash('success', 'เพิ่ม '. $product['name'] .' ลงตะกร้าแล้ว');
        redirect((string)($requestData['return_to'] ?? 'cart.php'));
}
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['remove_key'])) { cart_remove((string)$_POST['remove_key']); flash('success', 'นำสินค้าออกจากตะกร้าแล้ว'); redirect('cart.php'); }
    if ($action === 'update') {
        foreach ((array)($_POST['quantity'] ?? []) as $key => $quantity) {
            if (!isset($_SESSION['cart'][$key])) continue;
            $productId = (int)$_SESSION['cart'][$key]['product_id']; $stmt = db()->prepare('SELECT stock FROM products WHERE id=?'); $stmt->execute([$productId]); $stock = (int)$stmt->fetchColumn();
            $quantity = min(max(0, (int)$quantity), $stock);
            if ($quantity === 0) unset($_SESSION['cart'][$key]); else $_SESSION['cart'][$key]['quantity'] = $quantity;
        }
        flash('success', 'อัปเดตตะกร้าแล้ว'); redirect('cart.php');
    }
    if ($action === 'clear') { cart_clear(); flash('success', 'ล้างตะกร้าแล้ว'); redirect('cart.php'); }
}

$items = cart_items(); $total = 0; foreach ($items as $key => &$item) {
    $stmt = db()->prepare('SELECT stock, is_active FROM products WHERE id=?'); $stmt->execute([(int)$item['product_id']]); $live = $stmt->fetch();
    if (!$live || !$live['is_active'] || (int)$live['stock'] < 1) { unset($_SESSION['cart'][$key]); unset($items[$key]); continue; }
    $item['quantity'] = min((int)$item['quantity'], (int)$live['stock']); $total += $item['price'] * $item['quantity'];
} unset($item);
$page_title = 'ตะกร้าสินค้า | '.STORE_NAME; require __DIR__.'/partials_header.php';
?>
<link rel="stylesheet" href="assets/cart.css">
<main class="container cart-page">
  <div class="cart-heading"><div><div class="eyebrow">YOUR SELECTION</div><h1>ตะกร้าสินค้า</h1><p><?=cart_count()?> รายการที่เลือกไว้สำหรับคุณ</p></div><a class="button button-outline" href="index.php">เลือกซื้อสินค้าเพิ่ม</a></div>
  <?php if (!$items): ?>
    <section class="panel cart-empty"><div class="empty-cart-icon">♡</div><h2>ตะกร้าของคุณยังว่างอยู่</h2><p class="muted">เลือกชิ้นที่ชอบ แล้วกลับมาเช็กเอาต์ได้ทุกเมื่อ</p><a class="button" href="index.php">เริ่มเลือกสินค้า →</a></section>
  <?php else: ?>
    <form method="post" class="cart-layout"><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><input type="hidden" name="action" value="update">
      <section class="panel cart-list"><div class="cart-list-head"><h2>รายการสินค้า</h2><button class="text-button danger-text" type="submit" formaction="cart.php" name="action" value="clear" formnovalidate>ล้างตะกร้า</button></div>
      <?php foreach ($items as $key => $item): ?><article class="cart-item"><img src="<?=e($item['image_url'])?>" alt="<?=e($item['name'])?>"><div class="cart-item-info"><div class="card-meta"><?=e($item['color'])?><?= $item['size'] ? ' · ไซซ์ '.e($item['size']) : '' ?></div><h3><?=e($item['name'])?></h3><strong>฿<?=number_format($item['price'], 2)?></strong><button class="text-button danger-text" type="submit" name="remove_key" value="<?=e($key)?>" formnovalidate>นำออก</button></div><div class="quantity-control"><button type="button" data-qty-minus>−</button><input name="quantity[<?=e($key)?>]" value="<?=$item['quantity']?>" min="1" max="99" inputmode="numeric"><button type="button" data-qty-plus>+</button></div><div class="line-total">฿<?=number_format($item['price']*$item['quantity'], 2)?></div></article><?php endforeach; ?><button class="button button-outline cart-update" type="submit">อัปเดตจำนวน</button></section>
      <aside class="panel cart-summary"><div class="eyebrow">ORDER SUMMARY</div><h2>สรุปคำสั่งซื้อ</h2><div class="summary-row"><span>ยอดสินค้า</span><b>฿<?=number_format($total,2)?></b></div><div class="summary-row"><span>ค่าจัดส่ง</span><span class="muted">คำนวณเมื่อสั่งซื้อ</span></div><div class="summary-total"><span>รวมโดยประมาณ</span><b>฿<?=number_format($total,2)?></b></div><?php if (current_user()): ?><a class="button full" href="member.php">ดำเนินการสั่งซื้อ →</a><?php else: ?><a class="button full" href="login.php?redirect=cart.php">เข้าสู่ระบบเพื่อสั่งซื้อ →</a><small class="muted summary-note">คุณสามารถเลือกซื้อในฐานะผู้เยี่ยมชมได้</small><?php endif; ?></aside>
    </form>
  <?php endif; ?>
</main><?php require __DIR__.'/partials_footer.php'; ?>
