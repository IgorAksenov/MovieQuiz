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

    private var questionFactory: QuestionFactoryProtocol!
    private var statisticService: StatisticServiceProtocol!
    private var alertPresenter: AlertPresenterProtocol!
    private var presenter: MovieQuizPresenter!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        imageView.layer.cornerRadius = 20

        statisticService = StatisticServiceImplementation()
        presenter = MovieQuizPresenter(statisticService: statisticService)
        presenter.viewController = self

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter()

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
            self.presenter.restartGame()
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
        presenter.didReceiveNextQuestion(question: question)
    }

    private func setupUI() {
        buttonNo.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        buttonYes.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
    }

    func show(quizStep: QuizStepViewModel) {
        imageView.image = quizStep.image
        questionLabel.text = quizStep.question
        indexLabel.text = quizStep.questionNumber
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }

    func disableButtonsForOneSecond() {
        buttonYes.isEnabled = false
        buttonNo.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.buttonYes.isEnabled = true
            self.buttonNo.isEnabled = true
        }
    }

    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        if isCorrect {
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
            self.presenter.showNextQuestionOrResults()
        }
    }

    private func resetImageViewStyle() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }

    func requestNextQuestion() {
        questionFactory.requestNextQuestion()
    }

    func enableButtons() {
        buttonYes.isEnabled = true
        buttonNo.isEnabled = true
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
