import Foundation

struct CoinManager {
    var delegate: CoinManagerDelegate?
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "70FD7C39-C3BB-4609-B8AD-348D0CC9E7B1"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let url = "\(baseURL)/\(currency)?apiKey=\(apiKey)"
        
        performRequest(with: url)
    }
    
    func performRequest(with urlString: String) {
        // 1. Create URL
        if let url = URL(string: urlString) {
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeData = data {
                    if let coin = self.parseJOSN(safeData) {
                        self.delegate?.didUpdateCoin(self, coin: coin)
                    }
                }
            }
            
            // 4. Start the task
            task.resume()
        }
    }
    
    func parseJOSN(_ coinData: Data)-> CoinModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodedData.rate
            let assetIdQuote = decodedData.asset_id_quote
            let time = decodedData.time
            let assetIdBase = decodedData.asset_id_base
            
            let coin = CoinModel(time: time, assetIdBase: assetIdBase, assetIdQuote: assetIdQuote, rate: rate)
            
            return coin
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
}


protocol CoinManagerDelegate {
    func didUpdateCoin(_ coinManager: CoinManager, coin: CoinModel)
    
    func didFailWithError(_ error: Error)
}
