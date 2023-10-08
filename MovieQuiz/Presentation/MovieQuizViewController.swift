import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    //MARK: - IBOutlets
    
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: - Private Properties
    
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    
    private lazy var questionFactory: QuestionFactoryProtocol = {
        QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    }()
    
    private lazy var alertPresenter: AlertPresenterDelegate = {
        AlertPresenter(viewController: self)
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        
        questionFactory.requestNextQuestion()
        statisticService = StatisticServiceImpl()
        
        showLoadingIndicator()
        questionFactory.loadData()
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
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    //MARK: - Private methods
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func setupImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = QuizProperties.borderWidth
        imageView.layer.cornerRadius = QuizProperties.cornerRadius
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func buttonsState(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.borderWidth = QuizProperties.borderWidth
        imageView.layer.cornerRadius = QuizProperties.cornerRadius
        buttonsState(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            buttonsState(isEnabled: true)
            imageView.layer.borderWidth = QuizProperties.clearBorder
            
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showAlert()
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    private func showNetworkError(message: String) {
        
        hideLoadingIndicator()
        
        let errorAlertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
            }
        alertPresenter.presentAlert(with: errorAlertModel)
    }
    
    private func showAlert() {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage() ,
            buttonText: "Сыграть еще раз") { [ weak self ] in
                guard let self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
            }
        alertPresenter.presentAlert(with: alertModel)
    }
    
    private func makeResultMessage() -> String {
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else { return "error" }
        
        let resultMessage =
        
        """
        Ваш результат: \(correctAnswers)\\\(questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(bestGame.correct)\\\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        
        return resultMessage
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
