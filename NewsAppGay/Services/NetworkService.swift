import Foundation

class NetworkService {
    
    // Имитация сетевого запроса
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        // В реальном приложении здесь был бы URLSession.
        // Сейчас мы просто симулируем задержку и возвращаем тестовые данные.
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            // Создаем фейковые данные
            let mockPosts = [
                Post(id: 1, title: "Первая новость", body: "Текст первой новости..."),
                Post(id: 2, title: "Вторая новость", body: "Текст второй новости..."),
                Post(id: 3, title: "Третья новость", body: "Текст третьей новости...")
            ]
            
            // Возвращаем успешный результат
            completion(.success(mockPosts))
            
            // Если бы мы хотели проверить обработку ошибок, мы бы вернули:
            // let error = NSError(domain: "Test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера"])
            // completion(.failure(error))
        }
    }
}
