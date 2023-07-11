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
}
