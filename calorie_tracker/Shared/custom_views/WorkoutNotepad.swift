//
//  WorkoutNotepad.swift
//  calorie_tracker (iOS)
//
//  Created by Jake Landers on 10/3/23.
//

import SwiftUI

struct AssetItem {
    let title: String
    let asset: String
}

struct WorkoutNotepad: View {
    @Environment(\.presentationMode) private var presentationMode
    
    let items: [AssetItem] = [
        AssetItem(title: "Workout Notepad is for planning and tracking workouts, with the same simplicity as Calorie Me.", asset: "RAW-dashboard"),
        AssetItem(title: "Workouts are playlists! The exercises are songs. Compose them dynamically to fit your needs.", asset: "RAW-wedit"),
        AssetItem(title: "Seamless but customizable input and tagging lets you track workouts the way you want to.", asset: "RAW-wlaunch"),
        AssetItem(title: "Lastly, view advanced statistics on your logged exercises to tailor your future workouts better!", asset: "RAW-reps-graph")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#e1dcd2").edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        VStack(alignment:.leading) {
                            Text("Introducing")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                            Text("Workout Notepad")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(Color.wn)
                        }
                    }
                    .padding(20)
                    TabView {
                        ForEach(items, id: \.title) { item in
                            cell(item: item)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    Button {
                        print("TODO")
//                        UIApplication.shared.open(URL(string: "https://apps.apple.com/app/idYourAppID")!, options: [:], completionHandler: nil)
                    } label: {
                        Text("Download Now")
                            .font(.system(size: 18,weight: .medium))
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color.wn)
                            .cornerRadius(10)
                            .padding([.horizontal, .bottom], 20)
                    }
                }
                .navigationTitle("Looking For More?")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(Color.wn)
                    }
                }
            }
        }
    }
    
    func cell(item: AssetItem) -> some View {
        return VStack {
            Text(item.title)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
            Image(item.asset)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(6)
                .background(Color.black)
                .cornerRadius(30)
        }
        .padding(.bottom, 10)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue:  Double(b) / 255.0,
            opacity: 1
        )
    }
}

struct WorkoutNotepad_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutNotepad()
    }
}
