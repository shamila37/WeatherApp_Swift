//
//  WeatherService.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation
@MainActor
final class WeatherService {
    private let apiKey = "0b9d7f2a9b12c8cd6ee1d3e81812031b"
//    private let apiKey = "6a2778544832148277de1e7673343102"
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        // Constructs a URL for the OpenWeatherMap OneCall API using the provided coordinates and API key.
        guard let url = URL(
            string: 
                "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)"
//                "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&units=metric&appid=\(6a2778544832148277de1e7673343102)"
        ) else {
            throw WeatherMapError.invalidURL("OpenWeatherMap OneCall API URL is invalid.")
        }
        
        // Performs an asynchronous network request using URLSession.
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Validates the HTTP response status code.
            guard let http = response as? HTTPURLResponse,
                  200..<300 ~= http.statusCode else {
                throw WeatherMapError.invalidResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
            }
            
            // Decodes the received JSON data into a `WeatherResponse` object, using a specific date decoding strategy.
            return try JSONDecoder().decode(WeatherResponse.self, from: data)
            
            // Handles and throws specific `WeatherMapError` types for invalid URL, network failure, invalid response, and decoding errors.
        } catch let error as DecodingError {
            throw WeatherMapError.decodingError(error)
        } catch {
            throw WeatherMapError.networkError(error)
        }
        
        
        // DUMMY RETURN TO SATISFY COMPILER - you will have your own when the coding is done
//        preconditionFailure("Stubbed function not implemented. Requires a WeatherResponse return.")
    }
}
