import Foundation

struct ProductLookupService {
    
    static func name(for barcode: String) -> String {
        switch barcode {
        case "8901030895484":
            return "Milk"
        case "8906007282008":
            return "Bread"
        case "8901491101630":
            return "Rice"
        case "8901719123456":
            return "Peanut Butter"
        case "8901234567890":
            return "Eggs"
        default:
            return barcode
        }
    }
}
