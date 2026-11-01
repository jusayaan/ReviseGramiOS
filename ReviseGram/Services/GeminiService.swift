import Foundation

enum GeminiService {
    private static let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

    private struct Part: Codable {
        let text: String?
    }

    private struct Content: Codable {
        let parts: [Part]
    }

    private struct RequestBody: Codable {
        let contents: [Content]
        let systemInstruction: Content?
    }

    private struct Candidate: Codable {
        let content: Content?
    }

    private struct ResponseBody: Codable {
        let candidates: [Candidate]?
    }

    static func askSubjectTutor(
        subjectName: String,
        subjectCode: String,
        userQuestion: String,
        chatHistory: [(String, Bool)],
        apiKey: String?,
        userContext: String
    ) async throws -> String {
        try Task.checkCancellation()
        let key = (apiKey ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !key.isEmpty && key != "MY_GEMINI_API_KEY" {
            do {
                let sysPrompt = "You are an expert Cambridge IGCSE \(subjectName) (\(subjectCode)) tutor on ReviseGram. " +
                    "Provide concise, encouraging, bullet-pointed explanations tailored to Cambridge IGCSE mark schemes. " +
                    "Keep responses under 220 words. Student Context: \(userContext)"
                var contents: [Content] = chatHistory.suffix(6).map { (msg, isUser) in
                    Content(parts: [Part(text: isUser ? "Student: \(msg)" : "Tutor: \(msg)")])
                }
                contents.append(Content(parts: [Part(text: "Student: \(userQuestion)")]))

                let rawText = try await performGenerateContent(
                    apiKey: key,
                    request: RequestBody(contents: contents, systemInstruction: Content(parts: [Part(text: sysPrompt)]))
                )
                try Task.checkCancellation()
                if !rawText.isEmpty {
                    return rawText
                }
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                // Fall back to offline syllabus response
            }
        }
        return offlineTutorResponse(subjectName: subjectName, subjectCode: subjectCode, question: userQuestion)
    }

    static func generateSyllabusContent(
        subjectName: String,
        subjectCode: String,
        topic: String,
        contentType: String,
        difficulty: String,
        apiKey: String?
    ) async throws -> GeneratedAiContent {
        try Task.checkCancellation()
        let key = (apiKey ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !key.isEmpty && key != "MY_GEMINI_API_KEY" {
            do {
                let prompt = """
                Generate a Cambridge IGCSE \(subjectName) (\(subjectCode)) \(contentType) on topic '\(topic)' at \(difficulty) level.
                Return ONLY a valid JSON object matching this structure:
                {
                  "title": "Short title",
                  "content": "2-3 paragraph syllabus explanation",
                  "formulaOrKeyPoint": "Key equation, definition or mark scheme rule",
                  "quizQuestion": "Multiple choice question",
                  "quizOptions": ["Opt A", "Opt B", "Opt C", "Opt D"],
                  "quizCorrectIndex": 0,
                  "quizExplanation": "Mark scheme explanation",
                  "flashcardFront": "Flashcard front prompt",
                  "flashcardBack": "Flashcard back answer"
                }
                """
                let raw = try await performGenerateContent(
                    apiKey: key,
                    request: RequestBody(
                        contents: [Content(parts: [Part(text: prompt)])],
                        systemInstruction: Content(parts: [Part(text: "Output ONLY valid JSON.")])
                    )
                )
                try Task.checkCancellation()
                if let parsed = parseGeneratedContent(raw: raw, topic: topic) {
                    return parsed
                }
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                // Fall back to offline syllabus generator
            }
        }
        return offlineSyllabusContent(subjectName: subjectName, subjectCode: subjectCode, topic: topic, difficulty: difficulty)
    }

    static func markStudentAnswer(
        subjectName: String,
        subjectCode: String,
        topic: String,
        questionText: String,
        studentAnswer: String,
        maxScore: Int = 4,
        apiKey: String?
    ) async throws -> AiMarkingResult {
        try Task.checkCancellation()
        let safeMax = max(1, maxScore)
        let key = (apiKey ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty && key != "MY_GEMINI_API_KEY" else {
            return AiMarkingResult(
                score: 0,
                maxScore: safeMax,
                correctPoints: [],
                missingPoints: [],
                incorrectPoints: [],
                improvementTips: "Gemini API key is not configured.",
                modelAnswer: "Open Profile → Settings to add your Gemini API key for live AI Examiner marking.",
                isSuccess: false
            )
        }

        do {
            let prompt = """
            Act as a Cambridge IGCSE Examiner marking an answer for \(subjectName) (\(subjectCode)) on '\(topic)'.
            Question (\(safeMax) marks): \(questionText)
            Student Answer: \(studentAnswer)
            Return ONLY raw JSON:
            {
              "score": 3,
              "maxScore": \(safeMax),
              "correctPoints": ["Point 1"],
              "missingPoints": ["Missing concept"],
              "incorrectPoints": [],
              "improvementTips": "Examiner advice",
              "modelAnswer": "Full marks exemplar"
            }
            """
            let raw = try await performGenerateContent(
                apiKey: key,
                request: RequestBody(
                    contents: [Content(parts: [Part(text: prompt)])],
                    systemInstruction: Content(parts: [Part(text: "Output ONLY raw JSON.")])
                )
            )
            try Task.checkCancellation()
            if let parsed = parseMarkingResult(raw: raw, defaultMax: safeMax) {
                return parsed
            }
            throw URLError(.cannotParseResponse)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return AiMarkingResult(
                score: 0,
                maxScore: safeMax,
                correctPoints: [],
                missingPoints: [],
                incorrectPoints: [],
                improvementTips: "Unable to complete AI marking (\(error.localizedDescription)).",
                modelAnswer: "Your answer was not scored because the Gemini service was unreachable or returned an invalid response.",
                isSuccess: false
            )
        }
    }

    private static func performGenerateContent(apiKey: String, request: RequestBody) async throws -> String {
        guard var components = URLComponents(string: endpoint) else {
            throw URLError(.badURL)
        }
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = 30
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        return decoded.candidates?.first?.content?.parts.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private static func stripJsonFences(_ raw: String) -> String {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.lowercased().hasPrefix("```json") {
            text = String(text.dropFirst(7)).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if text.hasPrefix("```") {
            text = String(text.dropFirst(3)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if text.hasSuffix("```") {
            text = String(text.dropLast(3)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return text
    }

    private static func parseGeneratedContent(raw: String, topic: String) -> GeneratedAiContent? {
        let cleaned = stripJsonFences(raw)
        guard let data = cleaned.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let title = (json["title"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty,
              let content = (json["content"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines), !content.isEmpty else {
            return nil
        }
        let keyPoint = (json["formulaOrKeyPoint"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Key syllabus rule for \(topic)"
        let quizQ = (json["quizQuestion"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let quizOpts = (json["quizOptions"] as? [String])?.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let correctIdx = (json["quizCorrectIndex"] as? Int) ?? -1
        let hasValidQuiz = (quizQ?.isEmpty == false) && (quizOpts?.count ?? 0) >= 2 && (quizOpts?.indices.contains(correctIdx) == true)

        return GeneratedAiContent(
            title: title,
            content: content,
            formulaOrKeyPoint: keyPoint,
            quizQuestion: hasValidQuiz ? quizQ : nil,
            quizOptions: hasValidQuiz ? quizOpts : nil,
            quizCorrectIndex: hasValidQuiz ? correctIdx : -1,
            quizExplanation: hasValidQuiz ? (json["quizExplanation"] as? String) : nil,
            flashcardFront: (json["flashcardFront"] as? String) ?? "State the key principle of \(topic).",
            flashcardBack: (json["flashcardBack"] as? String) ?? keyPoint
        )
    }

    private static func parseMarkingResult(raw: String, defaultMax: Int) -> AiMarkingResult? {
        let cleaned = stripJsonFences(raw)
        guard let data = cleaned.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rawScore = json["score"] as? Int else {
            return nil
        }
        let maxScore = max(1, (json["maxScore"] as? Int) ?? defaultMax)
        let clampedScore = min(max(0, rawScore), maxScore)
        let tips = (json["improvementTips"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let model = (json["modelAnswer"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !tips.isEmpty || !model.isEmpty else { return nil }

        return AiMarkingResult(
            score: clampedScore,
            maxScore: maxScore,
            correctPoints: (json["correctPoints"] as? [String]) ?? [],
            missingPoints: (json["missingPoints"] as? [String]) ?? [],
            incorrectPoints: (json["incorrectPoints"] as? [String]) ?? [],
            improvementTips: tips.isEmpty ? "Review the exemplar response below." : tips,
            modelAnswer: model.isEmpty ? "Compare your key terms against the syllabus mark scheme." : model,
            isSuccess: true
        )
    }

    private static func offlineTutorResponse(subjectName: String, subjectCode: String, question: String) -> String {
        let lower = question.lowercased()
        if lower.contains("formula") || lower.contains("equation") {
            return "Key IGCSE \(subjectName) (\(subjectCode)) Formula Advice:\n• State the defining equation in symbols first before substituting numbers.\n• Check SI unit conversions (e.g. g to kg, cm to m, mA to A).\n• Which specific equation or variable would you like to rearrange?"
        } else if lower.contains("exam") || lower.contains("mark") || lower.contains("paper") {
            return "IGCSE \(subjectName) (\(subjectCode)) Examiner Tip:\n1. Match your response depth to the command word: 'State' = brief fact; 'Describe' = what happens; 'Explain' = why/how using 'because' or 'therefore'.\n2. Use the mark allocation [n] as a guide to the number of distinct mark-scheme points required."
        } else {
            return "\(subjectName) (\(subjectCode)) Study Guidance on '\(question)':\n• Anchor your answer in the exact Cambridge syllabus definition.\n• Link cause and effect step by step using precise technical terminology.\n• Try testing your recall with a quick Flashcard or Exam Mode session!"
        }
    }

    private static func offlineSyllabusContent(subjectName: String, subjectCode: String, topic: String, difficulty: String) -> GeneratedAiContent {
        GeneratedAiContent(
            title: "\(topic) · \(difficulty) Revision",
            content: "In Cambridge IGCSE \(subjectName) (\(subjectCode)), \(topic) is a core syllabus concept. Focus on the precise definition, governing relationships, and standard mark-scheme phrasing expected in structured Paper questions.",
            formulaOrKeyPoint: "Always state the fundamental principle or formula clearly and include appropriate units.",
            quizQuestion: "Which statement best reflects the Cambridge IGCSE \(subjectName) (\(subjectCode)) syllabus treatment of \(topic)?",
            quizOptions: [
                "It follows defined conservation, proportionality, or syllabus classification rules",
                "It varies randomly without measurable constraints",
                "It is excluded from both Core and Extended papers",
                "It requires no units or definitions in written answers"
            ],
            quizCorrectIndex: 0,
            quizExplanation: "Cambridge mark schemes reward accurate definitions, consistent units, and clear step-by-step reasoning.",
            flashcardFront: "What is the key syllabus rule for \(topic) in IGCSE \(subjectName) (\(subjectCode))?",
            flashcardBack: "State the formal definition, write the governing equation or criterion, and give one applied example."
        )
    }
}
