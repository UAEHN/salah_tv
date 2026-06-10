/// Tri-state mode shared by the adhan and iqama settings:
///   • [sound]  — default. Plays the chosen audio + shows the takeover screen.
///   • [silent] — shows the takeover screen for a short fixed duration with
///                no audio. Lets the user see the prayer cue without noise.
///   • [off]    — fully bypassed. No screen, no audio. The home countdown
///                rolls straight to the next prayer.
enum PrayerSoundMode { sound, silent, off }
