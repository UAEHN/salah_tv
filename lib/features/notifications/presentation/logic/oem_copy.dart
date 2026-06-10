/// User-facing labels for the OEM autostart guidance. Centralised here so
/// `oem_guidance_card.dart` and `oem_autostart_page.dart` share one source
/// — satisfies CLAUDE.md §3 (no key-policy / selection rules in widgets)
/// and §4 (DRY: same map repeated in 2+ widget files).
class OemCopy {
  const OemCopy();

  String label(String vendor) => switch (vendor) {
    'xiaomi' => 'Xiaomi / Redmi / Poco (MIUI)',
    'huawei' => 'Huawei / Honor (EMUI)',
    'oppo' => 'Oppo / Realme (ColorOS)',
    'vivo' => 'Vivo (FunTouch)',
    _ => vendor,
  };

  String guidanceMessage(String vendor) =>
      'نظام ${label(vendor)} يقتل التطبيقات في الخلفية حتى مع إعفاء البطارية. '
      'افتح صفحة Autostart أو "التطبيقات المحمية" وفعّل غسق لضمان وصول الإشعارات.';
}
