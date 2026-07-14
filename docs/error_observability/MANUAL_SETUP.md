# نظام مراقبة الأخطاء — دليل الإعداد اليدوي (المرحلة 3)

هذا الدليل ينشر طبقة الاستقبال والتجميع والتنبيه (Cloud Functions + قواعد +
فهارس + Telegram). الكود جاهز ومختبَر؛ الخطوات أدناه يدوية لأنها تحتاج حسابك
على Telegram و Firebase.

> المشروع: `ghasaq-75883` · موقع Firestore: `eur3` (أوروبا) · منطقة الدالة:
> `europe-west1` (يجب أن تطابق موقع Firestore، وإلا فشل نشر المُشغِّل).

---

## 0) المتطلبات

```bash
firebase login          # نفس حساب boodeuae0909@gmail.com
node --version          # 20 أو أحدث
cd functions && npm install && npm run build && npm test   # يجب أن يمرّ الكل
```

---

## 1) إنشاء بوت Telegram والحصول على المعرّفات

1. في Telegram: راسِل **@BotFather** → `/newbot` → اختر اسماً → ستحصل على
   **TOKEN** بالشكل `1234567890:AAE...`.
2. أرسل أي رسالة إلى بوتك الجديد (لتفعيل المحادثة).
3. احصل على **CHAT_ID**: افتح في المتصفح (ضع التوكن مكان `<TOKEN>`):
   ```
   https://api.telegram.org/bot<TOKEN>/getUpdates
   ```
   انسخ الرقم من `"chat":{"id":<CHAT_ID>...}`. (للمجموعات يكون سالباً.)

---

## 2) ضبط الأسرار (Secrets)

```bash
firebase functions:secrets:set 8596453872:AAEZx_DZ8c7JBspXt2h8l0ORugKaUIXrxME     # الصق التوكن
firebase functions:secrets:set 1311787318      # الصق chat id
```
تُخزَّن مشفّرة في Secret Manager ولا تدخل الكود أبداً.

---

## 3) نشر القواعد والفهارس

```bash
firebase deploy --only firestore:rules,firestore:indexes
```
- القواعد تفتح **القراءة للوحة فقط** (`isDashboardAdmin` = بريدك) وتُبقي كتابة
  التطبيق كما هي. `error_groups` تكتبها الدوال فقط (Admin SDK يتجاوز القواعد)؛
  اللوحة تقرأ وتُعدّل حقل `status` فقط.
- بناء الفهارس على مجموعات شبه فارغة فوري.

---

## 4) نشر الدوال

```bash
firebase deploy --only functions
```
يبني TypeScript ثم ينشر `onErrorEventCreated` في `europe-west1`.

> إن ظهر خطأ عن **location/region**: الرسالة تذكر المنطقة الصحيحة لموقع Firestore
> لديك — ضعها في `FUNCTION_REGION` داخل [functions/src/config.ts](../../functions/src/config.ts) وأعد النشر.

---

## 5) سياسات TTL (حذف تلقائي — من الكونسول)

Firestore Console → **TTL** → أضف سياستين:
| Collection | Timestamp field |
|---|---|
| `error_events` | `expire_at` (+30 يوماً، يضعه المُرفِّع) |
| `error_groups` — لا TTL (دائمة) | — |
| `flow_runs` | `expire_at` (+14 يوماً) |

(أو عبر gcloud):
```bash
gcloud firestore fields ttls update expire_at \
  --collection-group=error_events --enable-ttl --project=ghasaq-75883
gcloud firestore fields ttls update expire_at \
  --collection-group=flow_runs --enable-ttl --project=ghasaq-75883
```

---

## 6) التحقق (end-to-end)

1. من التطبيق (debug): `/error_test` → «رمي متزامن» مرتين.
2. Firestore → `error_events`: وثيقتان بنفس `fingerprint`.
3. `error_groups/<fingerprint>`: وثيقة واحدة `count: 2`، `counts_hourly` محدّث،
   subcollection `occurrences` فيها مؤشران.
4. Telegram: تصلك رسالة **مرة واحدة** (خطأ جديد ≥ error)؛ الضغطة الثانية مكبوتة
   بالتهدئة (6 ساعات).
5. زر «الفشل الصامت المصطنع» → يتجمّع تحت بصمة `silent_failure|adhan|...`.
6. سلبي: محاولة كتابة `error_groups` من عميل غير مصرّح → مرفوضة بالقواعد.

---

## 7) التراجع (Rollback)

```bash
# القواعد: انشر النسخة السابقة من firestore.rules عبر git
firebase functions:delete onErrorEventCreated --region europe-west1   # إزالة الدالة
```
حذف الدالة يوقف التجميع والتنبيه فوراً؛ التطبيق يستمر بالكتابة إلى `error_events`
بلا تأثّر (فصل تام بين الالتقاط والتجميع).

---

## ملاحظات معمارية

- **البصمة تُعاد حسابها في الخادم** (لا نثق ببصمة العميل) — `functions/src/fingerprint.ts`
  نسخة طبق الأصل من Dart بنفس متجهات الاختبار المشتركة.
- **قرار التنبيه**: خطأ جديد (≥ error) أو **قفزة** (≥10/ساعة و ≥5× المتوسط) أو
  **إعادة فتح** (resolved→open). تهدئة 6 ساعات لكل بصمة.
- **لا دوال مجدولة**: كشف القفزة داخل المُشغِّل عبر `counts_hourly`؛ نسب النجاح
  تُحسب في اللوحة من `flow_runs`.
