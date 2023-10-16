import UIKit

final class MovieQuizViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: - Private Properties
    
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    private lazy var alertPresenter: AlertPresenterDelegate = {
        AlertPresenter(viewController: self)
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        
        showLoadingIndicator()
        presenter.questionFactory.loadData()
        
        presenter.questionFactory.requestNextQuestion()
        statisticService = StatisticServiceImpl()
        presenter.viewController = self
        
    }
    
    //MARK: - Private methods
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            presenter.correctAnswers += 1
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
            
            presenter.showNextQuestionOrResults()
        }
    }
    
    func showNetworkError(message: String) {
        
        hideLoadingIndicator()
        
        let errorAlertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self else { return }
                
                presenter.restartGame()
            }
        alertPresenter.presentAlert(with: errorAlertModel)
    }
    
    func showAlert() {
        statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage() ,
            buttonText: "Сыграть ещё раз") { [ weak self ] in
                guard let self else { return }
                
                presenter.restartGame()
            }
        alertPresenter.presentAlert(with: alertModel)
    }
    
    private func makeResultMessage() -> String {
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else { return "error" }
        
        let resultMessage =
        """
        Ваш результат: \(presenter.correctAnswers)\\\(presenter.questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(bestGame.correct)\\\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        return resultMessage
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func setupImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = QuizProperties.borderWidth
        imageView.layer.cornerRadius = QuizProperties.cornerRadius
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
    }
    
    private func buttonsState(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    //MARK: - IBActions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
}
