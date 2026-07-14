import { fingerprintForEvent, fnv1a64Hex, normalizeMessage } from "../fingerprint";
import { CleanErrorEvent } from "../types";

const base: CleanErrorEvent = {
  eventId: "s-1",
  kind: "exception",
  severity: "error",
  name: "x",
  errorType: "StateError",
  message: "Bad state",
  category: "Prayer Engine",
  origin: { file: "unknown", member: "unknown" },
  route: "/",
  appVersion: "1.0.0",
  installId: "i",
  stackHead: "",
  breadcrumbTail: [],
};

describe("fnv1a64Hex — shared vectors (MUST match Dart error_fingerprinter)", () => {
  it("empty string → the offset basis", () => {
    expect(fnv1a64Hex("")).toBe("cbf29ce484222325");
  });
  it('"a"', () => {
    expect(fnv1a64Hex("a")).toBe("af63dc4c8601ec8c");
  });
  it('"foobar"', () => {
    expect(fnv1a64Hex("foobar")).toBe("85944171f73967e8");
  });
});

describe("normalizeMessage", () => {
  it("strips digits and collapses whitespace", () => {
    expect(normalizeMessage("waited 1500 ms   for  frame 42")).toBe(
      "waited # ms for frame #",
    );
  });
});

describe("fingerprintForEvent mirrors the Dart key composition", () => {
  it("exception with an app frame → type|category|file|member", () => {
    const fp = fingerprintForEvent({
      ...base,
      origin: {
        file: "features/audio/data/audio_service.dart",
        member: "AudioService.play",
      },
    });
    expect(fp).toBe(
      fnv1a64Hex(
        "StateError|Prayer Engine|features/audio/data/audio_service.dart|AudioService.play",
      ),
    );
  });

  it("exception without an app frame → type|category|normMessage|route", () => {
    const fp = fingerprintForEvent({
      ...base,
      errorType: "FlutterError",
      category: "UI Rendering",
      message: "A RenderFlex overflowed by 42 pixels on the right.",
      route: "/home",
    });
    expect(fp).toBe(
      fnv1a64Hex(
        "FlutterError|UI Rendering|A RenderFlex overflowed by # pixels on the right.|/home",
      ),
    );
  });

  it("silent_failure groups by flow + failed step", () => {
    const fp = fingerprintForEvent({
      ...base,
      kind: "silent_failure",
      flow: { flow: "adhan", failed_step: "alert_screen_shown" },
    });
    expect(fp).toBe(fnv1a64Hex("silent_failure|adhan|alert_screen_shown"));
  });

  it("native_crash groups by error type + top native frame", () => {
    const fp = fingerprintForEvent({
      ...base,
      kind: "native_crash",
      errorType: "java.lang.NullPointerException",
      origin: { file: "com.ghasaq.app.X", member: "y" },
    });
    expect(fp).toBe(
      fnv1a64Hex("native_crash|java.lang.NullPointerException|com.ghasaq.app.X.y"),
    );
  });
});
