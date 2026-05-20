// ========================================================
// Typography System - Ghasaq
// ========================================================
// Curated Arabic + Latin font stacks for a luxurious feel

export const FONTS = {
  // For the brand name "غسق" — most ornate
  brand: '"Aref Ruqaa Ink", "Aref Ruqaa", serif',

  // For large headlines — modern calligraphy feel
  display: '"El Messiri", "Reem Kufi Fun", serif',

  // For sub-headlines — traditional and elegant
  headline: '"El Messiri", "Markazi Text", serif',

  // For Quranic verses — official Quranic typography
  quran: '"Amiri Quran", "Amiri", serif',

  // For body text — clean and readable
  body: '"Tajawal", sans-serif',

  // For Latin / monospace text
  mono: '"SF Pro Display", -apple-system, system-ui, sans-serif',
};

// Google Fonts import URL (used in animations.css)
export const FONTS_IMPORT_URL =
  'https://fonts.googleapis.com/css2?' +
  [
    'family=Amiri:wght@400;700',
    'family=Amiri+Quran',
    'family=Aref+Ruqaa+Ink:wght@400;700',
    'family=El+Messiri:wght@400;500;600;700',
    'family=Markazi+Text:wght@400;500;600;700',
    'family=Reem+Kufi+Fun:wght@400;500;700',
    'family=Tajawal:wght@300;400;500;700;800',
  ].join('&') +
  '&display=swap';
