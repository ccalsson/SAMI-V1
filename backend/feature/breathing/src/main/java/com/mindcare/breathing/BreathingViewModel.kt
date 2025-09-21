@HiltViewModel
class BreathingViewModel @Inject constructor(
    private val breathingRepository: BreathingRepository,
    private val analyticsManager: AnalyticsManager
) : ViewModel() {

    private val _exercises = MutableStateFlow<List<BreathingExercise>>(emptyList())
    val exercises = _exercises.asStateFlow()

    private val _currentExercise = MutableStateFlow<BreathingExercise?>(null)
    val currentExercise = _currentExercise.asStateFlow()

    private val _progress = MutableStateFlow<BreathingProgress?>(null)
    val progress = _progress.asStateFlow()

    private val _isActive = MutableStateFlow(false)
    val isActive = _isActive.asStateFlow()

    private var exerciseJob: Job? = null

    init {
        loadExercises()
    }

    private fun loadExercises() {
        viewModelScope.launch {
            breathingRepository.getAllExercises()
                .catch { error ->
                    // Manejar error
                }
                .collect { exercises ->
                    _exercises.value = exercises
                }
        }
    }

    fun startExercise(exerciseId: String) {
        viewModelScope.launch {
            val exercise = breathingRepository.getExerciseById(exerciseId)
            exercise?.let {
                _currentExercise.value = it
                _isActive.value = true
                startBreathingCycle(it.pattern)
                analyticsManager.logEvent(AnalyticsEvent.BreathingExerciseStarted(exerciseId))
            }
        }
    }

    private fun startBreathingCycle(pattern: BreathingPattern) {
        exerciseJob?.cancel()
        exerciseJob = viewModelScope.launch {
            var cyclesCompleted = 0
            val totalCycles = pattern.repetitions

            while (cyclesCompleted < totalCycles && isActive.value) {
                // Inhalar
                updateProgress(BreathingPhase.INHALE, pattern.inhaleSeconds, cyclesCompleted, totalCycles)
                delay(pattern.inhaleSeconds * 1000L)

                // Mantener inhalación
                if (pattern.holdInhaleSeconds > 0) {
                    updateProgress(BreathingPhase.HOLD_INHALE, pattern.holdInhaleSeconds, cyclesCompleted, totalCycles)
                    delay(pattern.holdInhaleSeconds * 1000L)
                }

                // Exhalar
                updateProgress(BreathingPhase.EXHALE, pattern.exhaleSeconds, cyclesCompleted, totalCycles)
                delay(pattern.exhaleSeconds * 1000L)

                // Mantener exhalación
                if (pattern.holdExhaleSeconds > 0) {
                    updateProgress(BreathingPhase.HOLD_EXHALE, pattern.holdExhaleSeconds, cyclesCompleted, totalCycles)
                    delay(pattern.holdExhaleSeconds * 1000L)
                }

                cyclesCompleted++
            }

            if (cyclesCompleted >= totalCycles) {
                completeExercise()
            }
        }
    }

    private fun updateProgress(
        phase: BreathingPhase,
        remainingSeconds: Int,
        completedCycles: Int,
        totalCycles: Int
    ) {
        _progress.value = BreathingProgress(
            exerciseId = currentExercise.value?.id ?: "",
            completedCycles = completedCycles,
            totalCycles = totalCycles,
            currentPhase = phase,
            remainingSeconds = remainingSeconds
        )
    }

    fun pauseExercise() {
        exerciseJob?.cancel()
        _isActive.value = false
    }

    fun resumeExercise() {
        currentExercise.value?.let {
            _isActive.value = true
            startBreathingCycle(it.pattern)
        }
    }

    private fun completeExercise() {
        _isActive.value = false
        currentExercise.value?.let { exercise ->
            viewModelScope.launch {
                breathingRepository.saveExerciseCompletion(exercise.id)
                analyticsManager.logEvent(
                    AnalyticsEvent.BreathingExerciseCompleted(exercise.id)
                )
            }
        }
    }

    override fun onCleared() {
        super.onCleared()
        exerciseJob?.cancel()
    }
} 