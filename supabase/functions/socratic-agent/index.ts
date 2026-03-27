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
      Actúa como un tutor "Agente Socrático". El alumno debe preparar la meta "${goalData.title}" para el ${goalData.target_date}.
      Aplica las siguientes reglas de Fricción Cognitiva:
      1. Genera exactamente 3 sesiones de estudio para esta semana.
      2. No des resúmenes directos. Exige comprobación mediante "flashcards" o "quizzes".
      3. Proporciona analogías didácticas complejas para la "theory".
      
      Temario Extraído: ${syllabusText}
      
      Devuelve ÚNICAMENTE un JSON VÁLIDO con el formato:
      [
        {
          "title": "...",
          "scheduled_date": "2026-03-30T10:00:00Z",
          "mechanic": "theory" | "quiz" | "flashcard",
          "content_payload": {
             "analogy": "...",
             "questions": []
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
