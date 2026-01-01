//
//  CurrentWeatherView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData


struct CurrentWeatherView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    var body: some View {
        //        VStack{
        //            Text("Image shows the information to be presented in this view")
        //            Spacer()
        //            Image("now")
        //                .resizable()
        //
        //            Spacer()
        //        }
        //        .frame(height: 600)
        VStack(spacing: 16){
            Text(vm.activePlaceName)
                .font(.largeTitle)
                .bold()
            
            Text(DateFormatterUtils.formattedCurrentDate(format: "EEEE, d MMM"))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            if let currenWeather = vm.currentWeather{
                VStack(spacing: 20){
                    Text("\(Int(currenWeather.temp))°C")
                        .font(.system(size: 56))
                        .bold()
                    
                    Text("Feels Like:\(Int(currenWeather.feelsLike))°C")
                        .font(.system(size: 20))
                    
                    Image(systemName: WeatherAdviceCategory
                        .from(temp: currenWeather.temp, description: currenWeather.weather.first?.description ?? "")
                        .icon
                    )
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    
                    Text(
                        WeatherAdviceCategory
                            .from(temp: currenWeather.temp, description: currenWeather.weather.first?.description ?? ""
                                 ).adviceText
                    )
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [
                            .blue.opacity(0.35),
                            .cyan.opacity(0.15),
                            .red
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ).cornerRadius(10)
                )
                .shadow(radius: 10)
            }
            
            Spacer()
            
            if let currenWeather = vm.currentWeather{
                HStack(spacing: 30){
                    VStack{
                        Text("Humidity")
                        Text("\(currenWeather.humidity)%")
                            .bold()
                    }
                    VStack{
                        Text("Wind")
                        Text("\(Int(currenWeather.windSpeed)) m/s")
                            .bold()
                    }
                    VStack{
                        Text("UV")
                        Text("\(currenWeather.uvi)")
                            .bold()
                    }
                }
                .padding()
                .background(
                    Color.white.opacity(0.4)
                ).cornerRadius(10)
                
                .shadow(radius: 10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            //            LinearGradient(colors: [.blue.opacity(0.2), .cyan.opacity(0.05)], startPoint: .top, endPoint: .bottom)
            LinearGradient(
                colors: [
                    .blue.opacity(0.35),
                    .cyan.opacity(0.15),
                    .red
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    CurrentWeatherView()
        .environmentObject(vm)
}
