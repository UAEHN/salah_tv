import IconClock from "../components/icons/IconClock";
import IconCompass from "../components/icons/IconCompass";
import IconBeads from "../components/icons/IconBeads";

/**
 * Feature scene props.
 *
 * Copy is intentionally short and value-oriented — every line
 * earns its place. No descriptive filler. No generic English.
 */
export const FEATURES = {
  prayer: {
    Icon: IconClock,
    sceneNum: "01",
    title: "في موعدها · دائماً",
    subtitle: "بدقّة فلكية · لمدينتك · لمذهبك",
    kineticWords: ["13 طريقة حساب", "190+ دولة", "تعديل دقيق"],
    desc: "صلاتك في وقتها\nبلا تخمين · بلا تأخير",
    accentLine: "المواقيت",
  },
  qibla: {
    Icon: IconCompass,
    sceneNum: "02",
    title: "الكعبة في يدك",
    subtitle: "أينما كنت · بدون إنترنت",
    kineticWords: ["تتبع لحظي", "زاوية القبلة", "مسافة الكعبة"],
    desc: "وجّه قلبك\nووجّه صلاتك",
    accentLine: "القبلة",
  },
  athkar: {
    Icon: IconBeads,
    sceneNum: "03",
    title: "أذكار · لا تُنسى",
    subtitle: "صباحاً · مساءً · بعد كل صلاة",
    kineticWords: ["حصن المسلم", "تسبيح بالاهتزاز", "تذكير يومي"],
    desc: "اذكر الله\nوالتطبيق يحصي عنك",
    accentLine: "الأذكار",
  },
};

/**
 * Scene order and durations (in milliseconds).
 */
export const SCENE_TIMELINE = [
  { id: "hook",    dur: 6500 },
  { id: "verse",   dur: 7000 },
  { id: "problem", dur: 5000 },
  { id: "prayer",  dur: 6000 },
  { id: "qibla",   dur: 6000 },
  { id: "athkar",  dur: 6000 },
  { id: "notif",   dur: 5500 },
  { id: "stats",   dur: 6500 },
  { id: "cta",     dur: 7000 },
];
