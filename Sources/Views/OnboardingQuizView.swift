import SwiftUI

// MARK: - Data Models

struct InterestSubcategory {
    let name: String
    let entities: [String]
}

struct InterestCategory: Identifiable {
    let id: Int
    let emoji: String
    let name: String
    let subcategories: [InterestSubcategory]
}

// MARK: - OnboardingQuizView

struct OnboardingQuizView: View {
    @Environment(\.dismiss) private var dismiss
    var onComplete: ((_ categories: Set<Int>, _ subcategories: Set<String>, _ entities: Set<String>, _ freeText: String) -> Void)? = nil
    
    @State private var currentStep = 0
    @State private var selectedCategories: Set<Int> = []
    @State private var selectedSubcategories: Set<String> = []
    @State private var selectedEntities: Set<String> = []
    @State private var freeTextInput: String = ""
    @State private var locationName: String = "Palo Alto"
    @State private var showLocationPicker = false
    @State private var isBuilding = false
    @State private var sparkleScale: CGFloat = 1.0
    @State private var sparkleOpacity: Double = 1.0

    private let totalSteps = 4
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Personalize snapshot",
                backAction: handleBack
            )

            progressIndicator

            ScrollViewReader { scrollProxy in
                ScrollView {
                    Color.clear.frame(height: 0).id("step-top")
                    stepContent
                        .padding(.bottom, 24)
                }
                .onChange(of: currentStep) { _, _ in
                    scrollProxy.scrollTo("step-top", anchor: .top)
                }
            }
            .background(Color("surfaceBackground"))
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        Color("surfaceBackground").opacity(0),
                        Color("surfaceBackground")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 48)
                .allowsHitTesting(false)
            }

            bottomSection
        }
        .background(Color("surfaceBackground"))
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerSheet(selectedLocation: $locationName)
                .presentationDetents([.medium])
        }
    }

    // MARK: - Navigation

    private func handleBack() {
        dismiss()
    }

    private func navigateBack() {
        if currentStep > 0 {
            withAnimation(.moveIn(MotionDuration.shortIn)) {
                currentStep -= 1
            }
        }
    }
    
    private func handleNext() {
        if currentStep < totalSteps - 1 {
            withAnimation(.moveIn(MotionDuration.shortIn)) {
                currentStep += 1
            }
        } else {
            // Immediately return to landing page and trigger background content generation
            onComplete?(selectedCategories, selectedSubcategories, selectedEntities, freeTextInput)
            dismiss()
        }
    }

    // MARK: - Building Overlay (commented out — replaced by toast on landing page)
    /*
    private func startBuilding() {
        withAnimation(.easeInOut(duration: MotionDuration.mediumIn)) {
            isBuilding = true
        }

        withAnimation(
            .easeInOut(duration: 1.0)
            .repeatForever(autoreverses: true)
        ) {
            sparkleScale = 1.15
            sparkleOpacity = 0.5
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            onComplete?(selectedCategories, selectedSubcategories, selectedEntities, freeTextInput)
            dismiss()
        }
    }
    */
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? Color("accentColor") : Color("divider"))
                    .frame(height: 3)
                    .animation(.moveIn(MotionDuration.shortIn), value: currentStep)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
    
    // MARK: - Content Router
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0: categoriesStep
        case 1: subcategoriesStep
        case 2: entitiesStep
        case 3: freeTextStep
        default: EmptyView()
        }
    }
    
    // MARK: - Step 1: Category Selection
    
    private var categoriesStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            stepHeader(
                title: "What are you into?",
                subtitle: "Pick the topics you'd like to see in your daily snapshot."
            )
            
            VStack(spacing: 8) {
                ForEach(allCategories) { category in
                    categoryChip(category: category)
                }
            }
            .padding(.horizontal, 12)
            
        }
    }
    
    // MARK: - Step 2: Subcategory Selection
    
    private var subcategoriesStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Let's get specific")
                .headline1EmphasizedTypography()
                .foregroundStyle(Color("primaryText"))
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(selectedCategoriesSorted) { category in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(category.emoji) \(category.name)")
                            .headline4EmphasizedTypography()
                            .foregroundStyle(Color("primaryText"))
                            .padding(.top, 8)

                        WrappingHStack(spacing: 6) {
                            ForEach(category.subcategories, id: \.name) { sub in
                                let isSelected = selectedSubcategories.contains(sub.name)
                                FDSActionChip(
                                    type: isSelected ? .secondary : .primary,
                                    size: .medium,
                                    label: sub.name.titleCased,
                                    leftAddOn: .icon(isSelected ? "checkmark-outline" : "plus-outline"),
                                    action: {
                                        withAnimation(.moveIn(MotionDuration.extraShortIn)) {
                                            if isSelected {
                                                selectedSubcategories.remove(sub.name)
                                            } else {
                                                selectedSubcategories.insert(sub.name)
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            
        }
    }
    
    // MARK: - Step 3: Entity Selection

    private var entitiesStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Pick your favorites")
                    .headline1EmphasizedTypography()
                    .foregroundStyle(Color("primaryText"))

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Image("location-filled")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(Color("accentColor"))
                        .baselineOffset(-2)

                    Text(locationName)
                        .body4Typography()
                        .foregroundStyle(Color("accentColor"))

                    Text("·")
                        .body4Typography()
                        .foregroundStyle(Color("secondaryText"))

                    Button {
                        showLocationPicker = true
                    } label: {
                        Text("Change")
                            .meta4LinkTypography()
                            .foregroundStyle(Color("secondaryText"))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
            .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 32) {
                ForEach(selectedCategoriesSorted) { category in
                    let categoryGroups = localizedEntitiesForSubcategories.filter { $0.categoryEmoji == category.emoji }
                    if !categoryGroups.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            // Parent category header with emoji
                            Text("\(category.emoji) \(category.name)")
                                .headline4EmphasizedTypography()
                                .foregroundStyle(Color("primaryText"))
                                .padding(.top, 8)

                            ForEach(categoryGroups, id: \.subcategoryName) { group in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 6) {
                                        Text(group.hasLocalSuggestions ? "Local \(group.subcategoryName.titleCased)" : group.subcategoryName.titleCased)
                                            .headline4Typography()
                                            .foregroundStyle(Color("secondaryText"))

                                        if group.hasLocalSuggestions {
                                            Text("Near you")
                                                .meta3Typography()
                                                .foregroundStyle(Color("accentColor"))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 5)
                                                .background(Color("accentDeemphasized"))
                                                .cornerRadius(4)
                                        }
                                    }
                                    .padding(.bottom, 8)

                                    WrappingHStack(spacing: 6) {
                                        // Limit to first 5 entities to keep within ~3 lines
                                        ForEach(Array(group.entities.prefix(5)), id: \.self) { entity in
                                            let isSelected = selectedEntities.contains(entity)
                                            FDSActionChip(
                                                type: isSelected ? .secondary : .primary,
                                                size: .medium,
                                                label: entity,
                                                leftAddOn: .icon(isSelected ? "checkmark-outline" : "plus-outline"),
                                                action: {
                                                    withAnimation(.moveIn(MotionDuration.extraShortIn)) {
                                                        if isSelected {
                                                            selectedEntities.remove(entity)
                                                        } else {
                                                            selectedEntities.insert(entity)
                                                        }
                                                    }
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)

        }
    }
    
    // MARK: - Step 4: Free Text Input
    
    private var freeTextStep: some View {
        FreeTextStepContent(
            freeTextInput: $freeTextInput
        )
    }
    
    // MARK: - Subcategory Emoji Lookup

    /// Returns a unique emoji for each subcategory. No two subcategories on the same screen share an emoji.
    private func subcategoryEmoji(for name: String) -> String {
        subcategoryEmojiMap[name] ?? "📌"
    }

    // MARK: - Reusable Components
    
    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .headline1EmphasizedTypography()
                .foregroundStyle(Color("primaryText"))
            
            Text(subtitle)
                .body3Typography()
                .foregroundStyle(Color("secondaryText"))
        }
        .padding(.horizontal, 12)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
    
    
    private func categoryChip(category: InterestCategory) -> some View {
        let isSelected = selectedCategories.contains(category.id)

        return Button {
            withAnimation(.moveIn(MotionDuration.extraShortIn)) {
                if isSelected {
                    selectedCategories.remove(category.id)
                } else {
                    selectedCategories.insert(category.id)
                }
            }
        } label: {
            HStack(spacing: 12) {
                Text(category.emoji)
                    .font(.system(size: 24))
                
                Text(category.name)
                    .headline4EmphasizedTypography()
                    .foregroundStyle(Color("primaryText"))
                
                Spacer()
                
                Image(isSelected ? "checkmark-outline" : "plus-outline")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(isSelected ? Color("accentColor") : Color("secondaryIcon"))
                    .transition(.scale.combined(with: .opacity))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color("primaryDeemphasizedButtonBackground") : Color("cardBackground"))
            .cornerRadius(9999)
            .overlay(
                RoundedRectangle(cornerRadius: 9999)
                    .stroke(
                        isSelected ? Color("accentColor") : Color("borderUiEmphasis"),
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
            )
        }
        .buttonStyle(FDSPressedState(cornerRadius: 9999, scale: .small))
    }
    
    // MARK: - Bottom Section

    private var bottomSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color("divider"))
                .frame(height: 0.5)

            HStack(spacing: 12) {
                if currentStep >= 1 {
                    FDSButton(
                        type: .secondary,
                        label: "Back",
                        size: .medium,
                        widthMode: .flexible,
                        action: navigateBack
                    )
                }

                FDSButton(
                    type: .primary,
                    label: bottomButtonLabel,
                    size: .medium,
                    isDisabled: !isNextEnabled,
                    widthMode: .flexible,
                    action: handleNext
                )
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .background(Color("surfaceBackground"))
    }
    
    // MARK: - Building Overlay

    private var buildingOverlay: some View {
        VStack(spacing: 0) {
            // Top area with sparkle + message
            VStack(spacing: 20) {
                Spacer()

                Image("gen-ai-star-filled")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(Color("accentColor"))
                    .scaleEffect(sparkleScale)
                    .opacity(sparkleOpacity)

                Text("Building your snapshot...")
                    .headline3EmphasizedTypography()
                    .foregroundStyle(Color("primaryText"))

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)

            // Glimmer state of Highlights section
            highlightsGlimmer
        }
        .transition(.opacity)
    }

    private var highlightsGlimmer: some View {
        VStack(alignment: .leading, spacing: 0) {
            FDSUnitHeader(
                headlineText: "Highlights for you",
                hierarchyLevel: .level3
            )

            VStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { _ in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("divider"))
                            .frame(width: 40, height: 40)

                        VStack(alignment: .leading, spacing: 6) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color("divider"))
                                .frame(height: 14)
                                .frame(maxWidth: .infinity)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color("divider"))
                                .frame(height: 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.trailing, 40)
                        }
                    }
                    .padding(12)
                    .background(Color("cardBackground"))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            .glimmer()
        }
        .background(Color("bottomSheetBackgroundDeemphasized"))
    }

    private var bottomButtonLabel: String {
        switch currentStep {
        case 0:
            let count = selectedCategories.count
            return count > 0 ? "Continue (\(count))" : "Continue"
        case 1:
            let count = selectedSubcategories.count
            return count > 0 ? "Continue (\(count))" : "Continue"
        case 2:
            let count = selectedEntities.count
            return count > 0 ? "Continue (\(count))" : "Continue"
        case 3:
            return "Build my snapshot"
        default:
            return "Continue"
        }
    }
    
    private var isNextEnabled: Bool {
        switch currentStep {
        case 0: return !selectedCategories.isEmpty
        case 1: return !selectedSubcategories.isEmpty
        default: return true
        }
    }
    
    // MARK: - Entity Grouping Helper
    
    struct EntityGroup: Hashable {
        let categoryEmoji: String
        let subcategoryName: String
        let entities: [String]
        let hasLocalSuggestions: Bool
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(subcategoryName)
        }
        static func == (lhs: EntityGroup, rhs: EntityGroup) -> Bool {
            lhs.subcategoryName == rhs.subcategoryName
        }
    }
    
    private var entitiesForSelectedSubcategories: [EntityGroup] {
        var groups: [EntityGroup] = []
        let localCategories: Set<String> = [
            "Sports", "Food & drink", "Music & audio",
            "Home & garden", "Animals & pets", "Lifestyle"
        ]

        for category in selectedCategoriesSorted {
            for sub in category.subcategories where selectedSubcategories.contains(sub.name) {
                guard !sub.entities.isEmpty else { continue }
                groups.append(EntityGroup(
                    categoryEmoji: category.emoji,
                    subcategoryName: sub.name,
                    entities: sub.entities,
                    hasLocalSuggestions: localCategories.contains(category.name)
                ))
            }
        }
        return groups
    }

    /// Location-aware entity groups — swaps local entities based on selected location.
    /// `hasLocalSuggestions` is true only when the subcategory actually has location-specific overrides
    /// (e.g., "Football" in Sports has local teams, but "Motivation" in Lifestyle does not).
    private var localizedEntitiesForSubcategories: [EntityGroup] {
        var groups: [EntityGroup] = []

        for category in selectedCategoriesSorted {
            for sub in category.subcategories where selectedSubcategories.contains(sub.name) {
                guard !sub.entities.isEmpty else { continue }
                let hasLocalOverride = locationEntityOverrides[locationName]?[sub.name] != nil
                let entities: [String]
                if hasLocalOverride {
                    entities = locationEntityOverrides[locationName]![sub.name]!
                } else {
                    entities = sub.entities
                }
                groups.append(EntityGroup(
                    categoryEmoji: category.emoji,
                    subcategoryName: sub.name,
                    entities: entities,
                    hasLocalSuggestions: hasLocalOverride
                ))
            }
        }
        return groups
    }
    
    // MARK: - Helpers
    
    private var selectedCategoriesSorted: [InterestCategory] {
        allCategories.filter { selectedCategories.contains($0.id) }
    }
}

// MARK: - Free Text Step (Isolated View)

struct FreeTextStepContent: View {
    @Binding var freeTextInput: String
    @State private var localText: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Anything else?")
                .headline1EmphasizedTypography()
                .foregroundStyle(Color("primaryText"))
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 8)

            Text("Optional — tell us what else you'd like to see.")
                .body4Typography()
                .foregroundStyle(Color("secondaryText"))
                .padding(.horizontal, 12)
                .padding(.bottom, 16)

            ZStack(alignment: .topLeading) {
                if localText.isEmpty && !isFocused {
                    Text("e.g. NBA trade rumors, toddler activities, local restaurant openings...")
                        .body4Typography()
                        .foregroundStyle(Color("disabledText"))
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $localText)
                    .body4Typography()
                    .foregroundStyle(Color("primaryText"))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 80)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .focused($isFocused)
            }
            .padding(8)
            .background(Color("cardBackground"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color("accentColor") : Color("divider"), lineWidth: 1)
            )
            .padding(.horizontal, 12)
        }
        .onAppear {
            localText = freeTextInput
            isFocused = true
        }
        .onChange(of: localText) { _, newValue in
            freeTextInput = newValue
        }
        .onDisappear { freeTextInput = localText }
    }
}

// MARK: - Location Picker Sheet

struct LocationPickerSheet: View {
    @Binding var selectedLocation: String
    @Environment(\.dismiss) private var dismiss
    @State private var customLocation: String = ""
    @FocusState private var isCustomFocused: Bool

    private let locations = [
        "Palo Alto", "San Francisco", "Mountain View", "Sunnyvale",
        "San Jose", "Cupertino", "Redwood City", "Menlo Park",
        "Berkeley", "Oakland", "Santa Cruz", "Napa"
    ]

    // Extended city list for autocomplete matching
    private static let knownCities: [String] = [
        // Bay Area
        "Palo Alto", "San Francisco", "Mountain View", "Sunnyvale", "San Jose",
        "Cupertino", "Redwood City", "Menlo Park", "Berkeley", "Oakland",
        "Santa Cruz", "Napa", "Fremont", "Hayward", "San Mateo", "Daly City",
        "Walnut Creek", "Pleasanton", "Livermore", "Santa Clara", "Milpitas",
        "Foster City", "Burlingame", "San Bruno", "Half Moon Bay", "Sausalito",
        "Mill Valley", "San Rafael", "Novato", "Petaluma", "Sonoma", "Vallejo",
        // Major US cities
        "Los Angeles", "New York", "Chicago", "Houston", "Phoenix", "Philadelphia",
        "San Antonio", "San Diego", "Dallas", "Austin", "Jacksonville", "Fort Worth",
        "Columbus", "Charlotte", "Indianapolis", "Seattle", "Denver", "Washington",
        "Nashville", "Oklahoma City", "El Paso", "Boston", "Portland", "Las Vegas",
        "Memphis", "Louisville", "Baltimore", "Milwaukee", "Albuquerque", "Tucson",
        "Fresno", "Sacramento", "Mesa", "Kansas City", "Atlanta", "Omaha",
        "Colorado Springs", "Raleigh", "Long Beach", "Virginia Beach", "Miami",
        "Minneapolis", "Tampa", "Arlington", "New Orleans", "Cleveland",
        "Honolulu", "Anaheim", "Orlando", "St. Louis", "Pittsburgh", "Cincinnati",
        "Anchorage", "Henderson", "Greensboro", "Plano", "Newark", "Lincoln",
        "Buffalo", "Chandler", "Scottsdale", "St. Paul", "Norfolk", "Madison",
        "Boise", "Richmond", "Des Moines", "Salt Lake City", "Santa Monica",
        "Pasadena", "Beverly Hills", "Irvine", "Burbank", "Glendale"
    ]

    private var filteredSuggestions: [String] {
        let query = customLocation.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard query.count >= 2 else { return [] }
        return Self.knownCities.filter { city in
            city.lowercased().contains(query)
        }.prefix(5).map { $0 }
    }

    private func resolvedLocation(_ input: String) -> String {
        let query = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        // Exact prefix match first
        if let match = Self.knownCities.first(where: { $0.lowercased().hasPrefix(query) }) {
            return match
        }
        // Contains match
        if let match = Self.knownCities.first(where: { $0.lowercased().contains(query) }) {
            return match
        }
        // Fuzzy: check if removing spaces/punctuation helps
        let normalized = query.replacingOccurrences(of: " ", with: "")
        if let match = Self.knownCities.first(where: {
            $0.lowercased().replacingOccurrences(of: " ", with: "").contains(normalized)
        }) {
            return match
        }
        // Return capitalized input as fallback
        return input.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
    }

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Choose location",
                backAction: { dismiss() }
            )

            ScrollView {
                VStack(spacing: 0) {
                    // Custom location input
                    HStack(spacing: 12) {
                        Image("magnifying-glass-outline")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color("secondaryIcon"))

                        TextField("Enter a city or region", text: $customLocation)
                            .body3Typography()
                            .foregroundStyle(Color("primaryText"))
                            .focused($isCustomFocused)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .onSubmit {
                                let trimmed = customLocation.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !trimmed.isEmpty {
                                    selectedLocation = resolvedLocation(trimmed)
                                    dismiss()
                                }
                            }

                        if !customLocation.isEmpty {
                            Button {
                                let trimmed = customLocation.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !trimmed.isEmpty {
                                    selectedLocation = resolvedLocation(trimmed)
                                    dismiss()
                                }
                            } label: {
                                Text("Use")
                                    .button3Typography()
                                    .foregroundStyle(Color("accentColor"))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    // Autocomplete suggestions
                    if !filteredSuggestions.isEmpty {
                        ForEach(filteredSuggestions, id: \.self) { suggestion in
                            Button {
                                selectedLocation = suggestion
                                dismiss()
                            } label: {
                                HStack {
                                    Image("location-filled")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                        .foregroundStyle(Color("accentColor"))

                                    Text(suggestion)
                                        .body3Typography()
                                        .foregroundStyle(Color("primaryText"))

                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(FDSPressedState(cornerRadius: 0))
                        }
                    }

                    Rectangle()
                        .fill(Color("divider"))
                        .frame(height: 0.5)

                    // Preset locations
                    ForEach(locations, id: \.self) { location in
                        Button {
                            selectedLocation = location
                            dismiss()
                        } label: {
                            HStack {
                                Image("nearby-places-outline")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color("secondaryIcon"))

                                Text(location)
                                    .body3Typography()
                                    .foregroundStyle(Color("primaryText"))

                                Spacer()

                                if location == selectedLocation {
                                    Image("checkmark-outline")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color("accentColor"))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(FDSPressedState())

                        Rectangle()
                            .fill(Color("divider"))
                            .frame(height: 0.5)
                            .padding(.leading, 48)
                    }
                }
            }
        }
        .background(Color("surfaceBackground"))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isCustomFocused = true
            }
        }
    }
}

// MARK: - Subcategory Emoji Map (unique per subcategory — never reuse on same screen)

private let subcategoryEmojiMap: [String: String] = [
    // Sports
    "Football": "🏈", "Basketball": "🏀", "Soccer": "⚽", "Baseball": "⚾",
    "Tennis": "🎾", "Golf": "⛳", "Hockey": "🏒", "Cricket": "🏏",
    "Winter sports": "⛷️", "MMA & boxing": "🥊",
    // TV & movies
    "Action": "💥", "Comedy": "😂", "Drama": "🎭", "Sci-fi": "🚀",
    "Reality TV": "📺", "Documentaries": "🎬", "Anime": "⛩️", "Horror": "👻",
    "Thriller": "🔪", "Romance": "💕",
    // Food & drink
    "Cooking": "👨‍🍳", "Baking": "🧁", "Restaurants": "🍽️", "Recipes": "📖",
    "Food festivals": "🎪", "Coffee & tea": "☕", "Cocktails & wine": "🍷",
    "Street food": "🌮", "Healthy eating": "🥗", "Meal prep": "🥘",
    // Music & audio
    "Pop": "🎤", "Rock": "🎸", "Hip-hop": "🎧", "R&B": "🎵",
    "Country": "🤠", "Electronic": "🎛️", "Classical": "🎻", "Jazz": "🎷",
    "Podcasts": "🎙️", "Live concerts": "🎶",
    // Family & relationships
    "Parenting": "👨‍👩‍👧", "Family activities": "🎡", "Relationship advice": "💬",
    "Weddings": "💍", "Baby & toddler": "👶", "Teen parenting": "🧑‍🎓",
    "Family travel": "✈️", "Elder care": "🤝",
    // Home & garden
    "Home decor": "🏠", "Gardening": "🌱", "DIY projects": "🔨",
    "Real estate": "🏡", "Organization": "📦", "Interior design": "🛋️",
    "Outdoor living": "🌿", "Smart home": "💡",
    // Animals & pets
    "Dogs": "🐕", "Cats": "🐱", "Pet care": "🩺", "Wildlife": "🦌",
    "Aquariums": "🐠", "Birds": "🐦", "Horses": "🐴", "Pet adoption": "❤️",
    // Lifestyle
    "Fashion": "👗", "Fitness": "💪", "Wellness": "🧘", "Beauty": "💄",
    "Travel": "🗺️", "Motivation": "🌟", "Spirituality": "🕊️", "Minimalism": "✨",
    // Vehicles
    "Cars": "🚗", "Classic cars": "🏎️", "Car maintenance": "🔧",
    "Motorcycles": "🏍️", "Trucks": "🛻", "Electric vehicles": "⚡",
    "Racing": "🏁", "Off-road": "🛞",
    // Trending & memes
    "Memes": "🤣", "Viral challenges": "📱", "Current events": "📰",
    "Pop culture": "🌐", "Internet trends": "🔥", "Celebrity news": "⭐",
    "Social media trends": "📲", "Humor": "😄",
]

// MARK: - String Helpers

private extension String {
    /// Capitalizes the first letter of each word (e.g. "Winter sports" → "Winter Sports").
    var titleCased: String {
        self.split(separator: " ").map { word in
            // Preserve acronyms/uppercase words like "MMA", "TV", "DJ"
            if word == word.uppercased() && word.count > 1 { return String(word) }
            return word.prefix(1).uppercased() + word.dropFirst()
        }.joined(separator: " ")
    }
}

// MARK: - Local Category Names (categories with location-specific content)

/// Categories that have "Near you" chips and location-dependent entities.
/// National categories like TV & movies, Trending & memes, etc. are excluded.
private let localCategoryNames: Set<String> = [
    "Sports", "Food & drink", "Music & audio",
    "Home & garden", "Animals & pets", "Lifestyle",
    "Vehicles & transportation"
]

// MARK: - Location Entity Overrides

/// City-specific entity replacements for local subcategories.
/// Default (Palo Alto / Bay Area) entities are defined in the taxonomy below.
private let locationEntityOverrides: [String: [String: [String]]] = [
    "Palo Alto": [
        // Sports (already default in taxonomy, but override ensures Near you chip)
        "Football": ["SF 49ers", "Stanford Cardinal", "Las Vegas Raiders", "Kansas City Chiefs", "Dallas Cowboys"],
        "Basketball": ["Golden State Warriors", "Sacramento Kings", "Stanford Basketball", "LA Lakers", "Boston Celtics"],
        "Soccer": ["San Jose Earthquakes", "Bay FC", "LAFC", "Inter Miami", "Barcelona FC"],
        "Baseball": ["SF Giants", "Oakland A's", "LA Dodgers", "NY Yankees", "Chicago Cubs"],
        "Hockey": ["San Jose Sharks", "LA Kings", "Vegas Golden Knights", "Colorado Avalanche", "NHL Playoffs"],
        "Golf": ["Pebble Beach", "TPC Harding Park", "Stanford Golf Course", "PGA Tour", "LPGA"],
        "Cricket": ["Bay Area Cricket Alliance", "USA Cricket", "Silicon Valley Cricket", "IPL", "T20 World Cup"],
        "Winter sports": ["Lake Tahoe skiing", "Palisades Tahoe", "Northstar", "Heavenly", "Kirkwood"],
        // Food & drink
        "Restaurants": ["Tamarine Palo Alto", "Oren's Hummus", "Nobu Palo Alto", "Protégé", "Evvia Estiatorio"],
        "Baking": ["Manresa Bread", "Maison Alyzée", "Midwife and the Baker", "Tartine", "B. Patisserie"],
        "Food festivals": ["Palo Alto Festival of the Arts", "Mountain View Art & Wine", "Bay Area Bites", "Cupertino Fall Fest", "Menlo Park Harvest"],
        "Coffee & tea": ["Verve Coffee Palo Alto", "Blue Bottle", "Philz Coffee", "Chromatic Coffee", "Peet's University Ave"],
        "Cocktails & wine": ["The Wine Room", "Napa Valley wineries", "Ridge Vineyards", "Scratch", "Vino Locale"],
        "Street food": ["Off the Grid", "SoMa StrEat Food Park", "Bay Area food trucks", "Night markets", "Ramen pop-ups"],
        "Healthy eating": ["Sweetgreen Palo Alto", "Playa Bowl", "Pressed Juicery", "True Food Kitchen", "Whole Foods Town & Country"],
        // Music
        "Live concerts": ["Stanford Live", "The Fillmore", "Shoreline Amphitheatre", "Great American Music Hall", "Outside Lands"],
        "Classical": ["Stanford Symphony", "SF Symphony", "SF Conservatory", "Bing Concert Hall", "Community Philharmonic"],
        "Jazz": ["SF Jazz", "Club Fox", "Bach Dancing", "Kuumbwa Jazz", "Blue Note Records"],
        // Family
        "Family activities": ["Palo Alto Junior Museum", "Happy Hollow", "Bay Area Discovery Museum", "CuriOdyssey", "Children's Discovery Museum SJ"],
        "Parenting": ["Palo Alto parent groups", "Peninsula Parents", "PAMP", "Stanford Children's Health", "Local parenting classes"],
        "Baby & toddler": ["Shark's Cove Play Café", "Gymboree PA", "Music Together Palo Alto", "BabyStar classes", "Small World Preschool"],
        "Weddings": ["Stanford Memorial Church", "Thomas Fogarty Winery", "Kohl Mansion", "Nestldown", "Filoli Gardens"],
        "Family travel": ["Yosemite with kids", "Tahoe family trips", "Monterey Bay Aquarium", "Santa Cruz Beach Boardwalk", "Bay Area day trips"],
        "Elder care": ["Avenidas Senior Center", "Lytton Gardens", "Palo Alto care homes", "Stanford Hospital elder services", "Peninsula elder support"],
        // Home & garden
        "Gardening": ["Bay Area native plants", "Gamble Garden", "Master Gardeners PA", "Common Ground Garden", "SummerWinds Nursery"],
        "Real estate": ["Zillow", "Redfin", "Palo Alto housing", "Midtown listings", "Open houses"],
        "Home decor": ["Restoration Hardware PA", "Williams-Sonoma HQ", "West Elm Stanford", "Pottery Barn", "Town & Country Village shops"],
        "DIY projects": ["Palo Alto Ace Hardware", "Home Depot Mountain View", "TechShop", "Maker space classes", "Local workshops"],
        "Outdoor living": ["Bay Area patios", "Stanford campus gardens", "Backyard decks", "Landscaping", "Native plant gardens"],
        "Smart home": ["Fry's Electronics", "Best Buy Palo Alto", "Ring doorbells", "Nest thermostats", "Local smart home installers"],
        // Animals
        "Dogs": ["Mitchell Park dog run", "Esplanade dog park", "Baylands dog walk", "Palo Alto dog parks", "Shoreline Park off-leash"],
        "Cats": ["Nine Lives Foundation", "Town Cats", "Peninsula Humane Society", "Cat Connection", "Cat adoption events"],
        "Pet care": ["Adobe Animal Hospital", "Town & Country Vet", "Palo Alto Grooming", "Pet Food Express", "Peninsula pet services"],
        "Pet adoption": ["Palo Alto Animal Services", "Peninsula Humane Society", "Nine Lives Foundation", "Pets In Need", "Silicon Valley Animal Control"],
        "Wildlife": ["Baylands Nature Preserve", "Arastradero Preserve", "Foothills Park wildlife", "Bay Area birding", "Marine mammals"],
        "Birds": ["Baylands bird watching", "Foothills Park", "Arastradero trail birds", "Palo Alto Audubon", "SF Bay flyway"],
        "Aquariums": ["Monterey Bay Aquarium", "Steinhart Aquarium", "Aquarium of the Bay", "Sea Life San Jose", "Local fish stores"],
        // Lifestyle
        "Fitness": ["YMCA Palo Alto", "Bay Club", "Uforia Studios", "CrossFit Palo Alto", "Stanford gym"],
        "Beauty": ["Drybar Town & Country", "The Nail Bar PA", "Heyday Palo Alto", "Stanford Shopping salons", "Local spas"],
        "Wellness": ["Stanford Wellness", "Watercourse Way spa", "Palo Alto yoga studios", "Bay Club wellness", "Mindful Living PA"],
        "Travel": ["SFO deals", "SJC departures", "Napa weekends", "Tahoe trips", "Big Sur"],
        "Fashion": ["Stanford Shopping Center", "Town & Country Village", "Nike Palo Alto", "Lululemon University Ave", "Local boutiques"],
        // Vehicles
        "Electric vehicles": ["Tesla Palo Alto", "Rivian", "Lucid Motors", "Bay Area EV charging", "Polestar"],
    ],
    "Los Angeles": [
        // Sports
        "Football": ["LA Rams", "LA Chargers", "USC Trojans", "UCLA Bruins", "Dallas Cowboys"],
        "Basketball": ["LA Lakers", "LA Clippers", "UCLA Basketball", "USC Basketball", "Boston Celtics"],
        "Soccer": ["LAFC", "LA Galaxy", "Angel City FC", "Inter Miami", "Barcelona FC"],
        "Baseball": ["LA Dodgers", "LA Angels", "San Diego Padres", "NY Yankees", "Chicago Cubs"],
        "Hockey": ["LA Kings", "Anaheim Ducks", "Vegas Golden Knights", "Colorado Avalanche", "NHL Playoffs"],
        "Tennis": ["Indian Wells", "ATP Tour", "WTA Tour", "US Open", "Wimbledon"],
        "Golf": ["Riviera Country Club", "PGA Tour", "LPGA", "TPC Valencia", "Pelican Hill"],
        "MMA & boxing": ["UFC at Crypto.com Arena", "Bellator", "PFL", "Top Rank Boxing", "ONE Championship"],
        // Food & drink
        "Restaurants": ["Bestia", "Republique", "Gjelina", "Nobu Malibu", "Providence"],
        "Baking": ["Porto's Bakery", "Tartine LA", "Bottega Louie", "Bouchon Bakery", "Sycamore Kitchen"],
        "Food festivals": ["LA Food & Wine", "Smorgasburg LA", "626 Night Market", "Taste of LA", "Street Food Cinema"],
        "Coffee & tea": ["Intelligentsia", "Blue Bottle Venice", "Verve Coffee", "Alfred", "Stumptown"],
        "Cocktails & wine": ["Death & Co LA", "Bar Marmont", "Temecula wineries", "Thunderbolt", "Dante LA"],
        "Street food": ["Grand Central Market", "Smorgasburg", "LA food trucks", "Night markets", "Taco stands"],
        "Healthy eating": ["Sweetgreen", "Erewhon", "Moon Juice", "Pressed Juicery", "True Food Kitchen"],
        // Music
        "Live concerts": ["Hollywood Bowl", "The Greek Theatre", "The Forum", "Coachella", "The Troubadour"],
        "Classical": ["LA Philharmonic", "Disney Concert Hall", "Colburn School", "Pasadena Symphony", "Long Beach Symphony"],
        "Jazz": ["Blue Whale Jazz", "Catalina Jazz Club", "LA jazz scene", "Kamasi Washington", "Sam First"],
        // Family
        "Family activities": ["Griffith Observatory", "LA Zoo", "Santa Monica Pier", "Natural History Museum", "California Science Center"],
        "Parenting": ["LA parent groups", "Mommy & Me WeHo", "Cedars-Sinai pediatrics", "UCLA Health kids", "South Bay parents"],
        "Baby & toddler": ["Pump Station & Nurtury", "The Coop Studio", "LA Shark Tank Play Café", "My Gym Brentwood", "Bright Child Music"],
        "Weddings": ["Malibu Rocky Oaks", "Hummingbird Nest Ranch", "Vibiana DTLA", "Calamigos Ranch", "Rancho Las Lomas"],
        "Family travel": ["Disneyland day trips", "Big Bear with kids", "San Diego Zoo", "Legoland", "Santa Barbara family trips"],
        "Elder care": ["WISE & Healthy Aging", "LA Caregiver Resource", "UCLA geriatrics", "Senior centers LA", "Keiro"],
        // Home & garden
        "Gardening": ["SoCal native plants", "Theodore Payne Foundation", "Armstrong Garden Centers", "Drought-tolerant gardens", "Raised beds"],
        "Real estate": ["Zillow", "Redfin", "LA housing market", "West LA listings", "Open houses"],
        "Home decor": ["HD Buttercup", "West Elm", "CB2", "Restoration Hardware", "Pottery Barn"],
        "DIY projects": ["Home Depot Hollywood", "LA Maker Space", "Workshop LA", "Woodcraft Supply", "Local classes"],
        "Outdoor living": ["LA patios", "Outdoor dining setups", "Fire pits", "Landscaping", "Drought-tolerant gardens"],
        // Animals
        "Dogs": ["Runyon Canyon", "Laurel Canyon Dog Park", "Rosie's Dog Beach", "LA dog parks", "Griffith Park dog areas"],
        "Cats": ["Catfé LA", "spcaLA", "Best Friends LA", "Kitten Rescue", "Cat adoption events"],
        "Pet care": ["LA vet clinics", "VCA West LA", "Healthy Spot", "Pet food reviews", "Training tips"],
        "Pet adoption": ["spcaLA", "Best Friends LA", "Pasadena Humane", "Wags & Walks", "LA Animal Services"],
        "Wildlife": ["LA wildlife", "Channel Islands marine life", "Griffith Park wildlife", "Bird watching", "Marine mammals"],
        "Aquariums": ["Aquarium of the Pacific", "Heal the Bay Aquarium", "Cabrillo Marine Aquarium", "Local fish stores", "Tide pools Malibu"],
        // Lifestyle
        "Fitness": ["Equinox West Hollywood", "Peloton", "CrossFit", "Barry's", "Orange Theory"],
        "Beauty": ["Drybar West Hollywood", "Kate Somerville", "The Now Massage", "Beverly Hills spas", "Local salons"],
        "Wellness": ["Moon Juice", "Shape House", "The Den Meditation", "Alo Yoga", "Sage Yoga"],
        "Fashion": ["The Grove", "Rodeo Drive", "Nike", "Lululemon", "Zara"],
        "Travel": ["LAX deals", "Palm Springs weekends", "Big Bear trips", "Santa Barbara", "Joshua Tree"],
        // Vehicles
        "Electric vehicles": ["Tesla", "Rivian", "Lucid Motors", "Polestar", "LA EV charging"],
        "Racing": ["Formula 1", "NASCAR", "IndyCar", "Auto Club Speedway", "Long Beach Grand Prix"],
    ],
    "San Francisco": [
        // Sports
        "Football": ["SF 49ers", "Stanford Cardinal", "Cal Bears", "Las Vegas Raiders", "Kansas City Chiefs"],
        "Basketball": ["Golden State Warriors", "Sacramento Kings", "Stanford Basketball", "Cal Basketball", "Boston Celtics"],
        "Soccer": ["San Jose Earthquakes", "Bay FC", "LAFC", "Inter Miami", "Barcelona FC"],
        "Baseball": ["SF Giants", "Oakland A's", "LA Dodgers", "NY Yankees", "Chicago Cubs"],
        "Hockey": ["San Jose Sharks", "LA Kings", "Vegas Golden Knights", "Colorado Avalanche", "NHL Playoffs"],
        // Food & drink
        "Restaurants": ["State Bird Provisions", "Zuni Cafe", "House of Prime Rib", "Tartine", "Lazy Bear"],
        "Baking": ["Tartine Bakery", "B. Patisserie", "Arsicault Bakery", "Mr. Holmes Bakehouse", "Craftsman & Wolves"],
        "Food festivals": ["SF Street Food Fest", "Eat Drink SF", "Outside Lands", "Ghirardelli Chocolate Fest", "Ferry Building"],
        "Coffee & tea": ["Ritual Coffee", "Blue Bottle", "Sightglass", "Philz Coffee", "Four Barrel"],
        "Cocktails & wine": ["Napa Valley wineries", "Sonoma Coast", "Trick Dog", "ABV", "Smuggler's Cove"],
        "Street food": ["Off the Grid SF", "SoMa StrEat Food Park", "SF food trucks", "Night markets", "Ramen pop-ups"],
        "Healthy eating": ["Sweetgreen SF", "Nourish Cafe", "Pressed Juicery", "True Food Kitchen", "Rainbow Grocery"],
        // Music
        "Live concerts": ["The Fillmore", "Great American Music Hall", "Outside Lands", "Chase Center", "The Warfield"],
        "Classical": ["SF Symphony", "Stanford Lively Arts", "SF Conservatory", "Herbst Theatre", "Kronos Quartet"],
        "Jazz": ["SF Jazz", "Club Deluxe", "Black Cat", "Café du Nord", "Doc's Lab"],
        // Family
        "Family activities": ["Exploratorium", "California Academy of Sciences", "Children's Creativity Museum", "SF Zoo", "Bay Area Discovery Museum"],
        "Parenting": ["SF parent groups", "Golden Gate Mothers", "CPMC pediatrics", "UCSF children's", "Noe Valley parents"],
        "Baby & toddler": ["Recess SF", "Peekadoodle", "Gymboree SF", "Music Together SF", "Rhythm & Rolls"],
        "Weddings": ["City Hall SF", "Presidio Officers' Club", "Golden Gate Club", "Terra Gallery", "Bently Reserve"],
        "Family travel": ["Yosemite with kids", "Tahoe family trips", "Family camping", "Monterey Bay Aquarium", "Bay Area day trips"],
        "Elder care": ["On Lok Senior Services", "IHSS SF", "Institute on Aging", "SF senior centers", "Bay Area elder care"],
        // Home & garden
        "Gardening": ["Bay Area native plants", "SF Botanical Garden", "Master Gardeners", "Urban farming", "Raised beds"],
        "Real estate": ["Zillow", "Redfin", "SF housing market", "Bay Area listings", "Open houses"],
        "Home decor": ["West Elm", "CB2", "Heath Ceramics", "Paxton Gate", "FLAX art & design"],
        "DIY projects": ["Cole Hardware", "Workshop SF", "TechShop", "SF Maker Space", "Local classes"],
        "Outdoor living": ["Bay Area patios", "Rooftop gardens", "Fire pits", "Landscaping", "Drought-tolerant gardens"],
        // Animals
        "Dogs": ["Fort Funston", "Crissy Field", "McLaren Park", "SF dog parks", "Ocean Beach off-leash"],
        "Cats": ["SF SPCA", "Cat Town Café", "Milo Foundation", "Give Me Shelter", "Cat adoption events"],
        "Pet care": ["SF SPCA vet", "Mission Pet Hospital", "Healthy Spot", "Pet Food Express", "Training classes"],
        "Pet adoption": ["SF SPCA", "Milo Foundation", "Give Me Shelter", "Rocket Dog Rescue", "Wonder Dog Rescue"],
        "Wildlife": ["Bay Area wildlife", "Monterey Bay marine life", "Point Reyes", "Bird watching", "Marine mammals"],
        "Aquariums": ["Steinhart Aquarium", "Aquarium of the Bay", "Monterey Bay Aquarium", "Birch Aquarium", "Local fish stores"],
        // Lifestyle
        "Fitness": ["Equinox SF", "Peloton", "CrossFit", "Barry's", "Orange Theory"],
        "Beauty": ["Drybar Fillmore", "Heyday SF", "Sephora Powell", "Local spas", "Burke Williams"],
        "Wellness": ["Onsen Bath House", "Kabuki Springs", "Yoga Tree", "Spirit Rock", "The Center SF"],
        "Fashion": ["Union Square shops", "Nike", "Lululemon", "Zara", "Hayes Valley boutiques"],
        "Travel": ["SFO deals", "Napa weekends", "Tahoe trips", "Big Sur", "Mendocino"],
        // Vehicles
        "Electric vehicles": ["Tesla", "Rivian", "Lucid Motors", "Polestar", "Bay Area EV charging"],
    ],
    "New York": [
        // Sports
        "Football": ["NY Giants", "NY Jets", "Syracuse Orange", "Rutgers Scarlet Knights", "Dallas Cowboys"],
        "Basketball": ["NY Knicks", "Brooklyn Nets", "Syracuse Basketball", "St. John's", "Boston Celtics"],
        "Soccer": ["NYCFC", "NY Red Bulls", "NJ/NY Gotham FC", "Inter Miami", "Barcelona FC"],
        "Baseball": ["NY Yankees", "NY Mets", "LA Dodgers", "Boston Red Sox", "Chicago Cubs"],
        "Hockey": ["NY Rangers", "NY Islanders", "NJ Devils", "Buffalo Sabres", "NHL Playoffs"],
        // Food & drink
        "Restaurants": ["Le Bernardin", "Peter Luger", "Carbone", "Di Fara Pizza", "Eleven Madison Park"],
        "Baking": ["Levain Bakery", "Dominique Ansel", "Breads Bakery", "Magnolia Bakery", "L'Appartement 4F"],
        "Food festivals": ["Smorgasburg NYC", "NYC Wine & Food Fest", "Vendy Awards", "Queens Night Market", "Taste of Times Square"],
        "Coffee & tea": ["Joe Coffee", "Stumptown", "Blue Bottle", "Devocion", "Birch Coffee"],
        "Cocktails & wine": ["Attaboy", "Death & Co", "Employees Only", "NY wine bars", "PDT"],
        "Street food": ["Halal carts", "Smorgasburg", "NYC food trucks", "Night markets", "Pizza spots"],
        "Healthy eating": ["Sweetgreen", "By Chloe", "Juice Press", "Hu Kitchen", "Dig Inn"],
        // Music
        "Live concerts": ["Madison Square Garden", "Brooklyn Steel", "Radio City Music Hall", "Governors Ball", "Terminal 5"],
        "Classical": ["NY Philharmonic", "Carnegie Hall", "Lincoln Center", "Metropolitan Opera", "Juilliard"],
        "Jazz": ["Blue Note NYC", "Village Vanguard", "Jazz at Lincoln Center", "Smalls Jazz Club", "Birdland"],
        // Family
        "Family activities": ["American Museum of Natural History", "Central Park Zoo", "Brooklyn Children's Museum", "Intrepid Museum", "NY Hall of Science"],
        "Parenting": ["NYC parent groups", "Park Slope Parents", "NYU Langone pediatrics", "Upper West Side moms", "Brooklyn families"],
        "Baby & toddler": ["The Baby Show NYC", "Shark Tank NYC Play", "Music Together Brooklyn", "Gymboree UWS", "92Y baby classes"],
        "Weddings": ["The Plaza Hotel", "Brooklyn Botanic Garden", "Liberty House", "Prospect Park Boathouse", "The Foundry"],
        "Family travel": ["Hamptons with kids", "Bear Mountain", "Coney Island", "Montauk", "Hudson Valley day trips"],
        "Elder care": ["NYC Aging Services", "JASA", "Visiting Nurse Service", "NYC senior centers", "NY elder care programs"],
        // Home & garden
        "Gardening": ["NYC community gardens", "Brooklyn Botanic Garden", "Container gardening", "Rooftop gardens", "Window box gardens"],
        "Real estate": ["Zillow", "StreetEasy", "NYC housing market", "Brooklyn listings", "Open houses"],
        "Home decor": ["ABC Carpet & Home", "West Elm", "CB2", "Brooklyn Flea", "Design Within Reach"],
        "DIY projects": ["Home Depot Chelsea", "Brooklyn Maker Space", "3rd Ward", "Skillshare NYC", "Local workshops"],
        // Animals
        "Dogs": ["Central Park", "Prospect Park", "Tompkins Square", "NYC dog parks", "Hudson River Park"],
        "Cats": ["Meow Parlour", "Koneko Cat Café", "ASPCA NYC", "Animal Care Centers", "Cat adoption events"],
        "Pet care": ["ASPCA NYC", "Bond Vet", "Small Door Vet", "Pet food delivery NYC", "Training classes"],
        "Pet adoption": ["ASPCA NYC", "Animal Care Centers", "Muddy Paws Rescue", "Social Tees", "Best Friends NYC"],
        "Wildlife": ["Central Park birding", "Jamaica Bay wildlife", "Bronx Zoo", "NY Aquarium", "Bear Mountain wildlife"],
        "Aquariums": ["NY Aquarium", "Bronx Zoo aquatics", "Long Island Aquarium", "SeaQuest NJ", "Local fish stores"],
        // Lifestyle
        "Fitness": ["Equinox NYC", "Peloton", "CrossFit", "Barry's Bootcamp", "SoulCycle"],
        "Beauty": ["Drybar Flatiron", "Heyday NYC", "Sephora SoHo", "Aire Ancient Baths", "Bliss Spa"],
        "Wellness": ["MNDFL Meditation", "Y7 Studio", "Aire Ancient Baths", "The Well", "Sojo Spa"],
        "Fashion": ["SoHo shops", "Fifth Avenue", "Nike", "Lululemon", "Brooklyn boutiques"],
        "Travel": ["JFK deals", "Hamptons weekends", "Hudson Valley trips", "Fire Island", "Catskills getaways"],
        // Vehicles
        "Electric vehicles": ["Tesla", "Rivian", "Lucid Motors", "Polestar", "NYC EV charging"],
    ],
    "Denver": [
        // Sports
        "Football": ["Denver Broncos", "Colorado Buffaloes", "Colorado State Rams", "Kansas City Chiefs", "Dallas Cowboys"],
        "Basketball": ["Denver Nuggets", "Colorado Buffaloes", "Air Force Falcons", "LA Lakers", "Boston Celtics"],
        "Soccer": ["Colorado Rapids", "Inter Miami", "LAFC", "Portland Timbers", "Barcelona FC"],
        "Baseball": ["Colorado Rockies", "LA Dodgers", "NY Yankees", "Chicago Cubs", "SF Giants"],
        "Hockey": ["Colorado Avalanche", "Vegas Golden Knights", "Minnesota Wild", "Dallas Stars", "NHL Playoffs"],
        "Winter sports": ["Vail skiing", "Breckenridge", "Keystone", "Copper Mountain", "Arapahoe Basin"],
        // Food & drink
        "Restaurants": ["Fruition", "Beckon", "Guard and Grace", "Tavernetta", "Morin"],
        "Baking": ["Rosenberg's Bagels", "Reunion Bread", "Whipped Creamery", "Azucar Bakery", "Cake Crumbs"],
        "Food festivals": ["Denver Restaurant Week", "Great American Beer Fest", "Taste of Colorado", "Denver Food + Wine Fest", "Cherry Creek Food & Wine"],
        "Coffee & tea": ["Huckleberry Coffee", "Corvus Coffee", "Sweet Bloom", "Boxcar Coffee", "Little Owl"],
        "Cocktails & wine": ["Williams & Graham", "Death & Co Denver", "Colorado wineries", "Punch Bowl Social", "Finn's Manor"],
        "Street food": ["Denver food trucks", "South Pearl Street Market", "RiNo food halls", "Night markets", "Taco pop-ups"],
        "Healthy eating": ["Vital Root", "True Food Kitchen Denver", "Flower Child", "Native Foods", "Whole Foods RiNo"],
        // Music
        "Live concerts": ["Red Rocks", "Ball Arena", "The Ogden", "Bluebird Theater", "Mission Ballroom"],
        "Classical": ["Colorado Symphony", "Central City Opera", "Denver Center for Arts", "Boettcher Concert Hall", "Aspen Music Festival"],
        "Jazz": ["Dazzle Jazz", "Nocturne Jazz", "Denver jazz scene", "El Chapultepec", "Ophelia's"],
        // Family
        "Family activities": ["Denver Children's Museum", "Denver Zoo", "Denver Museum of Nature & Science", "Elitch Gardens", "Downtown Aquarium"],
        "Parenting": ["Denver parent groups", "Colorado Parent", "Children's Hospital Colorado", "Denver Families", "Highlands Ranch parents"],
        "Baby & toddler": ["Kids Kourt", "My Gym Denver", "Gymboree Denver", "Music Together Denver", "WonderLab play space"],
        "Weddings": ["Denver Botanic Gardens", "Wellshire Event Center", "Moss Denver", "The Manor House", "Arrowhead Golf Club"],
        "Family travel": ["Rocky Mountain NP with kids", "Breckenridge family trips", "Estes Park", "Garden of the Gods", "Colorado Springs day trips"],
        "Elder care": ["Denver Regional Council of Governments", "Jewish Family Service", "Denver senior centers", "UCHealth elder services", "Colorado elder care"],
        // Home & garden
        "Gardening": ["Colorado native plants", "Denver Botanic Gardens", "High altitude gardening", "Xeriscape gardens", "Tagawa Gardens"],
        "Real estate": ["Zillow", "Redfin", "Denver housing market", "RiNo listings", "Open houses"],
        "Home decor": ["West Elm Denver", "Restoration Hardware", "Rare Finds", "Decade", "2Modern"],
        "DIY projects": ["Home Depot Glendale", "Denver Tool Library", "Maker space Denver", "Woodcraft", "Local workshops"],
        "Outdoor living": ["Denver patios", "Mountain deck setups", "Fire pits", "Landscaping", "Xeriscape gardens"],
        // Animals
        "Dogs": ["Cherry Creek Dog Park", "Chatfield State Park", "Berkeley Park", "Denver dog parks", "Wash Park"],
        "Cats": ["Denver Dumb Friends League", "MaxFund", "Cat Care Society", "Foothills Animal Shelter", "Cat adoption events"],
        "Pet care": ["Denver Dumb Friends League", "Planned Pethood", "VCA Alameda East", "Pet food stores", "Training classes"],
        "Pet adoption": ["Denver Dumb Friends League", "MaxFund", "National Mill Dog Rescue", "PawsCo", "Foothills Animal Shelter"],
        "Wildlife": ["Rocky Mountain wildlife", "Elk viewing", "Rocky Mountain NP", "Bird watching", "Bear Creek wildlife"],
        "Aquariums": ["Downtown Aquarium Denver", "Denver Zoo aquatics", "Butterfly Pavilion", "Colorado fish stores", "Pueblo Zoo"],
        // Lifestyle
        "Fitness": ["Equinox Denver", "Peloton", "CrossFit", "Orange Theory", "Colorado Athletic Club"],
        "Beauty": ["Drybar Cherry Creek", "Heyday Denver", "Woodhouse Day Spa", "Local salons", "Cherry Creek spas"],
        "Wellness": ["Avanti Yoga", "CorePower Yoga Denver", "True Nature Healing Arts", "Float therapy Denver", "Denver wellness studios"],
        "Fashion": ["Cherry Creek Shopping", "Nike", "Lululemon", "Zara", "Larimer Square boutiques"],
        "Travel": ["DIA deals", "Breckenridge weekends", "Aspen trips", "Rocky Mountain NP", "Glenwood Springs"],
        // Vehicles
        "Electric vehicles": ["Tesla", "Rivian", "Lucid Motors", "Polestar", "Denver EV charging"],
    ]
]

// MARK: - Taxonomy Data (Region: Palo Alto / Bay Area)

private let allCategories: [InterestCategory] = [
    InterestCategory(id: 1, emoji: "⚽", name: "Sports", subcategories: [
        InterestSubcategory(name: "Football", entities: [
            "SF 49ers", "Stanford Cardinal", "Las Vegas Raiders", "Kansas City Chiefs", "Dallas Cowboys"
        ]),
        InterestSubcategory(name: "Basketball", entities: [
            "Golden State Warriors", "Sacramento Kings", "Stanford Basketball", "LA Lakers", "Boston Celtics"
        ]),
        InterestSubcategory(name: "Soccer", entities: [
            "San Jose Earthquakes", "Bay FC", "LAFC", "Inter Miami", "Barcelona FC"
        ]),
        InterestSubcategory(name: "Baseball", entities: [
            "SF Giants", "Oakland A's", "LA Dodgers", "NY Yankees", "Chicago Cubs"
        ]),
        InterestSubcategory(name: "Tennis", entities: [
            "ATP Tour", "WTA Tour", "US Open", "Wimbledon", "Indian Wells"
        ]),
        InterestSubcategory(name: "Golf", entities: [
            "Pebble Beach", "PGA Tour", "LPGA", "Augusta National", "TPC Harding Park"
        ]),
        InterestSubcategory(name: "Hockey", entities: [
            "San Jose Sharks", "LA Kings", "Vegas Golden Knights", "Colorado Avalanche", "NHL Playoffs"
        ]),
        InterestSubcategory(name: "Cricket", entities: [
            "Bay Area Cricket Alliance", "USA Cricket", "Mumbai Indians", "IPL", "T20 World Cup"
        ]),
        InterestSubcategory(name: "Winter sports", entities: [
            "Lake Tahoe skiing", "US Ski Team", "X Games", "Olympics", "Palisades Tahoe"
        ]),
        InterestSubcategory(name: "MMA & boxing", entities: [
            "UFC", "Bellator", "PFL", "Top Rank Boxing", "ONE Championship"
        ])
    ]),
    InterestCategory(id: 2, emoji: "🎬", name: "TV & movies", subcategories: [
        InterestSubcategory(name: "Action", entities: [
            "Marvel", "DC", "Mission Impossible", "John Wick", "Fast & Furious"
        ]),
        InterestSubcategory(name: "Comedy", entities: [
            "Ted Lasso", "Abbott Elementary", "The Office", "Schitt's Creek", "Only Murders"
        ]),
        InterestSubcategory(name: "Drama", entities: [
            "The Bear", "Succession", "Breaking Bad", "Yellowstone", "The Crown"
        ]),
        InterestSubcategory(name: "Sci-fi", entities: [
            "Star Wars", "Dune", "Black Mirror", "The Expanse", "Stranger Things"
        ]),
        InterestSubcategory(name: "Reality TV", entities: [
            "Survivor", "The Bachelor", "Love Island", "Below Deck", "Top Chef"
        ]),
        InterestSubcategory(name: "Documentaries", entities: [
            "Planet Earth", "The Last Dance", "Chef's Table", "30 for 30", "Making a Murderer"
        ]),
        InterestSubcategory(name: "Anime", entities: [
            "Demon Slayer", "One Piece", "Attack on Titan", "Jujutsu Kaisen", "My Hero Academia"
        ]),
        InterestSubcategory(name: "Horror", entities: [
            "A24 Horror", "Blumhouse", "The Conjuring", "Scream", "Get Out"
        ]),
        InterestSubcategory(name: "Thriller", entities: [
            "Severance", "Mr. Robot", "Ozark", "Mindhunter", "You"
        ]),
        InterestSubcategory(name: "Romance", entities: [
            "Bridgerton", "Emily in Paris", "Pride & Prejudice", "The Notebook", "When Harry Met Sally"
        ])
    ]),
    InterestCategory(id: 3, emoji: "🍕", name: "Food & drink", subcategories: [
        InterestSubcategory(name: "Cooking", entities: [
            "Gordon Ramsay", "Bon Appetit", "Tasty", "Serious Eats", "NYT Cooking"
        ]),
        InterestSubcategory(name: "Baking", entities: [
            "Great British Bake Off", "Sally's Baking", "King Arthur", "Dessert Person", "Milk Bar"
        ]),
        InterestSubcategory(name: "Restaurants", entities: [
            "Tamarine Palo Alto", "Oren's Hummus", "Nobu Palo Alto", "Evvia", "Sundance Steakhouse"
        ]),
        InterestSubcategory(name: "Recipes", entities: [
            "Half Baked Harvest", "Minimalist Baker", "Budget Bytes", "Pinch of Yum", "Delish"
        ]),
        InterestSubcategory(name: "Food festivals", entities: [
            "Palo Alto Chili Cook-Off", "SF Street Food Fest", "Eat Drink SF", "Napa Food & Wine", "Outside Lands"
        ]),
        InterestSubcategory(name: "Coffee & tea", entities: [
            "Philz Coffee", "Blue Bottle", "Verve Coffee", "Peet's", "Chromatic Coffee"
        ]),
        InterestSubcategory(name: "Cocktails & wine", entities: [
            "Napa Valley wineries", "Sonoma Coast", "Wine Folly", "Punch Drink", "Bay Area cocktail bars"
        ]),
        InterestSubcategory(name: "Street food", entities: [
            "Off the Grid SF", "SoMa StrEat Food Park", "Bay Area food trucks", "Night markets", "Ramen pop-ups"
        ]),
        InterestSubcategory(name: "Healthy eating", entities: [
            "Sweetgreen", "Tender Greens", "Daily Harvest", "Whole Foods", "Sakara Life"
        ]),
        InterestSubcategory(name: "Meal prep", entities: [
            "Batch cooking", "Freezer meals", "Weekly meal plans", "Budget-friendly prep", "Meal prep ideas"
        ])
    ]),
    InterestCategory(id: 4, emoji: "🎵", name: "Music & audio", subcategories: [
        InterestSubcategory(name: "Pop", entities: [
            "Taylor Swift", "Billie Eilish", "The Weeknd", "Dua Lipa", "Harry Styles"
        ]),
        InterestSubcategory(name: "Rock", entities: [
            "Foo Fighters", "Arctic Monkeys", "Red Hot Chili Peppers", "Imagine Dragons", "The Killers"
        ]),
        InterestSubcategory(name: "Hip-hop", entities: [
            "Kendrick Lamar", "Drake", "J. Cole", "Tyler the Creator", "SZA"
        ]),
        InterestSubcategory(name: "R&B", entities: [
            "Frank Ocean", "H.E.R.", "Daniel Caesar", "Summer Walker", "Usher"
        ]),
        InterestSubcategory(name: "Country", entities: [
            "Morgan Wallen", "Luke Combs", "Zach Bryan", "Chris Stapleton", "Kacey Musgraves"
        ]),
        InterestSubcategory(name: "Electronic", entities: [
            "Calvin Harris", "Skrillex", "Disclosure", "ODESZA", "Deadmau5"
        ]),
        InterestSubcategory(name: "Classical", entities: [
            "SF Symphony", "Stanford Lively Arts", "LA Philharmonic", "Vienna Philharmonic", "BBC Proms"
        ]),
        InterestSubcategory(name: "Jazz", entities: [
            "SF Jazz", "Snarky Puppy", "Kamasi Washington", "Robert Glasper", "Blue Note Records"
        ]),
        InterestSubcategory(name: "Podcasts", entities: [
            "The Daily", "Joe Rogan", "Serial", "Conan O'Brien", "How I Built This"
        ]),
        InterestSubcategory(name: "Live concerts", entities: [
            "Shoreline Amphitheatre", "The Fillmore", "Outside Lands", "BottleRock Napa", "Stanford Live"
        ])
    ]),
    InterestCategory(id: 5, emoji: "❤️", name: "Family & relationships", subcategories: [
        InterestSubcategory(name: "Parenting", entities: [
            "Scary Mommy", "Fatherly", "What to Expect", "Today's Parent", "Parent Magazine"
        ]),
        InterestSubcategory(name: "Family activities", entities: [
            "Bay Area Discovery Museum", "Palo Alto Junior Museum", "Happy Hollow", "Monterey Bay Aquarium", "California Academy of Sciences"
        ]),
        InterestSubcategory(name: "Relationship advice", entities: [
            "Gottman Institute", "Esther Perel", "Love Languages", "Couples therapy", "Relate"
        ]),
        InterestSubcategory(name: "Weddings", entities: [
            "The Knot", "Zola", "Bay Area venues", "Wedding Wire", "Brides"
        ]),
        InterestSubcategory(name: "Baby & toddler", entities: [
            "BabyCenter", "The Bump", "Hatch Baby", "Lovevery", "What to Expect app"
        ]),
        InterestSubcategory(name: "Teen parenting", entities: [
            "Common Sense Media", "Screen time tips", "College prep", "Teen mental health", "Parenting teens"
        ]),
        InterestSubcategory(name: "Family travel", entities: [
            "Yosemite with kids", "Tahoe family trips", "Family camping", "Road trip ideas", "Bay Area day trips"
        ]),
        InterestSubcategory(name: "Elder care", entities: [
            "AARP", "Senior living", "Caregiver support", "Elder law", "Aging in place"
        ])
    ]),
    InterestCategory(id: 6, emoji: "🏡", name: "Home & garden", subcategories: [
        InterestSubcategory(name: "Home decor", entities: [
            "Pottery Barn", "West Elm", "CB2", "Restoration Hardware", "IKEA"
        ]),
        InterestSubcategory(name: "Gardening", entities: [
            "Bay Area native plants", "Sunset Magazine", "Master Gardeners", "Container gardening", "Raised beds"
        ]),
        InterestSubcategory(name: "DIY projects", entities: [
            "Home Depot workshops", "Maker Faire", "Pinterest DIY", "YouTube tutorials", "Tool reviews"
        ]),
        InterestSubcategory(name: "Real estate", entities: [
            "Zillow", "Redfin", "Palo Alto housing", "Bay Area market", "Open houses"
        ]),
        InterestSubcategory(name: "Organization", entities: [
            "The Home Edit", "Marie Kondo", "Container Store", "Closet organizers", "Decluttering"
        ]),
        InterestSubcategory(name: "Interior design", entities: [
            "Architectural Digest", "Dwell", "Houzz", "HGTV", "Interior Design Magazine"
        ]),
        InterestSubcategory(name: "Outdoor living", entities: [
            "Bay Area patios", "Outdoor dining setups", "Fire pits", "Landscaping", "Drought-tolerant gardens"
        ]),
        InterestSubcategory(name: "Smart home", entities: [
            "Ring", "Nest", "Apple HomeKit", "Smart lighting", "Home automation"
        ])
    ]),
    InterestCategory(id: 7, emoji: "🐶", name: "Animals & pets", subcategories: [
        InterestSubcategory(name: "Dogs", entities: [
            "Golden Retrievers", "Labrador Retrievers", "French Bulldogs", "Palo Alto dog parks", "Bay Area dog beaches"
        ]),
        InterestSubcategory(name: "Cats", entities: [
            "Tabby cats", "Siamese", "Maine Coons", "Cat cafes", "Indoor cat tips"
        ]),
        InterestSubcategory(name: "Pet care", entities: [
            "Palo Alto vet clinics", "Pet insurance", "Grooming", "Pet food reviews", "Training tips"
        ]),
        InterestSubcategory(name: "Wildlife", entities: [
            "Bay Area wildlife", "Monterey Bay marine life", "Point Reyes", "Bird watching", "Marine mammals"
        ]),
        InterestSubcategory(name: "Aquariums", entities: [
            "Monterey Bay Aquarium", "Fishkeeping", "Reef tanks", "Aquascaping", "Freshwater setups"
        ]),
        InterestSubcategory(name: "Birds", entities: [
            "Bay Area birding", "Audubon Society", "Parrots", "Backyard birds", "Bird photography"
        ]),
        InterestSubcategory(name: "Horses", entities: [
            "Woodside horse country", "Bay Area equestrian", "Trail riding", "Horse shows", "Dressage"
        ]),
        InterestSubcategory(name: "Pet adoption", entities: [
            "Peninsula Humane Society", "Palo Alto Animal Shelter", "SPCA", "Rescue dogs", "Foster care"
        ])
    ]),
    InterestCategory(id: 8, emoji: "✨", name: "Lifestyle", subcategories: [
        InterestSubcategory(name: "Fashion", entities: [
            "Stanford Shopping Center", "Nike", "Lululemon", "Zara", "H&M"
        ]),
        InterestSubcategory(name: "Fitness", entities: [
            "Equinox Palo Alto", "Peloton", "CrossFit", "Bay Club", "Orange Theory"
        ]),
        InterestSubcategory(name: "Wellness", entities: [
            "Headspace", "Calm", "Mindbodygreen", "Goop", "Well+Good"
        ]),
        InterestSubcategory(name: "Beauty", entities: [
            "Sephora", "Glossier", "Fenty Beauty", "The Ordinary", "Ulta"
        ]),
        InterestSubcategory(name: "Travel", entities: [
            "SFO deals", "Napa weekends", "Tahoe trips", "Big Sur", "Bay Area getaways"
        ]),
        InterestSubcategory(name: "Motivation", entities: [
            "Tony Robbins", "Brené Brown", "James Clear", "Simon Sinek", "Mel Robbins"
        ]),
        InterestSubcategory(name: "Spirituality", entities: [
            "Insight Timer", "Bay Area yoga studios", "Meditation centers", "Mindfulness", "Spirit Rock"
        ]),
        InterestSubcategory(name: "Minimalism", entities: [
            "The Minimalists", "Becoming Minimalist", "Zero waste", "Capsule wardrobe", "Tiny homes"
        ])
    ]),
    InterestCategory(id: 9, emoji: "🚗", name: "Vehicles & transportation", subcategories: [
        InterestSubcategory(name: "Cars", entities: [
            "Tesla", "Toyota", "Honda", "BMW", "Mercedes-Benz"
        ]),
        InterestSubcategory(name: "Classic cars", entities: [
            "Hagerty", "Bring a Trailer", "Cars & Coffee", "Concours d'Elegance", "Jay Leno's Garage"
        ]),
        InterestSubcategory(name: "Car maintenance", entities: [
            "AutoZone", "O'Reilly Auto", "Palo Alto auto shops", "ChrisFix", "Mobile mechanics"
        ]),
        InterestSubcategory(name: "Motorcycles", entities: [
            "Harley-Davidson", "Ducati", "Indian Motorcycle", "Bay Area rides", "Highway 1"
        ]),
        InterestSubcategory(name: "Trucks", entities: [
            "Ford F-150", "RAM", "Chevrolet Silverado", "Toyota Tacoma", "Rivian R1T"
        ]),
        InterestSubcategory(name: "Electric vehicles", entities: [
            "Tesla", "Rivian", "Lucid Motors", "Polestar", "Bay Area EV charging"
        ]),
        InterestSubcategory(name: "Racing", entities: [
            "Formula 1", "NASCAR", "IndyCar", "Laguna Seca", "Sonoma Raceway"
        ]),
        InterestSubcategory(name: "Off-road", entities: [
            "Overlanding", "Jeep", "Toyota 4Runner", "Bay Area trails", "Hollister Hills"
        ])
    ]),
    InterestCategory(id: 10, emoji: "🔥", name: "Trending & memes", subcategories: [
        InterestSubcategory(name: "Memes", entities: [
            "Reddit memes", "Instagram memes", "TikTok memes", "Twitter/X memes", "Meme accounts"
        ]),
        InterestSubcategory(name: "Viral challenges", entities: [
            "TikTok challenges", "YouTube trends", "Reels trends", "Dance trends", "Social challenges"
        ]),
        InterestSubcategory(name: "Current events", entities: [
            "AP News", "NPR", "Reuters", "Bay Area news", "Tech industry news"
        ]),
        InterestSubcategory(name: "Pop culture", entities: [
            "Entertainment Weekly", "People", "Variety", "E! News", "TMZ"
        ]),
        InterestSubcategory(name: "Internet trends", entities: [
            "Product Hunt", "Hacker News", "Reddit popular", "Trending hashtags", "Tech Twitter"
        ]),
        InterestSubcategory(name: "Celebrity news", entities: [
            "Hollywood Reporter", "Deadline", "Celebrity interviews", "Red carpet", "Award shows"
        ]),
        InterestSubcategory(name: "Social media trends", entities: [
            "TikTok creators", "Instagram trends", "YouTube trending", "Twitter/X moments", "Threads"
        ]),
        InterestSubcategory(name: "Humor", entities: [
            "Stand-up comedy", "Comedy podcasts", "Funny videos", "Satire", "Sketch comedy"
        ])
    ])
]

// MARK: - Preview

#Preview {
    OnboardingQuizView()
}
