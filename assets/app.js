document.querySelectorAll('[data-confirm]').forEach(el => el.addEventListener('click', e => { if (!confirm(el.dataset.confirm)) e.preventDefault(); }));

// Global interaction polish: navigation, scroll feedback, reveal motion and safe image fallback.
const header = document.querySelector('.site-header');
const progress = document.querySelector('.page-progress');
const topButton = document.querySelector('.back-to-top');

// Smooth page-to-page transition for internal navigation.
const transitionLayer = document.createElement('div');
transitionLayer.className = 'page-transition';
transitionLayer.setAttribute('aria-hidden', 'true');
transitionLayer.innerHTML = '<div class="page-transition-mark"><span>LUNE</span><i>É</i><small>กำลังพาคุณไปต่อ</small><b></b></div>';
document.body.appendChild(transitionLayer);
requestAnimationFrame(() => document.body.classList.add('page-ready'));
addEventListener('pageshow', () => { document.body.classList.remove('is-leaving'); requestAnimationFrame(() => document.body.classList.add('page-ready')); });
document.addEventListener('click', event => {
  const link = event.target.closest('a[href]');
  if (!link || event.defaultPrevented || link.target === '_blank' || link.hasAttribute('download') || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
  const rawHref = link.getAttribute('href') || '';
  if (!rawHref || rawHref.startsWith('#') || rawHref.startsWith('mailto:') || rawHref.startsWith('tel:') || rawHref.startsWith('javascript:')) return;
  const destination = new URL(link.href, location.href);
  if (destination.origin !== location.origin || (destination.pathname === location.pathname && destination.search === location.search && destination.hash)) return;
  event.preventDefault();
  document.body.classList.add('is-leaving');
  transitionLayer.classList.add('active');
  window.setTimeout(() => { window.location.href = destination.href; }, 300);
});
const onScroll = () => {
  const max = document.documentElement.scrollHeight - innerHeight;
  if (progress) progress.style.transform = `scaleX(${max > 0 ? scrollY / max : 0})`;
  header?.classList.toggle('is-scrolled', scrollY > 18);
  topButton?.classList.toggle('is-visible', scrollY > 480);
};
addEventListener('scroll', onScroll, { passive: true }); onScroll();
topButton?.addEventListener('click', () => scrollTo({ top: 0, behavior: 'smooth' }));

const menuButton = document.querySelector('.menu-toggle');
menuButton?.addEventListener('click', () => {
  const isOpen = document.body.classList.toggle('menu-open');
  menuButton.setAttribute('aria-expanded', String(isOpen));
});
document.querySelectorAll('.main-nav a').forEach(link => link.addEventListener('click', () => document.body.classList.remove('menu-open')));

const observer = 'IntersectionObserver' in window ? new IntersectionObserver(entries => entries.forEach(entry => {
  if (entry.isIntersecting) { entry.target.classList.add('is-revealed'); observer.unobserve(entry.target); }
}), { threshold: .12 }) : null;
document.querySelectorAll('[data-reveal]').forEach(el => observer ? observer.observe(el) : el.classList.add('is-revealed'));

document.querySelectorAll('.notice button').forEach(button => button.addEventListener('click', () => button.parentElement.remove()));
setTimeout(() => document.querySelectorAll('.notice').forEach(el => el.classList.add('notice-out')), 4800);

const backupImage = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 800 1000'%3E%3Cdefs%3E%3ClinearGradient id='g' x1='0' y1='0' x2='1' y2='1'%3E%3Cstop stop-color='%23dce8df'/%3E%3Cstop offset='1' stop-color='%23b9ccbd'/%3E%3C/linearGradient%3E%3C/defs%3E%3Crect width='800' height='1000' fill='url(%23g)'/%3E%3Ccircle cx='400' cy='350' r='105' fill='%23f8f7f2' opacity='.62'/%3E%3Cpath d='M200 780c15-210 120-310 200-310s185 100 200 310' fill='%23f8f7f2' opacity='.62'/%3E%3Ctext x='400' y='920' text-anchor='middle' font-family='Arial' font-size='30' fill='%23385c46'%3EMELLOW WEAR%3C/text%3E%3C/svg%3E";
document.querySelectorAll('img').forEach(img => img.addEventListener('error', () => {
  if (img.src !== backupImage) { img.src = backupImage; img.classList.add('image-fallback'); }
}, { once: true }));

// Account forms: show/hide password, live strength feedback, confirmation and phone formatting.
document.querySelectorAll('.password-toggle').forEach(button => button.addEventListener('click', () => {
  const input = button.closest('.password-wrap').querySelector('input');
  const show = input.type === 'password'; input.type = show ? 'text' : 'password';
  button.textContent = show ? 'ซ่อน' : 'แสดง'; button.setAttribute('aria-label', show ? 'ซ่อนรหัสผ่าน' : 'แสดงรหัสผ่าน');
}));
document.querySelectorAll('.social a').forEach(link => {
  if (link.querySelector('.facebook-mark')) { link.onclick = null; link.href = 'auth/facebook_start.php'; }
});
document.querySelectorAll('.forgot-link').forEach(link => { link.href = 'forgot.php'; link.onclick = null; });
const consentBox = document.querySelector('.consent input[type="checkbox"]'); if (consentBox) consentBox.name = 'consent';
const consentNotice = [...document.querySelectorAll('.notice.error')].find(el => el.textContent.includes('ยอมรับข้อกำหนด'));
const consentLabel = document.querySelector('.consent');
if (consentNotice && consentLabel) { const inlineError=document.createElement('small'); inlineError.className='consent-error'; inlineError.textContent=consentNotice.textContent.replace('!','').trim(); consentLabel.insertAdjacentElement('afterend',inlineError); consentNotice.remove(); consentBox?.focus(); }
const brand = document.querySelector('.brand'); if (brand) { brand.innerHTML = 'LUNE<span>É</span>'; brand.setAttribute('aria-label','LUNEÉ หน้าหลัก'); }
const sizeFilter = document.querySelector('select[name="size"]');
if (sizeFilter) { [...sizeFilter.options].forEach(option => { if (/^\d+$/.test(option.value)) option.remove(); }); if (![...sizeFilter.options].some(option => option.value === '2XL')) sizeFilter.insertAdjacentHTML('beforeend', '<option value="2XL">2XL</option>'); }

const megaData = {
  men: [['เสื้อ','tops','เสื้อยืด · เสื้อเชิ้ต'],['กางเกง','pants','กางเกงขายาว · ชิโน'],['กางเกงยีนส์','jeans','ยีนส์ทรงตรง · ยีนส์ขากว้าง'],['กางเกงขาสั้น','shorts','ขาสั้นวันหยุด'],['รองเท้า','shoes','รองเท้าผ้าใบ']],
  women: [['เสื้อ','tops','เสื้อเบลาส์ · เสื้อยืด'],['กางเกงยีนส์','jeans','ยีนส์ทรงสวย'],['กางเกง','pants','กางเกงขายาว · ขากว้าง'],['เดรส','dresses','เดรสทุกโอกาส'],['รองเท้า','shoes','รองเท้าคู่โปรด']],
  kids: [['เสื้อ','tops','เสื้อนุ่มสำหรับเด็ก'],['กางเกง','pants','กางเกงคล่องตัว'],['กางเกงขาสั้น','shorts','ขาสั้นวันเล่น'],['รองเท้า','shoes','รองเท้าสำหรับเด็ก']]
};
const nav = document.querySelector('.main-nav'); if (nav) { const menu = document.createElement('div'); menu.className='mega-menu'; const close=()=>menu.classList.remove('open'); nav.parentElement.appendChild(menu); let timer;
  nav.querySelectorAll('a[href*="category="]').forEach(link => { const category=new URL(link.href,location.href).searchParams.get('category'); if(!megaData[category]) return; const open=()=>{clearTimeout(timer);menu.innerHTML='<div class="mega-inner"><div class="mega-heading">'+(category==='men'?'MEN':category==='women'?'WOMEN':'KIDS')+' / SHOP BY CATEGORY</div><div class="mega-columns">'+megaData[category].map(item=>'<a href="index.php?category='+category+'&type='+item[1]+'#new-arrivals"><b>'+item[0]+'</b><small>'+item[2]+'</small><span>→</span></a>').join('')+'</div></div>';menu.classList.add('open')}; link.addEventListener('mouseenter',open); link.addEventListener('focus',open); link.addEventListener('mouseleave',()=>{timer=setTimeout(close,180)}); }); menu.addEventListener('mouseenter',()=>clearTimeout(timer)); menu.addEventListener('mouseleave',()=>{timer=setTimeout(close,180)}); }

if (location.hash === '#new-arrivals' || new URLSearchParams(location.search).has('type')) {
  const productSection = document.querySelector('#new-arrivals');
  if (productSection) requestAnimationFrame(() => setTimeout(() => productSection.scrollIntoView({behavior:'smooth', block:'start'}), 120));
}
if (nav) { const currentCategory = new URLSearchParams(location.search).get('category'); nav.querySelectorAll('a').forEach(link => { const category = new URL(link.href, location.href).searchParams.get('category'); if ((currentCategory && category === currentCategory) || (!currentCategory && link.getAttribute('href') === 'index.php')) link.classList.add('active'); }); }
const registerForm = document.querySelector('[data-register-form]');
if (registerForm) {
  const password = registerForm.querySelector('#password');
  const confirmPassword = registerForm.querySelector('#confirm_password');
  const meter = registerForm.querySelector('.password-meter');
  const match = registerForm.querySelector('.match-message');
  const updatePasswordUI = () => {
    const value = password.value; const score = [value.length >= 8, /[A-Z]/i.test(value) && /\d/.test(value), /[^A-Za-z0-9]/.test(value), value.length >= 12].filter(Boolean).length;
    meter.className = `password-meter ${score <= 1 ? 'is-weak' : score === 2 ? 'is-fair' : score === 3 ? 'is-good' : value ? 'is-strong' : ''}`;
    if (confirmPassword.value) { const ok = value === confirmPassword.value; match.textContent = ok ? '✓ รหัสผ่านตรงกัน' : 'รหัสผ่านยังไม่ตรงกัน'; match.className = `match-message ${ok ? 'is-match' : 'is-error'}`; }
  };
  password.addEventListener('input', updatePasswordUI); confirmPassword.addEventListener('input', updatePasswordUI);
  registerForm.addEventListener('submit', event => { if (password.value !== confirmPassword.value) { event.preventDefault(); confirmPassword.focus(); updatePasswordUI(); } });
  const clearInlineErrors = () => registerForm.querySelectorAll('.field-error,.consent-error').forEach(el => el.remove());
  const addFieldError = (field, message) => { const error=document.createElement('small'); error.className='field-error'; error.textContent=message; field.closest('.field')?.appendChild(error); };
  const addConsentError = message => { const error=document.createElement('small'); error.className='consent-error'; error.textContent=message; document.querySelector('.consent')?.insertAdjacentElement('afterend', error); };
  registerForm.addEventListener('submit', event => {
    clearInlineErrors(); let firstInvalid=null;
    const name=registerForm.querySelector('#name'), email=registerForm.querySelector('#email'), phone=registerForm.querySelector('#phone'), confirm=registerForm.querySelector('#confirm_password');
    if (!name.value.trim() || name.value.trim().length < 2) { addFieldError(name,'กรุณากรอกชื่ออย่างน้อย 2 ตัวอักษร'); firstInvalid ||= name; }
    if (!email.value.trim() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim())) { addFieldError(email,'กรุณากรอกอีเมลให้ถูกต้อง'); firstInvalid ||= email; }
    if (!phone.value.replace(/\D/g,'') || phone.value.replace(/\D/g,'').length < 9) { addFieldError(phone,'กรุณากรอกเบอร์โทรศัพท์ให้ครบถ้วน'); firstInvalid ||= phone; }
    if (password.value.length < 8) { addFieldError(password,'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร'); firstInvalid ||= password; }
    if (confirm.value !== password.value) { addFieldError(confirm,'รหัสผ่านไม่ตรงกัน'); firstInvalid ||= confirm; }
    if (!consentBox?.checked) { addConsentError('กรุณายอมรับข้อกำหนดก่อนสมัครสมาชิก'); firstInvalid ||= consentBox; }
    if (firstInvalid) { event.preventDefault(); firstInvalid.focus(); }
  });
  const serverNotice = [...document.querySelectorAll('.notice.error')].find(el => el.textContent.includes('กรุณากรอกชื่อ'));
  if (serverNotice) { serverNotice.remove(); registerForm.dispatchEvent(new Event('submit',{cancelable:true})); }
  const phone = registerForm.querySelector('#phone');
  phone?.addEventListener('input', () => { const numbers = phone.value.replace(/\D/g, '').slice(0, 10); phone.value = numbers.length > 6 ? `${numbers.slice(0, 3)}-${numbers.slice(3, 6)}-${numbers.slice(6)}` : numbers.length > 3 ? `${numbers.slice(0, 3)}-${numbers.slice(3)}` : numbers; });
}

document.querySelectorAll('[data-qty-minus],[data-qty-plus]').forEach(button => button.addEventListener('click', () => {
  const input = button.parentElement.querySelector('input');
  const current = Number.parseInt(input.value, 10) || 1;
  input.value = Math.max(Number(input.min) || 1, Math.min(Number(input.max) || 99, current + (button.hasAttribute('data-qty-plus') ? 1 : -1)));
}));

document.querySelectorAll('.store-card').forEach(card => {
  const link = card.querySelector('a.card-image[href*="product.php?id="]');
  const body = card.querySelector('.card-body');
  if (!link || !body || card.querySelector('.quick-add-form')) return;
  const id = new URL(link.href, location.href).searchParams.get('id');
  if (!id) return;
  const form = document.createElement('form'); form.method = 'post'; form.action = 'cart.php'; form.className = 'quick-add-form';
  form.innerHTML = '<input type="hidden" name="action" value="add"><input type="hidden" name="product_id" value="' + id + '"><input type="hidden" name="return_to" value="cart.php"><button class="button" type="submit">เพิ่มลงตะกร้า</button>';
  body.appendChild(form);
});

const quickView = document.createElement('div'); quickView.className = 'quick-view-modal'; quickView.innerHTML = '<div class="quick-view-backdrop"></div><div class="quick-view-dialog"><button class="quick-view-close" aria-label="ปิด">×</button><div class="quick-view-content"></div></div>'; document.body.appendChild(quickView);
const quickStyle = document.createElement('style'); quickStyle.textContent = '.quick-view-modal{position:fixed;inset:0;z-index:100;display:none;place-items:center;padding:20px}.quick-view-modal.open{display:grid}.quick-view-backdrop{position:absolute;inset:0;background:rgba(20,31,24,.6);backdrop-filter:blur(5px)}.quick-view-dialog{position:relative;z-index:1;width:min(760px,100%);max-height:90vh;overflow:auto;background:#fff;border-radius:15px;padding:25px;box-shadow:0 25px 70px rgba(0,0,0,.25)}.quick-view-close{position:absolute;right:15px;top:11px;border:0;background:transparent;font-size:27px;cursor:pointer;color:#576158}.quick-view-content{display:grid;grid-template-columns:1fr 1fr;gap:25px}.quick-view-content img{width:100%;height:360px;object-fit:cover;border-radius:9px}.quick-view-content h2{margin:8px 0 16px}.quick-view-loading{text-align:center;padding:50px;color:#6d766f}@media(max-width:600px){.quick-view-content{grid-template-columns:1fr}.quick-view-content img{height:260px}}'; document.head.appendChild(quickStyle);
const closeQuick = () => quickView.classList.remove('open'); quickView.querySelector('.quick-view-close').addEventListener('click', closeQuick); quickView.querySelector('.quick-view-backdrop').addEventListener('click', closeQuick);
document.querySelectorAll('.store-card a.card-image').forEach(link => { const button=document.createElement('button'); button.type='button'; button.className='quick-view-button'; button.innerHTML='<span>⌕</span> ดูแบบเร็ว'; link.parentElement.appendChild(button); button.addEventListener('click', async event => { event.preventDefault(); quickView.classList.add('open'); const content=quickView.querySelector('.quick-view-content'); content.innerHTML='<div class="quick-view-loading">กำลังโหลดสินค้า…</div>'; try { const html=await fetch(link.href).then(r=>r.text()); const doc=new DOMParser().parseFromString(html,'text/html'); const image=doc.querySelector('.product-detail>img'); const title=doc.querySelector('.product-detail-copy h1'); const price=doc.querySelector('.product-price'); const desc=doc.querySelector('.product-detail-copy>p'); content.innerHTML='<div><img src="'+(image?.src||'')+'" alt=""></div><div><div class="eyebrow">MELLOW WEAR</div><h2>'+(title?.textContent||'สินค้า')+'</h2><div class="price">'+(price?.textContent||'')+'</div><p>'+(desc?.textContent||'')+'</p><a class="button" href="'+link.href+'">ดูรายละเอียดและเลือกไซซ์ →</a></div>'; } catch { content.innerHTML='<div class="quick-view-loading">โหลดข้อมูลไม่สำเร็จ</div>'; } }); });

// Storefront hero carousel with pause-on-hover and keyboard-friendly controls.
const hero = document.querySelector('.store-hero');
if (hero) {
  const slides = [...hero.querySelectorAll('.hero-slide')]; const dots = [...hero.querySelectorAll('.hero-dots i')]; let current = 0; let timer;
  const showSlide = (index) => { current = (index + slides.length) % slides.length; slides.forEach((slide, i) => slide.classList.toggle('active', i === current)); dots.forEach((dot, i) => dot.classList.toggle('active', i === current)); };
  const restart = () => { clearInterval(timer); timer = setInterval(() => showSlide(current + 1), 6500); };
  hero.querySelector('.next')?.addEventListener('click', () => { showSlide(current + 1); restart(); }); hero.querySelector('.prev')?.addEventListener('click', () => { showSlide(current - 1); restart(); }); dots.forEach((dot, i) => dot.addEventListener('click', () => { showSlide(i); restart(); })); hero.addEventListener('mouseenter', () => clearInterval(timer)); hero.addEventListener('mouseleave', restart); restart();
}
