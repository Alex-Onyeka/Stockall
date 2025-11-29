import { serve } from "https://deno.land/std/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js"

serve(async (req) => {
  try {
     const supabase = createClient(
        Deno.env.get("URL")!,              
        Deno.env.get("SERVICE_ROLE_KEY")!  
      )

    const { userId } = await req.json()

    const { error } = await supabase.auth.admin.deleteUser(userId)

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      })
    }

    return new Response(JSON.stringify({ message: "User deleted successfully" }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    })
  }
})
