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
    var onTextRecognized: ([String]) -> Void

    @State private var ocr = OCR()
    @State private var isProcessing = false
    @State private var languageCorrection = false
    @State private var selectedRecognitionLevel = "Accurate"
    @State private var selectedLanguage = Locale.Language(identifier: "en-US")

    var recognitionLevels = ["Accurate", "Fast"]

    /// Watch for changes to the request settings.
    var settingChanges: [String] {[
        languageCorrection.description,
        selectedRecognitionLevel,
        imageData!.description,
        selectedLanguage.maximalIdentifier
    ]}

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: ScanReceiptView()) {
                        Text("Retake Photo")
                            .padding()
                            .font(.headline)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            .onTapGesture {
                                showCamera = true
                            }
                    }
                    Spacer()
                    NavigationLink(destination: TranscriptView(imageOCR: $ocr)) {
                        Text("View Text")
                            .padding()
                            .font(.headline)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    Spacer()
                }

                /// Convert the image data to a `UIImage`, and display it in an `Image` view.
                if let uiImage = UIImage(data: imageData!) {
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

                /// Select the recognition level — fast or accurate.
                Picker("Recognition Level", selection: $selectedRecognitionLevel) {
                    ForEach(recognitionLevels, id: \.self) {
                        Text($0)
                    }
                }
                .overlay(Capsule().stroke(.blue, lineWidth: 1))

                /// Indicates whether the request uses the language-correction model.
                Toggle("Language Correction", isOn: $languageCorrection)
                    .frame(width: 250)

                /// Select which language the request prioritizes to detect.
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(ocr.request.supportedRecognitionLanguages, id: \.self) { language in
                        Text(language.maximalIdentifier)
                    }
                }
                .overlay(Capsule().stroke(.blue, lineWidth: 1))

                HStack {
                    Button("Retake") {
                        showCamera = true
                    }
                    .padding()
                    .font(.title2)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    
                    Button(isProcessing ? "Processing..." : "Extract Ingredients") {
                        extractIngredients()
                    }
                    .padding()
                    .font(.title2)
                    .background(isProcessing ? Color.gray : Color.green)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .disabled(isProcessing)
                }
                .padding()
            }
            /// Initially perform the request, and then perform the request when changes occur to the request settings.
            .onChange(of: settingChanges, initial: true) {
                updateRequestSettings()
                if imageData != nil {
                    Task {
                        try await ocr.performOCR(imageData: imageData!)
                    }
                }
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
