import { serve } from "https://deno.land/std/http/server.ts";

serve(async (req) => {
  try {
    // 1️⃣ Parse JSON body
    const { record } = await req.json();
    if (!record) return new Response("No record payload", { status: 400 });

    // 2️⃣ Load secrets from Supabase
    const oneSignalAppId = Deno.env.get("ONESIGNAL_APP_ID");
    const oneSignalApiKey = Deno.env.get("ONESIGNAL_API_KEY");

    if (!oneSignalAppId || !oneSignalApiKey) {
      throw new Error("Missing OneSignal environment variables");
    }

    // 3️⃣ Extract supplier ID from record
    const ownerId = record.owner_id;
    if (!ownerId) return new Response("Missing owner_id in record", { status: 400 });

    // 4️⃣ Build order items summary (optional)
    let itemsSummary = "";
    if (record.items && Array.isArray(record.items)) {
      itemsSummary = record.items
        .filter((i: any) => i.owner_id === ownerId)
        .map((i: any) => `${i.quantity} x ${i.product_name}`)
        .join(", ");
    }

    const content = `New order from ${record.user_name ?? "Unknown"}${
      itemsSummary ? ": " + itemsSummary : ""
    }`;

    // 5️⃣ Prepare OneSignal payload (official format)
    const notification = {
      app_id: oneSignalAppId,
      headings: { en: "New Order Received" },
      contents: { en: content },
      include_external_user_ids: [ownerId], // send to supplier
    };

    // 6️⃣ Send notification to OneSignal
    const response = await fetch("https://onesignal.com/api/v1/notifications", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Key ${oneSignalApiKey}`, // ✅ Official format
      },
      body: JSON.stringify(notification),
    });

    const data = await response.json();
    console.log("OneSignal response:", data);

    return new Response(JSON.stringify(data), { status: 200 });
  } catch (error) {
    console.error("Error sending notification:", error);
    const message =
      error instanceof Error ? error.message : typeof error === "string" ? error : String(error);
    return new Response(message, { status: 500 });
  }
});
