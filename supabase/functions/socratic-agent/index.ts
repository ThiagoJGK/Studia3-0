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

    // 1. Initialize Supabase Client internally to bypass RLS securely
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 2. Fetch Goal context
    const { data: goalData, error: goalError } = await supabaseClient
      .from('goals')
      .select('*')
      .eq('id', goal_id)
      .single()
    
    if (goalError) throw new Error(`Error fetching goal: ${goalError.message}`)

    // 3. (Mock) Download PDF & Extract Text 
    // In production, download from Storage and parse with pdf.js or pass to Gemini File API
    // const { data: fileData, error: fileError } = await supabaseClient.storage.from('syllabus').download(file_path)

    const syllabusText = "Contenido extraido del Syllabus (Mock): Fundamentos de matrices, espacios vectoriales y autovalores."

    // 4. Call Gemini API to generate the Pedagogical Study Sessions
    // Utilizando la API Key provista directamente para despliegue fácil desde la Web UI
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
      - Session 1 (Theory): Usa analogías didácticas complejas para explicar el "por qué" detrás del concepto (ej. Theory of Systems). 
      - Session 2 (Evaluative): Flashcards con preguntas abiertas que exijan auto-explicación.
      - Session 3 (Stress Test): Simil examen con problemas de aplicación real.
      
      TEXTO EXTRAÍDO DEL DOCUMENTO: 
      "${syllabusText.substring(0, 10000)}" 
      
      RETORNO: Únicamente un JSON válido con este formato:
      [
        {
          "title": "Unidad X: [Nombre]",
          "scheduled_date": "ISOString",
          "mechanic": "theory" | "quiz" | "flashcard",
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

    // 5. Insert Sessions into Database
    const recordsToInsert = sessions.map((s: any) => ({
      ...s,
      user_id: goalData.user_id,
      goal_id: goalData.id,
      status: 'pending'
    }))

    const { error: insertError } = await supabaseClient
      .from('study_sessions')
      .insert(recordsToInsert)

    if (insertError) throw new Error(`Error insertando sesiones: ${insertError.message}`)

    return new Response(JSON.stringify({ success: true, count: sessions.length }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
