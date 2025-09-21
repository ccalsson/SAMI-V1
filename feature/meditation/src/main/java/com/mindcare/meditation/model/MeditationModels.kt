package com.mindcare.meditation.model

data class MeditationSession(
    val id: String,
    val title: String,
    val description: String,
    val duration: Int, // en segundos
    val category: MeditationCategory,
    val audioUrl: String,
    val imageUrl: String,
    val isPremium: Boolean = false
)

data class MeditationProgress(
    val sessionId: String,
    val completedTime: Int,
    val totalTime: Int,
    val lastPlayedPosition: Long
)

enum class MeditationCategory {
    SLEEP,
    FOCUS,
    ANXIETY,
    STRESS,
    MINDFULNESS,
    BEGINNER
} 