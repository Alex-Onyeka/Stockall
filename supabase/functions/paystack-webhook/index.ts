import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const PAYSTACK_SECRET = Deno.env.get("PAYSTACK_SECRET_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

const supabase = createClient(
  SUPABASE_URL!,
  SUPABASE_SERVICE_ROLE_KEY!
);

function addMonths(duration: number, baseDate?: Date): string {
  const d = baseDate ? new Date(baseDate) : new Date();
  d.setMonth(d.getMonth() + duration);
  return d.toISOString();
}

async function verifyPaystackSignature(
  rawBody: string,
  signature: string | null,
  secret: string
): Promise<boolean> {
  if (!signature || !secret) return false;

  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-512" },
    false,
    ["sign"]
  );

  const signed = await crypto.subtle.sign(
    "HMAC",
    key,
    encoder.encode(rawBody)
  );

  const hashArray = Array.from(new Uint8Array(signed));
  const hexSignature = hashArray
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");

  return hexSignature.toLowerCase() === signature.toLowerCase();
}

serve(async (req) => {
  // Only accept POST requests for webhooks
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const rawBody = await req.text();
    const signature = req.headers.get("x-paystack-signature");

    if (!PAYSTACK_SECRET) {
      console.error("PAYSTACK_SECRET_KEY is not configured in Supabase Secrets");
      return new Response(
        JSON.stringify({ error: "Server misconfiguration" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    // 1. Verify Paystack webhook signature
    const isValid = await verifyPaystackSignature(
      rawBody,
      signature,
      PAYSTACK_SECRET
    );

    if (!isValid) {
      console.error("Invalid Paystack webhook signature received");
      return new Response(
        JSON.stringify({ error: "Invalid signature" }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      );
    }

    const eventData = JSON.parse(rawBody);

    // 2. Handle successful charge
    if (eventData.event === "charge.success") {
      const tx = eventData.data;
      const reference = tx.reference;
      const metadata = tx.metadata || {};
      const { user_id, plan, duration = 1, old_plan = 0 } = metadata;

      if (!user_id || plan === undefined || plan === null) {
        console.warn("charge.success event received without user_id or plan metadata", metadata);
        return new Response(
          JSON.stringify({ message: "Ignored: missing user_id or plan in metadata" }),
          { status: 200, headers: { "Content-Type": "application/json" } }
        );
      }

      const amount = Math.round(Number(tx.amount || 0) / 100);
      const paidAt = tx.paid_at || new Date().toISOString();
      const numDuration = Number(duration) > 0 ? Number(duration) : 1;
      const nextPayment = addMonths(numDuration, new Date(paidAt));

      // 3. Idempotency & Record in subscription_payments
      const { data: existingPayment } = await supabase
        .from("subscription_payments")
        .select("payments_id, status")
        .eq("reference", reference)
        .maybeSingle();

      if (!existingPayment) {
        const { error: insertError } = await supabase
          .from("subscription_payments")
          .insert({
            user_id,
            plan: Number(plan),
            old_plan: Number(old_plan),
            amount,
            duration: numDuration,
            next_payment: nextPayment,
            last_payment: paidAt,
            reference,
            status: tx.status,
            payment_channel: tx.channel,
            metadata: tx.metadata,
          });

        if (insertError) {
          console.error("Failed to insert into subscription_payments:", insertError);
        }
      } else if (existingPayment.status !== "success") {
        const { error: updatePayError } = await supabase
          .from("subscription_payments")
          .update({
            plan: Number(plan),
            old_plan: Number(old_plan),
            amount,
            duration: numDuration,
            next_payment: nextPayment,
            last_payment: paidAt,
            status: tx.status,
            payment_channel: tx.channel,
            metadata: tx.metadata,
          })
          .eq("payments_id", existingPayment.payments_id);

        if (updatePayError) {
          console.error("Failed to update subscription_payments:", updatePayError);
        }
      } else {
        console.log(`Payment reference ${reference} already marked successful in subscription_payments`);
      }

      // 4. Update the user's subscription in the 'subscription' table
      const { data: currentSub } = await supabase
        .from("subscription")
        .select("plan")
        .eq("user_id", user_id)
        .maybeSingle();

      const previousPlan = currentSub?.plan ?? old_plan ?? 0;

      if (currentSub) {
        const { error: updateError } = await supabase
          .from("subscription")
          .update({
            plan: Number(plan),
            old_plan: Number(previousPlan),
            next_payment: nextPayment,
            last_payment: paidAt,
            amount: amount,
          })
          .eq("user_id", user_id);

        if (updateError) {
          console.error("Failed to update subscription:", updateError);
        }
      } else {
        // If user record doesn't exist yet in subscription table, insert it
        const { error: newSubError } = await supabase
          .from("subscription")
          .insert({
            subscription_id: crypto.randomUUID(),
            user_id: user_id,
            plan: Number(plan),
            old_plan: Number(previousPlan),
            next_payment: nextPayment,
            last_payment: paidAt,
            amount: amount,
            email: tx.customer?.email,
          });

        if (newSubError) {
          console.error("Failed to create subscription:", newSubError);
        }
      }

      console.log(`Successfully processed webhook for user ${user_id}, reference ${reference}`);
    }

    // Always return 200 OK to Paystack
    return new Response(JSON.stringify({ status: "success" }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err: any) {
    console.error("Webhook processing error:", err);
    return new Response(
      JSON.stringify({ error: err.message || "Server error" }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});

