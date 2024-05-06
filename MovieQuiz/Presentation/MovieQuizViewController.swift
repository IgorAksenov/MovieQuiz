import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]

    
  
        
        // MARK: - Outlets
        
        @IBOutlet private var imageView: UIImageView!
        @IBOutlet private var indexLabel: UILabel!
        @IBOutlet private var questionTitleLabel: UILabel!
        @IBOutlet private var questionLabel: UILabel!
        @IBOutlet private var buttonNo: UIButton!
        @IBOutlet private var buttonYes: UIButton!
        
        // MARK: - Lifecycle
        
    override func viewDidLoad() {
           super.viewDidLoad()
           setupUI()
           showCurrentQuestion()
        imageView.layer.cornerRadius = 20
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
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
       private func showCurrentQuestion() {
           let currentQuestion = questions[currentQuestionIndex]
           let questionStep = convert(model: currentQuestion)
           show(quizStep: questionStep)
       }
       
       private func convert(model: QuizQuestion) -> QuizStepViewModel {
           return QuizStepViewModel(
               image: UIImage(named: model.image) ?? UIImage(),
               question: model.text,
               questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
           )
       }
       
       @IBAction private func yesButtonClicked(_ sender: Any) {
           let currentQuestion = questions[currentQuestionIndex]
           let givenAnswer = true
           showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
       }
       
       @IBAction private func noButtonClicked(_ sender: Any) {
           let currentQuestion = questions[currentQuestionIndex]
           let givenAnswer = false
           showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
       }
       
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
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
           
           if currentQuestionIndex == questions.count - 1 {
               let text = "Ваш результат: \(correctAnswers)/\(questions.count)"
               showAlert(title: "Этот раунд окончен!", message: text)
               currentQuestionIndex = 0
               correctAnswers = 0
           } else {
               currentQuestionIndex += 1
               showCurrentQuestion()
           }
       }
       
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Пройти еще раз", style: .default) { _ in
            self.restartQuiz()
        })
        present(alert, animated: true, completion: nil)
    }

    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        showCurrentQuestion()
    }
   }

   private struct QuizQuestion {
       let image: String
       let text: String
       let correctAnswer: Bool
   }

   private struct QuizStepViewModel {
       let image: UIImage
       let question: String
       let questionNumber: String
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
