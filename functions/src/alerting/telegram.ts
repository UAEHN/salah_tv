import { telegramBotToken, telegramChatId } from "../config";

// Sends an HTML message to the configured Telegram chat via the Bot API. Uses
// the Node 20 global fetch. Fail-soft: a missing secret or a network error
// returns false so the pipeline never throws on the alert path.
export async function sendTelegram(text: string): Promise<boolean> {
  try {
    const token = telegramBotToken.value().trim();
    const chatId = telegramChatId.value().trim();
    if (!token || !chatId) return false;
    const res = await fetch(
      `https://api.telegram.org/bot${token}/sendMessage`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          chat_id: chatId,
          text,
          parse_mode: "HTML",
          disable_web_page_preview: true,
        }),
      },
    );
    return res.ok;
  } catch {
    return false;
  }
}
