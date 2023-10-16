import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter?
    private var alertPresenter: AlertPresenterDelegate?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(viewController: self)
    }
    
    //MARK: - IBActions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    //MARK: - VC Methods
    
    func show(quiz step: QuizStepViewModel) {
        buttonsState(isEnabled: true)
        imageView.layer.borderWidth = QuizProperties.clearBorder
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        buttonsState(isEnabled: false)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = QuizProperties.borderWidth
        imageView.layer.cornerRadius = QuizProperties.cornerRadius
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showAlert() {
        
        guard let presenterMessage = presenter?.makeResultMessage() else { return }
        
        let endGameTitle = "Этот раунд окончен!"
        
        let alertModel = AlertModel(
            title: endGameTitle,
            message: presenterMessage ,
            buttonText: "Сыграть ещё раз") { [ weak self ] in
                guard let self else { return }
                
                presenter?.restartGame()
            }
        alertPresenter?.presentAlert(with: alertModel)
    }
    
    func showNetworkError(message: String) {
        
        hideLoadingIndicator()
        
        let errorAlertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self else { return }
                
                presenter?.restartGame()
            }
        alertPresenter?.presentAlert(with: errorAlertModel)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
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
}
