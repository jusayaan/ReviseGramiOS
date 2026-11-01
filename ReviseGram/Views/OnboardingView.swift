import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    @State private var selectedIds: Set<String> = Set(SubjectCatalogue.defaultSubjectIds)

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("CAMBRIDGE IGCSE")
                    .font(.caption.weight(.bold))
                    .foregroundColor(DesignTokens.primaryBrand)
                Text("Select your examination subjects")
                    .font(.title2.weight(.bold))
                Text("Personalise your revision feed, spaced-repetition flashcards, past paper tracker, and syllabus AI tutors.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 24)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(SubjectCatalogue.subjects) { subject in
                        let isSelected = selectedIds.contains(subject.id)
                        Button {
                            if isSelected {
                                selectedIds.remove(subject.id)
                            } else {
                                selectedIds.insert(subject.id)
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Text(subject.code)
                                    .font(.system(.caption, design: .monospaced).weight(.bold))
                                    .foregroundColor(isSelected ? .white : DesignTokens.primaryBrand)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(isSelected ? DesignTokens.primaryBrand : DesignTokens.primaryBrand.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(subject.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.primary)
                                    Text("Syllabus \(subject.syllabusVersion)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(isSelected ? DesignTokens.primaryBrand : .secondary)
                            }
                            .padding(14)
                            .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isSelected ? DesignTokens.primaryBrand : DesignTokens.border(isDark: viewModel.isDarkTheme), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button {
                viewModel.completeOnboarding(with: Array(selectedIds))
            } label: {
                Text("Continue with \(selectedIds.count) Subject\(selectedIds.count == 1 ? "" : "s")")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(selectedIds.isEmpty ? Color.gray : DesignTokens.primaryBrand)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(selectedIds.isEmpty)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, DesignTokens.screenHorizontalPadding)
        .background(DesignTokens.background(isDark: viewModel.isDarkTheme).ignoresSafeArea())
    }
}
