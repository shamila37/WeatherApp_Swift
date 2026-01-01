//
//  ForecastView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import Charts
import SwiftData


import SwiftUI
import Charts   // Include if you plan to show a chart later

// MARK: - Temperature Category
/// Example of how to categorize temperatures for display.
/// Add more cases or adjust logic as needed.
enum TempCategory: String, CaseIterable {
    case cold = "Cold"   // Example category
    case warm = "Warm"
    case hot = "Hot"

    /// Choose a color to represent this category.
    var color: Color {
        switch self {
        case .cold:
            return .blue
            // TODO: add more cases (e.g., .cool, .warm, .hot) with colors as needed
        case .warm:
            return .orange
        case .hot:
            return .red
        }
    }

    /// Convert a Celsius temperature into a category.
    static func from(tempC: Double) -> TempCategory {
        if tempC <= 0 {
            return .cold
        }
        // TODO: add more logic for other ranges (cool, warm, hot)
        else if tempC <= 25 {
            return .warm
        } else {
            return .hot
        }
    }
}

// MARK: - Temperature Data Model
/// A single temperature reading for the chart or list.
private struct TempData: Identifiable {
    let id = UUID()
    let time: Date          // e.g., forecast date
    let type: String        // e.g., "High" or "Low"
    let value: Double       // numeric value
    let category: TempCategory
//    let dayLable: String
//    let isMax: Bool
}

// MARK: - Forecast View
/// Stubbed Forecast View that includes an image placeholder to show
/// what the final view will look like. Replace the image once real data and charts are added.
struct ForecastView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    /// Converts forecast data into chart-friendly entries.
    private var chartData: [TempData] {
        vm.forecast.flatMap { day in
            [
                // These are hard-wired data, real data will come from weather data fetched by your api
                
                TempData(
                    time: Date(),
                    type: "High",
                    value: 24.5,
                    category: .from(tempC: 24.5)
                ),
                TempData(
                    time: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                    type: "High",
                    value: 19.0,
                    category: .from(tempC: 19.0)
                ),
                TempData(
                    time: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                    type: "High",
                    value: 5.5,
                    category: .from(tempC: 5.5)
                ),
                // TODO: add a "Low" entry or other data points if needed
                TempData(
                    time: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                    type: "Low",
                    value: 1.2,
                    category: .from(tempC: 1.2)
                )
            ]
        }
    }
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 20) {
                //            // MARK: - Header Text
                //            Text("Image shows the information to be presented in this view")
                //                .font(.headline)
                //                .multilineTextAlignment(.center)
                //                .padding(.top)
                //
                //            Spacer()
                //
                //            // MARK: - Placeholder Image
                //            // Replace "forecast" with the name of your image asset.
                //            // You can add your actual design or a wireframe image in Assets.xcassets.
                //            Image("forecast")
                //                .resizable()
                //                .scaledToFit()
                //                .frame(maxWidth: .infinity)
                //                .cornerRadius(12)
                //                .shadow(radius: 5)
                //                .padding()
                //
                //            Spacer()
                VStack(alignment: .leading, spacing: 4){
                    Text("8 Day Weather Forecast")
                        .font(.title2)
                        .bold()
                        .padding(.top)
                    
                    Text("Daily Highs and Lows (°C)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                Chart {
                    ForEach(vm.forecast) { day in
                        let date = Date(timeIntervalSince1970: TimeInterval(day.dt))
                        
                        // LOW
                        BarMark(
                            x: .value("Day", date),
                            y: .value("Low", day.temp.min)
                        )
                        .foregroundStyle(.blue)
                        .position(by: .value("Type", "Low"))
                        
                        // HIGH
                        BarMark(
                            x: .value("Day", date),
                            y: .value("High", day.temp.max)
                        )
                        .foregroundStyle(.orange)
                        .position(by: .value("Type", "High"))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .frame(height: 260)
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 4)
                .padding(.horizontal)
                
                Text("Detailed daily summery")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 12){
                    ForEach(vm.forecast){ day in
                        VStack(alignment: .leading, spacing: 5){
                            
                            HStack{
                                Text(DateFormatterUtils
                                    .formattedDateWithWeekdayAndDay(from: TimeInterval(day.dt))
                                )
                                Spacer()
                                if let iconName = day.weather.first?.icon {
                                    let iconUrl = "https://openweathermap.org/img/wn/\(iconName)@2x.png"
                                    AsyncImage(url: URL(string: iconUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                            .font(.headline)
                            
                            Text(day.summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Text("Low: \(Int(day.temp.min))°C")
                                Spacer()
                                Text("High: \(Int(day.temp.max))°C")
                            }
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color.cyan.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(radius: 3)
                    }
                }
                .padding(.horizontal)
                
            }
        }
        .padding()
        .background(
//            LinearGradient(
//                gradient: Gradient(colors: [.indigo.opacity(0.1), .blue.opacity(0.05)]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
            LinearGradient(
                colors: [.blue.opacity(0.35), .cyan.opacity(0.15), .red.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .navigationTitle("Forecast")
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    ForecastView()
        .environmentObject(vm)
}
