import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { goal_id, file_path } = await req.json()

    // 1. Require Authorization header (passed from Flutter Supabase client)
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing authorization header' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 401,
      })
    }

    // 2. Initialize admin client (service role bypasses RLS)
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 3. Fetch Goal context using admin client
    const { data: goalData, error: goalError } = await supabaseAdmin
      .from('goals')
      .select('*')
      .eq('id', goal_id)
      .single()
    
    if (goalError) throw new Error(`Error fetching goal: ${goalError.message}`)

    // 4. Download PDF from Storage and extract text
    let syllabusText = "Contenido del programa de la materia."
    if (file_path) {
      try {
        const { data: fileData, error: fileError } = await supabaseAdmin.storage
          .from('syllabus')
          .download(file_path)
        if (!fileError && fileData) {
          // For MVP: convert PDF blob to text (Gemini can handle raw text)
          syllabusText = await fileData.text()
        }
      } catch (_) {
        // If PDF parsing fails, continue with goal title context
      }
    }

    // 5. Call Gemini API
    const geminiApiKey = 'AIzaSyArqJNTKGHJht_4T_3sqLpbry9s_9pMKLY'

    const prompt = `
      Actúa como un tutor académico de alto nivel "Agente Socrático" en Studia 3.0. 
      Analiza este documento de planificación universitaria oficial (UTN).
      
      OBJETIVO:
      1. Extraer las "Unidades de Contenido" (Programa Analítico) y los "Resultados de Aprendizaje".
      2. Mapear el "Cronograma de Clases" para entender la progresión temporal.
      3. Generar una trayectoria de estudio para la meta "${goalData.title}" (Examen: ${goalData.target_date}).

      REGLAS DE FRICCIÓN COGNITIVA (Studia 3.0):
      - Divide el contenido en 3 sesiones iniciales enfocadas en las Unidades más críticas.
      - Session 1 (Theory): Usa analogías didácticas complejas para explicar el "por qué" detrás del concepto. 
      - Session 2 (Evaluative): Flashcards con preguntas abiertas que exijan auto-explicación.
      - Session 3 (Stress Test): Simil examen con problemas de aplicación real.
      
      TEXTO EXTRAÍDO DEL DOCUMENTO: 
      "${syllabusText.substring(0, 10000)}" 
      
      RETORNO: Únicamente un JSON válido con este formato exacto:
      [
        {
          "title": "Unidad X: [Nombre]",
          "scheduled_date": "2026-04-01T10:00:00Z",
          "mechanic": "theory",
          "content_payload": {
             "analogy": "...",
             "questions": [{"q": "...", "a": "..."}]
          }
        }
      ]
    `;

    const geminiRes = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ role: "user", parts: [{ text: prompt }] }],
        generationConfig: { response_mime_type: "application/json" }
      })
    });

    if (!geminiRes.ok) throw new Error('Fallo al contactar Gemini API.')

    const geminiData = await geminiRes.json()
    const generatedContent = geminiData.candidates[0].content.parts[0].text
    const sessions = JSON.parse(generatedContent)

    // 6. Insert Sessions into Database
    const recordsToInsert = sessions.map((s: any) => ({
      ...s,
      user_id: goalData.user_id,
      goal_id: goalData.id,
      status: 'pending'
    }))

    const { error: insertError } = await supabaseAdmin
      .from('study_sessions')
      .insert(recordsToInsert)

    if (insertError) throw new Error(`Error insertando sesiones: ${insertError.message}`)

    return new Response(JSON.stringify({ success: true, count: sessions.length }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error)
    return new Response(JSON.stringify({ error: msg }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
