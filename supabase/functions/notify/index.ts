// Schickt eine Push-Nachricht an alle Geräte mit eingeschalteten Benachrichtigungen,
// außer an die Person, die die Änderung selbst gemacht hat.
import webpush from "npm:web-push@3.6.7";
import { createClient } from "npm:@supabase/supabase-js@2.45.4";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

webpush.setVapidDetails(
  Deno.env.get("VAPID_SUBJECT")!,
  Deno.env.get("VAPID_PUBLIC_KEY")!,
  Deno.env.get("VAPID_PRIVATE_KEY")!,
);
const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405, headers: cors });
  let input: { title?: string; body?: string; actor?: string };
  try { input = await req.json(); } catch { return new Response("Bad request", { status: 400, headers: cors }); }
  const title = String(input.title ?? "Weihnachten bei Andy, Mel & Connor").slice(0, 80);
  const body = String(input.body ?? "").slice(0, 240);
  const actor = String(input.actor ?? "");
  if (!body) return new Response("Bad request", { status: 400, headers: cors });

  const { data: subs, error } = await db.from("push_subs").select("endpoint, sub, gast");
  if (error) return new Response(error.message, { status: 500, headers: cors });

  const payload = JSON.stringify({ title, body, url: "./", tag: "weihnachten-" + Date.now() });
  let sent = 0;
  await Promise.all((subs ?? []).filter((s) => !actor || s.gast !== actor).map(async (s) => {
    try { await webpush.sendNotification(s.sub, payload, { TTL: 60 * 60 * 24 }); sent++; }
    catch (e) {
      const code = (e as { statusCode?: number }).statusCode;
      if (code === 404 || code === 410) await db.from("push_subs").delete().eq("endpoint", s.endpoint);
      else console.error("push failed", code, (e as Error).message);
    }
  }));
  return new Response(JSON.stringify({ sent }), { headers: { ...cors, "Content-Type": "application/json" } });
});
