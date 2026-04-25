"use strict";

const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { GoogleGenerativeAI } = require("@google/generative-ai");

initializeApp();

const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");

const db = getFirestore();

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function stripJsonFences(text) {
  return text
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/\s*```$/i, "")
    .trim();
}

function buildPrompt(session, sessionId) {
  const level = session.fitnessLevel ?? "beginner";
  const exercise = session.exerciseType ?? "pushup";
  const totalReps = session.totalReps ?? 0;
  const goodReps = session.goodReps ?? 0;
  const formScore = session.formScore ?? 0;
  const commonErrors = (session.commonErrors ?? []).join(", ") || "none";

  const reps = (session.reps ?? []).slice(0, 30);
  const repSummary =
    reps.length > 0
      ? reps
          .map(
            (r, i) =>
              `Rep ${i + 1}: score=${r.formScore?.toFixed(1) ?? "?"}, errors=[${
                (r.errors ?? []).join(", ") || "none"
              }]`
          )
          .join("\n")
      : "No per-rep data available.";

  const levelGuidance =
    {
      beginner: "Use encouraging, simple language. Focus on 1-2 fundamental improvements.",
      intermediate: "Be direct and specific. Suggest technique refinements.",
      advanced: "Be concise and technical. Focus on marginal gains.",
    }[level] ?? "Use encouraging language.";

  return `You are a professional fitness coach analyzing a workout session.

Athlete level: ${level}
Exercise: ${exercise}
Session ID: ${sessionId}
Total reps: ${totalReps}
Good reps: ${goodReps}
Overall form score: ${formScore}/100
Common errors: ${commonErrors}

Per-rep breakdown:
${repSummary}

Coaching style: ${levelGuidance}

Respond with ONLY a JSON object (no markdown fences) with this exact shape:
{
  "summary": "2-3 sentence overall assessment",
  "strengths": ["strength 1", "strength 2"],
  "improvements": ["improvement 1", "improvement 2"],
  "nextSessionGoal": "one concrete goal for next session"
}`;
}

async function generateReportForSession(sessionId) {
  const sessionRef = db.collection("sessions").doc(sessionId);
  const reportRef = db.collection("reports").doc(sessionId);

  const sessionSnap = await sessionRef.get();
  if (!sessionSnap.exists) {
    console.warn(`Session ${sessionId} not found — skipping`);
    return;
  }

  const session = sessionSnap.data();

  // Idempotency guard
  if (session.reportStatus === "ready" || session.reportStatus === "generating") {
    console.log(`Session ${sessionId} already has reportStatus=${session.reportStatus} — skipping`);
    return;
  }

  await sessionRef.update({ reportStatus: "generating" });

  try {
    const apiKey = GEMINI_API_KEY.value();
    if (!apiKey) throw new Error("GEMINI_API_KEY secret is not set");

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

    const prompt = buildPrompt(session, sessionId);
    const result = await model.generateContent(prompt);
    const rawText = result.response.text();
    const cleanText = stripJsonFences(rawText);

    let parsed;
    try {
      parsed = JSON.parse(cleanText);
    } catch (parseErr) {
      // Log truncated excerpt only — don't write full LLM output to logs
      const excerpt = cleanText.slice(0, 200);
      throw new Error(`Failed to parse Gemini JSON: ${parseErr.message} | excerpt: ${excerpt}`);
    }

    const summary = typeof parsed.summary === "string" ? parsed.summary : "";
    const strengths = Array.isArray(parsed.strengths) ? parsed.strengths : [];
    const improvements = Array.isArray(parsed.improvements) ? parsed.improvements : [];
    const nextSessionGoal =
      typeof parsed.nextSessionGoal === "string" ? parsed.nextSessionGoal : "";

    await reportRef.set({
      sessionId,
      userId: session.userId,
      exerciseType: session.exerciseType,
      generatedAt: FieldValue.serverTimestamp(),
      overallScore: session.formScore ?? 0,
      summary,
      strengths,
      improvements,
      nextSessionGoal,
    });

    await sessionRef.update({ reportStatus: "ready" });
    console.log(`Report generated for session ${sessionId}`);
  } catch (err) {
    console.error(`Report generation failed for session ${sessionId}:`, err.message);
    await sessionRef.update({ reportStatus: "failed" });
  }
}

// ---------------------------------------------------------------------------
// Trigger: generate report when a new session document is created
// ---------------------------------------------------------------------------

exports.generateReport = onDocumentCreated(
  {
    document: "sessions/{sessionId}",
    region: "us-central1",
    secrets: [GEMINI_API_KEY],
  },
  async (event) => {
    await generateReportForSession(event.params.sessionId);
  }
);

// ---------------------------------------------------------------------------
// Trigger: re-generate when reportStatus is reset to 'pending' (retry path)
// Flutter client writes { reportStatus: 'pending' } to trigger this.
// ---------------------------------------------------------------------------

exports.retryOnPending = onDocumentUpdated(
  {
    document: "sessions/{sessionId}",
    region: "us-central1",
    secrets: [GEMINI_API_KEY],
  },
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    // Only fire when status transitions → 'pending' from a non-pending state
    if (after.reportStatus !== "pending" || before.reportStatus === "pending") {
      return;
    }

    await generateReportForSession(event.params.sessionId);
  }
);

// ---------------------------------------------------------------------------
// Callable: retry report generation — authenticated, ownership-checked
// ---------------------------------------------------------------------------

exports.retryReport = onCall(
  {
    region: "us-central1",
    secrets: [GEMINI_API_KEY],
  },
  async (request) => {
    // Auth check
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign-in required");
    }

    const { sessionId } = request.data;
    if (!sessionId || typeof sessionId !== "string") {
      throw new HttpsError("invalid-argument", "sessionId is required");
    }

    const sessionRef = db.collection("sessions").doc(sessionId);
    const sessionSnap = await sessionRef.get();

    if (!sessionSnap.exists) {
      throw new HttpsError("not-found", `Session ${sessionId} does not exist`);
    }

    // Ownership check — prevent cross-user report generation
    if (sessionSnap.data().userId !== request.auth.uid) {
      throw new HttpsError("permission-denied", "Not your session");
    }

    const currentStatus = sessionSnap.data().reportStatus;
    if (currentStatus === "ready" || currentStatus === "generating") {
      return { status: currentStatus };
    }

    await generateReportForSession(sessionId);
    return { status: "triggered" };
  }
);
