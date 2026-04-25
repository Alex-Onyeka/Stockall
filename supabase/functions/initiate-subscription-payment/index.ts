import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const PAYSTACK_SECRET = Deno.env.get("PAYSTACK_SECRET_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

const supabase = createClient(
  SUPABASE_URL!,
  SUPABASE_SERVICE_ROLE_KEY!
);

// ✅ CORS headers (REQUIRED for Flutter Web)
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function toKobo(amountNaira: number) {
  return Math.round(amountNaira * 100);
}

function addMonths(duration: number) {
  const d = new Date();
  d.setMonth(d.getMonth() + duration);
  return d.toISOString();
}

serve(async (req) => {
  // ✅ Handle preflight request
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
    const body = await req.json();
    const {
      user_id,
      email,
      plan,
      amount,
      duration = 1,
      metadata = {},
      callback_url,
    } = body;

    if (!user_id || !email || !plan || !amount) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: corsHeaders }
      );
    }

    const reference = `stk_${crypto.randomUUID()}`;

    // Initialize Paystack transaction
    const paystackRes = await fetch(
      "https://api.paystack.co/transaction/initialize",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${PAYSTACK_SECRET}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email,
          amount: toKobo(amount),
          reference,
          callback_url,
          metadata: { user_id, plan, duration, ...metadata },
          channels: ["card", "bank_transfer", "ussd"],
        }),
      }
    );

    const paystackData = await paystackRes.json();

    if (!paystackRes.ok || !paystackData?.status) {
      return new Response(
        JSON.stringify({
          error: paystackData?.message || "Paystack init failed",
        }),
        { status: 400, headers: corsHeaders }
      );
    }

    const { authorization_url, access_code } = paystackData.data;


    return new Response(
      JSON.stringify({ authorization_url, access_code, reference }),
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
