data class BreathingExercise(
    val id: String,
    val name: String,
    val description: String,
    val pattern: BreathingPattern,
    val duration: Int, // en minutos
    val difficulty: Difficulty,
    val benefits: List<String>,
    val imageUrl: String? = null,
    val isPremium: Boolean = false
)

data class BreathingPattern(
    val inhaleSeconds: Int,
    val holdInhaleSeconds: Int = 0,
    val exhaleSeconds: Int,
    val holdExhaleSeconds: Int = 0,
    val repetitions: Int
)

enum class Difficulty {
    BEGINNER,
    INTERMEDIATE,
    ADVANCED
}

data class BreathingProgress(
    val exerciseId: String,
    val completedCycles: Int,
    val totalCycles: Int,
    val currentPhase: BreathingPhase,
    val remainingSeconds: Int
)

enum class BreathingPhase {
    INHALE,
    HOLD_INHALE,
    EXHALE,
    HOLD_EXHALE
} 