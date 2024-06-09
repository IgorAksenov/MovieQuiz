import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var indexLabel: UILabel!
    @IBOutlet private var questionTitleLabel: UILabel!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var buttonNo: UIButton!
    @IBOutlet private var buttonYes: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol!
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var statisticService: StatisticServiceProtocol!
    private var alertPresenter: AlertPresenterProtocol!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        imageView.layer.cornerRadius = 20

        // Создаем экземпляры QuestionFactory и StatisticService
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()

        // Инициализация alertPresenter
        alertPresenter = AlertPresenter()

        // Показываем индикатор загрузки и начинаем загрузку данных
        showLoadingIndicator()
        questionFactory.loadData()
    }

    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory.requestNextQuestion()
        }

        alertPresenter.show(in: self, model: model)
    }

    // MARK: - QuestionFactoryDelegate
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let questionStep = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quizStep: questionStep)
        }
    }

    private func setupUI() {
        buttonNo.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        buttonYes.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
    }

    private func show(quizStep: QuizStepViewModel) {
        imageView.image = quizStep.image
        questionLabel.text = quizStep.question
        indexLabel.text = quizStep.questionNumber
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        disableButtonsForOneSecond()
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        disableButtonsForOneSecond()
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    private func disableButtonsForOneSecond() {
        buttonYes.isEnabled = false
        buttonNo.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.buttonYes.isEnabled = true
            self.buttonNo.isEnabled = true
        }
    }

    private func showAnswerResult(isCorrect: Bool) {
        if (isCorrect) {
            correctAnswers += 1
            imageView.layer.borderWidth = 8
            imageView.layer.masksToBounds = true
            imageView.layer.borderColor = UIColor.ypGreenIOS.cgColor
        } else {
            imageView.layer.borderWidth = 8
            imageView.layer.masksToBounds = true
            imageView.layer.borderColor = UIColor.ypRedIOS.cgColor
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.resetImageViewStyle()
            self.showNextQuestionOrResults()
        }
    }

    private func resetImageViewStyle() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showQuizResults()
            return
        }
        
        currentQuestionIndex += 1
        questionFactory.requestNextQuestion()
        enableButtons()
    }

    private func showQuizResults() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let totalAccuracyString = String(format: "%.2f", statisticService.totalAccuracy)
        let bestGameDate = DateFormatter.localizedString(from: statisticService.bestGame.date, dateStyle: .short, timeStyle: .short)
        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество игр: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/\(questionsAmount) (\(bestGameDate))
        Средняя точность: \(totalAccuracyString)%
        """
        ResultAlertPresenter.show(in: self, title: "Этот раунд окончен!", message: message) { [weak self] in
            self?.restartQuiz()
        }
    }


    private func enableButtons() {
        buttonYes.isEnabled = true
        buttonNo.isEnabled = true
    }


    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory.resetAskedQuestions()
        questionFactory.requestNextQuestion()
    }
}



/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
