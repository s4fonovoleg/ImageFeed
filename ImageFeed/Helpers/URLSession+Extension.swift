import Foundation

/// Ошибка сети.
enum NetworkEror: Error {
	/// Ошибка с кодом HTTP.
	case httpStatusCode(Int)
	
	/// Ошибка запроса.
	case urlRequestErorr(Error)
	
	/// Ошибка URLSession.
	case urlSessionError
}


extension URLSession {
	/// Получение данных запроса.
	func data(
		for request: URLRequest,
		completion: @escaping (Result<Data, Error>) -> Void
	) -> URLSessionTask {
		let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
			DispatchQueue.main.async {
				completion(result)
			}
		}
		
		let task = dataTask(with: request) { data, response, error in
			if let data,
			   let response,
			   let statusCode = (response as? HTTPURLResponse)?.statusCode
			{
				let dataStr = String(decoding: data, as: UTF8.self)
				
				if 200..<300 ~= statusCode {
					fulfillCompletion(.success(data))
				} else {
					fulfillCompletion(.failure(NetworkEror.httpStatusCode(statusCode)))
				}
			} else if let error {
				fulfillCompletion(.failure(NetworkEror.urlRequestErorr(error)))
			} else {
				fulfillCompletion(.failure(NetworkEror.urlSessionError))
			}
		}
		task.resume()
		
		return task
	}
	
	func objectTask<T: Decodable>(
		for request: URLRequest,
		completion: @escaping (Result<T, Error>) -> Void
	) -> URLSessionTask {
		let decoder = JSONDecoder()
		
		return URLSession.shared.data(for: request) { result in
			let response = result.flatMap { data -> Result<T, Error> in
				Result { try decoder.decode(T.self, from: data) }
			}
			completion(response)
		}
	}
}
