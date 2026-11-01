import Foundation

enum InitialData {
    static func initialUserStats() -> UserStats {
        UserStats(
            streakDays: 0,
            lastStudyTimestamp: 0,
            revisePoints: 0,
            totalQuizzesAnswered: 0,
            correctQuizzesCount: 0,
            storiesCompletedCount: 0,
            userLevel: 1,
            userTitle: "IGCSE Candidate",
            selectedAvatar: "IG",
            streakShieldsActive: 1
        )
    }

    static func initialPosts() -> [PostItem] {
        [
            PostItem(
                id: 1,
                subjectId: "physics",
                subjectName: "Physics",
                subjectCode: "0625",
                topicId: "physics_waves",
                authorHandle: "ReviseGram Library",
                authorAvatar: "0625",
                topicTitle: "Refraction & Snell's Law",
                chapterName: "Unit 3 · Properties of Waves",
                mainContent: "When light passes from an optically rarer medium into a denser medium (such as air into glass), it refracts towards the normal. Wave speed and wavelength both decrease proportionally, whereas frequency remains invariant.",
                formulaOrKeyPoint: "n = sin(i) / sin(r)   |   n = c / v",
                quizQuestion: "Monochromatic light enters glass (n = 1.5) from air at an angle of incidence i = 30°. What happens to its speed and frequency inside the glass?",
                quizOptions: [
                    "Speed decreases, frequency remains constant",
                    "Speed increases, frequency increases",
                    "Speed remains constant, frequency decreases",
                    "Both speed and frequency decrease"
                ],
                quizCorrectIndex: 0,
                quizExplanation: "Wave speed decreases in an optically denser medium (v = c / n), while frequency is determined solely by the source and never changes across a boundary.",
                commentsCount: 2,
                isSaved: true,
                postType: "FORMULA",
                difficulty: "Extended"
            ),
            PostItem(
                id: 2,
                subjectId: "mathematics",
                subjectName: "Mathematics",
                subjectCode: "0580",
                topicId: "math_algebra",
                authorHandle: "ReviseGram Library",
                authorAvatar: "0580",
                topicTitle: "The Quadratic Formula & Discriminant Analysis",
                chapterName: "Unit 2 · Algebra and Graphs",
                mainContent: "For any quadratic equation ax² + bx + c = 0 (where a ≠ 0), the discriminant Δ = b² – 4ac determines the nature of the real roots:\n• Δ > 0 : Two distinct real roots\n• Δ = 0 : One repeated real root (tangent to x-axis)\n• Δ < 0 : No real roots",
                formulaOrKeyPoint: "x = [ −b ± √(b² − 4ac) ] / 2a",
                quizQuestion: "Calculate the discriminant of 2x² − 4x + 2 = 0 and state the nature of its roots.",
                quizOptions: [
                    "0 (one repeated real root)",
                    "16 (two distinct real roots)",
                    "−8 (no real roots)",
                    "4 (two distinct real roots)"
                ],
                quizCorrectIndex: 0,
                quizExplanation: "Δ = (−4)² − 4(2)(2) = 16 − 16 = 0, indicating one repeated real root at x = 1.",
                commentsCount: 1,
                isSaved: true,
                postType: "FORMULA",
                difficulty: "Extended"
            ),
            PostItem(
                id: 3,
                subjectId: "chemistry",
                subjectName: "Chemistry",
                subjectCode: "0620",
                topicId: "chem_electrochemistry",
                authorHandle: "ReviseGram Library",
                authorAvatar: "0620",
                topicTitle: "Electrolysis of Concentrated Aqueous NaCl",
                chapterName: "Unit 4 · Electrochemistry",
                mainContent: "In concentrated aqueous sodium chloride (brine), four ions are present: Na⁺, Cl⁻, H⁺, and OH⁻.\n• At the cathode (–): H⁺ ions are reduced to hydrogen gas because hydrogen is less reactive than sodium.\n• At the anode (+): Cl⁻ ions are oxidised to chlorine gas due to halide concentration.",
                formulaOrKeyPoint: "Cathode: 2H⁺(aq) + 2e⁻ → H₂(g)\nAnode: 2Cl⁻(aq) → Cl₂(g) + 2e⁻",
                quizQuestion: "Which gas is evolved at the cathode during the electrolysis of concentrated aqueous sodium chloride?",
                quizOptions: [
                    "Oxygen (O₂)",
                    "Hydrogen (H₂)",
                    "Chlorine (Cl₂)",
                    "Sodium vapour"
                ],
                quizCorrectIndex: 1,
                quizExplanation: "Hydrogen gas is discharged at the negative cathode because H⁺ ions accept electrons more readily than Na⁺ ions.",
                commentsCount: 1,
                postType: "FORMULA",
                difficulty: "Extended"
            ),
            PostItem(
                id: 4,
                subjectId: "business",
                subjectName: "Business",
                subjectCode: "0264",
                topicId: "business_finance",
                authorHandle: "ReviseGram Library",
                authorAvatar: "0264",
                topicTitle: "Break-Even Analysis & Margin of Safety",
                chapterName: "Unit 5 · Financial Information and Decisions",
                mainContent: "Break-even output is the level of production at which Total Revenue equals Total Costs, resulting in neither profit nor loss. Margin of Safety measures how much current output exceeds the break-even level before the business incurs a loss.",
                formulaOrKeyPoint: "Break-Even = Fixed Costs / (Selling Price − Variable Cost per unit)",
                quizQuestion: "A business has fixed costs of $12,000, a selling price of $25 per unit, and variable cost of $15 per unit. What is its break-even output?",
                quizOptions: [
                    "1,200 units",
                    "480 units",
                    "800 units",
                    "300 units"
                ],
                quizCorrectIndex: 0,
                quizExplanation: "Contribution per unit = $25 − $15 = $10. Break-even output = $12,000 / $10 = 1,200 units.",
                commentsCount: 1,
                postType: "FORMULA",
                difficulty: "Extended"
            ),
            PostItem(
                id: 5,
                subjectId: "economics",
                subjectName: "Economics",
                subjectCode: "0455",
                topicId: "econ_micro",
                authorHandle: "ReviseGram Library",
                authorAvatar: "0455",
                topicTitle: "Price Elasticity of Demand (PED)",
                chapterName: "Unit 2 · The Allocation of Resources",
                mainContent: "Price Elasticity of Demand quantifies the responsiveness of quantity demanded to a percentage change in price.\n• |PED| > 1 : Price elastic (substitutes readily available; total revenue rises when price falls)\n• |PED| < 1 : Price inelastic (necessities; total revenue rises when price increases)",
                formulaOrKeyPoint: "PED = (% Δ Quantity Demanded) / (% Δ Price)",
                quizQuestion: "A 10% rise in price causes quantity demanded to fall by 25%. What is the absolute value of PED?",
                quizOptions: [
                    "2.5 (Price elastic)",
                    "0.4 (Price inelastic)",
                    "25.0 (Price elastic)",
                    "1.0 (Unitary elastic)"
                ],
                quizCorrectIndex: 0,
                quizExplanation: "|PED| = 25% / 10% = 2.5. Because |PED| > 1, demand is price elastic.",
                commentsCount: 1,
                postType: "FORMULA",
                difficulty: "Extended"
            ),
            PostItem(
                id: 6,
                subjectId: "ict",
                subjectName: "Information and Communication Technology (ICT)",
                subjectCode: "0417",
                topicId: "ict_systems_lifecycle",
                authorHandle: "ReviseGram Library",
                authorAvatar: "0417",
                topicTitle: "Systems Life Cycle: Verification vs Validation",
                chapterName: "Unit 7 · The Systems Life Cycle",
                mainContent: "In IGCSE ICT (0417), validation and verification prevent different types of data-entry errors:\n• Validation is an automated check that entered data is reasonable, sensible, and within acceptable rules (e.g., range check, length check, format check, presence check).\n• Verification ensures data copied from a source document matches the original accurately (double data entry, visual screen check).",
                formulaOrKeyPoint: "Revision Tip: Neither validation nor verification checks whether the source data itself is factually true—only that it is sensible (validation) and accurately transcribed (verification).",
                quizQuestion: "Which validation check ensures that a student's candidate number consists of exactly 4 characters?",
                quizOptions: [
                    "Length check",
                    "Range check",
                    "Double data entry",
                    "Visual verification"
                ],
                quizCorrectIndex: 0,
                quizExplanation: "A length check validates that the number of characters entered matches the required character count. Double data entry and visual checks are verification methods.",
                commentsCount: 1,
                postType: "EXAM_TIP",
                difficulty: "Core"
            ),
            PostItem(
                id: 7,
                subjectId: "english_first_language",
                subjectName: "English – First Language",
                subjectCode: "0500",
                topicId: "eng_writers_effect",
                authorHandle: "ReviseGram Library",
                authorAvatar: "0500",
                topicTitle: "Writer's Effect & Summary Task (Paper 1)",
                chapterName: "Paper 1 · Reading",
                mainContent: "In IGCSE English – First Language (0500, 2027–2029 syllabus), Paper 1 assesses comprehension, selective summary writing (Question 2), and language analysis:\n1. For Question 2 (Summary task), synthesise key points in your own words within the word limit.\n2. For Writer's Effect, select short micro-quotations (2–5 words), explain literal meaning in context, and unpack imagery connotations.",
                formulaOrKeyPoint: "Paper 1 Reminder: Question 2 is the selective Summary task. Avoid copying long verbatim phrases; group ideas logically and explain precise effects.",
                quizQuestion: "In IGCSE English – First Language (0500), what is the strongest approach to a Writer's Effect question?",
                quizOptions: [
                    "Embed brief, precise quotations and analyse both literal meaning and imagery connotations",
                    "Copy out entire sentences without explaining individual word choices",
                    "List grammatical terms without linking them to meaning",
                    "Write a personal summary of the plot only"
                ],
                quizCorrectIndex: 0,
                quizExplanation: "In 0500 Reading, credit is awarded for selecting precise choices of language, explaining their literal meaning in context, and exploring deeper connotations and effects.",
                commentsCount: 1,
                postType: "EXAM_TIP",
                difficulty: "Extended"
            )
        ]
    }

    static func initialComments() -> [PostComment] {
        [
            PostComment(id: 1, postId: 1, userName: "Syllabus Note", userAvatar: "N", commentText: "Always measure angles of incidence and refraction from the normal (90° to the boundary), never from the surface itself."),
            PostComment(id: 2, postId: 1, userName: "Syllabus Note", userAvatar: "N", commentText: "Frequency stays constant across boundaries because it is fixed by the wave source."),
            PostComment(id: 3, postId: 2, userName: "Syllabus Note", userAvatar: "N", commentText: "Bracket negative coefficients carefully when substituting b into (−b)² − 4ac."),
            PostComment(id: 4, postId: 3, userName: "Syllabus Note", userAvatar: "N", commentText: "In dilute aqueous NaCl, OH⁻ is discharged at the anode to form O₂ instead of Cl₂."),
            PostComment(id: 5, postId: 4, userName: "Syllabus Note", userAvatar: "N", commentText: "Margin of Safety = Actual Output − Break-Even Output."),
            PostComment(id: 6, postId: 5, userName: "Syllabus Note", userAvatar: "N", commentText: "When demand is price elastic (|PED| > 1), lowering price increases total revenue."),
            PostComment(id: 7, postId: 6, userName: "Syllabus Note", userAvatar: "N", commentText: "Check digit is a validation method calculated from the other digits (e.g., ISBN numbers)."),
            PostComment(id: 8, postId: 7, userName: "Syllabus Note", userAvatar: "N", commentText: "For Summary Writing (Question 2 in the 2027–2029 syllabus), synthesise points in your own words and stay strictly within the word limit.")
        ]
    }

    static func initialStories() -> [StoryItem] {
        [
            StoryItem(
                subjectId: "physics",
                subjectName: "Physics",
                subjectCode: "0625",
                iconEmoji: "0625",
                primaryColorHex: "#4F46E5",
                slides: [
                    StorySlide(
                        title: "Kinematics Equations",
                        subtitle: "v = u + at  |  s = ½(u + v)t",
                        content: "Speed is a scalar quantity; velocity is a vector quantity. The gradient of a speed–time graph equals acceleration, and the area under the graph equals total distance travelled.",
                        formulaOrTip: "Gradient of distance–time graph = speed\nGradient of speed–time graph = acceleration",
                        quizQuestion: "What physical quantity is represented by the area under a speed–time graph?",
                        quizOptions: ["Acceleration", "Total distance travelled", "Instantaneous velocity", "Resultant force"],
                        quizCorrectIndex: 1,
                        explanation: "The area enclosed beneath a speed–time curve equals the total distance travelled."
                    ),
                    StorySlide(
                        title: "Newton's Second Law",
                        subtitle: "F = m × a",
                        content: "A resultant force acting on a mass produces an acceleration directly proportional to the force and in the same direction. When resultant force is zero, the body remains at rest or moves at constant velocity.",
                        formulaOrTip: "W = m × g   (where g = 9.8 N/kg in IGCSE Physics 0625)",
                        quizQuestion: "A 5 kg mass experiences a resultant force of 20 N. What is its acceleration?",
                        quizOptions: ["4.0 m/s²", "0.25 m/s²", "100 m/s²", "15 m/s²"],
                        quizCorrectIndex: 0,
                        explanation: "a = F / m = 20 / 5 = 4.0 m/s²."
                    )
                ]
            ),
            StoryItem(
                subjectId: "mathematics",
                subjectName: "Mathematics",
                subjectCode: "0580",
                iconEmoji: "0580",
                primaryColorHex: "#4F46E5",
                slides: [
                    StorySlide(
                        title: "Right-Angled Trigonometry",
                        subtitle: "sin θ = O/H  |  cos θ = A/H  |  tan θ = O/A",
                        content: "For any right-angled triangle, Pythagoras' theorem states a² + b² = c² where c is the hypotenuse opposite the 90° angle.",
                        formulaOrTip: "Sine Rule: a / sin A = b / sin B\nCosine Rule: a² = b² + c² − 2bc cos A",
                        quizQuestion: "In a right-angled triangle with adjacent side 3 cm and hypotenuse 5 cm, what is cos θ?",
                        quizOptions: ["3/5", "4/5", "5/3", "3/4"],
                        quizCorrectIndex: 0,
                        explanation: "cos θ = Adjacent / Hypotenuse = 3/5."
                    )
                ]
            ),
            StoryItem(
                subjectId: "chemistry",
                subjectName: "Chemistry",
                subjectCode: "0620",
                iconEmoji: "0620",
                primaryColorHex: "#4F46E5",
                slides: [
                    StorySlide(
                        title: "Simple Molecular Substances",
                        subtitle: "Covalent Bonding & Intermolecular Forces",
                        content: "Non-metal atoms share pairs of electrons to form strong covalent bonds. However, simple molecular substances have low melting and boiling points because only weak intermolecular forces are overcome during state changes.",
                        formulaOrTip: "Covalent bonds are NOT broken when boiling water or methane—only weak intermolecular forces.",
                        quizQuestion: "Why does methane (CH₄) have a very low boiling point?",
                        quizOptions: ["Weak covalent bonds within molecules", "Weak intermolecular forces between molecules", "It forms a giant ionic lattice", "Carbon is a gas at room temperature"],
                        quizCorrectIndex: 1,
                        explanation: "Little thermal energy is required to overcome the weak attractive forces between individual CH₄ molecules."
                    )
                ]
            ),
            StoryItem(
                subjectId: "business",
                subjectName: "Business",
                subjectCode: "0264",
                iconEmoji: "0264",
                primaryColorHex: "#4F46E5",
                slides: [
                    StorySlide(
                        title: "Cash-Flow & Working Capital",
                        subtitle: "Net Cash Flow = Cash Inflows − Cash Outflows",
                        content: "Cash is the liquid funds immediately available to pay day-to-day expenses, whereas profit is total revenue minus total costs over a period. Even a profitable business can fail if it runs out of cash to pay short-term debts.",
                        formulaOrTip: "Closing Balance = Opening Balance + Net Cash Flow",
                        quizQuestion: "A business has an opening bank balance of $4,000, cash inflows of $15,000, and cash outflows of $11,000. What is its closing balance?",
                        quizOptions: ["$8,000", "$4,000", "$19,000", "$15,000"],
                        quizCorrectIndex: 0,
                        explanation: "Net cash flow = $15,000 − $11,000 = $4,000. Closing balance = $4,000 + $4,000 = $8,000."
                    )
                ]
            ),
            StoryItem(
                subjectId: "economics",
                subjectName: "Economics",
                subjectCode: "0455",
                iconEmoji: "0455",
                primaryColorHex: "#4F46E5",
                slides: [
                    StorySlide(
                        title: "Opportunity Cost & PPC",
                        subtitle: "Next Best Alternative Foregone",
                        content: "Because economic resources (land, labour, capital, enterprise) are scarce relative to unlimited wants, every allocation choice involves an opportunity cost.",
                        formulaOrTip: "Points on the Production Possibility Curve (PPC) represent maximum productive efficiency.",
                        quizQuestion: "A government allocates $50m to build a hospital instead of a highway. What is the opportunity cost?",
                        quizOptions: ["$50m in tax revenue", "The highway that could have been built", "Hospital operating costs", "Healthcare workers' wages"],
                        quizCorrectIndex: 1,
                        explanation: "Opportunity cost is the next best alternative foregone—in this case, the highway."
                    )
                ]
            ),
            StoryItem(
                subjectId: "ict",
                subjectName: "Information and Communication Technology (ICT)",
                subjectCode: "0417",
                iconEmoji: "0417",
                primaryColorHex: "#4F46E5",
                slides: [
                    StorySlide(
                        title: "Relational Databases & Keys",
                        subtitle: "Primary Key vs Foreign Key",
                        content: "In IGCSE ICT (0417), a relational database stores data across linked tables to reduce data redundancy and improve consistency. A Primary Key uniquely identifies each record in a table, while a Foreign Key links to the Primary Key of another table.",
                        formulaOrTip: "Relational databases eliminate duplicate data entry and avoid update anomalies compared to flat-file databases.",
                        quizQuestion: "Which field type uniquely identifies every individual record in a database table?",
                        quizOptions: ["Foreign key", "Primary key", "Boolean field", "Lookup list"],
                        quizCorrectIndex: 1,
                        explanation: "A primary key holds a unique value for each record in a table."
                    )
                ]
            ),
            StoryItem(
                subjectId: "english_first_language",
                subjectName: "English – First Language",
                subjectCode: "0500",
                iconEmoji: "0500",
                primaryColorHex: "#4F46E5",
                slides: [
                    StorySlide(
                        title: "Directed Writing & Register (VARP)",
                        subtitle: "Voice · Audience · Register · Purpose",
                        content: "In IGCSE English – First Language (0500, 2027–2029 syllabus), Directed Writing tests your ability to evaluate ideas from reading texts and adapt them into a convincing form such as a speech, letter, report, or article.",
                        formulaOrTip: "Always anchor your response in textual ideas while synthesising and evaluating them in your own voice.",
                        quizQuestion: "What does 'Register' refer to in Directed Writing (0500)?",
                        quizOptions: [
                            "The level of formality, tone, and style suited to the audience and purpose",
                            "Counting the number of paragraphs in the reading text",
                            "Writing only in bullet points",
                            "Copying quotations verbatim"
                        ],
                        quizCorrectIndex: 0,
                        explanation: "Register is the appropriateness of tone, vocabulary, and formality for the specified audience and format."
                    )
                ]
            )
        ]
    }

    static func initialFlashcards() -> [FlashcardItem] {
        [
            FlashcardItem(id: 1, subjectId: "physics", subjectCode: "0625", subjectName: "Physics", topicId: "physics_forces", topic: "Hooke's Law & Elasticity", difficulty: "Core", front: "State Hooke's Law and give its defining equation.", back: "The extension of a spring is directly proportional to the applied load, provided the limit of proportionality is not exceeded.\n\nF = k × x\n(F = force in N, k = spring constant in N/m, x = extension in m)"),
            FlashcardItem(id: 2, subjectId: "physics", subjectCode: "0625", subjectName: "Physics", topicId: "physics_electricity", topic: "Ideal Transformer Equations", difficulty: "Extended", front: "State the turns-ratio and power equations for an ideal (100% efficient) transformer.", back: "Vp / Vs = Np / Ns\n\nFor 100% efficiency:\nVp × Ip = Vs × Is   (Input power = Output power)"),
            FlashcardItem(id: 3, subjectId: "mathematics", subjectCode: "0580", subjectName: "Mathematics", topicId: "math_trigonometry", topic: "Non-Right-Angled Triangles", difficulty: "Extended", front: "State the Sine Rule, Cosine Rule, and trigonometric area formula for any triangle ABC.", back: "Sine Rule: a / sin A = b / sin B = c / sin C\n\nCosine Rule: a² = b² + c² − 2bc cos A\n\nArea: ½ ab sin C"),
            FlashcardItem(id: 4, subjectId: "mathematics", subjectCode: "0580", subjectName: "Mathematics", topicId: "math_coordinate_geometry", topic: "Coordinate Geometry & Gradients", difficulty: "Extended", front: "State the gradient formula, midpoint formula, and condition for perpendicular lines.", back: "Gradient: m = (y₂ − y₁) / (x₂ − x₁)\n\nMidpoint: ((x₁ + x₂)/2 , (y₁ + y₂)/2)\n\nPerpendicular gradients: m₁ × m₂ = −1"),
            FlashcardItem(id: 5, subjectId: "chemistry", subjectCode: "0620", subjectName: "Chemistry", topicId: "chem_electrochemistry", topic: "Electrolysis of Molten PbBr₂", difficulty: "Core", front: "Give the half-equations and observations at both electrodes during the electrolysis of molten lead(II) bromide.", back: "Cathode (–): Grey liquid lead forms.\nPb²⁺ + 2e⁻ → Pb  (Reduction)\n\nAnode (+): Red-brown bromine vapour evolves.\n2Br⁻ → Br₂ + 2e⁻  (Oxidation)"),
            FlashcardItem(id: 6, subjectId: "chemistry", subjectCode: "0620", subjectName: "Chemistry", topicId: "chem_reversible_reactions", topic: "The Haber Process", difficulty: "Extended", front: "State the essential operating conditions for the Haber process (N₂ + 3H₂ ⇌ 2NH₃).", back: "• Temperature: 450 °C (compromise between reaction rate and exothermic yield)\n• Pressure: 20,000 kPa / 200 atm\n• Catalyst: Finely divided iron (Fe)"),
            FlashcardItem(id: 7, subjectId: "business", subjectCode: "0264", subjectName: "Business", topicId: "business_finance", topic: "Financial Liquidity Ratios", difficulty: "Extended", front: "State the formulas for the Current Ratio and Acid Test (Quick) Ratio in IGCSE Business (0264).", back: "Current Ratio = Current Assets / Current Liabilities\n\nAcid Test Ratio = (Current Assets − Inventories) / Current Liabilities"),
            FlashcardItem(id: 8, subjectId: "business", subjectCode: "0264", subjectName: "Business", topicId: "business_activity", topic: "Added Value", difficulty: "Core", front: "Define Added Value and state two ways a business can increase it.", back: "Added Value = Selling Price − Cost of Bought-In Materials/Components.\n\nWays to increase:\n1. Increase selling price through branding, quality, or USP.\n2. Reduce input costs by sourcing cheaper raw materials."),
            FlashcardItem(id: 9, subjectId: "economics", subjectCode: "0455", subjectName: "Economics", topicId: "econ_macro", topic: "Demand-Side Macroeconomic Policy", difficulty: "Core", front: "Distinguish between fiscal policy and monetary policy instruments in IGCSE Economics (0455).", back: "Fiscal policy: Government adjustments to taxation and public expenditure.\n\nMonetary policy: Central bank adjustments to interest rates and the money supply."),
            FlashcardItem(id: 10, subjectId: "economics", subjectCode: "0455", subjectName: "Economics", topicId: "econ_market_failure", topic: "Market Failure & Externalities", difficulty: "Extended", front: "Define Social Cost and Social Benefit in terms of private and external components.", back: "Social Cost = Private Cost + External Cost\n\nSocial Benefit = Private Benefit + External Benefit\n\nMarket failure occurs when social costs exceed social benefits at the free-market equilibrium."),
            FlashcardItem(id: 11, subjectId: "ict", subjectCode: "0417", subjectName: "Information and Communication Technology (ICT)", topicId: "ict_systems_lifecycle", topic: "System Implementation Methods", difficulty: "Extended", front: "Compare Direct Changeover, Parallel Running, Pilot Running, and Phased Implementation in ICT (0417).", back: "• Direct: Old system replaced immediately; fast & low cost, but high risk if the new system fails.\n• Parallel: Old and new run together; safe fallback, but expensive.\n• Pilot: Implemented in one branch first.\n• Phased: Introduced module by module."),
            FlashcardItem(id: 12, subjectId: "ict", subjectCode: "0417", subjectName: "Information and Communication Technology (ICT)", topicId: "ict_networks", topic: "Network Hardware Devices", difficulty: "Core", front: "Distinguish between the roles of a Switch and a Router in a computer network.", back: "Switch: Connects devices together on a Local Area Network (LAN) and forwards data packets to the specific destination MAC address.\n\nRouter: Connects a LAN to a Wide Area Network (WAN / Internet) and routes data packets using IP addresses."),
            FlashcardItem(id: 13, subjectId: "english_first_language", subjectCode: "0500", subjectName: "English – First Language", topicId: "eng_summary_writing", topic: "Summary Writing (Question 2)", difficulty: "Extended", front: "List the core requirements for a high-scoring Summary response (Paper 1 Question 2) in IGCSE English – First Language (0500 · 2027–2029).", back: "1. Focus strictly on the specific aspect requested in Paper 1 Question 2.\n2. Identify 10–12 distinct content points from the reading text.\n3. Group related ideas logically and synthesise in your own words.\n4. Maintain a concise, objective register within the guided word count."),
            FlashcardItem(id: 14, subjectId: "english_first_language", subjectCode: "0500", subjectName: "English – First Language", topicId: "eng_composition", topic: "Descriptive vs Narrative Writing", difficulty: "Extended", front: "How does Descriptive Writing differ structurally from Narrative Writing in Paper 2?", back: "Descriptive Writing focuses on sensory atmosphere, spatial movement, and zoom-in imagery of a scene or moment without relying on a plot-driven storyline.\n\nNarrative Writing builds a structured plot arc (exposition, tension, climax, resolution) with character development.")
        ]
    }

    static func initialRewards() -> [RewardItem] {
        [
            RewardItem(itemId: "badge_astars", title: "Distinction Candidate", description: "Editorial distinction title on your study profile", pointCost: 200, iconEmoji: "A*", itemType: "BADGE", isUnlocked: false, isEquipped: false),
            RewardItem(itemId: "shield_streak", title: "Streak Rest Day", description: "Preserves your daily study streak during a rest day", pointCost: 350, iconEmoji: "1d", itemType: "SHIELD", isUnlocked: false, isEquipped: false),
            RewardItem(itemId: "avatar_quantum", title: "Physics Monogram", description: "Set your study monogram to Φ (Phi)", pointCost: 400, iconEmoji: "Φ", itemType: "AVATAR", isUnlocked: false, isEquipped: false),
            RewardItem(itemId: "avatar_genius", title: "Calculus Monogram", description: "Set your study monogram to ∫ (Integral)", pointCost: 600, iconEmoji: "∫", itemType: "AVATAR", isUnlocked: false, isEquipped: false),
            RewardItem(itemId: "theme_neon", title: "Senior Scholar Title", description: "Unlock the 'Senior Scholar' profile designation", pointCost: 800, iconEmoji: "I", itemType: "BADGE", isUnlocked: false, isEquipped: false)
        ]
    }

    static func initialChatMessages() -> [ChatMessage] {
        [
            ChatMessage(id: 1, subjectId: "physics", senderName: "Physics Tutor · 0625", messageText: "Welcome to IGCSE Physics (0625 · 2026–2028 syllabus). Ask for a derivation, a worked calculation, or revision guidance on Forces, Waves, Electricity, or Thermal Physics.", isFromUser: false),
            ChatMessage(id: 2, subjectId: "mathematics", senderName: "Mathematics Tutor · 0580", messageText: "Welcome to IGCSE Mathematics (0580 · 2025–2027 syllabus). Share any algebra, trigonometry, calculus, functions, or vector problem for a step-by-step breakdown.", isFromUser: false),
            ChatMessage(id: 3, subjectId: "chemistry", senderName: "Chemistry Tutor · 0620", messageText: "Welcome to IGCSE Chemistry (0620 · 2026–2028 syllabus). We can work through stoichiometry, ionic half-equations, organic chemistry, or practical test observations.", isFromUser: false),
            ChatMessage(id: 4, subjectId: "business", senderName: "Business Tutor · 0264", messageText: "Welcome to IGCSE Business (0264 · 2027–2029 syllabus route). Ask about enterprise, marketing mix, operations, break-even analysis, financial ratios, or evaluation structure.", isFromUser: false),
            ChatMessage(id: 5, subjectId: "economics", senderName: "Economics Tutor · 0455", messageText: "Welcome to IGCSE Economics (0455 · 2027–2029 syllabus). We can review price elasticity, market failure, macroeconomic objectives, or structured evaluation responses.", isFromUser: false),
            ChatMessage(id: 6, subjectId: "ict", senderName: "ICT Tutor · 0417", messageText: "Welcome to IGCSE Information and Communication Technology (ICT) (0417 · 2026–2028 syllabus). Ask about the systems life cycle, relational databases, spreadsheet functions, networks, or e-safety.", isFromUser: false),
            ChatMessage(id: 7, subjectId: "english_first_language", senderName: "English – First Language Tutor · 0500", messageText: "Welcome to IGCSE English – First Language (0500 · 2027–2029 syllabus). We can refine your reading comprehension, Question 2 summary concision, writer's effect analysis, or directed and descriptive writing.", isFromUser: false)
        ]
    }

    static func initialDailyMissions() -> [DailyMission] {
        [
            DailyMission(id: 1, title: "Syllabus Concept Check", description: "Complete 3 syllabus checkpoint questions across your subjects", topicId: "physics_waves", topic: "Core Concepts", rewardPoints: 30, targetCount: 3, currentCount: 0, missionType: "QUIZ"),
            DailyMission(id: 2, title: "Spaced Repetition Recall", description: "Review 5 flashcards across your active decks", topicId: "chem_electrochemistry", topic: "Active Recall", rewardPoints: 25, targetCount: 5, currentCount: 0, missionType: "FLASHCARD"),
            DailyMission(id: 3, title: "Written Response Practice", description: "Submit 1 structured answer for mark-scheme evaluation", rewardPoints: 35, targetCount: 1, currentCount: 0, missionType: "TUTOR")
        ]
    }

    static func initialCollections() -> [CollectionFolder] {
        [
            CollectionFolder(id: 1, name: "Must Revise Formulas", iconEmoji: "⚡", description: "High-yield formulas for Physics, Mathematics, and Chemistry", postIds: [1, 2])
        ]
    }
}
