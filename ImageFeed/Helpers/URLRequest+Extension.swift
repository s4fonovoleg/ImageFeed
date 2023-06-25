import Foundation

extension URLRequest {
	/// Создание HTTP запроса.
	/// - Parameters:
	///   - path: относительный путь.
	///   - httpMethod: HTTP метод.
	///   - baseUrl: базовый адрес.
	/// - Returns: HTTP запрос.
	static func makeHTTPRequest(
		path: String,
		httpMethod: String,
		baseUrl: URL = DefaultBaseURL
	) -> URLRequest {
		var request = URLRequest(url: URL(string: path, relativeTo: baseUrl)!)
		request.httpMethod = httpMethod
		
		return request
	}
}
