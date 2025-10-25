import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var selectedCategories: [ContentCategory] = []
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to Scroll Jail")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Select your interests to personalize your feed")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 15) {
                ForEach(ContentCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategories.contains(category)
                    ) {
                        if selectedCategories.contains(category) {
                            selectedCategories.removeAll { $0 == category }
                        } else {
                            selectedCategories.append(category)
                        }
                    }
                }
            }
            .padding()
            
            Button("Start Scrolling Mindfully") {
                viewModel.user.selectedCategories = selectedCategories
                viewModel.loadContent()
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedCategories.isEmpty)
            
            Text("Choose at least 3 categories for better personalization")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct CategoryButton: View {
    let category: ContentCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: iconForCategory(category))
                    .font(.title)
                Text(category.rawValue)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100, height: 80)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(10)
        }
    }
    
    private func iconForCategory(_ category: ContentCategory) -> String {
        switch category {
        case .gaming: return "gamecontroller"
        case .comedy: return "theatermasks"
        case .sports: return "sportscourt"
        case .cooking: return "fork.knife"
        case .tech: return "laptopcomputer"
        case .dance: return "music.note"
        case .education: return "book"
        case .animals: return "pawprint"
        }
    }
}
