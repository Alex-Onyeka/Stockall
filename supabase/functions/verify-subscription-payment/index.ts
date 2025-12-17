import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const PAYSTACK_SECRET = Deno.env.get("PAYSTACK_SECRET_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

const supabase = createClient(
  SUPABASE_URL!,
  SUPABASE_SERVICE_ROLE_KEY!
);

// ✅ REQUIRED for Flutter Web
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function addMonths(duration: number) {
  const d = new Date();
  d.setMonth(d.getMonth() + duration);
  return d.toISOString();
}

serve(async (req) => {
  // ✅ Handle browser preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405, headers: corsHeaders }
    );
  }

  try {
    const { reference } = await req.json();

    if (!reference) {
      return new Response(
        JSON.stringify({ error: "Missing reference" }),
        { status: 400, headers: corsHeaders }
      );
    }

    // 🔍 Verify Paystack transaction
    const verifyRes = await fetch(
      `https://api.paystack.co/transaction/verify/${reference}`,
      {
        headers: {
          Authorization: `Bearer ${PAYSTACK_SECRET}`,
        },
      }
    );

    const verifyData = await verifyRes.json();

    if (!verifyRes.ok || !verifyData?.status) {
      return new Response(
        JSON.stringify({
          error: verifyData?.message || "Verification failed",
        }),
        { status: 400, headers: corsHeaders }
      );
    }

    const tx = verifyData.data;

    if (tx.status !== "success") {
      return new Response(
        JSON.stringify({
          error: "Payment not successful",
          status: tx.status,
        }),
        { status: 400, headers: corsHeaders }
      );
    }

    // 📦 Metadata
    const { user_id, plan, duration = 1 } = tx.metadata || {};
    const amount = Math.round(tx.amount / 100);
    const next_payment = addMonths(Number(duration));

    // 🗓 Monthly deduplication
    const now = new Date();
    const startOfMonth = new Date(
      now.getFullYear(),
      now.getMonth(),
      1
    ).toISOString();

    const endOfMonth = new Date(
      now.getFullYear(),
      now.getMonth() + 1,
      1
    ).toISOString();

    const { data: existingPayments } = await supabase
      .from("subscription_payments")
      .select("payments_id")
      .eq("user_id", user_id)
      .gte("created_at", startOfMonth)
      .lt("created_at", endOfMonth);

    if (existingPayments?.length) {
      await supabase
        .from("subscription_payments")
        .update({
          plan,
          amount,
          reference: tx.reference,
          status: tx.status,
          payment_channel: tx.channel,
          metadata: tx.metadata,
          duration,
          next_payment,
        })
        .eq("payments_id", existingPayments[0].payments_id);
    } else {
      await supabase.from("subscription_payments").insert({
        user_id,
        plan,
        amount,
        reference: tx.reference,
        status: tx.status,
        payment_channel: tx.channel,
        metadata: tx.metadata,
        duration,
        next_payment,
      });
    }

    // 🔄 Update subscription
    await supabase
      .from("subscription")
      .update({
        plan,
        next_payment,
        last_payment: tx.paid_at,
        amount,
        duration,
      })
      .eq("user_id", user_id);

    return new Response(
      JSON.stringify({ success: true, reference: tx.reference }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (err) {
    console.error(err);
    return new Response(
      JSON.stringify({ error: "Server error" }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  }
});
