//
//  ServerAPI.swift
//  challenge-ios
//
//  Created by Vladislav Ternovskiy on 07.05.2018.
//  Copyright © 2018 Vladislav Ternovskiy. All rights reserved.
//

import Moya
import UIKit

enum RestAPI {
    case fetchQuote(guestSessionId: String, quoteApplicationId: String)
    case updateQuoteOptions(guestSessionId: String, supplementalPriceOffers: [SelectedSuplementalPriceOffer])
}

extension RestAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://api.test.one")!
    }
    
    var path: String {
        switch self {
        case let .fetchQuote(guestSessionId, quoteApplicationId):
            return "/quote?sessionId=\(guestSessionId)&applicationId=\(quoteApplicationId)"
        case let .updateQuoteOptions(guestSessionId, _):
            return "/quote?sessionId=\(guestSessionId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchQuote: return .get
        case .updateQuoteOptions: return .post
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .fetchQuote:
            return nil
        case let .updateQuoteOptions(_, supplementals):
            return ["supplementals": supplementals]
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch method {
        case .post, .put:
            return .requestParameters(parameters: parameters!, encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var url: String {
        return "\(baseURL)\(path)"
    }
}
