import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    
    //MARK: - Private Properties
    
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    
    private lazy var questionFactory: QuestionFactoryProtocol = {
        QuestionFactory(delegate: self)
    }()
    
    private lazy var alertPresenter: AlertPresenterDelegate = {
        AlertPresenter(viewController: self)
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        questionFactory.requestNextQuestion()
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    //MARK: - Private methods
    
    private func setupImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = QProperties.borderWidth
        imageView.layer.cornerRadius = QProperties.cornerRadius
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        currentQuestionIndex += 1
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.borderWidth = QProperties.borderWidth
        imageView.layer.cornerRadius = QProperties.cornerRadius
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            noButton.isEnabled = true
            yesButton.isEnabled = true
            imageView.layer.borderWidth = QProperties.clearBorder
            
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount {
            let text = correctAnswers == questionsAmount ?
            
            "Поздравляем, вы ответили на 10 из 10" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            
            showAlert(quiz: viewModel)
        } else {
            questionFactory.requestNextQuestion()
        }
    }
    
    private func showAlert(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) { [ weak self ] in
                guard let self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
            }
        alertPresenter.presentAlert(with: alertModel)
    }
    
    //MARK: - IBActions
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
