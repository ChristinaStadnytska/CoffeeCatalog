import Foundation
import Combine

// ============================================================
//  COMBINE PRACTICE — День 6
//  Як користуватись: запускай блоками. У Xcode Playground
//  результати зʼявляються справа й у консолі (Cmd+Shift+Y).
//  Розкоментовуй ОДИН блок за раз, дивись вивід, іди далі.
// ============================================================

// Тримаємо підписки живими. Без цього sink помирає одразу.
var cancellables = Set<AnyCancellable>()


// ------------------------------------------------------------
// БЛОК 1 — найпростіший потік. Publisher → Subscriber
// ------------------------------------------------------------
func block1() {
    print("── Блок 1 ──")
    [1, 2, 3].publisher
        .sink { value in
            print("отримав:", value)
        }
        .store(in: &cancellables)
}
// block1()   // ← прибери // і запусти. Очікуй: 1, 2, 3


// ------------------------------------------------------------
// БЛОК 2 — map: трансформуємо кожне значення
// ------------------------------------------------------------
func block2() {
    print("── Блок 2 (map) ──")
    [1, 2, 3, 4].publisher
        .map { $0 * 10 }
        .sink { print($0) }
        .store(in: &cancellables)
}
// block2()   // Очікуй: 10, 20, 30, 40


// ------------------------------------------------------------
// БЛОК 3 — filter + map разом (ланцюг)
// ------------------------------------------------------------
func block3() {
    print("── Блок 3 (filter + map) ──")
    [1, 2, 3, 4, 5, 6].publisher
        .filter { $0 % 2 == 0 }   // лишаємо парні
        .map { "☕️ x\($0)" }      // робимо рядок
        .sink { print($0) }
        .store(in: &cancellables)
}
// block3()   // Очікуй: ☕️ x2, ☕️ x4, ☕️ x6


// ------------------------------------------------------------
// БЛОК 4 — @Published як publisher (як у твоєму ViewModel!)
// ------------------------------------------------------------
final class CoffeeStore {
    @Published var count: Int = 0
}
func block4() {
    print("── Блок 4 (@Published) ──")
    let store = CoffeeStore()
    store.$count                       // $ дає доступ до publisher
        .sink { print("count змінився на:", $0) }
        .store(in: &cancellables)

    store.count = 1                    // кожна зміна → нове значення в потік
    store.count = 2
    store.count = 5
}
// block4()   // Очікуй: 0 (початкове), 1, 2, 5


// ------------------------------------------------------------
// БЛОК 5 — combineLatest: логін-форма (email + password)
// ------------------------------------------------------------
final class LoginForm {
    @Published var email = ""
    @Published var password = ""
}
func block5() {
    print("── Блок 5 (combineLatest) ──")
    let form = LoginForm()
    form.$email
        .combineLatest(form.$password)
        .map { email, password in
            !email.isEmpty && !password.isEmpty   // кнопка активна?
        }
        .sink { isEnabled in
            print("Кнопка Login активна:", isEnabled)
        }
        .store(in: &cancellables)

    form.email = "kris@mail.com"       // ще нема пароля → false
    form.password = "1234"             // тепер обидва є → true
}
// block5()   // Дивись, коли саме стане true


// ------------------------------------------------------------
// БЛОК 6 — debounce: пошук, що не спамить на кожну літеру
// ------------------------------------------------------------
func block6() {
    print("── Блок 6 (debounce) ──")
    let search = PassthroughSubject<String, Never>()  // ручний publisher
    search
        .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
        .sink { print("🔍 шукаю:", $0) }
        .store(in: &cancellables)

    // імітуємо швидкий набір "cof"
    search.send("c")
    search.send("co")
    search.send("cof")
    // debounce пропустить ЛИШЕ останнє після паузи → "cof"
}
// block6()   // Очікуй один вивід: 🔍 шукаю: cof
//            // (потрібен запущений RunLoop — у Playground працює)


// ============================================================
//  ТВОЇ ВПРАВИ — розвʼяжи сама, потім покажи мені
// ============================================================

// ВПРАВА A:
// Дано масив цін кави. Виведи ТІЛЬКИ ті, що дорожчі за 50,
// і додай до кожної "грн". Використай filter + map.
func exerciseA() {
    let prices = [30, 55, 45, 80, 60]
    // TODO: твій ланцюг тут
    // Очікуваний вивід: 55 грн, 80 грн, 60 грн
}
// exerciseA()

// ВПРАВА B:
// Є @Published var isFavourite: Bool. Підпишись і друкуй
// "❤️ у обраному" коли true, і "🤍 прибрано" коли false.
// (Підказка: map перетворює Bool у потрібний рядок)
final class Coffee {
    @Published var isFavourite = false
}
func exerciseB() {
    let coffee = Coffee()
    // TODO: підписка тут
    coffee.isFavourite = true
    coffee.isFavourite = false
}
// exerciseB()
