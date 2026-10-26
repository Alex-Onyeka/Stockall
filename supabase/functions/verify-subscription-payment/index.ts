import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const PAYSTACK_SECRET = Deno.env.get("PAYSTACK_SECRET_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

const supabase = createClient(
  SUPABASE_URL!,
  SUPABASE_SERVICE_ROLE_KEY!
);

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function addMonths(duration: number, baseDate?: Date): string {
  const d = baseDate ? new Date(baseDate) : new Date();
  d.setMonth(d.getMonth() + duration);
  return d.toISOString();
}

serve(async (req) => {
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

    // 1. Check if already processed by the webhook
    const { data: existingPayment } = await supabase
      .from("subscription_payments")
      .select("payments_id, user_id, plan")
      .eq("reference", reference)
      .maybeSingle();

    if (existingPayment) {
      return new Response(
        JSON.stringify({
          success: true,
          reference,
          message: "Payment already verified and processed by webhook",
        }),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    // 2. Verify with Paystack API if not yet processed
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

    // Extract metadata
    const metadata = tx.metadata || {};
    const { user_id, plan, duration = 1, old_plan = 0 } = metadata;
    const amount = Math.round(Number(tx.amount || 0) / 100);
    const paidAt = tx.paid_at || new Date().toISOString();
    const numDuration = Number(duration) > 0 ? Number(duration) : 1;
    const nextPayment = addMonths(numDuration, new Date(paidAt));

    // 3. Insert payment record into subscription_payments
    await supabase.from("subscription_payments").insert({
      user_id,
      plan: Number(plan),
      amount,
      duration: numDuration,
      next_payment: nextPayment,
      reference: tx.reference,
      status: tx.status,
      payment_channel: tx.channel,
      metadata: tx.metadata,
    });

    // 4. Update subscription table
    const { data: currentSub } = await supabase
      .from("subscription")
      .select("plan")
      .eq("user_id", user_id)
      .maybeSingle();

    const previousPlan = currentSub?.plan ?? old_plan ?? 0;

    if (currentSub) {
      await supabase
        .from("subscription")
        .update({
          plan: Number(plan),
          old_plan: Number(previousPlan),
          next_payment: nextPayment,
          last_payment: paidAt,
          amount,
        })
        .eq("user_id", user_id);
    } else {
      await supabase.from("subscription").insert({
        subscription_id: crypto.randomUUID(),
        user_id,
        plan: Number(plan),
        old_plan: Number(previousPlan),
        next_payment: nextPayment,
        last_payment: paidAt,
        amount,
        email: tx.customer?.email,
      });
    }

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
  } catch (err: any) {
    console.error(err);
    return new Response(
      JSON.stringify({ error: err.message || "Server error" }),
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

