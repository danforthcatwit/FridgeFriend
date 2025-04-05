/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Displays the captured image with bounding boxes, settings, and navigation buttons.
*/

import SwiftUI
import Vision

struct ImageView: View {
    @Binding var showCamera: Bool
    @Binding var imageData: Data?
    @Binding var hasPhoto: Bool
    var onTextRecognized: ([String]) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var ocr = OCR()
    @State private var isProcessing = false
    @State private var languageCorrection = false
    @State private var selectedRecognitionLevel = "Accurate"
    @State private var selectedLanguage = Locale.Language(identifier: "en-US")
    @State private var showManualInput = false
    @StateObject private var inventoryViewModel = InventoryViewModel()

    var recognitionLevels = ["Accurate", "Fast"]

    /// Watch for changes to the request settings.
    var settingChanges: [String] {[
        languageCorrection.description,
        selectedRecognitionLevel,
        imageData?.description ?? "",
        selectedLanguage.maximalIdentifier
    ]}

    var body: some View {
        NavigationStack {
            VStack {
                /// Convert the image data to a `UIImage`, and display it in an `Image` view.
                if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            GeometryReader { geometry in
                                ForEach(ocr.observations, id: \.uuid) { observation in
                                    Box(observation: observation)
                                        .stroke(.red, lineWidth: 2)
                                }
                            }
                        }
                        .padding()
                }

                VStack(spacing: 16) {
                    /// Select the recognition level — fast or accurate.
                    Picker("Recognition Level", selection: $selectedRecognitionLevel) {
                        ForEach(recognitionLevels, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    /// Indicates whether the request uses the language-correction model.
                    Toggle("Language Correction", isOn: $languageCorrection)
                        .frame(width: 250)

                    /// Select which language the request prioritizes to detect.
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(ocr.request.supportedRecognitionLanguages, id: \.self) { language in
                            Text(language.maximalIdentifier)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.vertical)

                HStack(spacing: 16) {
                    Button(action: { showCamera = true }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Retake")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button(action: { extractIngredients() }) {
                        HStack {
                            Image(systemName: "text.viewfinder")
                            Text(isProcessing ? "Processing..." : "Extract")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(isProcessing)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Scan Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        // Reset the camera state and return to the initial screen
                        showCamera = false
                        hasPhoto = false
                        imageData = nil
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: TranscriptView(imageOCR: $ocr)) {
                        Image(systemName: "text.justify")
                    }
                }
            }
            /// Initially perform the request, and then perform the request when changes occur to the request settings.
            .onChange(of: settingChanges, initial: true) {
                updateRequestSettings()
                if let imageData = imageData {
                    Task {
                        try await ocr.performOCR(imageData: imageData)
                    }
                }
            }
            .sheet(isPresented: $showManualInput) {
                ManualIngredientInputView(inventoryViewModel: inventoryViewModel)
            }
        }
    }

    /// Update the request settings based on the selected options on the `ImageView`.
    func updateRequestSettings() {
        /// A Boolean value that indicates whether the system applies the language-correction model.
        ocr.request.usesLanguageCorrection = languageCorrection

        ocr.request.recognitionLanguages = [selectedLanguage]

        switch selectedRecognitionLevel {
        case "Fast":
            ocr.request.recognitionLevel = .fast
        default:
            ocr.request.recognitionLevel = .accurate
        }
    }

    private func extractIngredients() {
        guard let imageData = imageData else { return }
        
        isProcessing = true
        
        Task {
            do {
                // Update request settings before performing OCR
                updateRequestSettings()
                try await ocr.performOCR(imageData: imageData)
                
                // Extract ingredients from OCR results
                let ingredients = ocr.observations.compactMap { observation -> String? in
                    // Filter out common non-ingredient text
                    let text = observation.topCandidates(1)[0].string.lowercased()
                    
                    // Skip if text is too short or contains common non-ingredient words
                    if text.count < 3 || 
                       text.contains("total") ||
                       text.contains("subtotal") ||
                       text.contains("tax") ||
                       text.contains("$") {
                        return nil
                    }
                    
                    return observation.topCandidates(1)[0].string
                }
                
                await MainActor.run {
                    isProcessing = false
                    onTextRecognized(ingredients)
                }
            } catch {
                print("Error performing OCR: \(error)")
                await MainActor.run {
                    isProcessing = false
                }
            }
        }
    }
}
