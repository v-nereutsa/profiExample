# profiExample

Простой модуль логина, в котором два UITextField для никнэйнма и пароля и кнопка входа. При нажатии на кнопку, если нет ошибок - выполняется запрос, если есть - выводится ошибка.<br>
В этом проекте стараюсь идти по пути Viper. На View слое используется MVVM.<br>
Для связи ViewController с ViewModel решил сделать ViewState, который объединяет данные для отображения и ViewEvent для того чтобы передавать некоторые одноразовые события во View.<br>
Для DI используется DITranquillity. Для реактивки - RxSwift. Для запросов - Apollo.
- DI - Сущность для внедрения зависимостей с помощью DI.
- View - Данные для отображения.
- ViewModel - Обработка UI.
- Domain - бизнес-логика.
<br>UserManager(через протокол) - инкапсулирует в себе логику работы с данными пользователя.
<br>NetworkClient(через протокол) - инкапсулирует в себе логику работы с сетевыми запросами.
- Entity - вспомогательные сущности. 

Screenshot:<br>
![Alt Text](https://github.com/v-nereutsa/profiExample/blob/main/image.jpeg)
