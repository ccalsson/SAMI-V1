package com.mindcare.meditation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mindcare.analytics.AnalyticsEvent
import com.mindcare.analytics.AnalyticsManager
import com.mindcare.meditation.data.repository.MeditationRepository
import com.mindcare.meditation.model.MeditationCategory
import com.mindcare.meditation.model.MeditationProgress
import com.mindcare.meditation.model.MeditationSession
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class MeditationViewModel @Inject constructor(
    private val meditationRepository: MeditationRepository,
    private val analyticsManager: AnalyticsManager
) : ViewModel() {

    private val _sessions = MutableStateFlow<List<MeditationSession>>(emptyList())
    val sessions = _sessions.asStateFlow()

    private val _currentSession = MutableStateFlow<MeditationSession?>(null)
    val currentSession = _currentSession.asStateFlow()

    private val _isPlaying = MutableStateFlow(false)
    val isPlaying = _isPlaying.asStateFlow()

    private val _currentProgress = MutableStateFlow(0f)
    val currentProgress = _currentProgress.asStateFlow()

    private val _selectedCategory = MutableStateFlow<MeditationCategory?>(null)
    val selectedCategory = _selectedCategory.asStateFlow()

    init {
        loadSessions()
        observeAudioProgress()
    }

    private fun loadSessions() {
        viewModelScope.launch {
            meditationRepository.getAllSessions()
                .catch { error ->
                    // Manejar error
                }
                .collect { sessions ->
                    _sessions.value = sessions
                }
        }
    }

    fun selectCategory(category: MeditationCategory?) {
        _selectedCategory.value = category
        if (category != null) {
            viewModelScope.launch {
                meditationRepository.getSessionsByCategory(category)
                    .collect { sessions ->
                        _sessions.value = sessions
                    }
            }
        } else {
            loadSessions()
        }
    }

    fun playSession(sessionId: String) {
        viewModelScope.launch {
            val session = sessions.value.find { it.id == sessionId }
            session?.let {
                _currentSession.value = it
                meditationRepository.startSession(sessionId)
                _isPlaying.value = true
                analyticsManager.logEvent(AnalyticsEvent.MeditationSessionStarted(sessionId))
            }
        }
    }

    fun pauseSession() {
        viewModelScope.launch {
            meditationRepository.pauseSession()
            _isPlaying.value = false
        }
    }

    fun resumeSession() {
        viewModelScope.launch {
            meditationRepository.resumeSession()
            _isPlaying.value = true
        }
    }

    fun stopSession() {
        viewModelScope.launch {
            currentSession.value?.let { session ->
                meditationRepository.stopSession(session.id)
                analyticsManager.logEvent(AnalyticsEvent.MeditationSessionCompleted(session.id))
            }
            _currentSession.value = null
            _isPlaying.value = false
        }
    }

    private fun observeAudioProgress() {
        viewModelScope.launch {
            meditationRepository.currentAudioProgress
                .collect { progress ->
                    _currentProgress.value = progress
                    if (progress >= 0.99f) {
                        stopSession()
                    }
                }
        }
    }

    override fun onCleared() {
        super.onCleared()
        viewModelScope.launch {
            meditationRepository.pauseSession()
        }
    }
} 