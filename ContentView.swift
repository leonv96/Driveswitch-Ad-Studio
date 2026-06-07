import SwiftUI
import PhotosUI

struct ContentView: View {
    // Image Selection States
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var inputImage: UIImage? = nil
    
    // Customizable Text States
    @State private var depositAmount: String = "10,000"
    @State private var monthlyAmount: String = "636"
    @State private var bottomBannerText: String = "FULLY PREPARED - DRIVE AWAY TODAY"
    
    // Toggle for the optional bottom row
    @State private var showBottomBanner: Bool = true
    
    // Brand Colors (Driveswitch Ltd Palette)
    let driveSwitchBlue = Color(red: 163/255, green: 198/255, blue: 237/255) // Light blue car icon
    let bannerBackground = Color.black
    let accentYellow = Color(red: 242/255, green: 181/255, blue: 64/255) // Classic high-visibility text color
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Image Preview Area
                Group {
                    if let inputImage = inputImage {
                        // This renders the precise composition layout
                        CardPreviewLayout(
                            image: inputImage,
                            deposit: depositAmount,
                            monthly: monthlyAmount,
                            bottomText: bottomBannerText,
                            showBottom: showBottomBanner,
                            brandBlue: driveSwitchBlue,
                            brandBlack: bannerBackground,
                            yellowAccent: accentYellow
                        )
                        .aspectRatio(4/3, contentMode: .fit)
                        .cornerRadius(12)
                        .shadow(radius: 8)
                        .padding()
                    } else {
                        // Placeholder state when no image is uploaded
                        VStack(spacing: 12) {
                            Image(systemName: "car.fill")
                                .font(.system(size: 60))
                                .foregroundColor(driveSwitchBlue)
                            Text("Select a car photo to begin")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinite, minHeight: 280)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding()
                    }
                }
                
                // MARK: - Control Panel Dashboard
                Form {
                    Section(header: Text("Media Selection")) {
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text(inputImage == nil ? "Choose Car Image" : "Change Image")
                            }
                        }
                    }
                    
                    Section(header: Text("Top Banner (Finance Details)")) {
                        HStack {
                            Text("Deposit (£)")
                            TextField("e.g. 10,000", text: $depositAmount)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Per Month (£)")
                            TextField("e.g. 636", text: $monthlyAmount)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    Section(header: Text("Optional Bottom Banner")) {
                        Toggle("Display Bottom Row", isOn: $showBottomBanner)
                        if showBottomBanner {
                            TextField("Banner Text", text: $bottomBannerText)
                        }
                    }
                    
                    // MARK: - Action Button
                    if inputImage != nil {
                        Button(action: saveGeneratedImage) {
                            HStack {
                                Spacer()
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("Save Overlaid Advert")
                                    .bold()
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(driveSwitchBlue)
                    }
                }
            }
            .navigationTitle("Driveswitch Ad Studio")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        inputImage = uiImage
                    }
                }
            }
        }
    }
    
    // MARK: - Render & Save Engine
    private func saveGeneratedImage() {
        guard let inputImage = inputImage else { return }
        
        // Instantiate the exact composition block for standard resolution export
        let rendererLayout = CardPreviewLayout(
            image: inputImage,
            deposit: depositAmount,
            monthly: monthlyAmount,
            bottomText: bottomBannerText,
            showBottom: showBottomBanner,
            brandBlue: driveSwitchBlue,
            brandBlack: bannerBackground,
            yellowAccent: accentYellow
        )
        .frame(width: 1200, height: 900) // Fixed standard high-quality aspect output
        
        let renderer = ImageRenderer(content: rendererLayout)
        renderer.scale = 2.0 // Ensures crisp graphic elements
        
        if let exportedUiImage = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(exportedUiImage, nil, nil, nil)
            
            // Haptic Feedback for successful export confirmation
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

// MARK: - Layout Template Hierarchy Component
struct CardPreviewLayout: View {
    let image: UIImage
    let deposit: String
    let monthly: String
    let bottomText: String
    let showBottom: Bool
    
    let brandBlue: Color
    let brandBlack: Color
    let yellowAccent: Color
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. TOP BANNER: Finance Header Setup
            HStack(spacing: 12) {
                // Green Finance Flag styled explicitly from image.png reference
                VStack(alignment: .leading, spacing: -2) {
                    Text("FINANCE")
                    Text("EXAMPLE")
                }
                .font(.system(size: 14, weight: .black, design: .sansSerif))
                .foregroundColor(Color(red: 46/255, green: 204/255, blue: 113/255))
                .padding(.leading, 12)
                
                Spacer()
                
                // Dynamic Finance String Fields
                HStack(spacing: 4) {
                    Text("£\(deposit)").foregroundColor(yellowAccent)
                    Text("DEPOSIT").foregroundColor(.white)
                    Text("  £\(monthly)").foregroundColor(yellowAccent)
                    Text("PER MONTH").foregroundColor(.white)
                }
                .font(.system(size: 18, weight: .bold, design: .sansSerif))
                
                Spacer()
            }
            .padding(.vertical, 14)
            .background(brandBlack)
            
            // 2. CENTRAL MEDIA CANVAS
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinite, maxHeight: .infinite)
                .clipped()
            
            // 3. OPTIONAL BOTTOM BANNER: Leverages Driveswitch Colors
            if showBottom {
                HStack {
                    Spacer()
                    Text(bottomText.uppercased())
                        .font(.system(size: 16, weight: .black, design: .sansSerif))
                        .foregroundColor(yellowAccent)
                        .padding(.vertical, 14)
                    Spacer()
                }
                .background(brandBlue) // Dynamically accents using Driveswitch primary brand tone
            }
        }
    }
}
