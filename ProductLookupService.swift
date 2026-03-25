import Foundation

struct ProductLookupService {
    
    static func lookup(barcode: String) async -> String? {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json") else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decoded = try JSONDecoder().decode(OpenFoodResponse.self, from: data)
            return decoded.product?.product_name
        } catch {
            print("Lookup failed:", error)
            return nil
        }
    }
}

struct OpenFoodResponse: Decodable {
    let product: Product?
}

struct Product: Decodable {
    let product_name: String?
}
