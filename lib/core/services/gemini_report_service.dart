import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/session_model.dart';
import '../models/user_model.dart';

/// Calls Gemini to generate a post-session report and writes it to Firestore.
///
/// API key is supplied at build time via:
///   flutter run --dart-define=GEMINI_API_KEY=<your_key>
///   flutter build apk --dart-define=GEMINI_API_KEY=<your_key>
class GeminiReportService {
  GeminiReportService();

  static const String _apiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Generate an AI report for [session] and write it to Firestore.
  /// Updates [session.reportStatus] to 'ready' or 'failed' when done.
  Future<void> generateReport(SessionModel session, FitnessLevel level) async {
    final sessionRef = FirebaseFirestore.instance
        .collection('sessions')
        .doc(session.sessionId);

    if (_apiKey.isEmpty) {
      await sessionRef.update({'reportStatus': 'failed'});
      return;
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final prompt = _buildPrompt(session, level);
      final response = await model.generateContent([Content.text(prompt)]);
      final raw = response.text ?? '';
      final clean = _stripFences(raw);
      final parsed = jsonDecode(clean) as Map<String, dynamic>;

      final summary = parsed['summary'] as String? ?? '';
      final strengths = (parsed['strengths'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final improvements = (parsed['improvements'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final nextSessionGoal = parsed['nextSessionGoal'] as String? ?? '';

      await FirebaseFirestore.instance
          .collection('reports')
          .doc(session.sessionId)
          .set({
        'sessionId': session.sessionId,
        'userId': session.userId,
        'exerciseType': session.exerciseType.name,
        'generatedAt': FieldValue.serverTimestamp(),
        'overallScore': session.formScore,
        'summary': summary,
        'strengths': strengths,
        'improvements': improvements,
        'nextSessionGoal': nextSessionGoal,
      });

      await sessionRef.update({'reportStatus': 'ready'});
    } catch (_) {
      await sessionRef.update({'reportStatus': 'failed'});
    }
  }

  String _buildPrompt(SessionModel session, FitnessLevel level) {
    final commonErrors = session.commonErrors.join(', ').isEmpty
        ? 'none'
        : session.commonErrors.join(', ');

    final repSummary = session.reps.isEmpty
        ? 'No per-rep data available.'
        : session.reps
            .take(30)
            .map((r) =>
                'Rep ${r.repNumber}: score=${r.formScore.toStringAsFixed(1)}, errors=[${r.errors.join(', ').isEmpty ? 'none' : r.errors.join(', ')}]')
            .join('\n');

    final levelGuidance = switch (level) {
      FitnessLevel.beginner =>
        'Use encouraging, simple language. Focus on 1-2 fundamental improvements.',
      FitnessLevel.intermediate =>
        'Be direct and specific. Suggest technique refinements.',
      FitnessLevel.advanced =>
        'Be concise and technical. Focus on marginal gains.',
    };

    return '''You are a professional fitness coach analyzing a workout session.

Athlete level: ${level.name}
Exercise: ${session.exerciseType.name}
Total reps: ${session.totalReps}
Good reps: ${session.goodReps}
Overall form score: ${session.formScore.toStringAsFixed(1)}/100
Common errors: $commonErrors

Per-rep breakdown:
$repSummary

Coaching style: $levelGuidance

Respond with ONLY a JSON object (no markdown) with this exact shape:
{
  "summary": "2-3 sentence overall assessment",
  "strengths": ["strength 1", "strength 2"],
  "improvements": ["improvement 1", "improvement 2"],
  "nextSessionGoal": "one concrete goal for next session"
}''';
  }

  String _stripFences(String text) => text
      .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
      .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
      .replaceAll(RegExp(r'\s*```$', multiLine: true), '')
      .trim();
}
